# auth.py
from datetime import datetime, timedelta
from typing import Optional, List
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from functools import wraps
import os
import uuid

from database import get_db
from models import User, UserSession
import hashlib

# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-this-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    
    return encoded_jwt

def verify_token(token: str):
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return uuid.UUID(user_id)
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Get current authenticated user"""
    token = credentials.credentials
    user_id = verify_token(token)
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account disabled",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user

def require_roles(allowed_roles: List[str]):
    """Decorator factory for role-based access control"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Get current user from dependencies
            current_user = None
            db = None
            
            for key, value in kwargs.items():
                if isinstance(value, User):
                    current_user = value
                elif hasattr(value, 'query'):  # Check if it's a database session
                    db = value
            
            if not current_user or not db:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Authentication setup error"
                )
            
            # Check user roles
            user_roles = [role.name for role in current_user.roles]
            
            if not any(role in user_roles for role in allowed_roles):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Access denied. Required roles: {', '.join(allowed_roles)}"
                )
            
            return await func(*args, **kwargs)
        return wrapper
    return decorator

def require_roles(allowed_roles: List[str]):
    """Role-based access control dependency"""
    async def role_checker(current_user: User = Depends(get_current_user)):
        user_roles = [role.name for role in current_user.roles]
        
        if not any(role in user_roles for role in allowed_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required roles: {', '.join(allowed_roles)}"
            )
        return current_user
    
    return role_checker

def hash_token(token: str) -> str:
    """Hash token for storage"""
    return hashlib.sha256(token.encode()).hexdigest()

async def create_user_session(user_id: uuid.UUID, token: str, db: Session):
    """Create user session record"""
    token_hash = hash_token(token)
    expires_at = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    session = UserSession(
        user_id=user_id,
        token_hash=token_hash,
        expires_at=expires_at
    )
    db.add(session)
    db.commit()
    
    return session

async def invalidate_user_session(token: str, db: Session):
    """Invalidate user session"""
    token_hash = hash_token(token)
    session = db.query(UserSession).filter(
        UserSession.token_hash == token_hash,
        UserSession.is_active == True
    ).first()
    
    if session:
        session.is_active = False
        db.commit()
    
    return session

def check_permission(user: User, resource: str, action: str) -> bool:
    """Check if user has specific permission"""
    # This would be extended with the Permission model
    # For now, basic role-based check
    user_roles = [role.name for role in user.roles]
    
    if "admin" in user_roles:
        return True
    
    permission_map = {
        "manager": ["users:read", "dashboard:read", "reports:read"],
        "user": ["profile:read", "profile:write"]
    }
    
    required_permission = f"{resource}:{action}"
    
    for role in user_roles:
        if role in permission_map and required_permission in permission_map[role]:
            return True
    
    return False