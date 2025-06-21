#!/usr/bin/env python3
"""
Script to clear all data from all tables while preserving table structure.
This allows starting fresh with clean data.
"""

import sys
import os
sys.path.append(os.path.dirname(__file__))

from sqlalchemy import text
from database import engine

def clear_all_data():
    """Delete all data from all tables in the correct order to respect foreign key constraints."""
    
    print("🗑️  Clearing all data from tables...")
    
    with engine.connect() as connection:
        try:
            # Delete all data from all tables using CASCADE
            tables_to_clear = [
                'policy_assignments',
                'regularization_requests', 
                'attendance',
                'user_roles',
                'role_permissions',
                'user_sessions',
                'notifications',
                'audit_logs',
                'departments',
                'branches',
                'projects',
                'clients',
                'policies',
                'permissions',
                'roles',
                'users',
                'tenants',
            ]
            
            for table in tables_to_clear:
                try:
                    result = connection.execute(text(f"DELETE FROM {table} CASCADE;"))
                    deleted_count = result.rowcount
                    print(f"✅ Cleared {deleted_count} records from {table}")
                except Exception as e:
                    print(f"⚠️  Warning: Could not clear {table}: {e}")
            
            # Reset sequences for UUID columns (PostgreSQL)
            print("\n🔄 Resetting sequences...")
            try:
                # Get all sequences in the database
                result = connection.execute(text("""
                    SELECT sequence_name 
                    FROM information_schema.sequences 
                    WHERE sequence_schema = 'public'
                """))
                sequences = [row[0] for row in result.fetchall()]
                
                for seq in sequences:
                    try:
                        connection.execute(text(f"ALTER SEQUENCE {seq} RESTART WITH 1;"))
                        print(f"✅ Reset sequence {seq}")
                    except Exception as e:
                        print(f"⚠️  Warning: Could not reset {seq}: {e}")
            except Exception as e:
                print(f"⚠️  Warning: Could not reset sequences: {e}")
            
            # Commit the changes
            connection.commit()
            print("\n✅ All data cleared successfully!")
            print("🎉 Database is now clean and ready for fresh data.")
            
        except Exception as e:
            print(f"❌ Error clearing data: {e}")
            connection.rollback()

if __name__ == "__main__":
    print("🧹 Database Cleanup Script")
    print("=" * 50)
    
    response = input("⚠️  This will DELETE ALL DATA from all tables. Are you sure? (yes/no): ")
    
    if response.lower() in ['yes', 'y']:
        clear_all_data()
    else:
        print("❌ Operation cancelled.") 