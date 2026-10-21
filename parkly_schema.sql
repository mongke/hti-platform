--
-- PostgreSQL database dump
--

\restrict wkHQVmNZDHdJMdExAUXtgVOKkHmV85GO2bKSaGLP5pqzgX0scHSqOAat1XsKqOO

-- Dumped from database version 14.24 (Ubuntu 14.24-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.18 (Ubuntu 14.18-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: feedback_system; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA feedback_system;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: feedback_assignment_role; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_assignment_role AS ENUM (
    'OWNER',
    'SUPPORT',
    'VIEWER'
);


--
-- Name: feedback_comment_author_type; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_comment_author_type AS ENUM (
    'EMPLOYEE',
    'CUSTOMER',
    'SYSTEM'
);


--
-- Name: feedback_history_action_type; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_history_action_type AS ENUM (
    'CREATED',
    'STATUS_CHANGED',
    'ASSIGNEE_CHANGED',
    'COLLABORATOR_ADDED',
    'COLLABORATOR_REMOVED',
    'COMMENT_ADDED',
    'PRIORITY_CHANGED',
    'CLOSED',
    'REOPENED',
    'SOFT_DELETED',
    'RESTORED'
);


--
-- Name: feedback_issue_priority; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_issue_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


--
-- Name: feedback_issue_status; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_issue_status AS ENUM (
    'NEW',
    'WAITING',
    'IN_PROGRESS',
    'TRANSFERRED',
    'RESOLVED',
    'CLOSED'
);


--
-- Name: feedback_issue_type; Type: TYPE; Schema: feedback_system; Owner: -
--

CREATE TYPE feedback_system.feedback_issue_type AS ENUM (
    'QUESTION',
    'COMPLAINT',
    'SUGGESTION',
    'BUG',
    'FIX_REQUIRED',
    'OTHER'
);


--
-- Name: delivery_payment_mode_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_payment_mode_enum AS ENUM (
    'prepaid',
    'postpaid'
);


--
-- Name: delivery_payment_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_payment_status_enum AS ENUM (
    'pending',
    'paid',
    'failed',
    'refunded'
);


--
-- Name: delivery_payment_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_payment_type_enum AS ENUM (
    'slot',
    'usage',
    'penalty'
);


--
-- Name: delivery_registration_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_registration_type_enum AS ENUM (
    'slot',
    'payAsYouGo'
);


--
-- Name: delivery_service_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_service_type_enum AS ENUM (
    'premium',
    'enterprise'
);


--
-- Name: delivery_slot_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_slot_status_enum AS ENUM (
    'active',
    'expired',
    'cancelled',
    'pending',
    'rejected'
);


--
-- Name: delivery_slot_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_slot_type_enum AS ENUM (
    'daily',
    'weekly',
    'monthly',
    'yearly'
);


--
-- Name: delivery_usage_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_usage_status_enum AS ENUM (
    'in',
    'out',
    'completed'
);


--
-- Name: delivery_vehicle_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_vehicle_type_enum AS ENUM (
    'motorcycle',
    'car',
    'van',
    'truck'
);


--
-- Name: delivery_wallet_related_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_wallet_related_type_enum AS ENUM (
    'slot',
    'usage',
    'invoice',
    'manual'
);


--
-- Name: delivery_wallet_transaction_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_wallet_transaction_status_enum AS ENUM (
    'pending',
    'completed',
    'failed',
    'cancelled'
);


--
-- Name: delivery_wallet_transaction_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_wallet_transaction_type_enum AS ENUM (
    'deposit',
    'deduct',
    'refund',
    'penalty'
);


--
-- Name: enum_Payments_ebarimt; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Payments_ebarimt" AS ENUM (
    'B2B',
    'B2C',
    'notVat',
    'noVat'
);


--
-- Name: enum_Payments_payment_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_Payments_payment_type" AS ENUM (
    'full',
    'notPaid',
    'pending',
    'lottery',
    'split',
    'paid',
    'free'
);


--
-- Name: enum_discounts_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_discounts_type AS ENUM (
    'minut',
    'percent'
);


--
-- Name: enum_guest_payment_config_payment_responsible; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_guest_payment_config_payment_responsible AS ENUM (
    'resident',
    'guest',
    'free'
);


--
-- Name: enum_park_parkType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_park_parkType" AS ENUM (
    'Хотхон',
    'Оффис',
    'Төлбөртэй зогсоол',
    'Хүргэлт'
);


--
-- Name: enum_requests_actionType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_requests_actionType" AS ENUM (
    'add',
    'delete',
    'inActive',
    'active'
);


--
-- Name: enum_worker_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_worker_type AS ENUM (
    'Ажилтан',
    'Админ',
    'Менежер',
    'Нягтлан бодогч'
);


--
-- Name: request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_status AS ENUM (
    'pending',
    'processing',
    'success',
    'failed',
    'cancelled'
);


--
-- Name: cleanup_right_now_camera_history(interval, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cleanup_right_now_camera_history(p_retention interval DEFAULT '1 mon'::interval, p_batch_size integer DEFAULT 5000) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_deleted INTEGER := 0;
    v_batch INTEGER;
    v_cutoff TIMESTAMPTZ := NOW() - p_retention;
BEGIN
    LOOP
        DELETE FROM "right_now_camera_history"
        WHERE id IN (
            SELECT id
            FROM "right_now_camera_history"
            WHERE "archivedAt" < v_cutoff
            ORDER BY id
            LIMIT p_batch_size
        );

        GET DIAGNOSTICS v_batch = ROW_COUNT;
        v_deleted := v_deleted + v_batch;
        EXIT WHEN v_batch = 0;
    END LOOP;

    RETURN v_deleted;
END;
$$;


--
-- Name: FUNCTION cleanup_right_now_camera_history(p_retention interval, p_batch_size integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cleanup_right_now_camera_history(p_retention interval, p_batch_size integer) IS 'right_now_camera_history: archivedAt-аас хуучин мөрийг устгана (default 1 month)';


--
-- Name: get_cameras(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_cameras() RETURNS TABLE(cam_id integer, cam_branchid integer, cam_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    branch_id integer := 5;
BEGIN
    RETURN QUERY
    SELECT c."id", c."branchId", c."name"
    FROM public.camera c
    WHERE c."branchId" = branch_id;
END;
$$;


--
-- Name: get_car_esukh_data(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_car_esukh_data(_branchid integer, _parkid integer) RETURNS TABLE(id integer, platenumber text, branchid integer, parkid integer, groupid integer, status integer, address text, propertyid integer, carid2 integer, ownername text, ownerphone text, description text)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c."plateNumber"::TEXT,
    c."branchId",
    c."parkId",
    c."groupId",      
    c."status",
    e."address"::TEXT,
    e."propertyId",
    ca.id,
    ca."ownerName"::TEXT,
    ca."ownerPhone"::TEXT,
    ca."description"::TEXT
  FROM "carConfig" c
  LEFT JOIN "esukhInfo" e ON c."esukhInfoId" = e.id
  LEFT JOIN "car" ca ON c."carId" = ca.id
  WHERE c."isDeleted" = 0 
    AND c."active" = 1
    AND (_branchId IS NULL OR c."branchId" = _branchId)
    AND (_parkId IS NULL OR c."parkId" = _parkId)
  ORDER BY c.id DESC
  LIMIT 10000;
END;
$$;


--
-- Name: get_incomepaymentsummary_with_pagination(integer, integer, date, date, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_incomepaymentsummary_with_pagination(p_branch_id integer, p_park_id integer, p_start_date date, p_end_date date, p_current_page integer DEFAULT 1, p_records_per_page integer DEFAULT 20) RETURNS TABLE(plate_number text, pos_total numeric, smartpay_total numeric, cash_total numeric, total_sum numeric, visit_count bigint, total_records bigint, total_pages integer, current_page integer, has_next_page boolean, has_previous_page boolean, records_per_page integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_offset INTEGER;
    v_total_records BIGINT;
    v_total_pages INTEGER;
BEGIN
    -- Offset тооцоолох
    v_offset := (p_current_page - 1) * p_records_per_page;
    
    -- Нийт бичлэгийн тоог тооцоолох
    SELECT COUNT(DISTINCT ioh."plateNumber")
    INTO v_total_records
    FROM "inOutHistory" AS ioh
    LEFT JOIN "Payments" AS p ON ioh."inRecord_id" = p."inRecord_id"
    WHERE
        ioh."branchId" = p_branch_id
        AND ioh."parkId" = p_park_id
        AND ioh."outDate"::DATE BETWEEN p_start_date AND p_end_date
        AND p."success" = true 
        AND p."payment_type" = 'pending';
    
    -- Нийт хуудасны тоог тооцоолох
    v_total_pages := CEIL(v_total_records::NUMERIC / p_records_per_page::NUMERIC)::INTEGER;
    
    RETURN QUERY
    SELECT
        ioh."plateNumber"::TEXT as plate_number,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'pos' THEN p."paid_amount" END), 0)::NUMERIC AS pos_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'smartpay' THEN p."paid_amount" END), 0)::NUMERIC AS smartpay_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'бэлэн' THEN p."paid_amount" END), 0)::NUMERIC AS cash_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          THEN p."paid_amount" END), 0)::NUMERIC AS total_sum,
        COUNT(*)::BIGINT AS visit_count,
        v_total_records AS total_records,
        v_total_pages AS total_pages,
        p_current_page AS current_page,
        (p_current_page < v_total_pages) AS has_next_page,
        (p_current_page > 1) AS has_previous_page,
        p_records_per_page AS records_per_page
    FROM
        "inOutHistory" AS ioh
    LEFT JOIN "Payments" AS p ON ioh."inRecord_id" = p."inRecord_id"
    LEFT JOIN "PaymentOptions" AS po ON p."payment_options_id" = po."id"
    WHERE
        ioh."branchId" = p_branch_id
        AND ioh."parkId" = p_park_id
        AND ioh."outDate"::DATE BETWEEN p_start_date AND p_end_date
    GROUP BY
        ioh."plateNumber"
    ORDER BY
        total_sum DESC
    LIMIT p_records_per_page
    OFFSET v_offset;
END;
$$;


--
-- Name: get_payment_summary_totals(integer, integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_payment_summary_totals(p_branch_id integer, p_park_id integer, p_start_date date, p_end_date date) RETURNS TABLE(pos_total numeric, smartpay_total numeric, cash_total numeric, grand_total numeric, total_transactions bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'pos' THEN p."paid_amount" END), 0)::NUMERIC AS pos_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'smartpay' THEN p."paid_amount" END), 0)::NUMERIC AS smartpay_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          AND LOWER(po."name") = 'бэлэн' THEN p."paid_amount" END), 0)::NUMERIC AS cash_total,
        COALESCE(SUM(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                          THEN p."paid_amount" END), 0)::NUMERIC AS grand_total,
        COUNT(CASE WHEN p."success" = true AND p."payment_type" = 'paid' 
                   THEN 1 END)::BIGINT AS total_transactions
    FROM
        "inOutHistory" AS ioh
    LEFT JOIN "Payments" AS p ON ioh."inRecord_id" = p."inRecord_id"
    LEFT JOIN "PaymentOptions" AS po ON p."payment_options_id" = po."id"
    WHERE
        ioh."branchId" = p_branch_id
        AND ioh."parkId" = p_park_id
        AND ioh."outDate"::DATE BETWEEN p_start_date AND p_end_date;
END;
$$;


--
-- Name: update_external_integration_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_external_integration_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW."updatedAt" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


--
-- Name: update_park_car_mirror_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_park_car_mirror_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW."updatedAt" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


