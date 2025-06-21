--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Homebrew)
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.week_offs DROP CONSTRAINT IF EXISTS week_offs_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_project_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.regularization_requests DROP CONSTRAINT IF EXISTS regularization_requests_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.regularization_requests DROP CONSTRAINT IF EXISTS regularization_requests_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.regularization_requests DROP CONSTRAINT IF EXISTS regularization_requests_approver_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_branch_id_fkey;
ALTER TABLE IF EXISTS ONLY public.policies DROP CONSTRAINT IF EXISTS policies_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_types DROP CONSTRAINT IF EXISTS leave_types_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_leave_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_approver_id_fkey;
ALTER TABLE IF EXISTS ONLY public.holidays DROP CONSTRAINT IF EXISTS holidays_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.departments DROP CONSTRAINT IF EXISTS departments_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.departments DROP CONSTRAINT IF EXISTS departments_branch_id_fkey;
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS clients_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.branches DROP CONSTRAINT IF EXISTS branches_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_sessions DROP CONSTRAINT IF EXISTS attendance_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_sessions DROP CONSTRAINT IF EXISTS attendance_sessions_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_sessions DROP CONSTRAINT IF EXISTS attendance_sessions_attendance_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_policy_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_logs DROP CONSTRAINT IF EXISTS attendance_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_logs DROP CONSTRAINT IF EXISTS attendance_logs_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_logs DROP CONSTRAINT IF EXISTS attendance_logs_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_logs DROP CONSTRAINT IF EXISTS attendance_logs_attendance_id_fkey;
DROP INDEX IF EXISTS public.ix_users_username;
DROP INDEX IF EXISTS public.ix_users_id;
DROP INDEX IF EXISTS public.ix_users_email;
DROP INDEX IF EXISTS public.ix_user_sessions_token_hash;
DROP INDEX IF EXISTS public.ix_user_sessions_id;
DROP INDEX IF EXISTS public.ix_user_roles_id;
DROP INDEX IF EXISTS public.ix_roles_name_tenant;
DROP INDEX IF EXISTS public.ix_roles_id;
DROP INDEX IF EXISTS public.ix_role_permissions_id;
DROP INDEX IF EXISTS public.ix_permissions_resource;
DROP INDEX IF EXISTS public.ix_permissions_name;
DROP INDEX IF EXISTS public.ix_permissions_id;
DROP INDEX IF EXISTS public.ix_permissions_action;
DROP INDEX IF EXISTS public.ix_notifications_user_id;
DROP INDEX IF EXISTS public.ix_notifications_tenant_id;
DROP INDEX IF EXISTS public.ix_audit_logs_user_id;
DROP INDEX IF EXISTS public.ix_audit_logs_tenant_id;
DROP INDEX IF EXISTS public.ix_audit_logs_action;
DROP INDEX IF EXISTS public.idx_user_username_active;
DROP INDEX IF EXISTS public.idx_user_role_unique;
DROP INDEX IF EXISTS public.idx_user_email_active;
DROP INDEX IF EXISTS public.idx_session_user_active;
DROP INDEX IF EXISTS public.idx_session_token_expires;
DROP INDEX IF EXISTS public.idx_role_permission_unique;
ALTER TABLE IF EXISTS ONLY public.week_offs DROP CONSTRAINT IF EXISTS week_offs_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_sessions DROP CONSTRAINT IF EXISTS user_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.tenants DROP CONSTRAINT IF EXISTS tenants_pkey;
ALTER TABLE IF EXISTS ONLY public.tenants DROP CONSTRAINT IF EXISTS tenants_name_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.regularization_requests DROP CONSTRAINT IF EXISTS regularization_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_pkey;
ALTER TABLE IF EXISTS ONLY public.policy_assignments DROP CONSTRAINT IF EXISTS policy_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.policies DROP CONSTRAINT IF EXISTS policies_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.leave_types DROP CONSTRAINT IF EXISTS leave_types_pkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.holidays DROP CONSTRAINT IF EXISTS holidays_pkey;
ALTER TABLE IF EXISTS ONLY public.departments DROP CONSTRAINT IF EXISTS departments_pkey;
ALTER TABLE IF EXISTS ONLY public.clients DROP CONSTRAINT IF EXISTS clients_pkey;
ALTER TABLE IF EXISTS ONLY public.branches DROP CONSTRAINT IF EXISTS branches_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance_sessions DROP CONSTRAINT IF EXISTS attendance_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance_logs DROP CONSTRAINT IF EXISTS attendance_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
DROP TABLE IF EXISTS public.week_offs;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_sessions;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.tenants;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.role_permissions;
DROP TABLE IF EXISTS public.regularization_requests;
DROP TABLE IF EXISTS public.projects;
DROP TABLE IF EXISTS public.policy_assignments;
DROP TABLE IF EXISTS public.policies;
DROP TABLE IF EXISTS public.permissions;
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.leave_types;
DROP TABLE IF EXISTS public.leave_requests;
DROP TABLE IF EXISTS public.holidays;
DROP TABLE IF EXISTS public.departments;
DROP TABLE IF EXISTS public.clients;
DROP TABLE IF EXISTS public.branches;
DROP TABLE IF EXISTS public.audit_logs;
DROP TABLE IF EXISTS public.attendance_sessions;
DROP TABLE IF EXISTS public.attendance_logs;
DROP TABLE IF EXISTS public.attendance;
DROP TABLE IF EXISTS public.alembic_version;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO maheshreddy;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.attendance (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    date date NOT NULL,
    status character varying,
    created_at timestamp with time zone DEFAULT now(),
    total_work_hours double precision,
    total_sessions integer,
    shift_type character varying,
    work_mode character varying,
    policy_id uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.attendance OWNER TO maheshreddy;

--
-- Name: attendance_logs; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.attendance_logs (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    attendance_id uuid NOT NULL,
    action character varying NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    latitude double precision,
    longitude double precision,
    location_address character varying,
    device_info character varying,
    ip_address character varying,
    created_at timestamp with time zone DEFAULT now(),
    session_id uuid,
    shift_timing character varying,
    shift_type character varying,
    work_mode character varying,
    policy_applied character varying,
    status character varying
);


ALTER TABLE public.attendance_logs OWNER TO maheshreddy;

--
-- Name: attendance_sessions; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.attendance_sessions (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    attendance_id uuid NOT NULL,
    session_number integer NOT NULL,
    clock_in timestamp with time zone NOT NULL,
    clock_out timestamp with time zone,
    work_hours double precision,
    break_duration integer,
    status character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.attendance_sessions OWNER TO maheshreddy;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.audit_logs (
    id uuid NOT NULL,
    tenant_id uuid,
    user_id uuid,
    action character varying NOT NULL,
    target_resource character varying,
    target_id character varying,
    details jsonb,
    "timestamp" timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_logs OWNER TO maheshreddy;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.branches (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    address character varying,
    geo_fence character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.branches OWNER TO maheshreddy;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.clients (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    contact_email character varying NOT NULL,
    contact_phone character varying,
    address text,
    industry character varying,
    status character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.clients OWNER TO maheshreddy;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.departments (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    branch_id uuid,
    name character varying NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.departments OWNER TO maheshreddy;

--
-- Name: holidays; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.holidays (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    date date NOT NULL,
    type character varying,
    description text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.holidays OWNER TO maheshreddy;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.leave_requests (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    leave_type_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    days_requested double precision NOT NULL,
    reason text,
    status character varying,
    approver_id uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.leave_requests OWNER TO maheshreddy;

--
-- Name: leave_types; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.leave_types (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    description text,
    default_days integer,
    is_paid boolean,
    requires_approval boolean,
    color character varying,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.leave_types OWNER TO maheshreddy;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    type character varying NOT NULL,
    message character varying NOT NULL,
    is_read boolean,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO maheshreddy;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.permissions (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    resource character varying(100),
    action character varying(50),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.permissions OWNER TO maheshreddy;

--
-- Name: policies; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.policies (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    level character varying NOT NULL,
    rules text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.policies OWNER TO maheshreddy;

--
-- Name: policy_assignments; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.policy_assignments (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    policy_id uuid NOT NULL,
    branch_id uuid,
    department_id uuid,
    user_id uuid,
    assigned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.policy_assignments OWNER TO maheshreddy;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    client_id uuid NOT NULL,
    name character varying NOT NULL,
    description text,
    start_date date,
    end_date date,
    status character varying,
    budget character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.projects OWNER TO maheshreddy;

--
-- Name: regularization_requests; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.regularization_requests (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    date date NOT NULL,
    reason character varying NOT NULL,
    requested_in timestamp without time zone,
    requested_out timestamp without time zone,
    status character varying,
    approver_id uuid,
    approved_at timestamp without time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.regularization_requests OWNER TO maheshreddy;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.role_permissions (
    id uuid NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.role_permissions OWNER TO maheshreddy;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.roles (
    id uuid NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now(),
    tenant_id uuid
);


ALTER TABLE public.roles OWNER TO maheshreddy;

--
-- Name: tenants; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.tenants (
    id uuid NOT NULL,
    name character varying NOT NULL,
    contact_email character varying NOT NULL,
    plan character varying,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.tenants OWNER TO maheshreddy;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.user_roles (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_roles OWNER TO maheshreddy;

--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.user_sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_active boolean
);


ALTER TABLE public.user_sessions OWNER TO maheshreddy;

--
-- Name: users; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean,
    needs_password boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    tenant_id uuid,
    client_id uuid,
    project_id uuid,
    department_id uuid,
    role_id uuid,
    name character varying,
    phone character varying,
    status character varying
);


ALTER TABLE public.users OWNER TO maheshreddy;

--
-- Name: week_offs; Type: TABLE; Schema: public; Owner: maheshreddy
--

CREATE TABLE public.week_offs (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    day_of_week integer NOT NULL,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.week_offs OWNER TO maheshreddy;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.alembic_version (version_num) FROM stdin;
206d8abf692d
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.attendance (id, tenant_id, user_id, date, status, created_at, total_work_hours, total_sessions, shift_type, work_mode, policy_id, updated_at) FROM stdin;
cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	2025-06-20	Present	2025-06-21 22:20:45.106195+05:30	10	3	Regular	Office	\N	2025-06-21 22:20:45.117767+05:30
28edaaaf-2c94-4439-b81a-5006022c0cf7	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	2025-06-19	Present	2025-06-21 22:20:45.123399+05:30	10	3	Regular	Office	\N	2025-06-21 22:20:45.127099+05:30
52916412-9df5-47e7-848b-a93257b0973b	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	2025-06-18	Present	2025-06-21 22:20:45.130521+05:30	10	3	Regular	Office	\N	2025-06-21 22:20:45.133889+05:30
1c5663ac-0539-4706-9c37-c013d3d0cda2	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	2025-06-21	Present	2025-06-21 21:27:39.628582+05:30	6.255083393055554	8	\N	\N	\N	2025-06-21 23:25:13.315552+05:30
\.


--
-- Data for Name: attendance_logs; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.attendance_logs (id, tenant_id, user_id, attendance_id, action, "timestamp", latitude, longitude, location_address, device_info, ip_address, created_at, session_id, shift_timing, shift_type, work_mode, policy_applied, status) FROM stdin;
bee086a0-28e2-4f4c-b456-51dc28434400	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 15:57:39.629981+05:30	12.96261866825674	77.71629707902738	\N	Web	127.0.0.1	2025-06-21 21:27:39.638401+05:30	\N	\N	\N	\N	\N	\N
2266f32d-97b0-4684-b76a-8df87c9fbc5c	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 15:58:10.028528+05:30	12.96261866825674	77.71629707902738	\N	Web	127.0.0.1	2025-06-21 21:28:10.027461+05:30	\N	\N	\N	\N	\N	\N
493c4775-47c0-45cc-ac6b-0299f7c8dc92	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 15:58:23.182828+05:30	12.962625963812448	77.71629762881857	\N	Web	127.0.0.1	2025-06-21 21:28:23.18202+05:30	\N	\N	\N	\N	\N	\N
bdbf473c-127a-4a01-9927-49120a1e79db	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 15:58:30.312929+05:30	12.96262594363139	77.71629765445414	\N	Web	127.0.0.1	2025-06-21 21:28:30.312261+05:30	\N	\N	\N	\N	\N	\N
8950005c-1403-46bd-87b6-b90422812642	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 16:07:35.702244+05:30	12.962468189650902	77.71635413118044	\N	Web	127.0.0.1	2025-06-21 21:37:35.701461+05:30	\N	\N	\N	\N	\N	\N
1558b709-6dae-4ba7-bf7b-004921dd0da6	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 16:47:42.110491+05:30	\N	\N	\N	\N	127.0.0.1	2025-06-21 22:17:42.109877+05:30	\N	\N	\N	\N	\N	On Time
dc03e653-60eb-4472-bd37-365937f088f5	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_in	2025-06-20 14:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	c6eb0eb5-6d35-4402-80d5-4652c0756e5e	\N	\N	\N	\N	On Time
281377f8-3847-4093-971c-a6659d196f87	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_out	2025-06-20 18:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	c6eb0eb5-6d35-4402-80d5-4652c0756e5e	\N	\N	\N	\N	On Time
f2b1a331-7fac-4dad-919d-439ec4c33ede	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_in	2025-06-20 19:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	11945379-1790-484c-8aa0-5d3d175fdf8c	\N	\N	\N	\N	On Time
def871a5-e4d0-4d78-a442-a114394c54ec	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_out	2025-06-20 23:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	11945379-1790-484c-8aa0-5d3d175fdf8c	\N	\N	\N	\N	On Time
f62d520a-bdd3-4d84-bd3f-7114eaafaabf	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_in	2025-06-21 00:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	9b17f25b-8e5d-4416-9bc7-32d038f863da	\N	\N	\N	\N	On Time
17078b62-8441-48cb-b026-d46286f7f363	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	clock_out	2025-06-21 02:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.117767+05:30	9b17f25b-8e5d-4416-9bc7-32d038f863da	\N	\N	\N	\N	On Time
bd087280-dc02-44fa-84dc-8f70b8f331fb	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_in	2025-06-19 14:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	4247aa98-7e00-4a37-b8f7-99344345d1fd	\N	\N	\N	\N	On Time
78663624-e477-4551-ac26-86e33a49ca7a	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_out	2025-06-19 18:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	4247aa98-7e00-4a37-b8f7-99344345d1fd	\N	\N	\N	\N	On Time
1129ebf7-51ee-4712-a80b-9e997d4dcfaf	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_in	2025-06-19 19:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	22909609-5c1c-44d3-a937-ea2fb485a249	\N	\N	\N	\N	On Time
24246adb-1294-4c67-9f57-3aa94ca11fce	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_out	2025-06-19 23:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	22909609-5c1c-44d3-a937-ea2fb485a249	\N	\N	\N	\N	On Time
7b7cee98-7386-40af-bbe8-183518da1f52	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_in	2025-06-20 00:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	4e8fb4ac-a42c-41f3-bb8e-68f8e5ea4159	\N	\N	\N	\N	On Time
3ed244f0-01f5-4865-a1d1-3b2769ab07bf	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	clock_out	2025-06-20 02:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.127099+05:30	4e8fb4ac-a42c-41f3-bb8e-68f8e5ea4159	\N	\N	\N	\N	On Time
f4b8fbf1-8be2-463a-a15c-eb8fc13d0422	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_in	2025-06-18 14:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	38de408e-db25-4b88-9194-43a5c4ed9834	\N	\N	\N	\N	On Time
802b152b-2371-4f55-b60f-ab42c996fc28	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_out	2025-06-18 18:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	38de408e-db25-4b88-9194-43a5c4ed9834	\N	\N	\N	\N	On Time
269c0206-4235-4077-a5f0-ec29716f4d93	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_in	2025-06-18 19:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	adf963a3-00c8-434b-9e92-f38ee9b4a9b7	\N	\N	\N	\N	On Time
79b2543c-7687-4ce7-b79e-b3cc1df75df3	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_out	2025-06-18 23:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	adf963a3-00c8-434b-9e92-f38ee9b4a9b7	\N	\N	\N	\N	On Time
a7338a75-77b5-4e50-9048-25b3f96143b8	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_in	2025-06-19 00:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	ec15401d-03f5-4fc9-86f0-fefaa1d660bd	\N	\N	\N	\N	On Time
6e0b7891-3268-4753-a4cd-65b257dd6dc9	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	clock_out	2025-06-19 02:30:00+05:30	\N	\N	\N	Web Browser	127.0.0.1	2025-06-21 22:20:45.133889+05:30	ec15401d-03f5-4fc9-86f0-fefaa1d660bd	\N	\N	\N	\N	On Time
6ffed92a-8823-4055-867f-508aaea13f4e	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 22:22:25.775999+05:30	\N	\N	\N	\N	127.0.0.1	2025-06-21 22:22:25.775641+05:30	a5a3060a-ce49-4219-9fe8-e10b3e83e61f	\N	\N	\N	\N	On Time
a20e659b-8c6e-489a-a9cb-8e1c9fa3134c	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 22:25:20.025636+05:30	12.962607672265515	77.71627510599502	\N	Web	127.0.0.1	2025-06-21 22:25:20.024935+05:30	\N	\N	\N	\N	\N	On Time
08561423-d2da-4cbe-b7f1-7d54ca45305f	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 22:25:51.320831+05:30	12.962783659300264	77.71606463043257	\N	Web	127.0.0.1	2025-06-21 22:25:51.320116+05:30	5b105cd7-5cce-45c7-99e7-57def1912e91	\N	\N	\N	\N	On Time
4d36f07d-5ff0-4dd4-92a5-8d572fe4e98b	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 22:26:26.71537+05:30	12.962560489986735	77.71624822733038	\N	Web	127.0.0.1	2025-06-21 22:26:26.714879+05:30	\N	\N	\N	\N	\N	On Time
7b6e3c2e-de0a-48c5-bdad-5c19f7b42212	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 22:26:36.854879+05:30	12.96253735473434	77.71630062276896	\N	Web	127.0.0.1	2025-06-21 22:26:36.854403+05:30	5e1348e5-9bc7-400f-9063-9e30181cc79a	\N	\N	\N	\N	On Time
57fac25c-3b94-4f07-9391-f7bf78bd8820	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 22:27:11.761482+05:30	12.962534006473334	77.71631359909422	\N	Web	127.0.0.1	2025-06-21 22:27:11.760802+05:30	\N	\N	\N	\N	\N	On Time
cf98ead1-a1db-4b26-9159-bba731284ac7	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 22:27:26.626808+05:30	12.962534013942523	77.7163135786256	\N	Web	127.0.0.1	2025-06-21 22:27:26.626447+05:30	ca766213-7759-4eff-b447-2d97a9f8b4bb	\N	\N	\N	\N	On Time
18f0cd62-803a-4f4e-8943-d872819e5c41	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 22:42:40.005438+05:30	12.962591349603095	77.71626319764479	\N	Web	127.0.0.1	2025-06-21 22:42:40.00469+05:30	\N	\N	\N	\N	\N	On Time
9ff6a02e-1e9f-44f2-84b1-99306a5839a6	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 22:42:58.246583+05:30	12.962591498865546	77.71626312529642	\N	Web	127.0.0.1	2025-06-21 22:42:58.246107+05:30	97cdc46e-464c-4fb1-9711-53694f7b1b68	\N	\N	\N	\N	On Time
8b26546c-e4e8-4924-a4b9-457c86d4a21d	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 22:45:14.168271+05:30	12.9716	77.5946	Bangalore, India	Test Device	127.0.0.1	2025-06-21 22:45:14.16663+05:30	\N	\N	\N	\N	\N	On Time
30fa5409-7fac-4dc3-bd2c-f42c1c93f290	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 23:24:30.57048+05:30	\N	\N	\N	\N	127.0.0.1	2025-06-21 23:24:30.568717+05:30	\N	\N	\N	\N	\N	On Time
4647a9f3-65b1-482f-ad4c-bb221be41585	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 23:24:34.261803+05:30	\N	\N	\N	\N	127.0.0.1	2025-06-21 23:24:34.261186+05:30	2a2343dc-b64e-47db-bf09-60e3587f3e92	\N	\N	\N	\N	On Time
d6a37578-d5db-4d27-b3b2-008bfd342a97	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_in	2025-06-21 23:25:02.502209+05:30	12.962461488080622	77.71632765999682	\N	Web	127.0.0.1	2025-06-21 23:25:02.501697+05:30	\N	\N	\N	\N	\N	On Time
6f733201-b2c6-40bf-b54c-082f5659336d	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	clock_out	2025-06-21 23:25:13.316049+05:30	12.962554361612527	77.71630754753473	\N	Web	127.0.0.1	2025-06-21 23:25:13.315552+05:30	3a21cb81-02b0-4d8d-a2ab-3fb4a5ec3da1	\N	\N	\N	\N	On Time
\.


--
-- Data for Name: attendance_sessions; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.attendance_sessions (id, tenant_id, user_id, attendance_id, session_number, clock_in, clock_out, work_hours, break_duration, status, created_at, updated_at) FROM stdin;
c6eb0eb5-6d35-4402-80d5-4652c0756e5e	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	1	2025-06-20 14:30:00+05:30	2025-06-20 18:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.112899+05:30	\N
11945379-1790-484c-8aa0-5d3d175fdf8c	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	2	2025-06-20 19:30:00+05:30	2025-06-20 23:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.112899+05:30	\N
9b17f25b-8e5d-4416-9bc7-32d038f863da	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	cb14c1ae-413d-4ca6-8cc5-2ce0726dcaa3	3	2025-06-21 00:30:00+05:30	2025-06-21 02:30:00+05:30	2	0	Completed	2025-06-21 22:20:45.112899+05:30	\N
4247aa98-7e00-4a37-b8f7-99344345d1fd	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	1	2025-06-19 14:30:00+05:30	2025-06-19 18:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.124895+05:30	\N
22909609-5c1c-44d3-a937-ea2fb485a249	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	2	2025-06-19 19:30:00+05:30	2025-06-19 23:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.124895+05:30	\N
4e8fb4ac-a42c-41f3-bb8e-68f8e5ea4159	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	28edaaaf-2c94-4439-b81a-5006022c0cf7	3	2025-06-20 00:30:00+05:30	2025-06-20 02:30:00+05:30	2	0	Completed	2025-06-21 22:20:45.124895+05:30	\N
38de408e-db25-4b88-9194-43a5c4ed9834	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	1	2025-06-18 14:30:00+05:30	2025-06-18 18:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.132045+05:30	\N
adf963a3-00c8-434b-9e92-f38ee9b4a9b7	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	2	2025-06-18 19:30:00+05:30	2025-06-18 23:30:00+05:30	4	0	Completed	2025-06-21 22:20:45.132045+05:30	\N
ec15401d-03f5-4fc9-86f0-fefaa1d660bd	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	52916412-9df5-47e7-848b-a93257b0973b	3	2025-06-19 00:30:00+05:30	2025-06-19 02:30:00+05:30	2	0	Completed	2025-06-21 22:20:45.132045+05:30	\N
a5a3060a-ce49-4219-9fe8-e10b3e83e61f	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	1	2025-06-21 16:47:42.110491+05:30	2025-06-21 22:22:25.775999+05:30	5.578795974444444	0	Completed	2025-06-21 22:17:42.109877+05:30	2025-06-21 22:22:25.775641+05:30
5b105cd7-5cce-45c7-99e7-57def1912e91	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	2	2025-06-21 22:25:20.025636+05:30	2025-06-21 22:25:51.320831+05:30	0.008693109722222222	0	Completed	2025-06-21 22:25:20.024935+05:30	2025-06-21 22:25:51.320116+05:30
5e1348e5-9bc7-400f-9063-9e30181cc79a	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	3	2025-06-21 22:26:26.71537+05:30	2025-06-21 22:26:36.854879+05:30	0.002816530277777778	0	Completed	2025-06-21 22:26:26.714879+05:30	2025-06-21 22:26:36.854403+05:30
ca766213-7759-4eff-b447-2d97a9f8b4bb	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	4	2025-06-21 22:27:11.761482+05:30	2025-06-21 22:27:26.626808+05:30	0.004129257222222222	0	Completed	2025-06-21 22:27:11.760802+05:30	2025-06-21 22:27:26.626447+05:30
97cdc46e-464c-4fb1-9711-53694f7b1b68	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	5	2025-06-21 22:42:40.005438+05:30	2025-06-21 22:42:58.246583+05:30	0.005066984722222222	0	Completed	2025-06-21 22:42:40.00469+05:30	2025-06-21 22:42:58.246107+05:30
9210e3b0-6587-49ad-96bc-a272b687396e	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	6	2025-06-21 22:45:14.168271+05:30	2025-06-21 23:24:30.57048+05:30	0.6545561691666666	0	Completed	2025-06-21 22:45:14.16663+05:30	2025-06-21 23:24:30.568717+05:30
2a2343dc-b64e-47db-bf09-60e3587f3e92	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	7	2025-06-21 23:24:30.57048+05:30	2025-06-21 23:24:34.261803+05:30	0.0010253675	0	Completed	2025-06-21 23:24:30.568717+05:30	2025-06-21 23:24:34.261186+05:30
3a21cb81-02b0-4d8d-a2ab-3fb4a5ec3da1	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	1c9c4019-c110-4cee-9848-7a2b36a71e02	1c5663ac-0539-4706-9c37-c013d3d0cda2	8	2025-06-21 23:25:02.502209+05:30	2025-06-21 23:25:13.316049+05:30	0.0030038444444444447	0	Completed	2025-06-21 23:25:02.501697+05:30	2025-06-21 23:25:13.315552+05:30
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.audit_logs (id, tenant_id, user_id, action, target_resource, target_id, details, "timestamp") FROM stdin;
\.


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.branches (id, tenant_id, name, address, geo_fence, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.clients (id, tenant_id, name, contact_email, contact_phone, address, industry, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.departments (id, tenant_id, branch_id, name, description, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.holidays (id, tenant_id, name, date, type, description, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.leave_requests (id, tenant_id, user_id, leave_type_id, start_date, end_date, days_requested, reason, status, approver_id, approved_at, created_at) FROM stdin;
\.


--
-- Data for Name: leave_types; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.leave_types (id, tenant_id, name, description, default_days, is_paid, requires_approval, color, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.notifications (id, tenant_id, user_id, type, message, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.permissions (id, name, description, resource, action, created_at) FROM stdin;
\.


--
-- Data for Name: policies; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.policies (id, tenant_id, name, type, level, rules, created_at, is_active, updated_at) FROM stdin;
\.


--
-- Data for Name: policy_assignments; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.policy_assignments (id, tenant_id, policy_id, branch_id, department_id, user_id, assigned_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.projects (id, tenant_id, client_id, name, description, start_date, end_date, status, budget, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: regularization_requests; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.regularization_requests (id, tenant_id, user_id, date, reason, requested_in, requested_out, status, approver_id, approved_at, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.role_permissions (id, role_id, permission_id, created_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.roles (id, name, description, created_at, tenant_id) FROM stdin;
3b15694d-e729-4c7c-a3e5-1ece4988772a	owner	Owner role	2025-06-21 19:46:45.996561+05:30	c7bc4535-b505-48f0-b0f6-80d2470d7c0d
1e395fee-56ac-403f-a84b-bba2075ebeab	admin	Admin role	2025-06-21 19:46:45.998932+05:30	c7bc4535-b505-48f0-b0f6-80d2470d7c0d
80435663-9e6d-4dcf-8b40-3438d39cfb4a	manager	Manager role	2025-06-21 19:46:46.000442+05:30	c7bc4535-b505-48f0-b0f6-80d2470d7c0d
4d05ad56-ff70-4e6b-9b2a-d4cbf5191f22	user	User role	2025-06-21 19:46:46.001952+05:30	c7bc4535-b505-48f0-b0f6-80d2470d7c0d
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.tenants (id, name, contact_email, plan, created_at) FROM stdin;
c7bc4535-b505-48f0-b0f6-80d2470d7c0d	Mahesh	maheshreddydandu@icloud.com	basic	2025-06-21 19:46:45.811273+05:30
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.user_roles (id, user_id, role_id, assigned_at) FROM stdin;
3ac2627c-271d-4ffe-8d28-b948779b1152	1c9c4019-c110-4cee-9848-7a2b36a71e02	3b15694d-e729-4c7c-a3e5-1ece4988772a	2025-06-21 19:46:46.003304+05:30
6f277af5-83f5-48f8-869e-0b1759b156bb	1c9c4019-c110-4cee-9848-7a2b36a71e02	1e395fee-56ac-403f-a84b-bba2075ebeab	2025-06-21 19:46:46.003304+05:30
dc4f139e-24af-4d51-8fbc-a1fc6b4b2dae	1c9c4019-c110-4cee-9848-7a2b36a71e02	80435663-9e6d-4dcf-8b40-3438d39cfb4a	2025-06-21 19:46:46.003304+05:30
02bfec3c-9f78-4a4e-980e-1e380bbca2c4	1c9c4019-c110-4cee-9848-7a2b36a71e02	4d05ad56-ff70-4e6b-9b2a-d4cbf5191f22	2025-06-21 19:46:46.003304+05:30
0772e3c1-ed9a-470b-a02f-06a0e92da884	b1e91b50-d0f5-4032-a6fe-27f233cb50fa	4d05ad56-ff70-4e6b-9b2a-d4cbf5191f22	2025-06-21 19:48:21.705366+05:30
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.user_sessions (id, user_id, token_hash, expires_at, created_at, is_active) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.users (id, email, username, hashed_password, is_active, needs_password, created_at, updated_at, tenant_id, client_id, project_id, department_id, role_id, name, phone, status) FROM stdin;
b1e91b50-d0f5-4032-a6fe-27f233cb50fa	maheshreddydandu@gmail.com	maheshreddy-user1	$2b$12$tP.bwnuaY1VaI0r9VJAqV.mBiGuLy1azyMSyrqxxNvc2TMuBiyllq	t	f	2025-06-21 19:48:21.697169+05:30	2025-06-21 19:49:15.572674+05:30	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	\N	\N	\N	\N	\N	\N	active
92b59336-5b5a-4245-8cd1-5a0390f9506c	admin@example.com	admin	$2b$12$O.HPkEEKLPdgvGSmIYs4Remxm3tuThDXE2wnbN5RIAVaDhChBmjfa	t	f	2025-06-21 20:06:23.478933+05:30	\N	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	\N	\N	\N	\N	\N	\N	active
1c9c4019-c110-4cee-9848-7a2b36a71e02	maheshreddydandu@icloud.com	Mahesh	$2b$12$XMs4/kukbfI9Svs8ro2Uv.ftGRv52wxhAiU2rXI2.ckDc/ItOacF6	t	f	2025-06-21 19:46:45.814735+05:30	\N	c7bc4535-b505-48f0-b0f6-80d2470d7c0d	\N	\N	\N	\N	\N	\N	active
\.


--
-- Data for Name: week_offs; Type: TABLE DATA; Schema: public; Owner: maheshreddy
--

COPY public.week_offs (id, tenant_id, day_of_week, is_active, created_at) FROM stdin;
\.


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: attendance_logs attendance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: attendance_sessions attendance_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_sessions
    ADD CONSTRAINT attendance_sessions_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: leave_types leave_types_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_types
    ADD CONSTRAINT leave_types_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: policies policies_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_pkey PRIMARY KEY (id);


--
-- Name: policy_assignments policy_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: regularization_requests regularization_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.regularization_requests
    ADD CONSTRAINT regularization_requests_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_name_key; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_name_key UNIQUE (name);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: week_offs week_offs_pkey; Type: CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.week_offs
    ADD CONSTRAINT week_offs_pkey PRIMARY KEY (id);


--
-- Name: idx_role_permission_unique; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX idx_role_permission_unique ON public.role_permissions USING btree (role_id, permission_id);


--
-- Name: idx_session_token_expires; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX idx_session_token_expires ON public.user_sessions USING btree (token_hash, expires_at);


--
-- Name: idx_session_user_active; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX idx_session_user_active ON public.user_sessions USING btree (user_id, is_active);


--
-- Name: idx_user_email_active; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX idx_user_email_active ON public.users USING btree (email, is_active);


--
-- Name: idx_user_role_unique; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX idx_user_role_unique ON public.user_roles USING btree (user_id, role_id);


--
-- Name: idx_user_username_active; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX idx_user_username_active ON public.users USING btree (username, is_active);


--
-- Name: ix_audit_logs_action; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_audit_logs_action ON public.audit_logs USING btree (action);


--
-- Name: ix_audit_logs_tenant_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_audit_logs_tenant_id ON public.audit_logs USING btree (tenant_id);


--
-- Name: ix_audit_logs_user_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: ix_notifications_tenant_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_notifications_tenant_id ON public.notifications USING btree (tenant_id);


--
-- Name: ix_notifications_user_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: ix_permissions_action; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_permissions_action ON public.permissions USING btree (action);


--
-- Name: ix_permissions_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_permissions_id ON public.permissions USING btree (id);


--
-- Name: ix_permissions_name; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX ix_permissions_name ON public.permissions USING btree (name);


--
-- Name: ix_permissions_resource; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_permissions_resource ON public.permissions USING btree (resource);


--
-- Name: ix_role_permissions_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_role_permissions_id ON public.role_permissions USING btree (id);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_roles_name_tenant; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX ix_roles_name_tenant ON public.roles USING btree (name, tenant_id);


--
-- Name: ix_user_roles_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_user_roles_id ON public.user_roles USING btree (id);


--
-- Name: ix_user_sessions_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_user_sessions_id ON public.user_sessions USING btree (id);


--
-- Name: ix_user_sessions_token_hash; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_user_sessions_token_hash ON public.user_sessions USING btree (token_hash);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: maheshreddy
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: attendance_logs attendance_logs_attendance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_attendance_id_fkey FOREIGN KEY (attendance_id) REFERENCES public.attendance(id);


--
-- Name: attendance_logs attendance_logs_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.attendance_sessions(id);


--
-- Name: attendance_logs attendance_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: attendance_logs attendance_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: attendance attendance_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: attendance_sessions attendance_sessions_attendance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_sessions
    ADD CONSTRAINT attendance_sessions_attendance_id_fkey FOREIGN KEY (attendance_id) REFERENCES public.attendance(id);


--
-- Name: attendance_sessions attendance_sessions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_sessions
    ADD CONSTRAINT attendance_sessions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: attendance_sessions attendance_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance_sessions
    ADD CONSTRAINT attendance_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: attendance attendance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: attendance attendance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: branches branches_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: clients clients_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: departments departments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: departments departments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: holidays holidays_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: leave_requests leave_requests_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: leave_requests leave_requests_leave_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id);


--
-- Name: leave_requests leave_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: leave_requests leave_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: leave_types leave_types_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.leave_types
    ADD CONSTRAINT leave_types_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notifications notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: policies policies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policies
    ADD CONSTRAINT policies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: policy_assignments policy_assignments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: policy_assignments policy_assignments_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: policy_assignments policy_assignments_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.policies(id);


--
-- Name: policy_assignments policy_assignments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: policy_assignments policy_assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.policy_assignments
    ADD CONSTRAINT policy_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: projects projects_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: projects projects_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: regularization_requests regularization_requests_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.regularization_requests
    ADD CONSTRAINT regularization_requests_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: regularization_requests regularization_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.regularization_requests
    ADD CONSTRAINT regularization_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: regularization_requests regularization_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.regularization_requests
    ADD CONSTRAINT regularization_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: roles roles_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: users users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: users users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: week_offs week_offs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maheshreddy
--

ALTER TABLE ONLY public.week_offs
    ADD CONSTRAINT week_offs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO maheshreddy;


--
-- PostgreSQL database dump complete
--

