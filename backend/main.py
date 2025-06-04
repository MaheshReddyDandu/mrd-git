# main.py
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import jwt
import bcrypt
from typing import Optional, List
import uvicorn

from database import get_db, engine, Base
from models import User, Role, UserRole
from schemas import UserCreate, UserResponse, UserLogin, TokenResponse, RoleResponse
from auth import create_access_token, verify_token, get_current_user, require_roles

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Role-Based Auth API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:4200"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

@app.on_event("startup")
async def startup_event():
    """Create default roles and admin user"""
    db = next(get_db())
    
    # Create default roles
    admin_role = db.query(Role).filter(Role.name == "admin").first()
    if not admin_role:
        admin_role = Role(name="admin", description="Administrator role")
        db.add(admin_role)
    
    user_role = db.query(Role).filter(Role.name == "user").first()
    if not user_role:
        user_role = Role(name="user", description="Regular user role")
        db.add(user_role)
    
    manager_role = db.query(Role).filter(Role.name == "manager").first()
    if not manager_role:
        manager_role = Role(name="manager", description="Manager role")
        db.add(manager_role)
    
    db.commit()
    
    # Create admin user
    admin_user = db.query(User).filter(User.email == "admin@example.com").first()
    if not admin_user:
        hashed_password = bcrypt.hashpw("admin123".encode('utf-8'), bcrypt.gensalt())
        admin_user = User(
            email="admin@example.com",
            username="admin",
            hashed_password=hashed_password.decode('utf-8'),
            is_active=True
        )
        db.add(admin_user)
        db.commit()
        
        # Assign admin role
        user_role_assignment = UserRole(user_id=admin_user.id, role_id=admin_role.id)
        db.add(user_role_assignment)
        db.commit()

# Authentication endpoints
@app.post("/auth/register", response_model=UserResponse)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    existing_user = db.query(User).filter(
        (User.email == user.email) | (User.username == user.username)
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already exists"
        )
    
    # Hash password
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    
    # Create user
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password.decode('utf-8'),
        is_active=True
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Assign default user role
    user_role = db.query(Role).filter(Role.name == "user").first()
    if user_role:
        user_role_assignment = UserRole(user_id=db_user.id, role_id=user_role.id)
        db.add(user_role_assignment)
        db.commit()
    
    return db_user

@app.post("/auth/login", response_model=TokenResponse)
async def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_credentials.email).first()
    
    if not user or not bcrypt.checkpw(
        user_credentials.password.encode('utf-8'), 
        user.hashed_password.encode('utf-8')
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is disabled"
        )
    
    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/auth/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user

# Protected endpoints with role-based access
@app.get("/admin/users", response_model=List[UserResponse])
async def get_all_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles(["admin"]))
):
    users = db.query(User).all()
    return users

@app.get("/manager/dashboard")
async def manager_dashboard(
    current_user: User = Depends(require_roles(["admin", "manager"]))
):
    return {"message": "Manager dashboard access granted", "user": current_user.username}

@app.get("/user/profile")
async def user_profile(current_user: User = Depends(get_current_user)):
    return {"message": "User profile", "user": current_user.username}

@app.post("/admin/assign-role")
async def assign_role(
    user_id: int,
    role_name: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles(["admin"]))
):
    user = db.query(User).filter(User.id == user_id).first()
    role = db.query(Role).filter(Role.name == role_name).first()
    
    if not user or not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User or role not found"
        )
    
    # Check if assignment already exists
    existing = db.query(UserRole).filter(
        UserRole.user_id == user_id,
        UserRole.role_id == role.id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role already assigned"
        )
    
    user_role = UserRole(user_id=user_id, role_id=role.id)
    db.add(user_role)
    db.commit()
    
    return {"message": f"Role {role_name} assigned to user {user.username}"}

@app.get("/roles", response_model=List[RoleResponse])
async def get_roles(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles(["admin", "manager"]))
):
    roles = db.query(Role).all()
    return roles

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)