--
-- Name: update_router_config_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_router_config_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW."updatedAt" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: feedback_assignment_durations; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_assignment_durations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    duration_seconds integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: feedback_board_columns; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_board_columns (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    label character varying(255) NOT NULL,
    mapped_status feedback_system.feedback_issue_status NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    color character varying(20),
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_comment_attachments; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_comment_attachments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    comment_id uuid NOT NULL,
    file_name character varying(500) NOT NULL,
    original_name character varying(500) NOT NULL,
    mime_type character varying(255) NOT NULL,
    size integer NOT NULL,
    url text,
    storage_key character varying(500),
    uploaded_by_employee_id uuid,
    uploaded_by_customer_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_comments; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_comments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    author_type feedback_system.feedback_comment_author_type NOT NULL,
    employee_id uuid,
    customer_contact_id uuid,
    body text NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_customer_contacts; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_customer_contacts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    customer_organization_id uuid NOT NULL,
    full_name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(50),
    "position" character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_customer_organizations; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_customer_organizations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    registration_number character varying(100),
    email character varying(255),
    phone character varying(50),
    address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_employees; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_employees (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    external_employee_id character varying(255),
    full_name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(50),
    "position" character varying(255),
    department character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_issue_assignees; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_issue_assignees (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    assigned_by_employee_id uuid,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    unassigned_at timestamp with time zone,
    reason text,
    is_current boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_issue_collaborators; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_issue_collaborators (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    added_by_employee_id uuid,
    added_at timestamp with time zone DEFAULT now() NOT NULL,
    removed_at timestamp with time zone,
    role feedback_system.feedback_assignment_role DEFAULT 'SUPPORT'::feedback_system.feedback_assignment_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_issue_histories; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_issue_histories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    action_type feedback_system.feedback_history_action_type NOT NULL,
    actor_employee_id uuid,
    actor_customer_contact_id uuid,
    from_value text,
    to_value text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: feedback_issues; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_issues (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    ticket_number character varying(50) NOT NULL,
    title character varying(500) NOT NULL,
    description text NOT NULL,
    type feedback_system.feedback_issue_type DEFAULT 'OTHER'::feedback_system.feedback_issue_type NOT NULL,
    priority feedback_system.feedback_issue_priority DEFAULT 'MEDIUM'::feedback_system.feedback_issue_priority NOT NULL,
    status feedback_system.feedback_issue_status DEFAULT 'NEW'::feedback_system.feedback_issue_status NOT NULL,
    customer_organization_id uuid,
    customer_contact_id uuid,
    current_assignee_id uuid,
    created_by_employee_id uuid,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    due_at timestamp with time zone,
    resolved_at timestamp with time zone,
    closed_at timestamp with time zone,
    reopened_at timestamp with time zone,
    last_activity_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: feedback_status_durations; Type: TABLE; Schema: feedback_system; Owner: -
--

CREATE TABLE feedback_system.feedback_status_durations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id character varying(100) NOT NULL,
    issue_id uuid NOT NULL,
    status feedback_system.feedback_issue_status NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    duration_seconds integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: PaymentOptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentOptions" (
    id bigint NOT NULL,
    name character varying,
    icon character varying,
    active boolean,
    show boolean,
    prepaid boolean,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone
);


--
-- Name: PaymentOptions_payment_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PaymentOptions_payment_options_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PaymentOptions_payment_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PaymentOptions_payment_options_id_seq" OWNED BY public."PaymentOptions".id;


--
-- Name: Payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payments" (
    id integer NOT NULL,
    "inRecord_id" integer NOT NULL,
    pay_amount double precision NOT NULL,
    paid_amount double precision NOT NULL,
    paid_date timestamp with time zone NOT NULL,
    payment_options_id integer,
    ebarimt public."enum_Payments_ebarimt",
    success boolean DEFAULT false,
    payment_type public."enum_Payments_payment_type" NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    worker_id integer,
    branch_id integer,
    park_id integer,
    remaining_amount double precision DEFAULT 0 NOT NULL
);


--
-- Name: Payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Payments_payment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Payments_payment_id_seq" OWNED BY public."Payments".id;


--
-- Name: accessTime; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."accessTime" (
    id integer NOT NULL,
    "parkId" integer,
    "hourType" double precision,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: accessTime_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."accessTime_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accessTime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."accessTime_id_seq" OWNED BY public."accessTime".id;


--
-- Name: branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch (
    id integer NOT NULL,
    "isDeleted" boolean DEFAULT false,
    name character varying(255) NOT NULL,
    register character varying(255),
    phone1 integer,
    phone2 integer,
    address character varying(255) NOT NULL,
    province character varying(255),
    district character varying(255),
    "vatDistrict" character varying(255),
    "qpayInvoiceId" integer,
    branch_uuid uuid NOT NULL,
    "esukhBranchId" integer,
    email character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    type_id bigint
);


--
-- Name: branchExternalSystem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchExternalSystem" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "systemCode" character varying(50) NOT NULL,
    "externalBranchId" character varying(100),
    config jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE "branchExternalSystem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."branchExternalSystem" IS 'Branch болон гадаад систем хоорондын холболт';


--
-- Name: COLUMN "branchExternalSystem"."externalBranchId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchExternalSystem"."externalBranchId" IS 'Тухайн системд буй branch ID/код';


--
-- Name: COLUMN "branchExternalSystem".config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchExternalSystem".config IS 'Системд тусгай тохиргоо (apiUrl, apiKey гэх мэт)';


--
-- Name: branchExternalSystem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchExternalSystem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchExternalSystem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchExternalSystem_id_seq" OWNED BY public."branchExternalSystem".id;


--
-- Name: branch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branch_id_seq OWNED BY public.branch.id;


--
-- Name: branch_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_types (
    id integer NOT NULL,
    type_name character varying(50) NOT NULL,
    description character varying(255),
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone
);


--
-- Name: branch_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branch_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branch_types_id_seq OWNED BY public.branch_types.id;


--
-- Name: camera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camera (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    name character varying(255) NOT NULL,
    ip character varying(255),
    "user" character varying(255),
    pass character varying(255),
    "insertBody" json,
    "deleteBody" json,
    "updateBody" json,
    "getBody" json,
    "insertEndPoint" character varying(255),
    "deleteEndPoint" character varying(255),
    "updateEndPoint" character varying(255),
    "getEndPoint" character varying(255),
    "position" character varying(255),
    "cameraType" character varying(255),
    "authType" character varying(255),
    "inTime" timestamp with time zone,
    "outTime" timestamp with time zone,
    "groupCode" integer,
    "addSignature" character varying(255),
    "deleteSignature" character varying(255),
    "selectSignature" character varying(255),
    "getRecordSignature" character varying(255),
    "parkingLot" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    gate_id integer,
    access character varying DEFAULT 'public'::character varying,
    "realTime" boolean DEFAULT false NOT NULL,
    online boolean DEFAULT true NOT NULL,
    "ledDisplay" character varying,
    "templateId" integer,
    "ledNormalContent" jsonb,
    "ledPort" integer,
    "ledMirror" boolean DEFAULT false NOT NULL,
    version character varying(255)
)
WITH (autovacuum_vacuum_scale_factor='0.01', autovacuum_analyze_scale_factor='0.01', autovacuum_vacuum_cost_delay='2');


--
-- Name: COLUMN camera."ledNormalContent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera."ledNormalContent" IS 'Dahua LED idle Normal.Contents — { "row1": "...", "row2": "...", "row3": "...", "row4": "..." }';


--
-- Name: COLUMN camera."ledMirror"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera."ledMirror" IS 'true бол энэ Dahua камер LED толь (mirror) — бусад камерын LED-ийг давхар харуулна';


--
-- Name: COLUMN camera.version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera.version IS 'Камерын програм хангамжийн хувилбар';


--
-- Name: camera_health_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camera_health_log (
    id integer NOT NULL,
    "cameraId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "offlineAt" timestamp without time zone DEFAULT now() NOT NULL,
    "onlineAt" timestamp without time zone,
    "downtimeSeconds" integer,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    "isPaid" boolean DEFAULT false NOT NULL,
    "processedPlates" integer DEFAULT 0
);


--
-- Name: camera_health_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camera_health_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camera_health_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camera_health_log_id_seq OWNED BY public.camera_health_log.id;


--
-- Name: camera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camera_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camera_id_seq OWNED BY public.camera.id;


--
-- Name: camera_request_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camera_request_queue (
    id integer NOT NULL,
    plate_number character varying(50) NOT NULL,
    action_type character varying(20) NOT NULL,
    group_id integer NOT NULL,
    group_name character varying(100) NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    camera_id integer NOT NULL,
    car_config_id integer,
    request_payload jsonb NOT NULL,
    status public.request_status DEFAULT 'pending'::public.request_status NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    max_retries integer DEFAULT 5 NOT NULL,
    last_attempt_at timestamp without time zone,
    next_retry_at timestamp without time zone,
    last_error text,
    error_count integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 5 NOT NULL,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp without time zone
);


--
-- Name: TABLE camera_request_queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.camera_request_queue IS 'Камер руу баталгаатай request илгээх queue';


--
-- Name: COLUMN camera_request_queue.plate_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.plate_number IS 'Машины дугаар';


--
-- Name: COLUMN camera_request_queue.action_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.action_type IS 'Үйлдлийн төрөл: add, delete';


--
-- Name: COLUMN camera_request_queue.group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.group_id IS 'Group ID';


--
-- Name: COLUMN camera_request_queue.group_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.group_name IS 'Group нэр';


--
-- Name: COLUMN camera_request_queue.branch_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.branch_id IS 'Branch ID';


--
-- Name: COLUMN camera_request_queue.park_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.park_id IS 'Park ID';


--
-- Name: COLUMN camera_request_queue.camera_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.camera_id IS 'Camera ID';


--
-- Name: COLUMN camera_request_queue.car_config_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.car_config_id IS 'CarConfig ID';


--
-- Name: COLUMN camera_request_queue.request_payload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.request_payload IS 'Камер руу илгээх бүрэн JSON дата';


--
-- Name: COLUMN camera_request_queue.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.status IS 'Төлөв';


--
-- Name: COLUMN camera_request_queue.retry_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.retry_count IS 'Хэдэн удаа дахин оролдсон';


--
-- Name: COLUMN camera_request_queue.max_retries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.max_retries IS 'Хамгийн их retry тоо';


--
-- Name: COLUMN camera_request_queue.last_attempt_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.last_attempt_at IS 'Сүүлд оролдсон цаг';


--
-- Name: COLUMN camera_request_queue.next_retry_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.next_retry_at IS 'Дараагийн retry цаг';


--
-- Name: COLUMN camera_request_queue.last_error; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.last_error IS 'Сүүлийн алдааны мэдээлэл';


--
-- Name: COLUMN camera_request_queue.error_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.error_count IS 'Нийт алдааны тоо';


--
-- Name: COLUMN camera_request_queue.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.priority IS 'Priority (0-10, 10 хамгийн өндөр)';


--
-- Name: COLUMN camera_request_queue.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.metadata IS 'Нэмэлт мэдээлэл';


--
-- Name: COLUMN camera_request_queue.completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camera_request_queue.completed_at IS 'Дууссан цаг';


--
-- Name: camera_request_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camera_request_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camera_request_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camera_request_queue_id_seq OWNED BY public.camera_request_queue.id;


--
-- Name: camera_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camera_template (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    parkly_version character varying(255),
    camera_model_version character varying(255),
    "cameraType" character varying(255) NOT NULL,
    "authType" character varying(255) NOT NULL,
    "insertEndPoint" character varying(255),
    "deleteEndPoint" character varying(255),
    "updateEndPoint" character varying(255),
    "getEndPoint" character varying(255),
    "insertBody" jsonb,
    "deleteBody" jsonb,
    "updateBody" jsonb,
    "getBody" jsonb,
    "groupCode" integer,
    "addSignature" character varying(255),
    "deleteSignature" character varying(255),
    "selectSignature" character varying(255),
    "getRecordSignature" character varying(255),
    "createdAt" timestamp with time zone DEFAULT now(),
    "updatedAt" timestamp with time zone DEFAULT now()
);


--
-- Name: camera_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camera_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camera_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camera_template_id_seq OWNED BY public.camera_template.id;


--
-- Name: car; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.car (
    id integer NOT NULL,
    "plateNumber" character varying(15) NOT NULL,
    email character varying(255),
    "ownerName" character varying(255),
    "ownerPhone" character varying(255),
    description character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: carConfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."carConfig" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "carId" integer NOT NULL,
    "plateNumber" character varying(15) NOT NULL,
    "groupId" integer NOT NULL,
    "beginDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    date timestamp with time zone,
    "workerId" integer,
    status integer DEFAULT 0 NOT NULL,
    "esukhInfoId" integer,
    active integer,
    "isDeleted" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    description character varying(500),
    "sourceParkId" integer,
    "sourceCarConfigId" integer
);


--
-- Name: COLUMN "carConfig"."sourceParkId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."carConfig"."sourceParkId" IS 'null = native машин; утгатай = өөр park-аас mirror';


--
-- Name: COLUMN "carConfig"."sourceCarConfigId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."carConfig"."sourceCarConfigId" IS 'Primary CarConfig-ийн ID (mirror машинд байна)';


--
-- Name: carConfigExternalInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."carConfigExternalInfo" (
    id integer NOT NULL,
    "carConfigId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "systemCode" character varying(50) NOT NULL,
    "externalUserId" character varying(100),
    "externalData" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE "carConfigExternalInfo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."carConfigExternalInfo" IS 'CarConfig болон гадаад системийн хэрэглэгч мэдээлэл';


--
-- Name: COLUMN "carConfigExternalInfo"."externalUserId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."carConfigExternalInfo"."externalUserId" IS 'Тухайн системд буй хэрэглэгчийн ID';


--
-- Name: COLUMN "carConfigExternalInfo"."externalData"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."carConfigExternalInfo"."externalData" IS 'Гадаад системийн нэмэлт өгөгдөл (нэр, хаяг, нэгж гэх мэт)';


--
-- Name: carConfigExternalInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."carConfigExternalInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carConfigExternalInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."carConfigExternalInfo_id_seq" OWNED BY public."carConfigExternalInfo".id;


--
-- Name: carConfig_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."carConfig_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."carConfig_id_seq" OWNED BY public."carConfig".id;


--
-- Name: car_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.car_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: car_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.car_id_seq OWNED BY public.car.id;


--
-- Name: childParkHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."childParkHistory" (
    id bigint NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "parent_inRecord_id" integer NOT NULL,
    "child_outHistory_id" integer NOT NULL,
    "parkedTimeMinut" integer NOT NULL,
    "paidSuccess" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: childParkHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."childParkHistory_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: childParkHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."childParkHistory_id_seq" OWNED BY public."childParkHistory".id;


--
-- Name: compare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compare (
    compare_id bigint NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    "carConfig_id" integer,
    device character varying(15) NOT NULL,
    type text NOT NULL,
    "plateNumber" character varying(50) NOT NULL,
    owner text,
    success integer DEFAULT 0,
    "beginDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "createdAt" timestamp with time zone
);


--
-- Name: COLUMN compare.device; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.compare.device IS 'parkly  эсвэл camera

parkly  Байвал carconfig дээр байгаа хэрнээ 
Camera дээр байхгүй


camera Байвал camera дээр байгаа хэрнээ 
carConfig дээр байхгүй


';


--
-- Name: COLUMN compare.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.compare.type IS 'нэмэх ба хасах

эсвэл 
хугацаа нь дууссан camera дээр байгаа устаагүй үлдсэн

Front дээр хугацаа дусаагүй гэж харуулах
Front дээр нэмэх үү  ба хасах уу гэж харуулах';


--
-- Name: compareProcess; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."compareProcess" (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    process character varying(255) NOT NULL,
    branch_active integer NOT NULL,
    "beginDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone,
    "actionType" character varying
);


--
-- Name: compareProcess_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."compareProcess_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compareProcess_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."compareProcess_id_seq" OWNED BY public."compareProcess".id;


--
-- Name: compare_compare_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.compare_compare_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compare_compare_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.compare_compare_id_seq OWNED BY public.compare.compare_id;


--
-- Name: conflict_exit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conflict_exit_log (
    id integer NOT NULL,
    plate_number character varying(255) NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    camera_id integer,
    original_in_record_id integer NOT NULL,
    original_in_date timestamp with time zone NOT NULL,
    original_in_image_name character varying(255),
    conflict_detected_at timestamp with time zone NOT NULL,
    new_in_record_id integer NOT NULL,
    auto_exit_history_id integer NOT NULL,
    conflict_group_id integer,
    conflict_group_name character varying(255),
    parking_duration_minutes integer DEFAULT 0 NOT NULL,
    resolved_by character varying(20) DEFAULT 'system'::character varying NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT conflict_exit_log_resolved_by_check CHECK (((resolved_by)::text = ANY ((ARRAY['system'::character varying, 'manual'::character varying])::text[])))
);


--
-- Name: conflict_exit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conflict_exit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conflict_exit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conflict_exit_log_id_seq OWNED BY public.conflict_exit_log.id;


--
-- Name: delivery_branch_park; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_branch_park (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE delivery_branch_park; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_branch_park IS 'Delivery organization allowed parks (when allow_all_parks = false)';


--
-- Name: delivery_branch_park_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_branch_park_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_branch_park_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_branch_park_id_seq OWNED BY public.delivery_branch_park.id;


--
-- Name: delivery_branch_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_branch_settings (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    service_type public.delivery_service_type_enum DEFAULT 'premium'::public.delivery_service_type_enum NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_approved boolean DEFAULT false NOT NULL,
    approved_at timestamp without time zone,
    approved_by integer,
    monthly_slot_price numeric(10,2),
    usage_price numeric(10,2),
    payment_mode public.delivery_payment_mode_enum DEFAULT 'prepaid'::public.delivery_payment_mode_enum NOT NULL,
    wallet_balance numeric(12,2) DEFAULT 0 NOT NULL,
    credit_limit numeric(12,2) DEFAULT 0 NOT NULL,
    is_credit_blocked boolean DEFAULT false NOT NULL,
    auto_recharge boolean DEFAULT false NOT NULL,
    recharge_threshold numeric(10,2),
    recharge_amount numeric(10,2),
    total_vehicles integer DEFAULT 0 NOT NULL,
    active_vehicles integer DEFAULT 0 NOT NULL,
    total_revenue numeric(15,2) DEFAULT 0 NOT NULL,
    last_usage_date timestamp without time zone,
    description text,
    notes text,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    allow_all_parks boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE delivery_branch_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_branch_settings IS 'Салбарын delivery үйлчилгээний тохиргоо (One-to-One)';


--
-- Name: COLUMN delivery_branch_settings.branch_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_branch_settings.branch_id IS 'Холбогдсон салбар (One-to-One)';


--
-- Name: COLUMN delivery_branch_settings.allow_all_parks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_branch_settings.allow_all_parks IS 'TRUE = all parks with public cameras; FALSE = only parks listed in delivery_branch_park';


--
-- Name: delivery_branch_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_branch_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_branch_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_branch_settings_id_seq OWNED BY public.delivery_branch_settings.id;


--
-- Name: delivery_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_payment (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    usage_id integer,
    slot_id integer,
    payment_type public.delivery_payment_type_enum NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_option_id integer NOT NULL,
    transaction_id character varying(100),
    paid_date timestamp without time zone DEFAULT now() NOT NULL,
    paid_by integer,
    status public.delivery_payment_status_enum DEFAULT 'paid'::public.delivery_payment_status_enum NOT NULL,
    notes text,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT valid_amount CHECK ((amount >= (0)::numeric))
);


--
-- Name: TABLE delivery_payment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_payment IS 'Төлбөрийн бүртгэл';


--
-- Name: delivery_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_payment_id_seq OWNED BY public.delivery_payment.id;


--
-- Name: delivery_pricing_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_pricing_config (
    id integer NOT NULL,
    config_key character varying(50) NOT NULL,
    config_value numeric(10,2) NOT NULL,
    description text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    updated_by integer,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT config_key_format CHECK (((config_key)::text ~ '^[a-z_]+$'::text))
);


--
-- Name: TABLE delivery_pricing_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_pricing_config IS 'Delivery системийн үнийн тохиргоо (admin засварладаг)';


--
-- Name: COLUMN delivery_pricing_config.config_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_pricing_config.config_key IS 'Тохиргооны түлхүүр (monthly_slot_price, usage_price)';


--
-- Name: COLUMN delivery_pricing_config.config_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_pricing_config.config_value IS 'Үнийн дүн (₮)';


--
-- Name: COLUMN delivery_pricing_config.sort_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_pricing_config.sort_order IS 'Эрэмбэлэх дараалал';


--
-- Name: delivery_pricing_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_pricing_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_pricing_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_pricing_config_id_seq OWNED BY public.delivery_pricing_config.id;


--
-- Name: delivery_slot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_slot (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    slot_type public.delivery_slot_type_enum DEFAULT 'monthly'::public.delivery_slot_type_enum NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    applied_price numeric(10,2) DEFAULT 0 NOT NULL,
    is_paid boolean DEFAULT false NOT NULL,
    payment_id integer,
    status public.delivery_slot_status_enum DEFAULT 'active'::public.delivery_slot_status_enum NOT NULL,
    max_vehicles integer DEFAULT 1 NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT valid_date_range CHECK ((end_date > start_date)),
    CONSTRAINT valid_max_vehicles CHECK ((max_vehicles > 0))
);


--
-- Name: TABLE delivery_slot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_slot IS 'Слот худалдан авалт (1 Slot → Many Vehicles via DeliveryVehicle.current_slot_id)';


--
-- Name: COLUMN delivery_slot.max_vehicles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_slot.max_vehicles IS 'Хэдэн машин бүртгэж болох (Premium: 1)';


--
-- Name: delivery_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_slot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_slot_id_seq OWNED BY public.delivery_slot.id;


--
-- Name: delivery_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_usage (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    plate_number character varying(20) NOT NULL,
    in_date timestamp without time zone NOT NULL,
    out_date timestamp without time zone,
    in_worker_id integer,
    out_worker_id integer,
    in_camera_id integer,
    out_camera_id integer,
    duration integer,
    fee numeric(10,2) DEFAULT 0,
    applied_price numeric(10,2) DEFAULT 0 NOT NULL,
    is_paid boolean DEFAULT false NOT NULL,
    payment_id integer,
    has_active_slot boolean DEFAULT false NOT NULL,
    slot_id integer,
    status public.delivery_usage_status_enum DEFAULT 'in'::public.delivery_usage_status_enum NOT NULL,
    is_invoiced boolean DEFAULT false NOT NULL,
    invoice_id integer,
    notes text,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT valid_out_date CHECK (((out_date IS NULL) OR (out_date > in_date)))
);


--
-- Name: TABLE delivery_usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_usage IS 'Машины орох/гарах бүртгэл';


--
-- Name: delivery_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_usage_id_seq OWNED BY public.delivery_usage.id;


--
-- Name: delivery_vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_vehicle (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    plate_number character varying(20) NOT NULL,
    driver_name character varying(100),
    driver_phone character varying(20),
    vehicle_type public.delivery_vehicle_type_enum DEFAULT 'motorcycle'::public.delivery_vehicle_type_enum NOT NULL,
    registration_type public.delivery_registration_type_enum DEFAULT 'payAsYouGo'::public.delivery_registration_type_enum NOT NULL,
    current_slot_id integer,
    custom_slot_price numeric(10,2),
    custom_usage_price numeric(10,2),
    is_active boolean DEFAULT true NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT plate_number_format CHECK (((plate_number)::text ~ '^[A-Z0-9А-ЯЁӨҮа-яёөү]{4,10}$'::text))
);


--
-- Name: TABLE delivery_vehicle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_vehicle IS 'Хүргэлтийн машины бүртгэл';


--
-- Name: COLUMN delivery_vehicle.current_slot_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_vehicle.current_slot_id IS 'Одоогийн идэвхтэй слот (nullable - payAsYouGo машинд байхгүй)';


--
-- Name: CONSTRAINT plate_number_format ON delivery_vehicle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT plate_number_format ON public.delivery_vehicle IS 'Монгол дугаар: латин/тоо + кирилл (Ө, Ү орно), 4–10 тэмдэгт';


--
-- Name: delivery_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_vehicle_id_seq OWNED BY public.delivery_vehicle.id;


--
-- Name: delivery_wallet_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_wallet_transaction (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    type public.delivery_wallet_transaction_type_enum NOT NULL,
    amount numeric(12,2) NOT NULL,
    balance_before numeric(12,2) NOT NULL,
    balance_after numeric(12,2) NOT NULL,
    related_type public.delivery_wallet_related_type_enum,
    related_id integer,
    description text NOT NULL,
    payment_method character varying(50),
    transaction_id character varying(255),
    invoice_number character varying(50),
    created_by integer,
    approved_by integer,
    status public.delivery_wallet_transaction_status_enum DEFAULT 'completed'::public.delivery_wallet_transaction_status_enum NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT valid_amount CHECK ((amount >= (0)::numeric)),
    CONSTRAINT valid_balance CHECK ((balance_after >= (0)::numeric))
);


--
-- Name: TABLE delivery_wallet_transaction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.delivery_wallet_transaction IS 'Wallet гүйлгээний түүх (audit trail)';


--
-- Name: COLUMN delivery_wallet_transaction.related_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_wallet_transaction.related_type IS 'Холбогдох entity төрөл';


--
-- Name: COLUMN delivery_wallet_transaction.related_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_wallet_transaction.related_id IS 'Холбогдох entity ID';


--
-- Name: delivery_wallet_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_wallet_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_wallet_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_wallet_transaction_id_seq OWNED BY public.delivery_wallet_transaction.id;


--
-- Name: discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discounts (
    id bigint NOT NULL,
    name character varying,
    type character varying,
    value integer,
    main boolean,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone,
    variable json,
    formula character varying
);


--
-- Name: discount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discount_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discount_id_seq OWNED BY public.discounts.id;


--
-- Name: esukhInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."esukhInfo" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "townId" integer,
    "apartmentId" integer,
    "propertyId" integer,
    address character varying(50) NOT NULL,
    "userId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "companyId" integer
);


--
-- Name: COLUMN "esukhInfo"."companyId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."esukhInfo"."companyId" IS 'Optional company id from createByPlateNumber; no FK';


--
-- Name: esukhInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."esukhInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: esukhInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."esukhInfo_id_seq" OWNED BY public."esukhInfo".id;


--
-- Name: externalSystem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."externalSystem" (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dataSchema" jsonb,
    "apiUsername" character varying(100),
    "apiPasswordHash" character varying(255)
);


--
-- Name: TABLE "externalSystem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."externalSystem" IS 'Холбогдох гадаад системүүдийн бүртгэл';


--
-- Name: COLUMN "externalSystem".code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."externalSystem".code IS 'Системийн код: ESUKH, ODYSSEY, OASIS, CUSTOM...';


--
-- Name: COLUMN "externalSystem"."dataSchema"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."externalSystem"."dataSchema" IS 'externalData field schema (fields[])';


--
-- Name: COLUMN "externalSystem"."apiUsername"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."externalSystem"."apiUsername" IS 'Гадаад системийн API нэвтрэх нэр';


--
-- Name: COLUMN "externalSystem"."apiPasswordHash"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."externalSystem"."apiPasswordHash" IS 'bcrypt hash — API нууц үг';


--
-- Name: externalSystem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."externalSystem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: externalSystem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."externalSystem_id_seq" OWNED BY public."externalSystem".id;


--
-- Name: gate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gate (
    id integer NOT NULL,
    name character varying(255),
    "branchId" character varying(255),
    "parkId" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "desc" character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: gate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gate_id_seq OWNED BY public.gate.id;


--
-- Name: group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."group" (
    id integer NOT NULL,
    name character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    type character varying(255),
    icon character varying(255)
);


--
-- Name: groupDiscount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."groupDiscount" (
    id bigint NOT NULL,
    "groupId" integer,
    "discountId" integer,
    formula character varying,
    "branchId" integer,
    "parkId" integer,
    sort integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "startDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    variable jsonb,
    "discountName" character varying
);


--
-- Name: groupDiscount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."groupDiscount_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groupDiscount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."groupDiscount_id_seq" OWNED BY public."groupDiscount".id;


--
-- Name: group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_id_seq OWNED BY public."group".id;


--
-- Name: guest_payment_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_payment_config (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    guest_car_config_id integer NOT NULL,
    resident_user_id integer NOT NULL,
    payment_responsible character varying(20) DEFAULT 'guest'::character varying NOT NULL,
    allow_prepayment boolean DEFAULT true NOT NULL,
    allow_postpayment boolean DEFAULT false NOT NULL,
    notify_overtime boolean DEFAULT true NOT NULL,
    overtime_grace_minutes integer DEFAULT 15 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    idempotency_key character varying(64),
    CONSTRAINT guest_payment_config_payment_responsible_check CHECK (((payment_responsible)::text = ANY ((ARRAY['resident'::character varying, 'guest'::character varying])::text[])))
);


--
-- Name: TABLE guest_payment_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.guest_payment_config IS 'Зочны төлбөрийн тохиргоо - оршин суугч зочин урьсан тохиолдолд';


--
-- Name: COLUMN guest_payment_config.guest_car_config_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.guest_car_config_id IS 'Зочны CarConfig ID (beginDate, endDate-тай)';


--
-- Name: COLUMN guest_payment_config.resident_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.resident_user_id IS 'Зочин урьсан оршин суугчийн user ID';


--
-- Name: COLUMN guest_payment_config.payment_responsible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.payment_responsible IS 'Хэн төлбөр төлөх вэ (resident/guest)';


--
-- Name: COLUMN guest_payment_config.allow_prepayment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.allow_prepayment IS 'Урьдчилж төлөх боломжтой эсэх';


--
-- Name: COLUMN guest_payment_config.allow_postpayment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.allow_postpayment IS 'Дараа төлөх боломжтой эсэх (оршин суугч хожим төлнө)';


--
-- Name: COLUMN guest_payment_config.notify_overtime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.notify_overtime IS 'Хугацаа хэтрэхэд SMA notification илгээх эсэх';


--
-- Name: COLUMN guest_payment_config.overtime_grace_minutes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.guest_payment_config.overtime_grace_minutes IS 'Хугацаа хэтрэснээс хойш хэдэн минутын дараа төлбөр тооцох';


--
-- Name: guest_payment_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_payment_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_payment_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_payment_config_id_seq OWNED BY public.guest_payment_config.id;


--
-- Name: inLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."inLog" (
    id integer NOT NULL,
    "plateNumber" character varying(255) NOT NULL,
    "regDate" timestamp with time zone NOT NULL,
    json character varying(255) NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: inLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."inLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."inLog_id_seq" OWNED BY public."inLog".id;


--
-- Name: inOutHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."inOutHistory" (
    id integer NOT NULL,
    "branchId" integer,
    "cameraId" integer,
    "parkId" integer,
    "inRecordNo" integer,
    "outRecordNo" integer,
    "carId" integer,
    "plateNumber" character varying(15) NOT NULL,
    "inImageName" character varying(100),
    "outImageName" character varying(100),
    "inDate" timestamp with time zone,
    "outDate" timestamp with time zone,
    "carConfigId" integer,
    "parkTime" integer,
    "payAmount" integer,
    "workerId" integer,
    status character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "inRecord_id" integer,
    formula character varying,
    "groupId" integer,
    "esukhInfoId" integer,
    "groupId_desc" character varying(255)
);


--
-- Name: inOutHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."inOutHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inOutHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."inOutHistory_id_seq" OWNED BY public."inOutHistory".id;


--
-- Name: inRecord; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."inRecord" (
    id integer NOT NULL,
    "branchId" integer,
    "cameraId" integer,
    "parkId" integer,
    formula character varying(500),
    "carId" integer,
    "plateNumber" character varying(15) NOT NULL,
    "inDate" timestamp with time zone NOT NULL,
    "inImageName" character varying(100),
    "carConfigId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "groupId" integer
);


--
-- Name: inRecord_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."inRecord_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inRecord_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."inRecord_id_seq" OWNED BY public."inRecord".id;


--
-- Name: logger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logger (
    id integer NOT NULL,
    "workerId" integer,
    "branchId" integer,
    "parkId" integer,
    method character varying(30),
    status integer,
    response_body character varying(500),
    endpoint character varying(255),
    "tableId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "actionText" character varying(1500),
    "actionDate" timestamp with time zone,
    "esukhInfoId" integer,
    "plateNumber" character varying(15),
    "esukhWorkerId" integer,
    "esukhBranchId" integer,
    "cameraId" integer
);


--
-- Name: logger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logger_id_seq OWNED BY public.logger.id;


--
-- Name: merchant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant (
    id integer NOT NULL,
    name character varying NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    token character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone
);


--
-- Name: merchant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merchant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merchant_id_seq OWNED BY public.merchant.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.models (
    "workerId" integer NOT NULL,
    "WorkerId" integer NOT NULL
);


--
-- Name: overtime_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overtime_payment (
    id integer NOT NULL,
    in_record_id integer NOT NULL,
    branch_id integer NOT NULL,
    park_id integer NOT NULL,
    guest_car_config_id integer NOT NULL,
    guest_payment_config_id integer,
    overtime_start timestamp with time zone NOT NULL,
    overtime_end timestamp with time zone,
    overtime_minutes integer DEFAULT 0 NOT NULL,
    calculated_amount double precision DEFAULT 0 NOT NULL,
    paid_amount double precision DEFAULT 0 NOT NULL,
    payment_status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    payment_method character varying(20),
    payment_id integer,
    notification_sent boolean DEFAULT false NOT NULL,
    notification_sent_at timestamp with time zone,
    paid_by character varying(20),
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT overtime_payment_paid_by_check CHECK (((paid_by)::text = ANY ((ARRAY['resident'::character varying, 'guest'::character varying])::text[]))),
    CONSTRAINT overtime_payment_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['prepaid'::character varying, 'on_exit'::character varying, 'postpaid'::character varying])::text[]))),
    CONSTRAINT overtime_payment_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['pending'::character varying, 'notified'::character varying, 'paid'::character varying, 'cancelled'::character varying, 'waived'::character varying])::text[])))
);


--
-- Name: TABLE overtime_payment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.overtime_payment IS 'Зочны хугацаа хэтэрсэн төлбөрийн өр';


--
-- Name: COLUMN overtime_payment.in_record_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.in_record_id IS 'InRecord ID';


--
-- Name: COLUMN overtime_payment.guest_car_config_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.guest_car_config_id IS 'Зочны CarConfig ID (groupId нь зочны group)';


--
-- Name: COLUMN overtime_payment.overtime_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.overtime_start IS 'Хугацаа хэтрэх эхлэл (carConfig.endDate)';


--
-- Name: COLUMN overtime_payment.overtime_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.overtime_end IS 'Хугацаа хэтрэх төгсгөл (гарсан цаг)';


--
-- Name: COLUMN overtime_payment.overtime_minutes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.overtime_minutes IS 'Хэдэн минут хугацаа хэтэрсэн';


--
-- Name: COLUMN overtime_payment.calculated_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.calculated_amount IS 'Тооцсон төлбөрийн дүн';


--
-- Name: COLUMN overtime_payment.paid_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.paid_amount IS 'Төлсөн дүн';


--
-- Name: COLUMN overtime_payment.payment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.payment_status IS 'pending: хүлээгдэж буй, notified: мэдэгдэл явуулсан, paid: төлсөн, cancelled: цуцлагдсан, waived: чөлөөлөгдсөн';


--
-- Name: COLUMN overtime_payment.payment_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.payment_method IS 'prepaid: урьдчилж, on_exit: гарахад, postpaid: дараа';


--
-- Name: COLUMN overtime_payment.payment_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.payment_id IS 'Payments table руу холбох';


--
-- Name: COLUMN overtime_payment.notification_sent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.notification_sent IS 'SMA notification илгээсэн эсэх';


--
-- Name: COLUMN overtime_payment.notification_sent_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.notification_sent_at IS 'Мэдэгдэл илгээсэн цаг';


--
-- Name: COLUMN overtime_payment.paid_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.overtime_payment.paid_by IS 'Хэн төлбөр төлсөн (resident/guest)';


--
-- Name: overtime_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.overtime_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: overtime_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.overtime_payment_id_seq OWNED BY public.overtime_payment.id;


--
-- Name: paidInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."paidInfo" (
    id bigint NOT NULL,
    "secureId" character varying NOT NULL,
    "inRecord_id" bigint NOT NULL,
    status character varying NOT NULL,
    "paymentMethod" character varying NOT NULL,
    amount character varying,
    payment_id integer,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone,
    "invoiceId" character varying,
    "responseData" jsonb
);


--
-- Name: paidInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."paidInfo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paidInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."paidInfo_id_seq" OWNED BY public."paidInfo".id;


--
-- Name: park; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.park (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkType" public."enum_park_parkType" NOT NULL,
    "parkName" character varying(255) NOT NULL,
    location character varying(255),
    "isPaid" boolean DEFAULT true,
    fee integer,
    "parkingSpaces" integer,
    "numberRecog" boolean DEFAULT true,
    type character varying(255),
    bank character varying(255),
    "accountNumber" character varying(20),
    "accountHolder" character varying(255),
    "workerId" integer,
    park_uuid uuid NOT NULL,
    formula character varying(500),
    "isDeleted" integer DEFAULT 0,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "penaliseFee" integer,
    vat boolean,
    "parentOrChild" character varying(255),
    "parentParkId" integer,
    register character varying,
    "sortOrder" integer DEFAULT 0 NOT NULL
);


--
-- Name: parkAccessConfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."parkAccessConfig" (
    id integer NOT NULL,
    "parkId" integer,
    "permaCar" integer DEFAULT 0,
    "tempCar" integer DEFAULT 0,
    "permaLimit" integer,
    "tempLimit" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "permaAANCar" integer,
    "permaAANLimit" integer,
    "tempAANCar" integer,
    "tempAANLimit" integer
);


--
-- Name: parkAccessConfig_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."parkAccessConfig_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parkAccessConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."parkAccessConfig_id_seq" OWNED BY public."parkAccessConfig".id;


--
-- Name: parkCarMirror; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."parkCarMirror" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "sourceParkId" integer NOT NULL,
    "targetParkId" integer NOT NULL,
    "targetGroupId" integer,
    "isActive" boolean DEFAULT true NOT NULL,
    "isDeleted" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "chk_parkCarMirror_no_self" CHECK (("sourceParkId" <> "targetParkId"))
);


