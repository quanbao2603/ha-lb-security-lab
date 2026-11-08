-- init-least-privilege.sql
-- Script khởi tạo quyền tối thiểu (Least Privilege) cho PostgreSQL HA Lab
-- Lưu ý: Thay thế <CHANGE_ME_AT_RUNTIME> tại thời điểm chạy thực tế, tuyệt đối không commit mật khẩu thật.
-- ponytail: single-schema static grants ceiling ~10 tables; upgrade to role-based group roles + pgbouncer when multi-service scales.

\set ON_ERROR_STOP on

-- 1. Tạo user chuyên biệt cho Streaming Replication
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'repl_user') THEN
        CREATE ROLE repl_user WITH LOGIN REPLICATION PASSWORD '<CHANGE_ME_AT_RUNTIME>' CONNECTION LIMIT 3;
    END IF;
END
$$;

-- 2. Tạo user ứng dụng (không có quyền SUPERUSER, CREATEDB, CREATEROLE, REPLICATION)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD '<CHANGE_ME_AT_RUNTIME>' CONNECTION LIMIT 50;
    END IF;
END
$$;

-- 3. Tạo database bài lab nếu chưa tồn tại (chạy qua psql ở db postgres)
SELECT 'CREATE DATABASE ha_lab_db OWNER postgres'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ha_lab_db')\gexec

\c ha_lab_db

-- 4. Thu hồi quyền mặc định của PUBLIC
REVOKE ALL ON DATABASE ha_lab_db FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE ha_lab_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;

-- 5. Tạo các bảng cần thiết cho ứng dụng Web HA Lab
CREATE TABLE IF NOT EXISTS public.health_checks (
    id BIGSERIAL PRIMARY KEY,
    node_name VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL CHECK (status IN ('OK', 'DEGRADED', 'DOWN')),
    checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.request_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    web_node VARCHAR(64) NOT NULL,
    client_ip INET NOT NULL,
    request_path VARCHAR(255) NOT NULL,
    http_status SMALLINT NOT NULL CHECK (http_status BETWEEN 100 AND 599),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Cấp quyền tối thiểu: app_user CHỈ có SELECT, INSERT, UPDATE trên các bảng cần thiết (KHÔNG có DELETE, TRUNCATE, DROP, ALTER)
REVOKE ALL ON TABLE public.health_checks, public.request_audit_logs FROM PUBLIC, app_user;
GRANT SELECT, INSERT, UPDATE ON TABLE public.health_checks, public.request_audit_logs TO app_user;
GRANT USAGE, SELECT ON SEQUENCE public.health_checks_id_seq, public.request_audit_logs_id_seq TO app_user;

-- 7. Tự động kiểm tra (Self-check assertions) bảo đảm app_user không có DELETE/SUPERUSER và có đúng SELECT/INSERT/UPDATE
DO $$
BEGIN
    ASSERT NOT (SELECT rolsuper FROM pg_roles WHERE rolname = 'app_user'), 'SECURITY FAIL: app_user must not be superuser';
    ASSERT (SELECT rolreplication FROM pg_roles WHERE rolname = 'repl_user'), 'CONFIG FAIL: repl_user must have REPLICATION privilege';
    ASSERT has_table_privilege('app_user', 'public.health_checks', 'SELECT'), 'GRANT FAIL: missing SELECT';
    ASSERT has_table_privilege('app_user', 'public.health_checks', 'INSERT'), 'GRANT FAIL: missing INSERT';
    ASSERT has_table_privilege('app_user', 'public.health_checks', 'UPDATE'), 'GRANT FAIL: missing UPDATE';
    ASSERT NOT has_table_privilege('app_user', 'public.health_checks', 'DELETE'), 'SECURITY FAIL: app_user must NOT have DELETE';
    ASSERT NOT has_table_privilege('app_user', 'public.request_audit_logs', 'DELETE'), 'SECURITY FAIL: app_user must NOT have DELETE on audit logs';
END
$$;
