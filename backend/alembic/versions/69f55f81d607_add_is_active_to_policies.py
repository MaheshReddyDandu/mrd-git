"""add_is_active_to_policies

Revision ID: 69f55f81d607
Revises: 09acc5631ec3
Create Date: 2025-06-21 22:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '69f55f81d607'
down_revision: Union[str, None] = '09acc5631ec3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('policies', sa.Column('is_active', sa.Boolean(), nullable=False, server_default=sa.true()))


def downgrade() -> None:
    op.drop_column('policies', 'is_active')