--
-- Name: TABLE "parkCarMirror"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."parkCarMirror" IS 'Park түвшний нэг чиглэлийн machine mirror тохиргоо (source → target)';


--
-- Name: COLUMN "parkCarMirror"."sourceParkId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."parkCarMirror"."sourceParkId" IS 'Энд машин нэмэхэд mirror эхэлнэ';


--
-- Name: COLUMN "parkCarMirror"."targetParkId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."parkCarMirror"."targetParkId" IS 'Давхар нэмэгдэх park';


--
-- Name: COLUMN "parkCarMirror"."targetGroupId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."parkCarMirror"."targetGroupId" IS 'Target park дээрх group (null бол source groupId ашиглана)';


--
-- Name: parkCarMirror_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."parkCarMirror_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parkCarMirror_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."parkCarMirror_id_seq" OWNED BY public."parkCarMirror".id;


--
-- Name: parkFee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."parkFee" (
    id bigint NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "groupId" integer NOT NULL,
    formula character varying,
    "validPeriod" json,
    "calcRules" json,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone
);


--
-- Name: parkFee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."parkFee_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parkFee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."parkFee_id_seq" OWNED BY public."parkFee".id;


--
-- Name: parkLocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."parkLocation" (
    id integer NOT NULL,
    "parkId" integer NOT NULL,
    "regionId" integer NOT NULL,
    "regionName" character varying(255) NOT NULL,
    "districtId" integer,
    "districtName" character varying(255),
    "subDistrictId" integer,
    "subDistrictName" character varying(255),
    "streetId" integer,
    "streetName" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    coordinates jsonb
);


