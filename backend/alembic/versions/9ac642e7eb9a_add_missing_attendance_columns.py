"""add_missing_attendance_columns

Revision ID: 9ac642e7eb9a
Revises: adc99ebb3c19
Create Date: 2025-06-21 22:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '9ac642e7eb9a'
down_revision: Union[str, None] = 'adc99ebb3c19'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add missing columns to attendance table
    op.add_column('attendance', sa.Column('total_work_hours', sa.Float(), nullable=True, default=0.0))
    op.add_column('attendance', sa.Column('total_sessions', sa.Integer(), nullable=True, default=0))
    op.add_column('attendance', sa.Column('shift_type', sa.String(), nullable=True))
    op.add_column('attendance', sa.Column('work_mode', sa.String(), nullable=True))
    op.add_column('attendance', sa.Column('policy_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column('attendance', sa.Column('updated_at', postgresql.TIMESTAMP(timezone=True), nullable=True))
    
    # Add foreign key constraint for policy_id
    op.create_foreign_key('attendance_policy_id_fkey', 'attendance', 'policies', ['policy_id'], ['id'])
    
    # Remove old columns that are no longer needed
    op.drop_column('attendance', 'clock_in')
    op.drop_column('attendance', 'clock_out')
    op.drop_column('attendance', 'location')


def downgrade() -> None:
    # Add back old columns
    op.add_column('attendance', sa.Column('clock_in', postgresql.TIMESTAMP(), nullable=True))
    op.add_column('attendance', sa.Column('clock_out', postgresql.TIMESTAMP(), nullable=True))
    op.add_column('attendance', sa.Column('location', sa.VARCHAR(), nullable=True))
    
    # Remove foreign key constraint
    op.drop_constraint('attendance_policy_id_fkey', 'attendance', type_='foreignkey')
    
    # Remove new columns
    op.drop_column('attendance', 'updated_at')
    op.drop_column('attendance', 'policy_id')
    op.drop_column('attendance', 'work_mode')
    op.drop_column('attendance', 'shift_type')
    op.drop_column('attendance', 'total_sessions')
    op.drop_column('attendance', 'total_work_hours')
