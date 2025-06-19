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

from database import get_db, engine, Base
from models import User, Role, UserRole, Tenant, Branch, Department, Employee, Attendance, Policy, PolicyAssignment, RegularizationRequest
from schemas import (
    UserCreate, UserResponse, UserLogin, TokenResponse, RoleResponse,
    TenantCreate, TenantResponse,
    BranchCreate, BranchResponse,
    DepartmentCreate, DepartmentResponse,
    EmployeeCreate, EmployeeResponse,
    AttendanceCreate, AttendanceResponse,
    PolicyCreate, PolicyResponse,
    PolicyAssignmentCreate, PolicyAssignmentResponse,
    RegularizationRequestCreate, RegularizationRequestApprove, RegularizationRequestResponse,
    ForgotPasswordRequest, ResetPasswordRequest, ChangePasswordRequest,
    UserSignupClient, UserAddByAdmin
)
from auth import create_access_token, verify_token, get_current_user, require_roles

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Role-Based Auth API", version="1.0.0")

print("[SERVER] FastAPI app instance created.")

# CORS middleware with more permissive settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8001"],  # Only allow frontend origin
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
    
    # Create default roles
    admin_role = db.query(Role).filter(Role.name == "admin").first()
    print("[DEBUG] Queried for admin role.")
    if not admin_role:
        admin_role = Role(name="admin", description="Administrator role")
        db.add(admin_role)
        print("[DEBUG] Added admin role.")
    
    user_role = db.query(Role).filter(Role.name == "user").first()
    print("[DEBUG] Queried for user role.")
    if not user_role:
        user_role = Role(name="user", description="Regular user role")
        db.add(user_role)
        print("[DEBUG] Added user role.")
    
    manager_role = db.query(Role).filter(Role.name == "manager").first()
    print("[DEBUG] Queried for manager role.")
    if not manager_role:
        manager_role = Role(name="manager", description="Manager role")
        db.add(manager_role)
        print("[DEBUG] Added manager role.")
    
    db.commit()
    print("[DEBUG] Committed roles.")
    
    # Create admin user
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
        
        # Assign admin role
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

@app.post("/tenants", response_model=TenantResponse)
def create_tenant(tenant: TenantCreate, db: Session = Depends(get_db)):
    db_tenant = Tenant(**tenant.dict())
    db.add(db_tenant)
    db.commit()
    db.refresh(db_tenant)
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

@app.post("/tenants/{tenant_id}/employees", response_model=EmployeeResponse)
def create_employee(tenant_id: uuid.UUID, employee: EmployeeCreate, db: Session = Depends(get_db)):
    if employee.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_employee = Employee(**employee.dict())
    db.add(db_employee)
    db.commit()
    db.refresh(db_employee)
    return db_employee

@app.post("/tenants/{tenant_id}/attendance", response_model=AttendanceResponse)
def create_attendance(tenant_id: uuid.UUID, attendance: AttendanceCreate, db: Session = Depends(get_db)):
    if attendance.tenant_id != tenant_id:
        raise HTTPException(status_code=400, detail="Tenant ID mismatch")
    db_attendance = Attendance(**attendance.dict())
    db.add(db_attendance)
    db.commit()
    db.refresh(db_attendance)
    return db_attendance

@app.get("/tenants/{tenant_id}/employees", response_model=list[EmployeeResponse])
def list_employees(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    employees = db.query(Employee).filter(Employee.tenant_id == tenant_id).all()
    return employees

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

@app.get("/tenants/{tenant_id}/employees/{employee_id}/effective-policy", response_model=List[PolicyResponse])
def get_effective_policy(tenant_id: uuid.UUID, employee_id: uuid.UUID, db: Session = Depends(get_db)):
    # Get all policies assigned to this employee, department, branch, or org (tenant)
    assignments = db.query(PolicyAssignment).filter(
        PolicyAssignment.tenant_id == tenant_id,
        ((PolicyAssignment.employee_id == employee_id) |
         (PolicyAssignment.department_id == db.query(Employee.department_id).filter(Employee.id == employee_id).scalar()) |
         (PolicyAssignment.branch_id == db.query(Department.branch_id).filter(Department.id == db.query(Employee.department_id).filter(Employee.id == employee_id).scalar()).scalar()) |
         (PolicyAssignment.branch_id == None and PolicyAssignment.department_id == None and PolicyAssignment.employee_id == None))
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
    ).join(Employee, Attendance.employee_id == Employee.id)
    query = query.filter(Attendance.tenant_id == tenant_id, Employee.department_id == department_id)
    query = query.group_by(Attendance.date)
    return [dict(row) for row in query.all()]

@app.get("/tenants/{tenant_id}/dashboard-stats")
def dashboard_stats(tenant_id: uuid.UUID, db: Session = Depends(get_db)):
    total_employees = db.query(Employee).filter(Employee.tenant_id == tenant_id).count()
    total_departments = db.query(Department).filter(Department.tenant_id == tenant_id).count()
    total_branches = db.query(Branch).filter(Branch.tenant_id == tenant_id).count()
    total_attendance = db.query(Attendance).filter(Attendance.tenant_id == tenant_id).count()
    return {
        "total_employees": total_employees,
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
    total_employees = db.query(Employee).filter(Employee.tenant_id == tenant_id).count()
    total_attendance = db.query(Attendance).filter(Attendance.tenant_id == tenant_id).count()
    return {
        "total_employees": total_employees,
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
    # Create owner role if not exists
    owner_role = db.query(Role).filter(Role.name == "owner", Role.tenant_id == tenant.id).first()
    if not owner_role:
        owner_role = Role(name="owner", description="Tenant Owner", tenant_id=tenant.id)
        db.add(owner_role)
        db.commit()
        db.refresh(owner_role)
    # Assign owner role
    user_role = UserRole(user_id=owner_user.id, role_id=owner_role.id)
    db.add(user_role)
    db.commit()
    # Return JWT
    access_token = create_access_token(data={"sub": str(owner_user.id), "tenant_id": str(tenant.id)})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/admin/add-user")
def admin_add_user(payload: UserAddByAdmin, db: Session = Depends(get_db), current_user: User = Depends(require_roles(["owner", "admin"]))):
    from models import Role, UserRole
    # Check if user exists
    existing_user = db.query(User).filter(User.email == payload.email, User.tenant_id == payload.tenant_id).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")
    # Create user with no password, inactive, needs_password=True
    user = User(
        email=payload.email,
        username=payload.username,
        hashed_password="",
        is_active=False,
        needs_password=True,
        tenant_id=payload.tenant_id
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    # Assign role
    role = db.query(Role).filter(Role.name == payload.role_name, Role.tenant_id == payload.tenant_id).first()
    if not role:
        role = Role(name=payload.role_name, tenant_id=payload.tenant_id)
        db.add(role)
        db.commit()
        db.refresh(role)
    user_role = UserRole(user_id=user.id, role_id=role.id)
    db.add(user_role)
    db.commit()
    # Generate reset token (for demo)
    import uuid as uuidlib
    token = str(uuidlib.uuid4())
    reset_tokens[token] = str(user.id)
    return {"user_id": str(user.id), "reset_token": token, "message": "User created. Provide reset token to user for first login."}

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

if __name__ == "__main__":
    print("[SERVER] Starting FastAPI server on http://0.0.0.0:8000 ...")
    uvicorn.run(app, host="0.0.0.0", port=8000)