--
-- Name: parkLocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."parkLocations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parkLocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."parkLocations_id_seq" OWNED BY public."parkLocation".id;


--
-- Name: park_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.park_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: park_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.park_id_seq OWNED BY public.park.id;


--
-- Name: qrCodeController; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."qrCodeController" (
    id bigint NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "cameraId" integer NOT NULL,
    count integer,
    "defaultLink" character varying NOT NULL,
    "mainLink" character varying NOT NULL,
    "updatedAt" timestamp without time zone,
    "createdAt" timestamp without time zone
);


--
-- Name: qrCodeContoroller_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."qrCodeContoroller_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qrCodeContoroller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."qrCodeContoroller_id_seq" OWNED BY public."qrCodeController".id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requests (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "carConfigId" integer,
    "actionType" public."enum_requests_actionType",
    address text NOT NULL,
    success integer DEFAULT 0 NOT NULL,
    "regDate" timestamp with time zone NOT NULL,
    "actionDate" timestamp with time zone,
    uuid character varying(100),
    "cameraId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requests_id_seq OWNED BY public.requests.id;


--
-- Name: rightNowCamera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."rightNowCamera" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "cameraId" integer NOT NULL,
    "inRecord_id" integer,
    "plateNumber" character varying(255) NOT NULL,
    "imageName" character varying(255),
    "updatedAt" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    gate_id integer,
    "outDate" timestamp with time zone
);


--
-- Name: rightNowCamera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."rightNowCamera_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rightNowCamera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."rightNowCamera_id_seq" OWNED BY public."rightNowCamera".id;


--
-- Name: right_now_camera_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.right_now_camera_history (
    id integer NOT NULL,
    "rightNowCameraId" integer,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "cameraId" integer NOT NULL,
    gate_id integer,
    "inRecord_id" integer,
    "plateNumber" character varying(255) NOT NULL,
    "imageName" character varying(255),
    "outDate" timestamp with time zone,
    action character varying(20) NOT NULL,
    source character varying(100) NOT NULL,
    "originalCreatedAt" timestamp with time zone,
    "originalUpdatedAt" timestamp with time zone,
    "archivedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT right_now_camera_history_action_check CHECK (((action)::text = ANY ((ARRAY['detect'::character varying, 'create'::character varying, 'update'::character varying, 'delete'::character varying])::text[])))
);


--
-- Name: TABLE right_now_camera_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.right_now_camera_history IS 'Хаалт дээр ирсэн дугаарын түүх (detect) болон rightNowCamera create/update/delete архив. Retention: 1 сар (ANK-9c cleanup).';


--
-- Name: COLUMN right_now_camera_history."rightNowCameraId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.right_now_camera_history."rightNowCameraId" IS 'rightNowCamera хүснэгтийн анхны id';


--
-- Name: COLUMN right_now_camera_history."inRecord_id"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.right_now_camera_history."inRecord_id" IS 'Холбоотой inRecord id (байхгүй бол null)';


--
-- Name: COLUMN right_now_camera_history.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.right_now_camera_history.action IS 'detect | create | update | delete';


--
-- Name: COLUMN right_now_camera_history.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.right_now_camera_history.source IS 'Түүхийг хадгалсан кодын байршил';


--
-- Name: right_now_camera_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.right_now_camera_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: right_now_camera_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.right_now_camera_history_id_seq OWNED BY public.right_now_camera_history.id;


--
-- Name: routerConfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."routerConfig" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "routerIp" character varying(45),
    "routerPass" character varying(255),
    "anydeskId" character varying(100),
    "anydeskPass" character varying(255),
    "wifiPassword" character varying(255),
    "externalIpBillingType" character varying(20) DEFAULT 'company_paid'::character varying NOT NULL,
    "extraConfig" jsonb,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "routerUser" character varying(100),
    CONSTRAINT "chk_routerConfig_billing_type" CHECK ((("externalIpBillingType")::text = ANY ((ARRAY['company_paid'::character varying, 'self_paid'::character varying])::text[])))
);


--
-- Name: TABLE "routerConfig"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."routerConfig" IS 'Branch/park түвшний router болон сүлжээний тохиргоо';


--
-- Name: COLUMN "routerConfig"."externalIpBillingType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."routerConfig"."externalIpBillingType" IS 'company_paid = манайхаар төлнө, self_paid = өөрсдөө төлнө';


--
-- Name: COLUMN "routerConfig"."extraConfig"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."routerConfig"."extraConfig" IS 'mask, gateway, primaryDns, secondaryDns, notes';


--
-- Name: routerConfig_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."routerConfig_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routerConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."routerConfig_id_seq" OWNED BY public."routerConfig".id;


--
-- Name: signupRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signupRequest" (
    id integer NOT NULL,
    location character varying(255) NOT NULL,
    capacity integer NOT NULL,
    phone character varying(20) NOT NULL,
    "adminId" integer,
    success boolean DEFAULT false NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "isDuplicated" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    type character varying
);


--
-- Name: signupRequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."signupRequest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signupRequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."signupRequest_id_seq" OWNED BY public."signupRequest".id;


--
-- Name: spayCheckLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."spayCheckLog" (
    id integer NOT NULL,
    "secureId" character varying(255),
    "inRecord_id" integer,
    option_id integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "reportError" character varying(255)
);


--
-- Name: spayCheckLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."spayCheckLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spayCheckLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."spayCheckLog_id_seq" OWNED BY public."spayCheckLog".id;


