"""add_missing_attendance_logs_columns

Revision ID: 09acc5631ec3
Revises: 9ac642e7eb9a
Create Date: 2025-06-21 22:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '09acc5631ec3'
down_revision: Union[str, None] = '9ac642e7eb9a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add missing columns to attendance_logs table
    op.add_column('attendance_logs', sa.Column('session_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column('attendance_logs', sa.Column('shift_timing', sa.String(), nullable=True))
    op.add_column('attendance_logs', sa.Column('shift_type', sa.String(), nullable=True))
    op.add_column('attendance_logs', sa.Column('work_mode', sa.String(), nullable=True))
    op.add_column('attendance_logs', sa.Column('policy_applied', sa.String(), nullable=True))
    op.add_column('attendance_logs', sa.Column('status', sa.String(), nullable=True))
    
    # Add foreign key constraint for session_id
    op.create_foreign_key('attendance_logs_session_id_fkey', 'attendance_logs', 'attendance_sessions', ['session_id'], ['id'])


def downgrade() -> None:
    # Remove foreign key constraint
    op.drop_constraint('attendance_logs_session_id_fkey', 'attendance_logs', type_='foreignkey')
    
    # Remove new columns
    op.drop_column('attendance_logs', 'status')
    op.drop_column('attendance_logs', 'policy_applied')
    op.drop_column('attendance_logs', 'work_mode')
    op.drop_column('attendance_logs', 'shift_type')
    op.drop_column('attendance_logs', 'shift_timing')
    op.drop_column('attendance_logs', 'session_id')
