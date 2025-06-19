"""Make role name unique per tenant

Revision ID: 904f235aff6a
Revises: ec9840b46e31
Create Date: 2025-06-19 21:59:54.533940

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '904f235aff6a'
down_revision: Union[str, None] = 'ec9840b46e31'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drop the unique index on roles.name if it exists, then add unique constraint on (name, tenant_id)
    with op.batch_alter_table('roles') as batch_op:
        batch_op.drop_index('ix_roles_name')  # Drop index if it exists (safe to try)
        batch_op.create_unique_constraint('ix_roles_name_tenant', ['name', 'tenant_id'])

    # Data migration: assign tenant_id to default roles
    conn = op.get_bind()
    tenants = conn.execute(sa.text('SELECT id FROM tenants')).fetchall()
    for tenant in tenants:
        for role_name in ['admin', 'user', 'manager']:
            # Check if role exists for this tenant
            role_exists = conn.execute(sa.text('SELECT 1 FROM roles WHERE name=:name AND tenant_id=:tenant_id'), {'name': role_name, 'tenant_id': tenant[0]}).fetchone()
            if not role_exists:
                # Find a global role (tenant_id is NULL)
                global_role = conn.execute(sa.text('SELECT id FROM roles WHERE name=:name AND tenant_id IS NULL'), {'name': role_name}).fetchone()
                if global_role:
                    # Update the global role to belong to this tenant
                    conn.execute(sa.text('UPDATE roles SET tenant_id=:tenant_id WHERE id=:id'), {'tenant_id': tenant[0], 'id': global_role[0]})


def downgrade() -> None:
    # Remove the unique constraint on (name, tenant_id)
    with op.batch_alter_table('roles') as batch_op:
        batch_op.drop_constraint('ix_roles_name_tenant', type_='unique')
        # Recreate the unique constraint on name only
        batch_op.create_index('ix_roles_name', ['name'], unique=True)