--
-- Name: system_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_admin (
    id bigint NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    "branchId" integer NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    permission jsonb
);


--
-- Name: system_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_admin_id_seq OWNED BY public.system_admin.id;


--
-- Name: tableName; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."tableName" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: tableName_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."tableName_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tableName_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."tableName_id_seq" OWNED BY public."tableName".id;


--
-- Name: v_camera_request_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_camera_request_stats AS
 SELECT camera_request_queue.branch_id,
    camera_request_queue.status,
    count(*) AS total,
    avg(camera_request_queue.retry_count) AS avg_retries,
    sum(
        CASE
            WHEN (camera_request_queue.error_count > 0) THEN 1
            ELSE 0
        END) AS errored_requests
   FROM public.camera_request_queue
  GROUP BY camera_request_queue.branch_id, camera_request_queue.status;


--
-- Name: vatInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."vatInfo" (
    id bigint NOT NULL,
    "vatId" character varying NOT NULL,
    "inRecord_id" integer,
    payment_id integer,
    "qrJson" json,
    "updatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone
);


--
-- Name: vatInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."vatInfo_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vatInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."vatInfo_id_seq" OWNED BY public."vatInfo".id;


--
-- Name: worker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker (
    id integer NOT NULL,
    "isDeleted" integer DEFAULT 0,
    "branchId" integer,
    name character varying(255),
    "lastName" character varying(255),
    gender character varying(10),
    email character varying(255),
    image text,
    "loginName" character varying(255),
    "loginPass" character varying(255),
    "mobileToken" text,
    phone1 character varying(20),
    phone2 character varying(20),
    address character varying(255),
    "regDate" timestamp with time zone NOT NULL,
    "regWorkerId" integer,
    "verificationCode" character varying(4),
    "isVerified" boolean DEFAULT false,
    type public.enum_worker_type DEFAULT 'Ажилтан'::public.enum_worker_type,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    permission jsonb,
    "otherSystemWorkerId" bigint,
    domain character varying
);


--
-- Name: workerPark; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."workerPark" (
    id integer NOT NULL,
    "workerId" integer NOT NULL,
    "parkId" integer NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "cameraId" integer
);


--
-- Name: workerPark_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."workerPark_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workerPark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."workerPark_id_seq" OWNED BY public."workerPark".id;


--
-- Name: worker_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_id_seq OWNED BY public.worker.id;


--
-- Name: PaymentOptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentOptions" ALTER COLUMN id SET DEFAULT nextval('public."PaymentOptions_payment_options_id_seq"'::regclass);


--
-- Name: Payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payments" ALTER COLUMN id SET DEFAULT nextval('public."Payments_payment_id_seq"'::regclass);


--
-- Name: accessTime id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accessTime" ALTER COLUMN id SET DEFAULT nextval('public."accessTime_id_seq"'::regclass);


--
-- Name: branch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch ALTER COLUMN id SET DEFAULT nextval('public.branch_id_seq'::regclass);


--
-- Name: branchExternalSystem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchExternalSystem" ALTER COLUMN id SET DEFAULT nextval('public."branchExternalSystem_id_seq"'::regclass);


--
-- Name: branch_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_types ALTER COLUMN id SET DEFAULT nextval('public.branch_types_id_seq'::regclass);


--
-- Name: camera id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera ALTER COLUMN id SET DEFAULT nextval('public.camera_id_seq'::regclass);


--
-- Name: camera_health_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_health_log ALTER COLUMN id SET DEFAULT nextval('public.camera_health_log_id_seq'::regclass);


--
-- Name: camera_request_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_request_queue ALTER COLUMN id SET DEFAULT nextval('public.camera_request_queue_id_seq'::regclass);


--
-- Name: camera_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_template ALTER COLUMN id SET DEFAULT nextval('public.camera_template_id_seq'::regclass);


--
-- Name: car id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car ALTER COLUMN id SET DEFAULT nextval('public.car_id_seq'::regclass);


--
-- Name: carConfig id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig" ALTER COLUMN id SET DEFAULT nextval('public."carConfig_id_seq"'::regclass);


--
-- Name: carConfigExternalInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfigExternalInfo" ALTER COLUMN id SET DEFAULT nextval('public."carConfigExternalInfo_id_seq"'::regclass);


--
-- Name: childParkHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."childParkHistory" ALTER COLUMN id SET DEFAULT nextval('public."childParkHistory_id_seq"'::regclass);


--
-- Name: compare compare_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare ALTER COLUMN compare_id SET DEFAULT nextval('public.compare_compare_id_seq'::regclass);


--
-- Name: compareProcess id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."compareProcess" ALTER COLUMN id SET DEFAULT nextval('public."compareProcess_id_seq"'::regclass);


--
-- Name: conflict_exit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conflict_exit_log ALTER COLUMN id SET DEFAULT nextval('public.conflict_exit_log_id_seq'::regclass);


--
-- Name: delivery_branch_park id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_park ALTER COLUMN id SET DEFAULT nextval('public.delivery_branch_park_id_seq'::regclass);


--
-- Name: delivery_branch_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_settings ALTER COLUMN id SET DEFAULT nextval('public.delivery_branch_settings_id_seq'::regclass);


--
-- Name: delivery_payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment ALTER COLUMN id SET DEFAULT nextval('public.delivery_payment_id_seq'::regclass);


--
-- Name: delivery_pricing_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_pricing_config ALTER COLUMN id SET DEFAULT nextval('public.delivery_pricing_config_id_seq'::regclass);


--
-- Name: delivery_slot id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_slot ALTER COLUMN id SET DEFAULT nextval('public.delivery_slot_id_seq'::regclass);


--
-- Name: delivery_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage ALTER COLUMN id SET DEFAULT nextval('public.delivery_usage_id_seq'::regclass);


--
-- Name: delivery_vehicle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle ALTER COLUMN id SET DEFAULT nextval('public.delivery_vehicle_id_seq'::regclass);


--
-- Name: delivery_wallet_transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_wallet_transaction ALTER COLUMN id SET DEFAULT nextval('public.delivery_wallet_transaction_id_seq'::regclass);


--
-- Name: discounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discounts ALTER COLUMN id SET DEFAULT nextval('public.discount_id_seq'::regclass);


--
-- Name: esukhInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."esukhInfo" ALTER COLUMN id SET DEFAULT nextval('public."esukhInfo_id_seq"'::regclass);


--
-- Name: externalSystem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."externalSystem" ALTER COLUMN id SET DEFAULT nextval('public."externalSystem_id_seq"'::regclass);


--
-- Name: gate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate ALTER COLUMN id SET DEFAULT nextval('public.gate_id_seq'::regclass);


--
-- Name: group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);


--
-- Name: groupDiscount id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount" ALTER COLUMN id SET DEFAULT nextval('public."groupDiscount_id_seq"'::regclass);


--
-- Name: guest_payment_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config ALTER COLUMN id SET DEFAULT nextval('public.guest_payment_config_id_seq'::regclass);


--
-- Name: inLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inLog" ALTER COLUMN id SET DEFAULT nextval('public."inLog_id_seq"'::regclass);


--
-- Name: inOutHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inOutHistory" ALTER COLUMN id SET DEFAULT nextval('public."inOutHistory_id_seq"'::regclass);


--
-- Name: inRecord id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inRecord" ALTER COLUMN id SET DEFAULT nextval('public."inRecord_id_seq"'::regclass);


--
-- Name: logger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger ALTER COLUMN id SET DEFAULT nextval('public.logger_id_seq'::regclass);


--
-- Name: merchant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant ALTER COLUMN id SET DEFAULT nextval('public.merchant_id_seq'::regclass);


--
-- Name: overtime_payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment ALTER COLUMN id SET DEFAULT nextval('public.overtime_payment_id_seq'::regclass);


--
-- Name: paidInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paidInfo" ALTER COLUMN id SET DEFAULT nextval('public."paidInfo_id_seq"'::regclass);


--
-- Name: park id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park ALTER COLUMN id SET DEFAULT nextval('public.park_id_seq'::regclass);


--
-- Name: parkAccessConfig id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkAccessConfig" ALTER COLUMN id SET DEFAULT nextval('public."parkAccessConfig_id_seq"'::regclass);


--
-- Name: parkCarMirror id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkCarMirror" ALTER COLUMN id SET DEFAULT nextval('public."parkCarMirror_id_seq"'::regclass);


--
-- Name: parkFee id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkFee" ALTER COLUMN id SET DEFAULT nextval('public."parkFee_id_seq"'::regclass);


--
-- Name: parkLocation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkLocation" ALTER COLUMN id SET DEFAULT nextval('public."parkLocations_id_seq"'::regclass);


--
-- Name: qrCodeController id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qrCodeController" ALTER COLUMN id SET DEFAULT nextval('public."qrCodeContoroller_id_seq"'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests ALTER COLUMN id SET DEFAULT nextval('public.requests_id_seq'::regclass);


--
-- Name: rightNowCamera id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."rightNowCamera" ALTER COLUMN id SET DEFAULT nextval('public."rightNowCamera_id_seq"'::regclass);


--
-- Name: right_now_camera_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.right_now_camera_history ALTER COLUMN id SET DEFAULT nextval('public.right_now_camera_history_id_seq'::regclass);


--
-- Name: routerConfig id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."routerConfig" ALTER COLUMN id SET DEFAULT nextval('public."routerConfig_id_seq"'::regclass);


--
-- Name: signupRequest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signupRequest" ALTER COLUMN id SET DEFAULT nextval('public."signupRequest_id_seq"'::regclass);


--
-- Name: spayCheckLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."spayCheckLog" ALTER COLUMN id SET DEFAULT nextval('public."spayCheckLog_id_seq"'::regclass);


--
-- Name: system_admin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_admin ALTER COLUMN id SET DEFAULT nextval('public.system_admin_id_seq'::regclass);


--
-- Name: tableName id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tableName" ALTER COLUMN id SET DEFAULT nextval('public."tableName_id_seq"'::regclass);


--
-- Name: vatInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatInfo" ALTER COLUMN id SET DEFAULT nextval('public."vatInfo_id_seq"'::regclass);


--
-- Name: worker id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker ALTER COLUMN id SET DEFAULT nextval('public.worker_id_seq'::regclass);


--
-- Name: workerPark id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerPark" ALTER COLUMN id SET DEFAULT nextval('public."workerPark_id_seq"'::regclass);


--
-- Name: feedback_assignment_durations feedback_assignment_durations_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_assignment_durations
    ADD CONSTRAINT feedback_assignment_durations_pkey PRIMARY KEY (id);


--
-- Name: feedback_board_columns feedback_board_columns_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_board_columns
    ADD CONSTRAINT feedback_board_columns_pkey PRIMARY KEY (id);


--
-- Name: feedback_comment_attachments feedback_comment_attachments_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comment_attachments
    ADD CONSTRAINT feedback_comment_attachments_pkey PRIMARY KEY (id);


--
-- Name: feedback_comments feedback_comments_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comments
    ADD CONSTRAINT feedback_comments_pkey PRIMARY KEY (id);


--
-- Name: feedback_customer_contacts feedback_customer_contacts_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_customer_contacts
    ADD CONSTRAINT feedback_customer_contacts_pkey PRIMARY KEY (id);


--
-- Name: feedback_customer_organizations feedback_customer_organizations_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_customer_organizations
    ADD CONSTRAINT feedback_customer_organizations_pkey PRIMARY KEY (id);


--
-- Name: feedback_employees feedback_employees_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_employees
    ADD CONSTRAINT feedback_employees_pkey PRIMARY KEY (id);


--
-- Name: feedback_issue_assignees feedback_issue_assignees_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_assignees
    ADD CONSTRAINT feedback_issue_assignees_pkey PRIMARY KEY (id);


--
-- Name: feedback_issue_collaborators feedback_issue_collaborators_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_collaborators
    ADD CONSTRAINT feedback_issue_collaborators_pkey PRIMARY KEY (id);


--
-- Name: feedback_issue_histories feedback_issue_histories_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_histories
    ADD CONSTRAINT feedback_issue_histories_pkey PRIMARY KEY (id);


--
-- Name: feedback_issues feedback_issues_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT feedback_issues_pkey PRIMARY KEY (id);


--
-- Name: feedback_status_durations feedback_status_durations_pkey; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_status_durations
    ADD CONSTRAINT feedback_status_durations_pkey PRIMARY KEY (id);


--
-- Name: feedback_issues uq_feedback_issues_org_ticket; Type: CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT uq_feedback_issues_org_ticket UNIQUE (organization_id, ticket_number);


--
-- Name: PaymentOptions PaymentOptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentOptions"
    ADD CONSTRAINT "PaymentOptions_pkey" PRIMARY KEY (id);


--
-- Name: Payments Payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "Payments_pkey" PRIMARY KEY (id);


--
-- Name: accessTime accessTime_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accessTime"
    ADD CONSTRAINT "accessTime_pkey" PRIMARY KEY (id);


--
-- Name: branchExternalSystem branchExternalSystem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchExternalSystem"
    ADD CONSTRAINT "branchExternalSystem_pkey" PRIMARY KEY (id);


--
-- Name: branch branch_branch_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key1 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key2 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key3 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key4 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key5 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key6 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key7 UNIQUE (branch_uuid);


--
-- Name: branch branch_branch_uuid_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_uuid_key8 UNIQUE (branch_uuid);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- Name: branch_types branch_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_types
    ADD CONSTRAINT branch_types_pkey PRIMARY KEY (id);


--
-- Name: camera_health_log camera_health_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_health_log
    ADD CONSTRAINT camera_health_log_pkey PRIMARY KEY (id);


--
-- Name: camera camera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera
    ADD CONSTRAINT camera_pkey PRIMARY KEY (id);


--
-- Name: camera_request_queue camera_request_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_request_queue
    ADD CONSTRAINT camera_request_queue_pkey PRIMARY KEY (id);


--
-- Name: camera_template camera_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera_template
    ADD CONSTRAINT camera_template_pkey PRIMARY KEY (id);


--
-- Name: carConfigExternalInfo carConfigExternalInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfigExternalInfo"
    ADD CONSTRAINT "carConfigExternalInfo_pkey" PRIMARY KEY (id);


--
-- Name: carConfig carConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_pkey" PRIMARY KEY (id);


--
-- Name: car car_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key UNIQUE (email);


