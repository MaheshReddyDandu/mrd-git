# schemas.py
from pydantic import BaseModel, EmailStr, validator
from typing import List, Optional
from datetime import datetime
import uuid

class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str
    tenant_id: uuid.UUID
    
    @validator('username')
    def username_alphanumeric(cls, v):
        if not v.replace('_', '').replace('-', '').isalnum():
            raise ValueError('Username must be alphanumeric with optional underscores or hyphens')
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters long')
        return v
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    username: str
    is_active: bool
    created_at: datetime
    roles: List['RoleResponse'] = []
    
    class Config:
        from_attributes = True

class RoleResponse(BaseModel):
    id: uuid.UUID
    name: str
    description: Optional[str] = None
    
    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    is_active: Optional[bool] = None

class RoleCreate(BaseModel):
    name: str
    description: Optional[str] = None

class PermissionResponse(BaseModel):
    id: uuid.UUID
    name: str
    description: Optional[str] = None
    resource: Optional[str] = None
    action: Optional[str] = None
    
    class Config:
        from_attributes = True

class UserRoleAssignment(BaseModel):
    user_id: uuid.UUID
    role_name: str

# Forward reference resolution
UserResponse.model_rebuild()

class TenantBase(BaseModel):
    name: str
    contact_email: str
    plan: Optional[str] = "basic"

class TenantCreate(TenantBase):
    pass

class TenantResponse(TenantBase):
    id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class BranchBase(BaseModel):
    name: str
    address: Optional[str] = None
    geo_fence: Optional[str] = None

class BranchCreate(BranchBase):
    pass

class BranchUpdate(BranchBase):
    name: Optional[str] = None
    address: Optional[str] = None
    geo_fence: Optional[str] = None

class BranchResponse(BranchBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    class Config:
        from_attributes = True

class DepartmentBase(BaseModel):
    name: str
    branch_id: Optional[uuid.UUID] = None

class DepartmentCreate(DepartmentBase):
    pass

class DepartmentUpdate(DepartmentBase):
    name: Optional[str] = None
    branch_id: Optional[uuid.UUID] = None

class DepartmentResponse(DepartmentBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    class Config:
        from_attributes = True

class EmployeeBase(BaseModel):
    name: str
    email: str
    department_id: Optional[uuid.UUID] = None
    role_id: Optional[uuid.UUID] = None
    phone: Optional[str] = None
    status: Optional[str] = "active"

class EmployeeCreate(EmployeeBase):
    tenant_id: uuid.UUID

class EmployeeResponse(EmployeeBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    class Config:
        from_attributes = True

class AttendanceBase(BaseModel):
    employee_id: uuid.UUID
    date: datetime
    clock_in: Optional[datetime] = None
    clock_out: Optional[datetime] = None
    location: Optional[str] = None
    status: Optional[str] = None

class AttendanceCreate(AttendanceBase):
    tenant_id: uuid.UUID

class AttendanceResponse(AttendanceBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    class Config:
        from_attributes = True

class PolicyBase(BaseModel):
    name: str
    type: str
    level: str
    rules: str

class PolicyCreate(PolicyBase):
    tenant_id: uuid.UUID

class PolicyResponse(PolicyBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class PolicyAssignmentBase(BaseModel):
    policy_id: uuid.UUID
    branch_id: Optional[uuid.UUID] = None
    department_id: Optional[uuid.UUID] = None
    employee_id: Optional[uuid.UUID] = None

class PolicyAssignmentCreate(PolicyAssignmentBase):
    tenant_id: uuid.UUID

class PolicyAssignmentResponse(PolicyAssignmentBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    assigned_at: datetime
    class Config:
        from_attributes = True

class RegularizationRequestBase(BaseModel):
    employee_id: uuid.UUID
    date: datetime
    reason: str
    requested_in: Optional[datetime] = None
    requested_out: Optional[datetime] = None

class RegularizationRequestCreate(RegularizationRequestBase):
    tenant_id: uuid.UUID

class RegularizationRequestApprove(BaseModel):
    approver_id: uuid.UUID
    status: str

class RegularizationRequestResponse(RegularizationRequestBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    status: str
    approver_id: Optional[uuid.UUID] = None
    approved_at: Optional[datetime] = None

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class UserSignupClient(BaseModel):
    tenant_name: str
    tenant_contact_email: str
    owner_email: EmailStr
    owner_username: str
    owner_password: str

class UserAddByAdmin(BaseModel):
    email: EmailStr
    username: str
    role_id: str  # Accept role_id instead of role_name

class AuditLogResponse(BaseModel):
    id: uuid.UUID
    tenant_id: Optional[uuid.UUID] = None
    user_id: Optional[uuid.UUID] = None
    action: str
    target_resource: Optional[str] = None
    target_id: Optional[str] = None
    details: Optional[dict] = None
    timestamp: datetime
    user: Optional[UserResponse] = None

    class Config:
        from_attributes = True

class NotificationBase(BaseModel):
    type: str
    message: str
    user_id: Optional[uuid.UUID] = None

class NotificationCreate(NotificationBase):
    tenant_id: uuid.UUID

class NotificationResponse(NotificationBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    is_read: bool
    created_at: datetime
    user: Optional[UserResponse] = None
    class Config:
        from_attributes = True