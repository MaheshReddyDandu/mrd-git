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

