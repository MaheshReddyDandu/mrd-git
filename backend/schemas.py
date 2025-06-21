# schemas.py
from pydantic import BaseModel, EmailStr, validator
from typing import List, Optional, Dict, Any
from datetime import datetime, date, time
import uuid

class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str
    tenant_id: uuid.UUID
    
    # User profile fields (optional for registration)
    name: Optional[str] = None
    phone: Optional[str] = None
    client_id: Optional[uuid.UUID] = None
    project_id: Optional[uuid.UUID] = None
    department_id: Optional[uuid.UUID] = None
    role_id: Optional[uuid.UUID] = None
    
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
    
    # User profile fields
    name: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None
    client_id: Optional[uuid.UUID] = None
    project_id: Optional[uuid.UUID] = None
    department_id: Optional[uuid.UUID] = None
    role_id: Optional[uuid.UUID] = None
    
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
    
    # User profile fields
    name: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None
    client_id: Optional[uuid.UUID] = None
    project_id: Optional[uuid.UUID] = None
    department_id: Optional[uuid.UUID] = None
    role_id: Optional[uuid.UUID] = None

class RoleCreate(BaseModel):
    name: str
    description: Optional[str] = None

class RoleUpdate(BaseModel):
    name: Optional[str] = None
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

class TenantUpdate(BaseModel):
    name: Optional[str] = None
    contact_email: Optional[str] = None
    plan: Optional[str] = None

class TenantResponse(TenantBase):
    id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class ClientBase(BaseModel):
    name: str
    contact_email: str
    contact_phone: Optional[str] = None
    address: Optional[str] = None
    industry: Optional[str] = None
    status: Optional[str] = "active"

class ClientCreate(ClientBase):
    pass

class ClientUpdate(BaseModel):
    name: Optional[str] = None
    contact_email: Optional[str] = None
    contact_phone: Optional[str] = None
    address: Optional[str] = None
    industry: Optional[str] = None
    status: Optional[str] = None

