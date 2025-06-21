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
import uuid
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError

from database import get_db, engine, Base
from models import User, Role, UserRole, Tenant, Branch, Department, Attendance, Policy, PolicyAssignment, RegularizationRequest, Client, Project
from schemas import (
    UserCreate, UserResponse, UserLogin, TokenResponse, RoleResponse,
    TenantCreate, TenantResponse,
    BranchCreate, BranchResponse,
    DepartmentCreate, DepartmentResponse,
    AttendanceCreate, AttendanceResponse,
    PolicyCreate, PolicyResponse,
    PolicyAssignmentCreate, PolicyAssignmentResponse,
    RegularizationRequestCreate, RegularizationRequestApprove, RegularizationRequestResponse,
    ForgotPasswordRequest, ResetPasswordRequest, ChangePasswordRequest,
    UserSignupClient, UserAddByAdmin,
    ClientCreate, ClientUpdate, ClientResponse,
    ProjectCreate, ProjectUpdate, ProjectResponse,
    RoleCreate, RoleUpdate, DepartmentUpdate, BranchUpdate, UserUpdate
)
from auth import create_access_token, verify_token, get_current_user, require_roles

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Role-Based Auth API", version="1.0.0")

print("[SERVER] FastAPI app instance created.")

# CORS middleware with more permissive settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Only allow frontend origin
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
    expose_headers=["*"],  # Exposes all headers
    max_age=3600,  # Cache preflight requests for 1 hour
)

print("[SERVER] CORS middleware added.")

security = HTTPBearer()

# In-memory store for reset tokens (for demo)
reset_tokens = {}

@app.on_event("startup")
async def startup_event():
    print("[SERVER] Startup event triggered. Initializing roles and admin user...")
    db = next(get_db())
    print("[DEBUG] DB session acquired.")
    tenants = db.query(Tenant).all()
    for tenant in tenants:
        for role_name, desc in [("admin", "Administrator role"), ("user", "Regular user role"), ("manager", "Manager role")]:
            role = db.query(Role).filter(Role.name == role_name, Role.tenant_id == tenant.id).first()
            if not role:
                role = Role(name=role_name, description=desc, tenant_id=tenant.id)
                db.add(role)
                print(f"[DEBUG] Added {role_name} role for tenant {tenant.name}.")
    db.commit()
    print("[DEBUG] Committed roles.")
    # (Keep admin user creation logic as is)
    admin_user = db.query(User).filter(User.email == "admin@example.com").first()
    print("[DEBUG] Queried for admin user.")
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
        print("[DEBUG] Created and committed admin user.")
        # Assign admin role (global, not tenant-specific)
        admin_role = db.query(Role).filter(Role.name == "admin", Role.tenant_id == None).first()
        if admin_role:
            user_role_assignment = UserRole(user_id=admin_user.id, role_id=admin_role.id)
            db.add(user_role_assignment)
            db.commit()
            print("[DEBUG] Assigned admin role to admin user and committed.")
    print("[SERVER] Startup event complete.")

# Authentication endpoints
@app.post("/auth/register", response_model=UserResponse)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists for this tenant
    existing_user = db.query(User).filter(
        (User.email == user.email) | (User.username == user.username),
        User.tenant_id == user.tenant_id
    ).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already exists for this tenant"
        )
    # Hash password
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    # Create user
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password.decode('utf-8'),
        is_active=True,
        tenant_id=user.tenant_id
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    # Assign default user role for this tenant
    user_role = db.query(Role).filter(Role.name == "user", Role.tenant_id == user.tenant_id).first()
    if user_role:
        user_role_assignment = UserRole(user_id=db_user.id, role_id=user_role.id)
        db.add(user_role_assignment)
        db.commit()
    return db_user