--
-- Name: car car_email_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key1 UNIQUE (email);


--
-- Name: car car_email_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key2 UNIQUE (email);


--
-- Name: car car_email_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key3 UNIQUE (email);


--
-- Name: car car_email_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key4 UNIQUE (email);


--
-- Name: car car_email_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_email_key5 UNIQUE (email);


--
-- Name: car car_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (id);


--
-- Name: car car_plateNumber_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key" UNIQUE ("plateNumber");


--
-- Name: car car_plateNumber_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key1" UNIQUE ("plateNumber");


--
-- Name: car car_plateNumber_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key2" UNIQUE ("plateNumber");


--
-- Name: car car_plateNumber_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key3" UNIQUE ("plateNumber");


--
-- Name: car car_plateNumber_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key4" UNIQUE ("plateNumber");


--
-- Name: car car_plateNumber_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT "car_plateNumber_key5" UNIQUE ("plateNumber");


--
-- Name: childParkHistory childParkHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."childParkHistory"
    ADD CONSTRAINT "childParkHistory_pkey" PRIMARY KEY (id);


--
-- Name: compareProcess compareProcess_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."compareProcess"
    ADD CONSTRAINT "compareProcess_pkey" PRIMARY KEY (id);


--
-- Name: compare compare_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare
    ADD CONSTRAINT compare_pkey PRIMARY KEY (compare_id);


--
-- Name: conflict_exit_log conflict_exit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conflict_exit_log
    ADD CONSTRAINT conflict_exit_log_pkey PRIMARY KEY (id);


--
-- Name: delivery_branch_park delivery_branch_park_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_park
    ADD CONSTRAINT delivery_branch_park_pkey PRIMARY KEY (id);


--
-- Name: delivery_branch_park delivery_branch_park_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_park
    ADD CONSTRAINT delivery_branch_park_unique UNIQUE (branch_id, park_id);


--
-- Name: delivery_branch_settings delivery_branch_settings_branch_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_settings
    ADD CONSTRAINT delivery_branch_settings_branch_id_key UNIQUE (branch_id);


--
-- Name: delivery_branch_settings delivery_branch_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_settings
    ADD CONSTRAINT delivery_branch_settings_pkey PRIMARY KEY (id);


--
-- Name: delivery_payment delivery_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_pkey PRIMARY KEY (id);


--
-- Name: delivery_pricing_config delivery_pricing_config_config_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_pricing_config
    ADD CONSTRAINT delivery_pricing_config_config_key_key UNIQUE (config_key);


--
-- Name: delivery_pricing_config delivery_pricing_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_pricing_config
    ADD CONSTRAINT delivery_pricing_config_pkey PRIMARY KEY (id);


--
-- Name: delivery_slot delivery_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_slot
    ADD CONSTRAINT delivery_slot_pkey PRIMARY KEY (id);


--
-- Name: delivery_usage delivery_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_pkey PRIMARY KEY (id);


--
-- Name: delivery_vehicle delivery_vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle
    ADD CONSTRAINT delivery_vehicle_pkey PRIMARY KEY (id);


--
-- Name: delivery_vehicle delivery_vehicle_plate_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle
    ADD CONSTRAINT delivery_vehicle_plate_number_key UNIQUE (plate_number);


--
-- Name: delivery_wallet_transaction delivery_wallet_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_wallet_transaction
    ADD CONSTRAINT delivery_wallet_transaction_pkey PRIMARY KEY (id);


--
-- Name: discounts discount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discount_pkey PRIMARY KEY (id);


--
-- Name: esukhInfo esukhInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."esukhInfo"
    ADD CONSTRAINT "esukhInfo_pkey" PRIMARY KEY (id);


--
-- Name: externalSystem externalSystem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."externalSystem"
    ADD CONSTRAINT "externalSystem_pkey" PRIMARY KEY (id);


--
-- Name: gate gate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate
    ADD CONSTRAINT gate_pkey PRIMARY KEY (id);


--
-- Name: groupDiscount groupDiscount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount"
    ADD CONSTRAINT "groupDiscount_pkey" PRIMARY KEY (id);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: guest_payment_config guest_payment_config_guest_car_config_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config
    ADD CONSTRAINT guest_payment_config_guest_car_config_id_key UNIQUE (guest_car_config_id);


--
-- Name: guest_payment_config guest_payment_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config
    ADD CONSTRAINT guest_payment_config_pkey PRIMARY KEY (id);


--
-- Name: inLog inLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inLog"
    ADD CONSTRAINT "inLog_pkey" PRIMARY KEY (id);


--
-- Name: inOutHistory inOutHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inOutHistory"
    ADD CONSTRAINT "inOutHistory_pkey" PRIMARY KEY (id);


--
-- Name: inRecord inRecord_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inRecord"
    ADD CONSTRAINT "inRecord_pkey" PRIMARY KEY (id);


--
-- Name: logger logger_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logger
    ADD CONSTRAINT logger_new_pkey PRIMARY KEY (id);


--
-- Name: merchant merchant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY ("workerId", "WorkerId");


--
-- Name: overtime_payment overtime_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_pkey PRIMARY KEY (id);


--
-- Name: paidInfo paidInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paidInfo"
    ADD CONSTRAINT "paidInfo_pkey" PRIMARY KEY (id);


--
-- Name: parkAccessConfig parkAccessConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkAccessConfig"
    ADD CONSTRAINT "parkAccessConfig_pkey" PRIMARY KEY (id);


--
-- Name: parkCarMirror parkCarMirror_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkCarMirror"
    ADD CONSTRAINT "parkCarMirror_pkey" PRIMARY KEY (id);


--
-- Name: parkFee parkFee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkFee"
    ADD CONSTRAINT "parkFee_pkey" PRIMARY KEY (id);


--
-- Name: parkLocation parkLocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkLocation"
    ADD CONSTRAINT "parkLocations_pkey" PRIMARY KEY (id);


--
-- Name: park park_park_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key1 UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key2 UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key3 UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key4 UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key5 UNIQUE (park_uuid);


--
-- Name: park park_park_uuid_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_park_uuid_key6 UNIQUE (park_uuid);


--
-- Name: park park_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT park_pkey PRIMARY KEY (id);


--
-- Name: qrCodeController qrCodeContoroller_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qrCodeController"
    ADD CONSTRAINT "qrCodeContoroller_pkey" PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: rightNowCamera rightNowCamera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."rightNowCamera"
    ADD CONSTRAINT "rightNowCamera_pkey" PRIMARY KEY (id);


--
-- Name: right_now_camera_history right_now_camera_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.right_now_camera_history
    ADD CONSTRAINT right_now_camera_history_pkey PRIMARY KEY (id);


--
-- Name: routerConfig routerConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."routerConfig"
    ADD CONSTRAINT "routerConfig_pkey" PRIMARY KEY (id);


--
-- Name: signupRequest signupRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signupRequest"
    ADD CONSTRAINT "signupRequest_pkey" PRIMARY KEY (id);


--
-- Name: spayCheckLog spayCheckLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."spayCheckLog"
    ADD CONSTRAINT "spayCheckLog_pkey" PRIMARY KEY (id);


--
-- Name: system_admin system_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_admin
    ADD CONSTRAINT system_admin_pkey PRIMARY KEY (id);


--
-- Name: tableName tableName_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tableName"
    ADD CONSTRAINT "tableName_pkey" PRIMARY KEY (id);


--
-- Name: parkCarMirror uq_parkCarMirror_src_tgt; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkCarMirror"
    ADD CONSTRAINT "uq_parkCarMirror_src_tgt" UNIQUE ("sourceParkId", "targetParkId");


--
-- Name: routerConfig uq_routerConfig_branch_park; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."routerConfig"
    ADD CONSTRAINT "uq_routerConfig_branch_park" UNIQUE ("branchId", "parkId");


--
-- Name: vatInfo vatInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatInfo"
    ADD CONSTRAINT "vatInfo_pkey" PRIMARY KEY (id);


--
-- Name: workerPark workerPark_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerPark"
    ADD CONSTRAINT "workerPark_pkey" PRIMARY KEY (id);


--
-- Name: workerPark workerPark_workerId_parkId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerPark"
    ADD CONSTRAINT "workerPark_workerId_parkId_key" UNIQUE ("workerId", "parkId");


--
-- Name: worker worker_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key UNIQUE (email);


--
-- Name: worker worker_email_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key1 UNIQUE (email);


--
-- Name: worker worker_email_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key2 UNIQUE (email);


--
-- Name: worker worker_email_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key3 UNIQUE (email);


--
-- Name: worker worker_email_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key4 UNIQUE (email);


--
-- Name: worker worker_email_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key5 UNIQUE (email);


--
-- Name: worker worker_email_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key6 UNIQUE (email);


--
-- Name: worker worker_email_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_email_key7 UNIQUE (email);


--
-- Name: worker worker_loginName_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key1" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key2" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key3" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key4" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key5" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key6" UNIQUE ("loginName");


--
-- Name: worker worker_loginName_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_loginName_key7" UNIQUE ("loginName");


--
-- Name: worker worker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_pkey PRIMARY KEY (id);


--
-- Name: idx_feedback_assignment_durations_employee; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_assignment_durations_employee ON feedback_system.feedback_assignment_durations USING btree (employee_id);


--
-- Name: idx_feedback_assignment_durations_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_assignment_durations_org_issue ON feedback_system.feedback_assignment_durations USING btree (organization_id, issue_id);


