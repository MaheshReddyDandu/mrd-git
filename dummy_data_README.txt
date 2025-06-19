# Dummy Data Setup for SaaS HRMS

This guide helps you populate your PostgreSQL database with realistic dummy data for all features of the multi-tenant SaaS HRMS platform.

## Requirements
- PostgreSQL installed and running
- Database and user created (default: roleauth_db, user: maheshreddy)
- All migrations applied (database schema up-to-date)

## Usage
1. Copy `dummy_data_template.sql` to your server or local machine.
2. Run the following command to populate your database:

   ```bash
   psql -U maheshreddy -d roleauth_db -f dummy_data_template.sql
   ```
   (You may need to enter your password.)

3. All tables will be filled with sample tenants, users, roles, employees, attendance, policies, and more.

## Default Data
- **Tenants:**
  - Acme Corp (premium)
  - Beta Inc (basic)
- **Users:**
  - owner@acme.com / acmeowner
  - admin@acme.com / acmeadmin
  - manager@acme.com / acmemanager
  - user1@acme.com / acmeuser1
  - owner@beta.com / betaowner
  - admin@beta.com / betaadmin
  - manager@beta.com / betamanager
  - user1@beta.com / betauser1
- **Default Password for All Users:**
  - `password123`

## What's Included
- Tenants, roles, users, user_roles
- Branches, departments, employees
- Attendance records
- Policies and assignments
- Regularization requests

## Notes
- Passwords are pre-hashed with bcrypt for security.
- You can modify or extend the data as needed for your use case.
- If you want to reset the DB, TRUNCATE all tables and re-run this script.

---

**For any issues or questions, contact your system administrator or developer.** 