@app.post("/auth/login", response_model=TokenResponse)
async def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    print(f"[LOGIN] Received credentials: email={user_credentials.email}")
    user = db.query(User).filter(
        User.email == user_credentials.email
    ).first()
    print(f"[LOGIN] User lookup result: {user}")
    if not user:
        print("[LOGIN] No user found with that email.")
    else:
        print(f"[LOGIN] Found user: {user.email}, is_active={user.is_active}")
        password_matches = bcrypt.checkpw(
            user_credentials.password.encode('utf-8'), 
            user.hashed_password.encode('utf-8')
        )
        print(f"[LOGIN] Password matches: {password_matches}")
    if not user or not bcrypt.checkpw(
        user_credentials.password.encode('utf-8'), 
        user.hashed_password.encode('utf-8')
    ):
        print("[LOGIN] Invalid credentials.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    if not user.is_active:
        print("[LOGIN] User account is disabled.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is disabled"
        )
    print(f"[LOGIN] Login successful for user: {user.email}, tenant_id={user.tenant_id}")
    access_token = create_access_token(data={"sub": str(user.id), "tenant_id": str(user.tenant_id)})
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
    user_id: uuid.UUID,
    role_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles(["admin"]))
):
    user = db.query(User).filter(User.id == user_id, User.tenant_id == current_user.tenant_id).first()
    role = db.query(Role).filter(Role.id == role_id, Role.tenant_id == current_user.tenant_id).first()
    if not user or not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User or role not found for this tenant"
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
    return {"message": f"Role {role.name} assigned to user {user.username}"}