--
-- Name: idx_feedback_board_columns_org_sort; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_board_columns_org_sort ON feedback_system.feedback_board_columns USING btree (organization_id, sort_order) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_comment_attachments_comment; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_comment_attachments_comment ON feedback_system.feedback_comment_attachments USING btree (comment_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_comments_issue_created_at; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_comments_issue_created_at ON feedback_system.feedback_comments USING btree (issue_id, created_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_comments_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_comments_org_issue ON feedback_system.feedback_comments USING btree (organization_id, issue_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_customer_contacts_org_org_id; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_customer_contacts_org_org_id ON feedback_system.feedback_customer_contacts USING btree (organization_id, customer_organization_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_customer_contacts_organization_id; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_customer_contacts_organization_id ON feedback_system.feedback_customer_contacts USING btree (organization_id);


--
-- Name: idx_feedback_customer_orgs_org_deleted; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_customer_orgs_org_deleted ON feedback_system.feedback_customer_organizations USING btree (organization_id, deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_customer_orgs_organization_id; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_customer_orgs_organization_id ON feedback_system.feedback_customer_organizations USING btree (organization_id);


--
-- Name: idx_feedback_employees_org_active; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_employees_org_active ON feedback_system.feedback_employees USING btree (organization_id, is_active) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_employees_organization_id; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_employees_organization_id ON feedback_system.feedback_employees USING btree (organization_id);


--
-- Name: idx_feedback_issue_assignees_employee_current; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issue_assignees_employee_current ON feedback_system.feedback_issue_assignees USING btree (employee_id, is_current) WHERE ((is_current = true) AND (deleted_at IS NULL));


--
-- Name: idx_feedback_issue_assignees_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issue_assignees_org_issue ON feedback_system.feedback_issue_assignees USING btree (organization_id, issue_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issue_collaborators_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issue_collaborators_org_issue ON feedback_system.feedback_issue_collaborators USING btree (organization_id, issue_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issue_histories_issue_created_at; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issue_histories_issue_created_at ON feedback_system.feedback_issue_histories USING btree (issue_id, created_at);


--
-- Name: idx_feedback_issue_histories_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issue_histories_org_issue ON feedback_system.feedback_issue_histories USING btree (organization_id, issue_id);


--
-- Name: idx_feedback_issues_org_assignee; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_assignee ON feedback_system.feedback_issues USING btree (organization_id, current_assignee_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issues_org_created_at; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_created_at ON feedback_system.feedback_issues USING btree (organization_id, created_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issues_org_customer_org; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_customer_org ON feedback_system.feedback_issues USING btree (organization_id, customer_organization_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issues_org_deleted_at; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_deleted_at ON feedback_system.feedback_issues USING btree (organization_id, deleted_at);


--
-- Name: idx_feedback_issues_org_priority; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_priority ON feedback_system.feedback_issues USING btree (organization_id, priority) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issues_org_status; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_org_status ON feedback_system.feedback_issues USING btree (organization_id, status) WHERE (deleted_at IS NULL);


--
-- Name: idx_feedback_issues_organization_id; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_issues_organization_id ON feedback_system.feedback_issues USING btree (organization_id);


--
-- Name: idx_feedback_status_durations_org_issue; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE INDEX idx_feedback_status_durations_org_issue ON feedback_system.feedback_status_durations USING btree (organization_id, issue_id);


--
-- Name: uq_feedback_board_columns_org_status; Type: INDEX; Schema: feedback_system; Owner: -
--

CREATE UNIQUE INDEX uq_feedback_board_columns_org_status ON feedback_system.feedback_board_columns USING btree (organization_id, mapped_status) WHERE (deleted_at IS NULL);


--
-- Name: car_config_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX car_config_branch_id ON public."carConfig" USING btree ("branchId");


--
-- Name: car_config_park_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX car_config_park_id ON public."carConfig" USING btree ("parkId");


--
-- Name: car_config_plate_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX car_config_plate_number ON public."carConfig" USING btree ("plateNumber");


--
-- Name: idx_branchExternalSystem_branchId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_branchExternalSystem_branchId" ON public."branchExternalSystem" USING btree ("branchId");


--
-- Name: idx_branchExternalSystem_systemCode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_branchExternalSystem_systemCode" ON public."branchExternalSystem" USING btree ("systemCode");


--
-- Name: idx_branch_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branch_id_status ON public.camera_request_queue USING btree (branch_id, status);


--
-- Name: idx_branch_settings_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branch_settings_active ON public.delivery_branch_settings USING btree (is_active) WHERE (is_deleted = false);


--
-- Name: idx_branch_settings_active_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branch_settings_active_approved ON public.delivery_branch_settings USING btree (is_active, is_approved);


--
-- Name: idx_branch_settings_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branch_settings_approved ON public.delivery_branch_settings USING btree (is_approved);


--
-- Name: idx_branch_settings_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branch_settings_service ON public.delivery_branch_settings USING btree (service_type);


--
-- Name: idx_camera_branchid_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_branchid_ip ON public.camera USING btree ("branchId", ip text_pattern_ops);


--
-- Name: idx_camera_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_id_status ON public.camera_request_queue USING btree (camera_id, status);


--
-- Name: idx_camera_ip_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_ip_pattern ON public.camera USING btree (ip text_pattern_ops);


--
-- Name: idx_camera_online_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_online_ip ON public.camera USING btree (online, ip text_pattern_ops);


--
-- Name: idx_camera_parkid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_parkid ON public.camera USING btree ("parkId");


--
-- Name: idx_camera_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_camera_template_id ON public.camera USING btree ("templateId");


--
-- Name: idx_carConfigExternalInfo_branchId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_carConfigExternalInfo_branchId" ON public."carConfigExternalInfo" USING btree ("branchId");


--
-- Name: idx_carConfigExternalInfo_carConfigId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_carConfigExternalInfo_carConfigId" ON public."carConfigExternalInfo" USING btree ("carConfigId");


--
-- Name: idx_carConfigExternalInfo_externalUserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_carConfigExternalInfo_externalUserId" ON public."carConfigExternalInfo" USING btree ("externalUserId");


--
-- Name: idx_carConfigExternalInfo_systemCode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_carConfigExternalInfo_systemCode" ON public."carConfigExternalInfo" USING btree ("systemCode");


--
-- Name: idx_carConfig_sourceCarConfigId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_carConfig_sourceCarConfigId" ON public."carConfig" USING btree ("sourceCarConfigId") WHERE ("sourceCarConfigId" IS NOT NULL);


--
-- Name: idx_carconfig_branch_park; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_carconfig_branch_park ON public."carConfig" USING btree ("branchId", "parkId");


--
-- Name: idx_carconfig_branch_park_deleted_enddate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_carconfig_branch_park_deleted_enddate ON public."carConfig" USING btree ("branchId", "parkId", "isDeleted", "endDate");


--
-- Name: idx_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_created_at ON public.camera_request_queue USING btree (created_at);


--
-- Name: idx_delivery_branch_park_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_branch_park_branch ON public.delivery_branch_park USING btree (branch_id) WHERE (is_deleted = false);


--
-- Name: idx_delivery_branch_park_park; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_delivery_branch_park_park ON public.delivery_branch_park USING btree (park_id) WHERE (is_deleted = false);


--
-- Name: idx_esukh_info_apartment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_esukh_info_apartment_id ON public."esukhInfo" USING btree ("apartmentId") WHERE ("apartmentId" IS NOT NULL);


--
-- Name: idx_esukhinfo_userid_branchid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_esukhinfo_userid_branchid ON public."esukhInfo" USING btree ("userId", "branchId");


--
-- Name: idx_groupdiscount_active_formula_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupdiscount_active_formula_lookup ON public."groupDiscount" USING btree ("parkId", "groupId", "isActive", sort);


--
-- Name: idx_groupdiscount_park; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupdiscount_park ON public."groupDiscount" USING btree ("parkId");


--
-- Name: idx_guest_payment_config_branch_park; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_guest_payment_config_branch_park ON public.guest_payment_config USING btree (branch_id, park_id);


--
-- Name: idx_guest_payment_config_guest_car; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_guest_payment_config_guest_car ON public.guest_payment_config USING btree (guest_car_config_id);


--
-- Name: idx_guest_payment_config_idempotency; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_guest_payment_config_idempotency ON public.guest_payment_config USING btree (idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- Name: idx_guest_payment_config_resident; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_guest_payment_config_resident ON public.guest_payment_config USING btree (resident_user_id);


--
-- Name: idx_inouthistory_branch_park_plate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inouthistory_branch_park_plate ON public."inOutHistory" USING btree ("branchId", "parkId", "plateNumber", id DESC);


--
-- Name: idx_inouthistory_branch_park_platenumber; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inouthistory_branch_park_platenumber ON public."inOutHistory" USING btree ("branchId", "parkId", "plateNumber");


--
-- Name: idx_inouthistory_inrecord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inouthistory_inrecord ON public."inOutHistory" USING btree ("inRecord_id");


--
-- Name: idx_inouthistory_parkid_indate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inouthistory_parkid_indate ON public."inOutHistory" USING btree ("parkId", "inDate");


--
-- Name: idx_inrecord_active_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inrecord_active_lookup ON public."inRecord" USING btree ("plateNumber", "parkId", "branchId", id DESC);


--
-- Name: idx_inrecord_plate_park_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inrecord_plate_park_branch ON public."inRecord" USING btree ("plateNumber", "parkId", "branchId");


--
-- Name: idx_logger_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_action ON public.logger USING btree ("actionDate");


--
-- Name: idx_logger_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_branch ON public.logger USING btree ("branchId", "createdAt");


--
-- Name: idx_logger_branch_park_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_branch_park_created ON public.logger USING btree ("branchId", "parkId", "createdAt" DESC);


--
-- Name: idx_logger_branch_park_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_branch_park_id_desc ON public.logger USING btree ("branchId", "parkId", id DESC);


--
-- Name: idx_logger_esukh_info_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_esukh_info_id ON public.logger USING btree ("esukhInfoId") WHERE ("esukhInfoId" IS NOT NULL);


--
-- Name: idx_logger_plate_number_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_plate_number_trgm ON public.logger USING gin ("plateNumber" public.gin_trgm_ops);


--
-- Name: idx_logger_worker; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_logger_worker ON public.logger USING btree ("workerId", "createdAt");


--
-- Name: idx_overtime_payment_branch_park; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_branch_park ON public.overtime_payment USING btree (branch_id, park_id);


--
-- Name: idx_overtime_payment_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_created_at ON public.overtime_payment USING btree (created_at);


--
-- Name: idx_overtime_payment_guest_car_config; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_guest_car_config ON public.overtime_payment USING btree (guest_car_config_id);


--
-- Name: idx_overtime_payment_in_record; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_in_record ON public.overtime_payment USING btree (in_record_id);


--
-- Name: idx_overtime_payment_payment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_payment ON public.overtime_payment USING btree (payment_id);


--
-- Name: idx_overtime_payment_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_overtime_payment_status ON public.overtime_payment USING btree (payment_status);


--
-- Name: idx_parkCarMirror_branchId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_parkCarMirror_branchId" ON public."parkCarMirror" USING btree ("branchId");


--
-- Name: idx_parkCarMirror_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_parkCarMirror_source" ON public."parkCarMirror" USING btree ("sourceParkId", "isActive", "isDeleted");


--
-- Name: idx_park_ispaid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_park_ispaid ON public.park USING btree ("isPaid");


--
-- Name: idx_parkfee_park_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parkfee_park_group ON public."parkFee" USING btree ("parkId", "groupId");


--
-- Name: idx_payment_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_branch ON public.delivery_payment USING btree (branch_id);


--
-- Name: idx_payment_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_date ON public.delivery_payment USING btree (paid_date);


--
-- Name: idx_payment_slot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_slot ON public.delivery_payment USING btree (slot_id);


--
-- Name: idx_payment_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_status ON public.delivery_payment USING btree (status) WHERE (is_deleted = false);


--
-- Name: idx_payment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_type ON public.delivery_payment USING btree (payment_type);


--
-- Name: idx_payment_usage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_usage ON public.delivery_payment USING btree (usage_id);


--
-- Name: idx_payment_vehicle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_vehicle ON public.delivery_payment USING btree (vehicle_id);


--
-- Name: idx_payments_inrecord_success; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_inrecord_success ON public."Payments" USING btree ("inRecord_id", success);


--
-- Name: idx_payments_paid_sum_by_inrecord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_paid_sum_by_inrecord ON public."Payments" USING btree ("inRecord_id") INCLUDE (paid_amount) WHERE (success = true);


--
-- Name: idx_plate_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_plate_number ON public.camera_request_queue USING btree (plate_number);


--
-- Name: idx_pricing_config_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pricing_config_active ON public.delivery_pricing_config USING btree (is_active) WHERE (is_deleted = false);


--
-- Name: idx_pricing_config_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pricing_config_sort ON public.delivery_pricing_config USING btree (sort_order) WHERE (is_active = true);


--
-- Name: idx_priority_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_priority_status ON public.camera_request_queue USING btree (priority, status);


--
-- Name: idx_propertyid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyid ON public."esukhInfo" USING btree ("propertyId");


--
-- Name: idx_requests_cameraid_success; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_requests_cameraid_success ON public.requests USING btree ("cameraId", success);


--
-- Name: idx_requests_cameraid_success_cover; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_requests_cameraid_success_cover ON public.requests USING btree ("cameraId", success) INCLUDE (id, address);


--
-- Name: idx_requests_success; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_requests_success ON public.requests USING btree (success);


--
-- Name: idx_rnc_camera_latest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_camera_latest ON public."rightNowCamera" USING btree ("cameraId", id DESC);


--
-- Name: idx_rnc_gate_latest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_gate_latest ON public."rightNowCamera" USING btree (gate_id, id DESC) WHERE (gate_id IS NOT NULL);


--
-- Name: idx_rnc_history_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_archived_at ON public.right_now_camera_history USING btree ("archivedAt");


--
-- Name: idx_rnc_history_camera; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_camera ON public.right_now_camera_history USING btree ("cameraId");


--
-- Name: idx_rnc_history_gate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_gate ON public.right_now_camera_history USING btree (gate_id);


--
-- Name: idx_rnc_history_in_record; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_in_record ON public.right_now_camera_history USING btree ("inRecord_id");


--
-- Name: idx_rnc_history_park_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_park_branch ON public.right_now_camera_history USING btree ("parkId", "branchId");


--
-- Name: idx_rnc_history_plate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rnc_history_plate ON public.right_now_camera_history USING btree ("plateNumber");


--
-- Name: idx_routerConfig_branchId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_routerConfig_branchId" ON public."routerConfig" USING btree ("branchId");


--
-- Name: idx_routerConfig_parkId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_routerConfig_parkId" ON public."routerConfig" USING btree ("parkId");


--
-- Name: idx_slot_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_slot_branch ON public.delivery_slot USING btree (branch_id);


--
-- Name: idx_slot_branch_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_slot_branch_status ON public.delivery_slot USING btree (branch_id, status) WHERE (is_deleted = false);


--
-- Name: idx_slot_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_slot_dates ON public.delivery_slot USING btree (start_date, end_date);


--
-- Name: idx_slot_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_slot_status ON public.delivery_slot USING btree (status) WHERE (is_deleted = false);


--
-- Name: idx_status_next_retry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_next_retry ON public.camera_request_queue USING btree (status, next_retry_at);


--
-- Name: idx_usage_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_branch ON public.delivery_usage USING btree (branch_id);


--
-- Name: idx_usage_branch_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_branch_date ON public.delivery_usage USING btree (branch_id, in_date DESC);


--
-- Name: idx_usage_has_slot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_has_slot ON public.delivery_usage USING btree (has_active_slot);


--
-- Name: idx_usage_in_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_in_date ON public.delivery_usage USING btree (in_date);


--
-- Name: idx_usage_plate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_plate ON public.delivery_usage USING btree (plate_number);


--
-- Name: idx_usage_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_status ON public.delivery_usage USING btree (status) WHERE (is_deleted = false);


--
-- Name: idx_usage_vehicle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usage_vehicle ON public.delivery_usage USING btree (vehicle_id);


--
-- Name: idx_vehicle_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_branch ON public.delivery_vehicle USING btree (branch_id);


--
-- Name: idx_vehicle_branch_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_branch_active ON public.delivery_vehicle USING btree (branch_id, is_active) WHERE (is_deleted = false);


--
-- Name: idx_vehicle_current_slot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_current_slot ON public.delivery_vehicle USING btree (current_slot_id) WHERE ((current_slot_id IS NOT NULL) AND (is_deleted = false));


--
-- Name: idx_vehicle_plate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_plate ON public.delivery_vehicle USING btree (plate_number) WHERE (is_deleted = false);


--
-- Name: idx_vehicle_registration_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicle_registration_type ON public.delivery_vehicle USING btree (registration_type);


--
-- Name: idx_wallet_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_branch ON public.delivery_wallet_transaction USING btree (branch_id);


--
-- Name: idx_wallet_branch_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_branch_created ON public.delivery_wallet_transaction USING btree (branch_id, created_at DESC);


--
-- Name: idx_wallet_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_created ON public.delivery_wallet_transaction USING btree (created_at DESC);


--
-- Name: idx_wallet_related; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_related ON public.delivery_wallet_transaction USING btree (related_type, related_id);


--
-- Name: idx_wallet_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_status ON public.delivery_wallet_transaction USING btree (status);


--
-- Name: idx_wallet_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_transaction_id ON public.delivery_wallet_transaction USING btree (transaction_id);


--
-- Name: idx_wallet_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wallet_type ON public.delivery_wallet_transaction USING btree (type);


--
-- Name: in_out_history_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_out_history_branch_id ON public."inOutHistory" USING btree ("branchId");


--
-- Name: in_out_history_in_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_out_history_in_date ON public."inOutHistory" USING btree ("inDate");


--
-- Name: in_out_history_in_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_out_history_in_record_id ON public."inOutHistory" USING btree ("inRecord_id");


--
-- Name: in_out_history_out_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_out_history_out_date ON public."inOutHistory" USING btree ("outDate");


--
-- Name: in_out_history_park_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_out_history_park_id ON public."inOutHistory" USING btree ("parkId");


--
-- Name: in_record_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_record_branch_id ON public."inRecord" USING btree ("branchId");


--
-- Name: in_record_park_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_record_park_id ON public."inRecord" USING btree ("parkId");


--
-- Name: in_record_plate_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX in_record_plate_number ON public."inRecord" USING btree ("plateNumber");


--
-- Name: logger_new_branchId_parkId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "logger_new_branchId_parkId_idx" ON public.logger USING btree ("branchId", "parkId");


--
-- Name: payments_in_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_in_record_id ON public."Payments" USING btree ("inRecord_id");


--
-- Name: requests_car_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX requests_car_config_id ON public.requests USING btree ("carConfigId");


--
-- Name: requests_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX requests_uuid ON public.requests USING btree (uuid);


--
-- Name: uq_branch_system; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_branch_system ON public."branchExternalSystem" USING btree ("branchId", "systemCode");


--
-- Name: uq_externalSystem_apiUsername; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "uq_externalSystem_apiUsername" ON public."externalSystem" USING btree ("apiUsername") WHERE ("apiUsername" IS NOT NULL);


--
-- Name: uq_externalSystem_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "uq_externalSystem_code" ON public."externalSystem" USING btree (code);


--
-- Name: worker_login_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_login_name ON public.worker USING btree ("loginName");


--
-- Name: branchExternalSystem trigger_branchexternalsystem_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_branchexternalsystem_updated_at BEFORE UPDATE ON public."branchExternalSystem" FOR EACH ROW EXECUTE FUNCTION public.update_external_integration_updated_at();


--
-- Name: carConfigExternalInfo trigger_carconfigexternalinfo_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_carconfigexternalinfo_updated_at BEFORE UPDATE ON public."carConfigExternalInfo" FOR EACH ROW EXECUTE FUNCTION public.update_external_integration_updated_at();


--
-- Name: externalSystem trigger_externalsystem_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_externalsystem_updated_at BEFORE UPDATE ON public."externalSystem" FOR EACH ROW EXECUTE FUNCTION public.update_external_integration_updated_at();


--
-- Name: parkCarMirror trigger_parkcarmirror_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_parkcarmirror_updated_at BEFORE UPDATE ON public."parkCarMirror" FOR EACH ROW EXECUTE FUNCTION public.update_park_car_mirror_updated_at();


--
-- Name: routerConfig trigger_routerconfig_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_routerconfig_updated_at BEFORE UPDATE ON public."routerConfig" FOR EACH ROW EXECUTE FUNCTION public.update_router_config_updated_at();


--
-- Name: feedback_assignment_durations fk_feedback_assignment_durations_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_assignment_durations
    ADD CONSTRAINT fk_feedback_assignment_durations_employee FOREIGN KEY (employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_assignment_durations fk_feedback_assignment_durations_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_assignment_durations
    ADD CONSTRAINT fk_feedback_assignment_durations_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: feedback_comment_attachments fk_feedback_comment_attachments_comment; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comment_attachments
    ADD CONSTRAINT fk_feedback_comment_attachments_comment FOREIGN KEY (comment_id) REFERENCES feedback_system.feedback_comments(id);


--
-- Name: feedback_comment_attachments fk_feedback_comment_attachments_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comment_attachments
    ADD CONSTRAINT fk_feedback_comment_attachments_employee FOREIGN KEY (uploaded_by_employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_comments fk_feedback_comments_customer_contact; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comments
    ADD CONSTRAINT fk_feedback_comments_customer_contact FOREIGN KEY (customer_contact_id) REFERENCES feedback_system.feedback_customer_contacts(id);


--
-- Name: feedback_comments fk_feedback_comments_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comments
    ADD CONSTRAINT fk_feedback_comments_employee FOREIGN KEY (employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_comments fk_feedback_comments_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_comments
    ADD CONSTRAINT fk_feedback_comments_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: feedback_customer_contacts fk_feedback_customer_contacts_org; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_customer_contacts
    ADD CONSTRAINT fk_feedback_customer_contacts_org FOREIGN KEY (customer_organization_id) REFERENCES feedback_system.feedback_customer_organizations(id);


--
-- Name: feedback_issue_assignees fk_feedback_issue_assignees_assigned_by; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_assignees
    ADD CONSTRAINT fk_feedback_issue_assignees_assigned_by FOREIGN KEY (assigned_by_employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issue_assignees fk_feedback_issue_assignees_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_assignees
    ADD CONSTRAINT fk_feedback_issue_assignees_employee FOREIGN KEY (employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issue_assignees fk_feedback_issue_assignees_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_assignees
    ADD CONSTRAINT fk_feedback_issue_assignees_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: feedback_issue_collaborators fk_feedback_issue_collaborators_added_by; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_collaborators
    ADD CONSTRAINT fk_feedback_issue_collaborators_added_by FOREIGN KEY (added_by_employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issue_collaborators fk_feedback_issue_collaborators_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_collaborators
    ADD CONSTRAINT fk_feedback_issue_collaborators_employee FOREIGN KEY (employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issue_collaborators fk_feedback_issue_collaborators_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_collaborators
    ADD CONSTRAINT fk_feedback_issue_collaborators_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: feedback_issue_histories fk_feedback_issue_histories_actor_customer; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_histories
    ADD CONSTRAINT fk_feedback_issue_histories_actor_customer FOREIGN KEY (actor_customer_contact_id) REFERENCES feedback_system.feedback_customer_contacts(id);


--
-- Name: feedback_issue_histories fk_feedback_issue_histories_actor_employee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_histories
    ADD CONSTRAINT fk_feedback_issue_histories_actor_employee FOREIGN KEY (actor_employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issue_histories fk_feedback_issue_histories_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issue_histories
    ADD CONSTRAINT fk_feedback_issue_histories_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: feedback_issues fk_feedback_issues_created_by; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT fk_feedback_issues_created_by FOREIGN KEY (created_by_employee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issues fk_feedback_issues_current_assignee; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT fk_feedback_issues_current_assignee FOREIGN KEY (current_assignee_id) REFERENCES feedback_system.feedback_employees(id);


--
-- Name: feedback_issues fk_feedback_issues_customer_contact; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT fk_feedback_issues_customer_contact FOREIGN KEY (customer_contact_id) REFERENCES feedback_system.feedback_customer_contacts(id);


--
-- Name: feedback_issues fk_feedback_issues_customer_org; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_issues
    ADD CONSTRAINT fk_feedback_issues_customer_org FOREIGN KEY (customer_organization_id) REFERENCES feedback_system.feedback_customer_organizations(id);


--
-- Name: feedback_status_durations fk_feedback_status_durations_issue; Type: FK CONSTRAINT; Schema: feedback_system; Owner: -
--

ALTER TABLE ONLY feedback_system.feedback_status_durations
    ADD CONSTRAINT fk_feedback_status_durations_issue FOREIGN KEY (issue_id) REFERENCES feedback_system.feedback_issues(id);


--
-- Name: Payments Payments_payment_options_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "Payments_payment_options_id_fkey" FOREIGN KEY (payment_options_id) REFERENCES public."PaymentOptions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: groupDiscount branchId_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount"
    ADD CONSTRAINT "branchId_fk" FOREIGN KEY ("branchId") REFERENCES public.branch(id) NOT VALID;


--
-- Name: camera camera_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera
    ADD CONSTRAINT "camera_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: camera camera_templateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camera
    ADD CONSTRAINT "camera_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES public.camera_template(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: carConfig carConfig_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: carConfig carConfig_carId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_carId_fkey" FOREIGN KEY ("carId") REFERENCES public.car(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: carConfig carConfig_esukhInfoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_esukhInfoId_fkey" FOREIGN KEY ("esukhInfoId") REFERENCES public."esukhInfo"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: carConfig carConfig_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."group"(id) ON UPDATE CASCADE;


--
-- Name: carConfig carConfig_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON UPDATE CASCADE;


--
-- Name: carConfig carConfig_sourceCarConfigId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carConfig"
    ADD CONSTRAINT "carConfig_sourceCarConfigId_fkey" FOREIGN KEY ("sourceCarConfigId") REFERENCES public."carConfig"(id);


--
-- Name: delivery_branch_park delivery_branch_park_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_park
    ADD CONSTRAINT delivery_branch_park_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_branch_park delivery_branch_park_park_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_park
    ADD CONSTRAINT delivery_branch_park_park_id_fkey FOREIGN KEY (park_id) REFERENCES public.park(id) ON DELETE CASCADE;


--
-- Name: delivery_branch_settings delivery_branch_settings_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_settings
    ADD CONSTRAINT delivery_branch_settings_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_branch_settings delivery_branch_settings_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_branch_settings
    ADD CONSTRAINT delivery_branch_settings_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_payment delivery_payment_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_payment delivery_payment_paid_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_payment delivery_payment_payment_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_payment_option_id_fkey FOREIGN KEY (payment_option_id) REFERENCES public."PaymentOptions"(id) ON DELETE RESTRICT;


--
-- Name: delivery_payment delivery_payment_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.delivery_slot(id) ON DELETE SET NULL;


--
-- Name: delivery_payment delivery_payment_usage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_usage_id_fkey FOREIGN KEY (usage_id) REFERENCES public.delivery_usage(id) ON DELETE SET NULL;


--
-- Name: delivery_payment delivery_payment_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_payment
    ADD CONSTRAINT delivery_payment_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.delivery_vehicle(id) ON DELETE CASCADE;


--
-- Name: delivery_pricing_config delivery_pricing_config_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_pricing_config
    ADD CONSTRAINT delivery_pricing_config_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_slot delivery_slot_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_slot
    ADD CONSTRAINT delivery_slot_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_slot delivery_slot_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_slot
    ADD CONSTRAINT delivery_slot_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_usage delivery_usage_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_usage delivery_usage_in_worker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_in_worker_id_fkey FOREIGN KEY (in_worker_id) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_usage delivery_usage_out_worker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_out_worker_id_fkey FOREIGN KEY (out_worker_id) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_usage delivery_usage_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.delivery_slot(id) ON DELETE SET NULL;


--
-- Name: delivery_usage delivery_usage_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT delivery_usage_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.delivery_vehicle(id) ON DELETE CASCADE;


--
-- Name: delivery_vehicle delivery_vehicle_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle
    ADD CONSTRAINT delivery_vehicle_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_vehicle delivery_vehicle_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle
    ADD CONSTRAINT delivery_vehicle_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_wallet_transaction delivery_wallet_transaction_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_wallet_transaction
    ADD CONSTRAINT delivery_wallet_transaction_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: delivery_wallet_transaction delivery_wallet_transaction_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_wallet_transaction
    ADD CONSTRAINT delivery_wallet_transaction_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: delivery_wallet_transaction delivery_wallet_transaction_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_wallet_transaction
    ADD CONSTRAINT delivery_wallet_transaction_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: groupDiscount discountsId_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount"
    ADD CONSTRAINT "discountsId_fk" FOREIGN KEY ("discountId") REFERENCES public.discounts(id) NOT VALID;


--
-- Name: delivery_slot fk_slot_payment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_slot
    ADD CONSTRAINT fk_slot_payment FOREIGN KEY (payment_id) REFERENCES public.delivery_payment(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: delivery_usage fk_usage_payment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_usage
    ADD CONSTRAINT fk_usage_payment FOREIGN KEY (payment_id) REFERENCES public.delivery_payment(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: delivery_vehicle fk_vehicle_current_slot; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_vehicle
    ADD CONSTRAINT fk_vehicle_current_slot FOREIGN KEY (current_slot_id) REFERENCES public.delivery_slot(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: groupDiscount groupId_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount"
    ADD CONSTRAINT "groupId_fk" FOREIGN KEY ("groupId") REFERENCES public."group"(id) ON UPDATE RESTRICT ON DELETE CASCADE NOT VALID;


--
-- Name: guest_payment_config guest_payment_config_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config
    ADD CONSTRAINT guest_payment_config_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: guest_payment_config guest_payment_config_guest_car_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config
    ADD CONSTRAINT guest_payment_config_guest_car_config_id_fkey FOREIGN KEY (guest_car_config_id) REFERENCES public."carConfig"(id) ON DELETE CASCADE;


--
-- Name: guest_payment_config guest_payment_config_park_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_payment_config
    ADD CONSTRAINT guest_payment_config_park_id_fkey FOREIGN KEY (park_id) REFERENCES public.park(id) ON DELETE CASCADE;


--
-- Name: inOutHistory inOutHistory_carConfigId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."inOutHistory"
    ADD CONSTRAINT "inOutHistory_carConfigId_fkey" FOREIGN KEY ("carConfigId") REFERENCES public."carConfig"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: models models_WorkerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT "models_WorkerId_fkey" FOREIGN KEY ("WorkerId") REFERENCES public.worker(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: models models_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT "models_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public."workerPark"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: overtime_payment overtime_payment_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: overtime_payment overtime_payment_guest_car_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_guest_car_config_id_fkey FOREIGN KEY (guest_car_config_id) REFERENCES public."carConfig"(id) ON DELETE CASCADE;


--
-- Name: overtime_payment overtime_payment_guest_payment_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_guest_payment_config_id_fkey FOREIGN KEY (guest_payment_config_id) REFERENCES public.guest_payment_config(id) ON DELETE SET NULL;


--
-- Name: overtime_payment overtime_payment_park_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_park_id_fkey FOREIGN KEY (park_id) REFERENCES public.park(id) ON DELETE CASCADE;


--
-- Name: overtime_payment overtime_payment_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtime_payment
    ADD CONSTRAINT overtime_payment_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public."Payments"(id) ON DELETE SET NULL;


--
-- Name: parkCarMirror parkCarMirror_sourceParkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkCarMirror"
    ADD CONSTRAINT "parkCarMirror_sourceParkId_fkey" FOREIGN KEY ("sourceParkId") REFERENCES public.park(id);


--
-- Name: parkCarMirror parkCarMirror_targetParkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkCarMirror"
    ADD CONSTRAINT "parkCarMirror_targetParkId_fkey" FOREIGN KEY ("targetParkId") REFERENCES public.park(id);


--
-- Name: groupDiscount parkId_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."groupDiscount"
    ADD CONSTRAINT "parkId_fk" FOREIGN KEY ("parkId") REFERENCES public.park(id) NOT VALID;


--
-- Name: parkLocation parkLocations_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."parkLocation"
    ADD CONSTRAINT "parkLocations_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: park park_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT "park_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON UPDATE CASCADE;


--
-- Name: park park_parentParkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT "park_parentParkId_fkey" FOREIGN KEY ("parentParkId") REFERENCES public.park(id);


--
-- Name: park park_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.park
    ADD CONSTRAINT "park_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id);


--
-- Name: requests requests_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT "requests_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requests requests_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT "requests_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: routerConfig routerConfig_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."routerConfig"
    ADD CONSTRAINT "routerConfig_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE RESTRICT;


--
-- Name: routerConfig routerConfig_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."routerConfig"
    ADD CONSTRAINT "routerConfig_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON DELETE RESTRICT;


--
-- Name: workerPark workerPark_parkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerPark"
    ADD CONSTRAINT "workerPark_parkId_fkey" FOREIGN KEY ("parkId") REFERENCES public.park(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: workerPark workerPark_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerPark"
    ADD CONSTRAINT "workerPark_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: worker worker_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT "worker_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict wkHQVmNZDHdJMdExAUXtgVOKkHmV85GO2bKSaGLP5pqzgX0scHSqOAat1XsKqOO