class ClientResponse(ClientBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = "active"
    budget: Optional[str] = None

class ProjectCreate(ProjectBase):
    client_id: uuid.UUID

class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = None
    budget: Optional[str] = None
    client_id: Optional[uuid.UUID] = None

class ProjectResponse(ProjectBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    client_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class BranchBase(BaseModel):
    name: str
    address: Optional[str] = None
    geo_fence: Optional[str] = None

class BranchCreate(BranchBase):
    pass

class BranchUpdate(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    geo_fence: Optional[str] = None

class BranchResponse(BranchBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None
    branch_id: Optional[uuid.UUID] = None

class DepartmentCreate(DepartmentBase):
    pass

class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    branch_id: Optional[uuid.UUID] = None

class DepartmentResponse(DepartmentBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

# Enhanced Attendance Schemas
class AttendanceBase(BaseModel):
    user_id: uuid.UUID
    date: date
    total_work_hours: Optional[float] = 0.0
    total_sessions: Optional[int] = 0
    status: Optional[str] = "Present"
    shift_type: Optional[str] = None
    work_mode: Optional[str] = None
    policy_id: Optional[uuid.UUID] = None

class AttendanceCreate(AttendanceBase):
    tenant_id: uuid.UUID

class AttendanceResponse(AttendanceBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class AttendanceSessionBase(BaseModel):
    user_id: uuid.UUID
    attendance_id: uuid.UUID
    session_number: int
    clock_in: datetime
    clock_out: Optional[datetime] = None
    work_hours: Optional[float] = 0.0
    break_duration: Optional[int] = 0
    status: Optional[str] = "Active"

class AttendanceSessionCreate(AttendanceSessionBase):
    tenant_id: uuid.UUID

class AttendanceSessionResponse(AttendanceSessionBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class AttendanceLogBase(BaseModel):
    user_id: uuid.UUID
    attendance_id: uuid.UUID
    session_id: Optional[uuid.UUID] = None
    action: str  # clock_in, clock_out, break_start, break_end
    timestamp: datetime
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_address: Optional[str] = None
    device_info: Optional[str] = None
    ip_address: Optional[str] = None
    shift_timing: Optional[str] = None
    shift_type: Optional[str] = None
    work_mode: Optional[str] = None
    policy_applied: Optional[str] = None
    status: Optional[str] = None

class AttendanceLogCreate(AttendanceLogBase):
    tenant_id: uuid.UUID

class AttendanceLogResponse(AttendanceLogBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class ClockInOutRequest(BaseModel):
    action: str  # clock_in, clock_out
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_address: Optional[str] = None
    device_info: Optional[str] = None

class AttendanceSummaryResponse(BaseModel):
    date: date
    total_records: int
    present: int
    late: int
    absent: int
    class Config:
        from_attributes = True

class AttendanceDetailResponse(BaseModel):
    attendance: AttendanceResponse
    sessions: List[AttendanceSessionResponse]
    logs: List[AttendanceLogResponse]
    shift_info: Optional[Dict[str, Any]] = None
    policy_info: Optional[Dict[str, Any]] = None
    class Config:
        from_attributes = True

# Enhanced Policy Schemas
class PolicyBase(BaseModel):
    name: str
    type: str  # attendance, leave, calendar, time, leave
    level: str  # org, branch, department, user
    rules: Dict[str, Any]
    is_active: bool = True

class PolicyCreate(PolicyBase):
    tenant_id: uuid.UUID

class PolicyUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    level: Optional[str] = None
    rules: Optional[Dict[str, Any]] = None
    is_active: Optional[bool] = None

class PolicyResponse(PolicyBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class PolicyAssignmentBase(BaseModel):
    policy_id: uuid.UUID
    branch_id: Optional[uuid.UUID] = None
    department_id: Optional[uuid.UUID] = None
    user_id: Optional[uuid.UUID] = None
    client_id: Optional[uuid.UUID] = None
    project_id: Optional[uuid.UUID] = None

class PolicyAssignmentCreate(PolicyAssignmentBase):
    tenant_id: uuid.UUID

class PolicyAssignmentResponse(PolicyAssignmentBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    assigned_at: datetime
    class Config:
        from_attributes = True

# Calendar and Holiday Schemas
class HolidayBase(BaseModel):
    name: str
    date: date
    type: str = "holiday"  # holiday, optional_holiday, company_holiday
    description: Optional[str] = None
    is_active: bool = True

class HolidayCreate(HolidayBase):
    pass

class HolidayUpdate(BaseModel):
    name: Optional[str] = None
    date: Optional[date] = None
    type: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None

class HolidayResponse(HolidayBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class WeekOffBase(BaseModel):
    day_of_week: int  # 0=Monday, 6=Sunday
    is_active: bool = True

class WeekOffCreate(WeekOffBase):
    pass

class WeekOffUpdate(BaseModel):
    day_of_week: Optional[int] = None
    is_active: Optional[bool] = None

class WeekOffResponse(WeekOffBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

# Time Policy Schemas
class TimePolicyRules(BaseModel):
    working_hours: int = 8  # hours per day
    start_time: str = "09:00"  # HH:MM format
    end_time: str = "18:00"  # HH:MM format
    flexible_time: bool = False
    flexible_start_time: Optional[str] = None  # HH:MM format
    flexible_end_time: Optional[str] = None  # HH:MM format
    wfh_enabled: bool = False
    hybrid_mode: bool = False
    wfh_days: List[int] = []  # 0=Monday, 6=Sunday
    grace_period: int = 15  # minutes
    late_threshold: int = 30  # minutes
    break_duration: int = 60  # minutes
    overtime_enabled: bool = True
    overtime_threshold: int = 8  # hours

# Leave Schemas
class LeaveTypeBase(BaseModel):
    name: str  # Annual Leave, Sick Leave, etc.
    description: Optional[str] = None
    default_days: int = 0
    is_paid: bool = True
    requires_approval: bool = True
    color: str = "#2196F3"
    is_active: bool = True

class LeaveTypeCreate(LeaveTypeBase):
    pass

class LeaveTypeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    default_days: Optional[int] = None
    is_paid: Optional[bool] = None
    requires_approval: Optional[bool] = None
    color: Optional[str] = None
    is_active: Optional[bool] = None

class LeaveTypeResponse(LeaveTypeBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    created_at: datetime
    class Config:
        from_attributes = True

class LeaveRequestBase(BaseModel):
    user_id: uuid.UUID
    leave_type_id: uuid.UUID
    start_date: date
    end_date: date
    days_requested: float
    reason: Optional[str] = None

class LeaveRequestCreate(LeaveRequestBase):
    pass

class LeaveRequestUpdate(BaseModel):
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_requested: Optional[float] = None
    reason: Optional[str] = None

class LeaveRequestResponse(LeaveRequestBase):
    id: uuid.UUID
    tenant_id: uuid.UUID
    status: str
    approver_id: Optional[uuid.UUID] = None
    approved_at: Optional[datetime] = None
    created_at: datetime
    class Config:
        from_attributes = True

class LeaveApprovalRequest(BaseModel):
    status: str  # approved, rejected
    approver_id: uuid.UUID

class RegularizationRequestBase(BaseModel):
    user_id: uuid.UUID
    date: date
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
    created_at: datetime
    class Config:
        from_attributes = True

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