@app.get("/roles", response_model=List[RoleResponse])
def list_roles(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(Role).filter(Role.tenant_id == current_user.tenant_id).all()

@app.post("/roles", response_model=RoleResponse)
def create_role(role: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_role = Role(**role.dict(), tenant_id=current_user.tenant_id)
    db.add(db_role)
    db.commit()
    db.refresh(db_role)
    return db_role

@app.put("/roles/{role_id}", response_model=RoleResponse)
def update_role(role_id: uuid.UUID, role: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_role = db.query(Role).filter(Role.id == role_id, Role.tenant_id == current_user.tenant_id).first()
    if not db_role:
        raise HTTPException(status_code=404, detail="Role not found")
    for key, value in role.dict(exclude_unset=True).items():
        setattr(db_role, key, value)
    db.commit()
    db.refresh(db_role)
    return db_role

@app.delete("/roles/{role_id}")
def delete_role(role_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_role = db.query(Role).filter(Role.id == role_id, Role.tenant_id == current_user.tenant_id).first()
    if not db_role:
        raise HTTPException(status_code=404, detail="Role not found")
    db.delete(db_role)
    db.commit()
    return {"detail": "Role deleted"}

@app.post("/tenants", response_model=TenantResponse)
def create_tenant(tenant: TenantCreate, db: Session = Depends(get_db)):
    db_tenant = Tenant(**tenant.dict())
    db.add(db_tenant)
    db.commit()
    db.refresh(db_tenant)
    # Create default roles for this tenant
    for role_name, desc in [("admin", "Administrator role"), ("user", "Regular user role"), ("manager", "Manager role")]:
        role = Role(name=role_name, description=desc, tenant_id=db_tenant.id)
        db.add(role)
    db.commit()
    return db_tenant

@app.post("/tenants/{tenant_id}/branches", response_model=BranchResponse)
def create_branch(tenant_id: uuid.UUID, branch: BranchCreate, db: Session = Depends(get_db)):
    if branch.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_branch = Branch(**branch.dict())
    db.add(db_branch)
    db.commit()
    db.refresh(db_branch)
    return db_branch

@app.post("/tenants/{tenant_id}/departments", response_model=DepartmentResponse)
def create_department(tenant_id: uuid.UUID, department: DepartmentCreate, db: Session = Depends(get_db)):
    if department.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_department = Department(**department.dict())
    db.add(db_department)
    db.commit()
    db.refresh(db_department)
    return db_department

@app.post("/tenants/{tenant_id}/attendance", response_model=AttendanceResponse)
def create_attendance(tenant_id: uuid.UUID, attendance: AttendanceCreate, db: Session = Depends(get_db)):
    if attendance.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_attendance = Attendance(**attendance.dict())
    db.add(db_attendance)
    db.commit()
    db.refresh(db_attendance)
    return db_attendance

@app.get("/tenants/{tenant_id}/users", response_model=list[UserResponse])
def list_users(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    users = db.query(User).filter(User.tenant_id == tenant_id).all()
    return users

@app.post("/tenants/{tenant_id}/policies", response_model=PolicyResponse)
def create_policy(tenant_id: uuid.UUID, policy: PolicyCreate, db: Session = Depends(get_db)):
    if policy.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_policy = Policy(**policy.dict())
    db.add(db_policy)
    db.commit()
    db.refresh(db_policy)
    return db_policy

@app.get("/tenants/{tenant_id}/policies", response_model=List[PolicyResponse])
def list_policies(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    policies = db.query(Policy).filter(Policy.tenant_id == tenant_id).all()
    return policies

@app.post("/tenants/{tenant_id}/policy-assignments", response_model=PolicyAssignmentResponse)
def assign_policy(tenant_id: uuid.UUID, assignment: PolicyAssignmentCreate, db: Session = Depends(get_db)):
    if assignment.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_assignment = PolicyAssignment(**assignment.dict())
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    return db_assignment

@app.get("/tenants/{tenant_id}/users/{user_id}/effective-policy", response_model=List[PolicyResponse])
def get_effective_policy(tenant_id: uuid.UUID, user_id: uuid.UUID, db: Session = Depends(get_db)):
    # Get all policies assigned to this user, department, branch, or org (tenant)
    assignments = db.query(PolicyAssignment).filter(
        PolicyAssignment.tenant_id == tenant_id,
        ((PolicyAssignment.user_id == user_id) |
         (PolicyAssignment.department_id == db.query(User.department_id).filter(User.id == user_id).scalar()) |
         (PolicyAssignment.branch_id == db.query(Department.branch_id).filter(Department.id == db.query(User.department_id).filter(User.id == user_id).scalar()).scalar()) |
         (PolicyAssignment.branch_id == None and PolicyAssignment.department_id == None and PolicyAssignment.user_id == None))
    ).all()
    policy_ids = [a.policy_id for a in assignments]
    policies = db.query(Policy).filter(Policy.id.in_(policy_ids)).all()
    return policies

@app.post("/tenants/{tenant_id}/regularization-requests", response_model=RegularizationRequestResponse)
def submit_regularization_request(tenant_id: uuid.UUID, req: RegularizationRequestCreate, db: Session = Depends(get_db)):
    if req.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_req = RegularizationRequest(**req.dict())
    db.add(db_req)
    db.commit()
    db.refresh(db_req)
    return db_req

@app.get("/tenants/{tenant_id}/regularization-requests", response_model=List[RegularizationRequestResponse])
def list_regularization_requests(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    requests = db.query(RegularizationRequest).filter(RegularizationRequest.tenant_id == tenant_id).all()
    return requests

@app.post("/tenants/{tenant_id}/regularization-requests/{request_id}/approve", response_model=RegularizationRequestResponse)
def approve_regularization_request(tenant_id: uuid.UUID, request_id: uuid.UUID, approval: RegularizationRequestApprove, db: Session = Depends(get_db)):
    db_req = db.query(RegularizationRequest).filter(RegularizationRequest.id == request_id, RegularizationRequest.tenant_id == tenant_id).first()
    if not db_req:
        raise HTTPException(status_code=404, detail="Request not found")
    db_req.status = approval.status
    db_req.approver_id = approval.approver_id
    db_req.approved_at = datetime.utcnow()
    db.commit()
    db.refresh(db_req)
    return db_req

# --- Reporting/Analytics Endpoints ---
@app.get("/tenants/{tenant_id}/attendance-summary")
def attendance_summary(tenant_id: uuid.UUID, period: str = "daily", db: Session = Depends(get_db)):
    # period: daily, weekly, monthly
    query = db.query(
        Attendance.date,
        func.count(Attendance.id).label("total_records"),
        func.count(func.nullif(Attendance.status != "Present", True)).label("present"),
        func.count(func.nullif(Attendance.status == "Late", False)).label("late"),
        func.count(func.nullif(Attendance.status == "Absent", False)).label("absent")
    ).filter(Attendance.tenant_id == tenant_id)
    if period == "daily":
        query = query.group_by(Attendance.date)
    elif period == "monthly":
        query = query.group_by(func.date_trunc('month', Attendance.date))
    elif period == "weekly":
        query = query.group_by(func.date_trunc('week', Attendance.date))
    return [dict(row) for row in query.all()]

@app.get("/tenants/{tenant_id}/departments/{department_id}/attendance-summary")
def department_attendance_summary(tenant_id: uuid.UUID, department_id: uuid.UUID, db: Session = Depends(get_db)):
    query = db.query(
        Attendance.date,
        func.count(Attendance.id).label("total_records"),
        func.count(func.nullif(Attendance.status != "Present", True)).label("present"),
        func.count(func.nullif(Attendance.status == "Late", False)).label("late"),
        func.count(func.nullif(Attendance.status == "Absent", False)).label("absent")
    ).join(User, Attendance.user_id == User.id)
    query = query.filter(Attendance.tenant_id == tenant_id, User.department_id == department_id)
    query = query.group_by(Attendance.date)
    return [dict(row) for row in query.all()]

@app.get("/tenants/{tenant_id}/dashboard-stats")
def dashboard_stats(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    total_users = db.query(User).filter(User.tenant_id == tenant_id).count()
    total_departments = db.query(Department).filter(Department.tenant_id == tenant_id).count()
    total_branches = db.query(Branch).filter(Branch.tenant_id == tenant_id).count()
    total_attendance = db.query(Attendance).filter(Attendance.tenant_id == tenant_id).count()
    return {
        "total_users": total_users,
        "total_departments": total_departments,
        "total_branches": total_branches,
        "total_attendance_records": total_attendance
    }

# --- SaaS Admin Endpoints ---
@app.get("/admin/tenants", response_model=List[TenantResponse])
def admin_list_tenants(db: Session = Depends(get_db)):
    return db.query(Tenant).all()

@app.get("/admin/tenants/{tenant_id}", response_model=TenantResponse)
def admin_get_tenant(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant

@app.put("/admin/tenants/{tenant_id}", response_model=TenantResponse)
def admin_update_tenant(tenant_id: uuid.UUID, tenant: TenantCreate, db: Session = Depends(get_db)):
    db_tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not db_tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    for key, value in tenant.dict().items():
        setattr(db_tenant, key, value)
    db.commit()
    db.refresh(db_tenant)
    return db_tenant

@app.delete("/admin/tenants/{tenant_id}")
def admin_delete_tenant(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    db_tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not db_tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    db.delete(db_tenant)
    db.commit()
    return {"detail": "Tenant deleted"}

@app.post("/admin/tenants/{tenant_id}/assign-plan")
def admin_assign_plan(tenant_id: uuid.UUID, plan: str, db: Session = Depends(get_db)):
    db_tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not db_tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    db_tenant.plan = plan
    db.commit()
    return {"detail": f"Plan '{plan}' assigned to tenant."}

@app.get("/admin/tenants/{tenant_id}/usage")
def admin_tenant_usage(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    total_users = db.query(User).filter(User.tenant_id == tenant_id).count()
    total_attendance = db.query(Attendance).filter(Attendance.tenant_id == tenant_id).count()
    return {
        "total_users": total_users,
        "total_attendance_records": total_attendance
    }

@app.post("/auth/forgot-password")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    # Generate a simple token (uuid4 for demo)
    token = str(uuid.uuid4())
    reset_tokens[token] = str(user.id)
    # In production, send this token via email
    return {"reset_token": token, "message": "Use this token to reset your password."}

@app.post("/auth/signup-client", response_model=TokenResponse)
def signup_client(payload: UserSignupClient, db: Session = Depends(get_db)):
    # Check if tenant exists
    from models import Role, UserRole
    from sqlalchemy.exc import IntegrityError
    import bcrypt
    import uuid as uuidlib
    existing_tenant = db.query(Tenant).filter(Tenant.name == payload.tenant_name).first()
    if existing_tenant:
        raise HTTPException(status_code=400, detail="Tenant already exists")
    # Create tenant
    tenant = Tenant(name=payload.tenant_name, contact_email=payload.tenant_contact_email)
    db.add(tenant)
    db.commit()
    db.refresh(tenant)
    # Create owner user
    hashed_password = bcrypt.hashpw(payload.owner_password.encode('utf-8'), bcrypt.gensalt())
    owner_user = User(
        email=payload.owner_email,
        username=payload.owner_username,
        hashed_password=hashed_password.decode('utf-8'),
        is_active=True,
        needs_password=False,
        tenant_id=tenant.id
    )
    db.add(owner_user)
    db.commit()
    db.refresh(owner_user)
    # Create all roles if not exist
    role_names = ["owner", "admin", "manager", "user"]
    role_objs = []
    for role_name in role_names:
        role = db.query(Role).filter(Role.name == role_name, Role.tenant_id == tenant.id).first()
        if not role:
            role = Role(name=role_name, description=f"{role_name.capitalize()} role", tenant_id=tenant.id)
            db.add(role)
            db.commit()
            db.refresh(role)
        role_objs.append(role)
    # Assign all roles to owner user
    for role in role_objs:
        user_role = UserRole(user_id=owner_user.id, role_id=role.id)
        db.add(user_role)
    db.commit()
    # Return JWT
    access_token = create_access_token(data={"sub": str(owner_user.id), "tenant_id": str(tenant.id)})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/admin/add-user")
def admin_add_user(payload: UserAddByAdmin, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["owner", "admin"]))):
    tenant_id = current_user.tenant_id
    try:
        existing_user = db.query(User).filter(User.email == payload.email, User.tenant_id == tenant_id).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="User with this email already exists")
        user = User(
            email=payload.email,
            username=payload.username,
            hashed_password="",
            is_active=False,
            needs_password=True,
            tenant_id=tenant_id
        )
        db.add(user)
        db.commit()
        db.refresh(user)  # Ensure user.id is available
        # Use the provided role_id directly
        role = db.query(Role).filter(Role.id == payload.role_id, Role.tenant_id == tenant_id).first()
        if not role:
            raise HTTPException(status_code=400, detail="Role not found for this tenant")
        user_role = UserRole(user_id=user.id, role_id=role.id)
        db.add(user_role)
        db.commit()
        import uuid as uuidlib
        token = str(uuidlib.uuid4())
        reset_tokens[token] = str(user.id)
        return {"user_id": str(user.id), "reset_token": token, "message": "User created. Provide reset token to user for first login."}
    except IntegrityError as e:
        db.rollback()
        error_str = str(e.orig)
        if 'ix_users_username' in error_str:
            raise HTTPException(status_code=400, detail="Username already exists")
        if 'ix_users_email' in error_str:
            raise HTTPException(status_code=400, detail="Email already exists")
        if 'ix_roles_name' in error_str:
            raise HTTPException(status_code=400, detail="Role already exists for this tenant")
        raise HTTPException(status_code=400, detail="Integrity error: " + error_str)

@app.post("/auth/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    user_id = reset_tokens.get(req.token)
    if not user_id:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    hashed_password = bcrypt.hashpw(req.new_password.encode('utf-8'), bcrypt.gensalt())
    user.hashed_password = hashed_password.decode('utf-8')
    user.is_active = True
    user.needs_password = False
    db.commit()
    # Remove token after use
    del reset_tokens[req.token]
    return {"message": "Password reset successful"}

@app.post("/auth/change-password")
def change_password(req: ChangePasswordRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not bcrypt.checkpw(req.old_password.encode('utf-8'), current_user.hashed_password.encode('utf-8')):
        raise HTTPException(status_code=400, detail="Old password is incorrect")
    hashed_password = bcrypt.hashpw(req.new_password.encode('utf-8'), bcrypt.gensalt())
    current_user.hashed_password = hashed_password.decode('utf-8')
    db.commit()
    return {"message": "Password changed successfully"}

# --- Client CRUD Endpoints ---
@app.get("/clients", response_model=List[ClientResponse])
def list_clients(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(Client).filter(Client.tenant_id == current_user.tenant_id).all()

@app.post("/clients", response_model=ClientResponse)
def create_client(client: ClientCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_client = Client(**client.dict(), tenant_id=current_user.tenant_id)
    db.add(db_client)
    db.commit()
    db.refresh(db_client)
    return db_client

@app.put("/clients/{client_id}", response_model=ClientResponse)
def update_client(client_id: uuid.UUID, client: ClientUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_client = db.query(Client).filter(Client.id == client_id, Client.tenant_id == current_user.tenant_id).first()
    if not db_client:
        raise HTTPException(status_code=404, detail="Client not found")
    for key, value in client.dict(exclude_unset=True).items():
        setattr(db_client, key, value)
    db.commit()
    db.refresh(db_client)
    return db_client

@app.delete("/clients/{client_id}")
def delete_client(client_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_client = db.query(Client).filter(Client.id == client_id, Client.tenant_id == current_user.tenant_id).first()
    if not db_client:
        raise HTTPException(status_code=404, detail="Client not found")
    db.delete(db_client)
    db.commit()
    return {"detail": "Client deleted"}

# --- Project CRUD Endpoints ---
@app.get("/projects", response_model=List[ProjectResponse])
def list_projects(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(Project).filter(Project.tenant_id == current_user.tenant_id).all()

@app.post("/projects", response_model=ProjectResponse)
def create_project(project: ProjectCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_project = Project(**project.dict(), tenant_id=current_user.tenant_id)
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

@app.put("/projects/{project_id}", response_model=ProjectResponse)
def update_project(project_id: uuid.UUID, project: ProjectUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_project = db.query(Project).filter(Project.id == project_id, Project.tenant_id == current_user.tenant_id).first()
    if not db_project:
        raise HTTPException(status_code=404, detail="Project not found")
    for key, value in project.dict(exclude_unset=True).items():
        setattr(db_project, key, value)
    db.commit()
    db.refresh(db_project)
    return db_project

@app.delete("/projects/{project_id}")
def delete_project(project_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_project = db.query(Project).filter(Project.id == project_id, Project.tenant_id == current_user.tenant_id).first()
    if not db_project:
        raise HTTPException(status_code=404, detail="Project not found")
    db.delete(db_project)
    db.commit()
    return {"detail": "Project deleted"}

# --- Department CRUD Endpoints ---
@app.get("/departments", response_model=List[DepartmentResponse])
def list_departments(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(Department).filter(Department.tenant_id == current_user.tenant_id).all()

@app.post("/departments", response_model=DepartmentResponse)
def create_department(department: DepartmentCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_department = Department(**department.dict(), tenant_id=current_user.tenant_id)
    db.add(db_department)
    db.commit()
    db.refresh(db_department)
    return db_department

@app.put("/departments/{department_id}", response_model=DepartmentResponse)
def update_department(department_id: uuid.UUID, department: DepartmentUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_department = db.query(Department).filter(Department.id == department_id, Department.tenant_id == current_user.tenant_id).first()
    if not db_department:
        raise HTTPException(status_code=404, detail="Department not found")
    for key, value in department.dict(exclude_unset=True).items():
        setattr(db_department, key, value)
    db.commit()
    db.refresh(db_department)
    return db_department

@app.delete("/departments/{department_id}")
def delete_department(department_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_department = db.query(Department).filter(Department.id == department_id, Department.tenant_id == current_user.tenant_id).first()
    if not db_department:
        raise HTTPException(status_code=404, detail="Department not found")
    db.delete(db_department)
    db.commit()
    return {"detail": "Department deleted"}

# --- Branch CRUD Endpoints ---
@app.get("/branches", response_model=List[BranchResponse])
def list_branches(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(Branch).filter(Branch.tenant_id == current_user.tenant_id).all()

@app.post("/branches", response_model=BranchResponse)
def create_branch(branch: BranchCreate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_branch = Branch(**branch.dict(), tenant_id=current_user.tenant_id)
    db.add(db_branch)
    db.commit()
    db.refresh(db_branch)
    return db_branch

@app.put("/branches/{branch_id}", response_model=BranchResponse)
def update_branch(branch_id: uuid.UUID, branch: BranchUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_branch = db.query(Branch).filter(Branch.id == branch_id, Branch.tenant_id == current_user.tenant_id).first()
    if not db_branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    for key, value in branch.dict(exclude_unset=True).items():
        setattr(db_branch, key, value)
    db.commit()
    db.refresh(db_branch)
    return db_branch

@app.delete("/branches/{branch_id}")
def delete_branch(branch_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_branch = db.query(Branch).filter(Branch.id == branch_id, Branch.tenant_id == current_user.tenant_id).first()
    if not db_branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    db.delete(db_branch)
    db.commit()
    return {"detail": "Branch deleted"}

# --- User CRUD Endpoints ---
@app.get("/users", response_model=List[UserResponse])
def list_users(db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    return db.query(User).filter(User.tenant_id == current_user.tenant_id).all()

@app.post("/tenants/{tenant_id}/users", response_model=UserResponse)
def create_user(tenant_id: uuid.UUID, user: UserCreate, db: Session = Depends(get_db)):
    if user.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    # Hash password
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    # Create user with user profile fields
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password.decode('utf-8'),
        is_active=True,
        tenant_id=user.tenant_id,
        name=user.name,
        phone=user.phone,
        client_id=user.client_id,
        project_id=user.project_id,
        department_id=user.department_id,
        role_id=user.role_id
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    # Assign default user role for this tenant
    user_role = db.query(Role).filter(Role.name == "user", Role.tenant_id == user.tenant_id).first()
    if user_role:
        user_role_assignment = UserRole(user_id=db_user.id, role_id=user_role.id)
        db.add(user_role_assignment)
        db.commit()
    return db_user

@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: uuid.UUID, user: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_user = db.query(User).filter(User.id == user_id, User.tenant_id == current_user.tenant_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    for key, value in user.dict(exclude_unset=True).items():
        setattr(db_user, key, value)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.delete("/users/{user_id}")
def delete_user(user_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["admin", "owner"]))):
    db_user = db.query(User).filter(User.id == user_id, User.tenant_id == current_user.tenant_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(db_user)
    db.commit()
    return {"detail": "User deleted"}

if __name__ == "__main__":
    print("[SERVER] Starting FastAPI server on http://0.0.0.0:8000 ...")
    uvicorn.run(app, host="0.0.0.0", port=8000)