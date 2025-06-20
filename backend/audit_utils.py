from sqlalchemy.orm import Session
from models import AuditLog, User
from typing import Optional, Dict
import uuid

def log_action(
    db: Session,
    user: Optional[User],
    action: str,
    target_resource: Optional[str] = None,
    target_id: Optional[str] = None,
    details: Optional[Dict] = None,
):
    """
    Helper function to create an audit log entry.
    """
    log_entry = AuditLog(
        tenant_id=user.tenant_id if user else None,
        user_id=user.id if user else None,
        action=action,
        target_resource=target_resource,
        target_id=target_id,
        details=details,
    )
    db.add(log_entry)
    db.commit() 