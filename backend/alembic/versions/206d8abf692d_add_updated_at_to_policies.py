"""add_updated_at_to_policies

Revision ID: 206d8abf692d
Revises: 69f55f81d607
Create Date: 2025-06-21 22:35:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = '206d8abf692d'
down_revision: Union[str, None] = '69f55f81d607'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('policies', sa.Column('updated_at', postgresql.TIMESTAMP(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column('policies', 'updated_at')
