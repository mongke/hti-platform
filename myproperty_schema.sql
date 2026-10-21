--
-- PostgreSQL database dump
--

\restrict Zq0S6AWHahuthdRsvOU6b0VAwr1n7p8cLfUIT6GFhJ2PUO0fESoqIdOPbZGuNUF

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: enum_notification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_notification_status AS ENUM (
    'UNREAD',
    'READ'
);


--
-- Name: enum_taskActivity_activityType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_taskActivity_activityType" AS ENUM (
    'COMMENT',
    'STATUS_CHANGE',
    'ASSIGNMENT',
    'UPDATE'
);


--
-- Name: enum_task_priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_task_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


--
-- Name: enum_task_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_task_status AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'WAITING',
    'RESOLVED',
    'CLOSED'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action (
    id integer NOT NULL,
    "rootId" integer,
    name character varying(255),
    type integer
);


--
-- Name: action_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_id_seq OWNED BY public.action.id;


--
-- Name: archiveFile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."archiveFile" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "fileName" character varying(255) NOT NULL,
    "fileUrl" character varying(500) NOT NULL,
    "filePath" character varying(500),
    "mimeType" character varying(100),
    "fileSize" integer,
    "uploadedBy" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: archiveFile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."archiveFile_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archiveFile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."archiveFile_id_seq" OWNED BY public."archiveFile".id;


--
-- Name: bankStatement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."bankStatement" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "accountNumber" character varying(30) NOT NULL,
    "bankCode" character varying(20) NOT NULL,
    "bankName" character varying(100),
    "transactionDate" timestamp with time zone NOT NULL,
    amount numeric(14,2) NOT NULL,
    description character varying(100),
    "referenceNo" character varying(120),
    "relatedAccount" character varying(50),
    "externalId" character varying(100) NOT NULL,
    direction character varying(10) DEFAULT 'CREDIT'::character varying,
    status character varying(20) DEFAULT 'NEW'::character varying,
    "contractId" integer,
    "paymentId" integer,
    "appliedBy" integer,
    "appliedAt" timestamp with time zone,
    raw json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: bankStatementPayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."bankStatementPayment" (
    id integer NOT NULL,
    "bankStatementId" integer NOT NULL,
    "paymentId" integer,
    "contractId" integer,
    amount numeric(12,2) DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "isDepositPayment" boolean DEFAULT false NOT NULL
);


--
-- Name: bankStatementPayment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."bankStatementPayment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bankStatementPayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."bankStatementPayment_id_seq" OWNED BY public."bankStatementPayment".id;


--
-- Name: bankStatement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."bankStatement_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bankStatement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."bankStatement_id_seq" OWNED BY public."bankStatement".id;


--
-- Name: block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.block (
    id integer NOT NULL,
    "buildingId" integer NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(2000),
    "totalFloors" integer,
    "totalArea" numeric(12,2),
    "contactPhone" character varying(20),
    "contactEmail" character varying(100),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN block.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.code IS 'Short code for block (e.g., A, B, RETAIL)';


--
-- Name: COLUMN block.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block.name IS 'Full name of the block (e.g., Tower A, Retail Wing)';


--
-- Name: COLUMN block."totalFloors"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block."totalFloors" IS 'Number of floors in this block';


--
-- Name: COLUMN block."totalArea"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.block."totalArea" IS 'Total area (m²)';


--
-- Name: block_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.block_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: block_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.block_id_seq OWNED BY public.block.id;


--
-- Name: branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    "companyName" character varying(150),
    address character varying(2000),
    phone character varying(30),
    email character varying(100),
    description character varying(2000),
    "logoUrl" character varying(500),
    "mainBuildingImageUrl" character varying(500),
    "sealUrl" character varying(500),
    "startDate" timestamp with time zone,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "contractDraftUrl" character varying(500),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "registerNo" character varying(10),
    "subscriptionPlan" character varying(120),
    "showDetailedInfo" boolean DEFAULT false NOT NULL,
    "canSkipPay" boolean DEFAULT false NOT NULL,
    "canTerminateWithRemain" boolean DEFAULT false NOT NULL,
    "createVatOnSystemInvoicePayment" boolean DEFAULT true NOT NULL,
    "feePercent" numeric(7,4),
    "feeServiceIds" jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: COLUMN branch."logoUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."logoUrl" IS 'Branch logo image URL';


--
-- Name: COLUMN branch."mainBuildingImageUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."mainBuildingImageUrl" IS 'Main building background image URL';


--
-- Name: COLUMN branch."sealUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."sealUrl" IS 'Branch seal image URL for documents/emails';


--
-- Name: COLUMN branch."contractDraftUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."contractDraftUrl" IS 'Branch-level contract Word draft template URL';


--
-- Name: COLUMN branch."feePercent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."feePercent" IS 'Branch system fee percentage, e.g. 2 means 2%';


--
-- Name: COLUMN branch."feeServiceIds"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.branch."feeServiceIds" IS 'Selected service IDs used as fee base; empty means invoice totalAmount';


--
-- Name: branchBuilding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchBuilding" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer NOT NULL,
    role character varying(50),
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "branchBuilding".role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchBuilding".role IS 'e.g., MAIN_MANAGER, MAINTENANCE_PARTNER, CLEANING_CONTRACTOR';


--
-- Name: branchBuildingCorporate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchBuildingCorporate" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer,
    "bankAccountNumber" character varying(20),
    "bankCode" character varying(6),
    status character varying(20),
    credential json,
    "startSyncDate" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "fetchDebitStatements" boolean DEFAULT false NOT NULL
);


--
-- Name: branchBuildingCorporate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchBuildingCorporate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchBuildingCorporate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchBuildingCorporate_id_seq" OWNED BY public."branchBuildingCorporate".id;


--
-- Name: branchBuildingMessageFormat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchBuildingMessageFormat" (
    id integer NOT NULL,
    "invoiceFormat" character varying(160) DEFAULT 'Tani @contractNo gereenii @yearMonth tulbur @balance, uldegdel @totalBalance. @link'::character varying NOT NULL,
    "buildingId" integer,
    "branchId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchBuildingMessageFormat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchBuildingMessageFormat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchBuildingMessageFormat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchBuildingMessageFormat_id_seq" OWNED BY public."branchBuildingMessageFormat".id;


--
-- Name: branchBuildingPaymentInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchBuildingPaymentInfo" (
    id integer NOT NULL,
    "qpayCode" character varying(100) NOT NULL,
    "bankAccountNumber" character varying(20),
    "bankCode" character varying(6),
    "roundDecimal" integer DEFAULT 2,
    "feeFormula" character varying(500),
    "branchId" integer NOT NULL,
    "buildingId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "startInvoiceDate" date,
    "depositBankAccountNumber" character varying(20),
    "depositBankCode" character varying(6)
);


--
-- Name: COLUMN "branchBuildingPaymentInfo"."roundDecimal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchBuildingPaymentInfo"."roundDecimal" IS 'Decimal places to round invoice totals for this branch';


--
-- Name: COLUMN "branchBuildingPaymentInfo"."feeFormula"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchBuildingPaymentInfo"."feeFormula" IS 'System fee rate as string (eg: 0.02 for 2%)';


--
-- Name: branchBuildingPaymentInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchBuildingPaymentInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchBuildingPaymentInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchBuildingPaymentInfo_id_seq" OWNED BY public."branchBuildingPaymentInfo".id;


--
-- Name: branchBuildingVatInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchBuildingVatInfo" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer,
    tin character varying(15),
    "districtCode" character varying(4),
    approved boolean DEFAULT false,
    register character varying(12),
    "taxType" character varying(10),
    "serviceName" character varying(100),
    "serviceCode" character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchBuildingVatInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchBuildingVatInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchBuildingVatInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchBuildingVatInfo_id_seq" OWNED BY public."branchBuildingVatInfo".id;


--
-- Name: branchBuilding_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchBuilding_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchBuilding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchBuilding_id_seq" OWNED BY public."branchBuilding".id;


--
-- Name: branchCorporate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchCorporate" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "bankAccountNumber" character varying(20),
    "bankCode" character varying(6),
    status character varying(20),
    credential json,
    "startSyncDate" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchCorporate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchCorporate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchCorporate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchCorporate_id_seq" OWNED BY public."branchCorporate".id;


--
-- Name: branchInvoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchInvoice" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "walletId" integer,
    "invoiceNo" character varying(60) NOT NULL,
    "periodMonth" character varying(7) NOT NULL,
    "issueDate" date NOT NULL,
    "dueDate" date NOT NULL,
    "baseAmount" numeric(14,2) DEFAULT 0 NOT NULL,
    "feeRate" numeric(6,4) DEFAULT 0.02 NOT NULL,
    "totalAmount" numeric(14,2) DEFAULT 0 NOT NULL,
    "paidAmount" numeric(14,2) DEFAULT 0 NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'ISSUED'::character varying NOT NULL,
    "autoPaid" boolean DEFAULT false,
    "autoPaidAt" timestamp with time zone,
    "lastPaidAt" timestamp with time zone,
    notes character varying(500),
    meta json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "branchInvoice"."periodMonth"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchInvoice"."periodMonth" IS 'YYYY-MM of fee calculation period';


--
-- Name: branchInvoiceHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchInvoiceHistory" (
    id integer NOT NULL,
    "branchInvoiceId" integer,
    "branchId" integer NOT NULL,
    "workerId" integer,
    action character varying(30) NOT NULL,
    snapshot jsonb,
    "prevSnapshot" jsonb,
    note character varying(1000),
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: branchInvoiceHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchInvoiceHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchInvoiceHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchInvoiceHistory_id_seq" OWNED BY public."branchInvoiceHistory".id;


--
-- Name: branchInvoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchInvoice_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchInvoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchInvoice_id_seq" OWNED BY public."branchInvoice".id;


--
-- Name: branchMessageFormat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchMessageFormat" (
    id integer NOT NULL,
    "invoiceFormat" character varying(160) DEFAULT 'Tani @contractNo gereenii @yearMonth tulbur @balance, uldegdel @totalBalance. @link'::character varying NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "branchId" integer
);


--
-- Name: branchMessageFormat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchMessageFormat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchMessageFormat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchMessageFormat_id_seq" OWNED BY public."branchMessageFormat".id;


--
-- Name: branchPaymentInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchPaymentInfo" (
    id integer NOT NULL,
    "qpayCode" character varying(100) NOT NULL,
    "bankAccountNumber" character varying(20),
    "bankCode" character varying(6),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "branchId" integer NOT NULL,
    "roundDecimal" integer DEFAULT 2,
    "feeFormula" character varying(500)
);


--
-- Name: COLUMN "branchPaymentInfo"."roundDecimal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchPaymentInfo"."roundDecimal" IS 'Decimal places to round invoice totals for this branch';


--
-- Name: COLUMN "branchPaymentInfo"."feeFormula"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchPaymentInfo"."feeFormula" IS 'System fee rate as string (eg: 0.02 for 2%)';


--
-- Name: branchPaymentInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchPaymentInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchPaymentInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchPaymentInfo_id_seq" OWNED BY public."branchPaymentInfo".id;


--
-- Name: branchRegistration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchRegistration" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    "progressPercent" integer DEFAULT 0 NOT NULL,
    "currentStep" character varying(50),
    "activatedAt" timestamp without time zone,
    "activatedBy" integer,
    metadata jsonb,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: branchRegistrationStep; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchRegistrationStep" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "stepCode" character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    "completedAt" timestamp without time zone,
    "completedBy" integer,
    notes text,
    metadata jsonb,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: branchRegistrationStep_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchRegistrationStep_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchRegistrationStep_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchRegistrationStep_id_seq" OWNED BY public."branchRegistrationStep".id;


--
-- Name: branchRegistration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchRegistration_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchRegistration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchRegistration_id_seq" OWNED BY public."branchRegistration".id;


--
-- Name: branchSupportVar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchSupportVar" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "variableName" character varying(100) NOT NULL,
    formula character varying(500),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchSupportVar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchSupportVar_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchSupportVar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchSupportVar_id_seq" OWNED BY public."branchSupportVar".id;


--
-- Name: branchVatInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchVatInfo" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    tin character varying(15),
    "districtCode" character varying(4),
    approved boolean DEFAULT false,
    register character varying(12),
    "taxType" character varying(10),
    "serviceName" character varying(100),
    "serviceCode" character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchVatInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchVatInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchVatInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchVatInfo_id_seq" OWNED BY public."branchVatInfo".id;


--
-- Name: branchWallet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchWallet" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL,
    currency character varying(6) DEFAULT 'MNT'::character varying NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    "lastAutoChargeAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: branchWalletTransaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchWalletTransaction" (
    id integer NOT NULL,
    "walletId" integer NOT NULL,
    "branchId" integer NOT NULL,
    type character varying(30) DEFAULT 'TOP_UP'::character varying NOT NULL,
    source character varying(30) DEFAULT 'SYSTEM'::character varying NOT NULL,
    "referenceType" character varying(40),
    "referenceId" integer,
    amount numeric(14,2) NOT NULL,
    "balanceAfter" numeric(14,2),
    description character varying(500),
    meta json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "vatId" integer
);


--
-- Name: COLUMN "branchWalletTransaction".type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchWalletTransaction".type IS 'TOP_UP, FEE_DEBIT, ADJUSTMENT, REFUND';


--
-- Name: COLUMN "branchWalletTransaction".source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."branchWalletTransaction".source IS 'SYSTEM, QPAY, BANK_STATEMENT, ADMIN';


--
-- Name: branchWalletTransaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchWalletTransaction_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchWalletTransaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchWalletTransaction_id_seq" OWNED BY public."branchWalletTransaction".id;


--
-- Name: branchWallet_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchWallet_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchWallet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchWallet_id_seq" OWNED BY public."branchWallet".id;


--
-- Name: branchWorkReport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."branchWorkReport" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    "startDate" date,
    "endDate" date,
    "imageUrls" jsonb,
    files jsonb,
    "createdBy" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: branchWorkReport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."branchWorkReport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branchWorkReport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."branchWorkReport_id_seq" OWNED BY public."branchWorkReport".id;


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
-- Name: building; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building (
    id integer NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    address character varying(2000),
    "totalBlocks" integer DEFAULT 0,
    "totalFloors" integer DEFAULT 0,
    "totalArea" numeric(12,2),
    "constructionYear" integer,
    "contactPhone" character varying(30),
    "contactEmail" character varying(100),
    latitude numeric(10,7),
    longitude numeric(10,7),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    description character varying(2000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "branchId" integer,
    "contractDraftUrl" character varying(500),
    "sealUrl" character varying(500),
    "mainBuildingImageUrl" character varying(500),
    "extendContractDraftUrl" character varying(500)
);


--
-- Name: TABLE building; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.building IS 'Stores all managed buildings within each branch (property management system)';


--
-- Name: COLUMN building.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.id IS 'Primary key ID of the building record';


--
-- Name: COLUMN building.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.code IS 'Short building code used internally (e.g., ICC, SHANG)';


--
-- Name: COLUMN building.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.name IS 'Full display name of the building (e.g., ICC Tower)';


--
-- Name: COLUMN building.address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.address IS 'Full physical address of the building';


--
-- Name: COLUMN building."totalBlocks"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."totalBlocks" IS 'Number of blocks or towers in this building';


--
-- Name: COLUMN building."totalFloors"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."totalFloors" IS 'Total number of floors in the building';


--
-- Name: COLUMN building."totalArea"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."totalArea" IS 'Total area (m²) covered by this building';


--
-- Name: COLUMN building."constructionYear"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."constructionYear" IS 'Year when the building was constructed or commissioned';


--
-- Name: COLUMN building."contactPhone"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."contactPhone" IS 'Primary contact phone number for this building';


--
-- Name: COLUMN building."contactEmail"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building."contactEmail" IS 'Primary contact email for this building';


--
-- Name: COLUMN building.latitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.latitude IS 'Latitude coordinate for map location';


--
-- Name: COLUMN building.longitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.longitude IS 'Longitude coordinate for map location';


--
-- Name: COLUMN building.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.status IS 'Building operational status: ACTIVE / INACTIVE / UNDER_MAINTENANCE';


--
-- Name: COLUMN building.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.building.description IS 'Optional remarks or description about the building';


--
-- Name: building_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_id_seq OWNED BY public.building.id;


--
-- Name: capitalCategory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."capitalCategory" (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(1000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: capitalCategory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."capitalCategory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capitalCategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."capitalCategory_id_seq" OWNED BY public."capitalCategory".id;


--
-- Name: capitalDisposal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."capitalDisposal" (
    id integer NOT NULL,
    "capitalId" integer NOT NULL,
    "disposalDate" date NOT NULL,
    method character varying(30) NOT NULL,
    "salePrice" numeric(12,2),
    reason character varying(2000),
    "approvedBy" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: capitalDisposal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."capitalDisposal_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capitalDisposal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."capitalDisposal_id_seq" OWNED BY public."capitalDisposal".id;


--
-- Name: capitalItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."capitalItem" (
    id integer NOT NULL,
    "categoryId" integer NOT NULL,
    "branchId" integer NOT NULL,
    name character varying(200) NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(2000),
    "purchaseDate" date,
    "purchaseCost" numeric(12,2) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    condition character varying(20) DEFAULT 'NEW'::character varying NOT NULL,
    "warrantyExpireDate" date,
    "depreciationRate" numeric(5,2) DEFAULT 0,
    "imageUrls" jsonb,
    "createdBy" integer,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "capitalItem".status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."capitalItem".status IS 'ACTIVE, DISPOSED, LOST';


--
-- Name: capitalItem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."capitalItem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capitalItem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."capitalItem_id_seq" OWNED BY public."capitalItem".id;


--
-- Name: capitalLocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."capitalLocation" (
    id integer NOT NULL,
    "capitalId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer,
    "blockId" integer,
    "floorId" integer,
    "roomId" integer,
    "assignedTo" integer,
    "assignedDate" date,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: capitalLocation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."capitalLocation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capitalLocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."capitalLocation_id_seq" OWNED BY public."capitalLocation".id;


--
-- Name: capitalMaintenance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."capitalMaintenance" (
    id integer NOT NULL,
    "capitalId" integer NOT NULL,
    "maintenanceDate" date NOT NULL,
    "maintenanceType" character varying(50) NOT NULL,
    cost numeric(12,2) DEFAULT 0,
    notes character varying(2000),
    "performedBy" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "imageUrls" json
);


--
-- Name: capitalMaintenance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."capitalMaintenance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: capitalMaintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."capitalMaintenance_id_seq" OWNED BY public."capitalMaintenance".id;


--
-- Name: contract; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract (
    id integer NOT NULL,
    "contractNo" character varying(50) NOT NULL,
    "tenantId" integer,
    "branchId" integer NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    "rentPrice" numeric(12,2) DEFAULT 0,
    "depositAmount" numeric(12,2) DEFAULT 0,
    "depositBalance" numeric(12,2) DEFAULT 0,
    "paymentDueDay" integer DEFAULT 10,
    "lateFeeRate" numeric(6,4) DEFAULT 0.001,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "workerId" integer,
    description character varying(2000),
    "contractFileUrl" character varying(500),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    currency character varying(10) DEFAULT 'MNT'::character varying NOT NULL,
    "buildingId" integer,
    "extensionHistory" jsonb,
    "contractType" character varying(20) DEFAULT 'USAGE'::character varying NOT NULL,
    "counterpartyType" character varying(20) DEFAULT 'TENANT'::character varying NOT NULL,
    "ownerId" integer,
    "invoiceRecipientType" character varying(30) DEFAULT 'CONTRACT_PARTY'::character varying NOT NULL,
    "invoiceRecipientOwnerId" integer,
    "invoiceRecipientRentalAgreementId" integer,
    "rentServicePackId" integer,
    CONSTRAINT contract_counterparty_valid CHECK ((((("counterpartyType")::text = 'TENANT'::text) AND ("tenantId" IS NOT NULL) AND ("ownerId" IS NULL)) OR ((("counterpartyType")::text = 'OWNER'::text) AND ("ownerId" IS NOT NULL) AND ("tenantId" IS NULL))))
);


--
-- Name: COLUMN contract."startDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.contract."startDate" IS 'Contract start date';


--
-- Name: COLUMN contract."endDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.contract."endDate" IS 'Contract end date';


--
-- Name: COLUMN contract.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.contract.status IS 'ACTIVE, TERMINATED';


--
-- Name: COLUMN contract.currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.contract.currency IS 'Currency code for contract (e.g., MNT, USD, CNY)';


--
-- Name: contractBalance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractBalance" (
    id integer NOT NULL,
    contract_id integer NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    "prevBalance" numeric(12,2) DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contractBalanceHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractBalanceHistory" (
    id integer NOT NULL,
    contract_id integer NOT NULL,
    payment_id integer,
    delta numeric(12,2) DEFAULT 0 NOT NULL,
    "prevBalance" numeric(12,2) DEFAULT 0 NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    reason character varying(120),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contractBalanceHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractBalanceHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractBalanceHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractBalanceHistory_id_seq" OWNED BY public."contractBalanceHistory".id;


--
-- Name: contractBalance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractBalance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractBalance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractBalance_id_seq" OWNED BY public."contractBalance".id;


--
-- Name: contractDepositHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractDepositHistory" (
    id integer NOT NULL,
    "contractId" integer NOT NULL,
    "contractDepositInvoiceId" integer,
    "paymentId" integer,
    type character varying(20) NOT NULL,
    amount numeric(12,2) DEFAULT 0 NOT NULL,
    "balanceBefore" numeric(12,2) DEFAULT 0 NOT NULL,
    "balanceAfter" numeric(12,2) DEFAULT 0 NOT NULL,
    description character varying(300),
    "workerId" integer,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: contractDepositHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractDepositHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractDepositHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractDepositHistory_id_seq" OWNED BY public."contractDepositHistory".id;


--
-- Name: contractDepositInvoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractDepositInvoice" (
    id integer NOT NULL,
    "contractId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "tenantId" integer NOT NULL,
    "invoiceNo" character varying(80) NOT NULL,
    amount numeric(12,2) DEFAULT 0 NOT NULL,
    "paidAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'INVOICED'::character varying NOT NULL,
    "issuedAt" date NOT NULL,
    "dueDate" date,
    "paidAt" timestamp without time zone,
    "paymentId" integer,
    "paymentMethod" character varying(30),
    description character varying(255),
    "createdBy" integer,
    "closedAt" timestamp without time zone,
    "closedBy" integer,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: contractDepositInvoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractDepositInvoice_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractDepositInvoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractDepositInvoice_id_seq" OWNED BY public."contractDepositInvoice".id;


--
-- Name: contractHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractHistory" (
    id integer NOT NULL,
    "contractId" integer NOT NULL,
    "workerId" integer,
    changes jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: contractHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractHistory_id_seq" OWNED BY public."contractHistory".id;


--
-- Name: contractRemainReason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractRemainReason" (
    id integer NOT NULL,
    contract_id integer NOT NULL,
    worker_id integer,
    note text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contractRemainReason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractRemainReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractRemainReason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractRemainReason_id_seq" OWNED BY public."contractRemainReason".id;


--
-- Name: contractRoom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractRoom" (
    id integer NOT NULL,
    "contractId" integer NOT NULL,
    "servicePackId" integer,
    "roomId" integer NOT NULL,
    "calculatedArea" numeric(12,2),
    note character varying(2000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: TABLE "contractRoom"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."contractRoom" IS 'Links each contract to one or multiple rooms (supports multi-room contracts)';


--
-- Name: COLUMN "contractRoom".id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom".id IS 'Primary key for contract-room linkage record';


--
-- Name: COLUMN "contractRoom"."contractId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom"."contractId" IS 'Linked contract ID';


--
-- Name: COLUMN "contractRoom"."servicePackId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom"."servicePackId" IS 'Linked service pack ID for this room under contract';


--
-- Name: COLUMN "contractRoom"."roomId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom"."roomId" IS 'Linked room ID';


--
-- Name: COLUMN "contractRoom"."calculatedArea"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom"."calculatedArea" IS 'Area of the room at the time of contract signing';


--
-- Name: COLUMN "contractRoom".note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractRoom".note IS 'Remarks or internal notes about this room under contract';


--
-- Name: contractRoomService; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractRoomService" (
    id integer NOT NULL,
    "contractRoomId" integer NOT NULL,
    "serviceId" integer NOT NULL,
    price numeric(12,2) NOT NULL,
    quantity numeric(12,3) DEFAULT 0,
    formula character varying(500),
    note character varying(2000),
    "hasVat" boolean DEFAULT true,
    "lossDiff" numeric(12,3) DEFAULT 0 NOT NULL
);


--
-- Name: TABLE "contractRoomService"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."contractRoomService" IS 'Service setup for each room under a contract. Allows per-room service customization.';


--
-- Name: contractRoomService_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractRoomService_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractRoomService_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractRoomService_id_seq" OWNED BY public."contractRoomService".id;


--
-- Name: contractRoom_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractRoom_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractRoom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractRoom_id_seq" OWNED BY public."contractRoom".id;


--
-- Name: contractTemplate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."contractTemplate" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(30) NOT NULL,
    "paymentDueDay" integer DEFAULT 10,
    "lateFeeRate" numeric(6,4) DEFAULT 0.001,
    "durationMonths" integer DEFAULT 12,
    "depositAmount" numeric(12,2) DEFAULT 0,
    "rentPrice" numeric(12,2) DEFAULT 0,
    description character varying(2000),
    "branchId" integer,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "servicePackId" integer
);


--
-- Name: COLUMN "contractTemplate".category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."contractTemplate".category IS 'RENT, PARK, STORAGE, OFFICE, etc.';


--
-- Name: contractTemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."contractTemplate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contractTemplate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."contractTemplate_id_seq" OWNED BY public."contractTemplate".id;


--
-- Name: contract_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contract_id_seq OWNED BY public.contract.id;


--
-- Name: ekontorCredential; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ekontorCredential" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "baseUrl" character varying(500) DEFAULT 'https://ekontor.mn'::character varying NOT NULL,
    username character varying(200) NOT NULL,
    "passwordEncrypted" text NOT NULL,
    "companyId" integer,
    "townId" integer,
    "isActive" boolean DEFAULT true NOT NULL,
    "lastConnectedAt" timestamp with time zone,
    "lastError" character varying(2000),
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ekontorCredential_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ekontorCredential_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ekontorCredential_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ekontorCredential_id_seq" OWNED BY public."ekontorCredential".id;


--
-- Name: email; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email (
    id integer NOT NULL,
    "contractId" integer,
    "tenantId" integer,
    "ownerId" integer,
    "branchId" integer,
    "workerId" integer,
    subject character varying(255),
    body text NOT NULL,
    "recipientName" character varying(150),
    "invoiceId" integer,
    "recipientEmail" character varying(200) NOT NULL,
    type character varying(50) NOT NULL,
    "deliveryStatus" character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    html character varying(40000),
    "responseMessage" character varying(5000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN email.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.email.type IS 'Type of email, e.g., INVOICE, CONTRACT, NOTIFICATION';


--
-- Name: COLUMN email."deliveryStatus"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.email."deliveryStatus" IS 'PENDING, SENT, FAILED';


--
-- Name: email_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_id_seq OWNED BY public.email.id;


--
-- Name: floor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.floor (
    id integer NOT NULL,
    "buildingId" integer NOT NULL,
    "blockId" integer,
    code character varying(50),
    name character varying(100),
    level integer,
    area numeric(12,2),
    "totalRooms" integer DEFAULT 0,
    "floorImageUrl" character varying(2000),
    "planJson" jsonb,
    description character varying(2000),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: TABLE floor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.floor IS 'Stores floors within blocks and buildings including blueprint & floorplan data';


--
-- Name: COLUMN floor.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.id IS 'Primary key ID of the floor record';


--
-- Name: COLUMN floor."buildingId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."buildingId" IS 'Reference to the parent building';


--
-- Name: COLUMN floor."blockId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."blockId" IS 'Reference to the block or tower this floor belongs to';


--
-- Name: COLUMN floor.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.code IS 'Internal code for floor (e.g., F12, B1)';


--
-- Name: COLUMN floor.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.name IS 'Display name for the floor (e.g., 12th Floor, Basement 1)';


--
-- Name: COLUMN floor.level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.level IS 'Numeric floor level (e.g., 12 or -1)';


--
-- Name: COLUMN floor.area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.area IS 'Total area (m²) of this floor';


--
-- Name: COLUMN floor."totalRooms"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."totalRooms" IS 'Number of rooms defined on this floor';


--
-- Name: COLUMN floor."floorImageUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."floorImageUrl" IS 'URL or file path of floor blueprint or plan image';


--
-- Name: COLUMN floor."planJson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."planJson" IS 'Serialized JSON data of drawn plan (shapes, room positions, coordinates)';


--
-- Name: COLUMN floor.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.description IS 'Optional remarks or notes about this floor';


--
-- Name: COLUMN floor.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor.status IS 'ACTIVE / INACTIVE / UNDER_CONSTRUCTION';


--
-- Name: COLUMN floor."createdAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."createdAt" IS 'Timestamp when this record was created';


--
-- Name: COLUMN floor."updatedAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.floor."updatedAt" IS 'Timestamp of last record update';


--
-- Name: floor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.floor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: floor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.floor_id_seq OWNED BY public.floor.id;


--
-- Name: helpRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."helpRequest" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "workerId" integer NOT NULL,
    description text NOT NULL,
    "attachmentUrl" character varying(500),
    "attachmentName" character varying(255),
    status character varying(30) DEFAULT 'OPEN'::character varying NOT NULL,
    "resolutionNote" text,
    "resolvedBy" integer,
    "resolvedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "resolutionHistory" json,
    "assignedWorkerId" integer,
    "assignedBy" integer,
    "assignedAt" timestamp with time zone
);


--
-- Name: helpRequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."helpRequest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helpRequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."helpRequest_id_seq" OWNED BY public."helpRequest".id;


--
-- Name: internalMilestone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."internalMilestone" (
    id integer NOT NULL,
    "planId" integer NOT NULL,
    title character varying(300) NOT NULL,
    description text,
    "dueDate" date NOT NULL,
    "assignedWorkerIds" jsonb,
    "offsetDays" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "recurrenceType" character varying(20) DEFAULT 'NONE'::character varying NOT NULL,
    "recurrenceInterval" integer DEFAULT 1 NOT NULL,
    "recurrenceWeekdays" jsonb,
    "recurrenceMonthDay" integer,
    "recurrenceEndDate" date
);


--
-- Name: internalMilestone_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."internalMilestone_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internalMilestone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."internalMilestone_id_seq" OWNED BY public."internalMilestone".id;


--
-- Name: internalPlan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."internalPlan" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    "startDate" date,
    "endDate" date,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdBy" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: internalPlan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."internalPlan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internalPlan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."internalPlan_id_seq" OWNED BY public."internalPlan".id;


--
-- Name: internalWorkTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."internalWorkTask" (
    id integer NOT NULL,
    "milestoneId" integer NOT NULL,
    "workerId" integer NOT NULL,
    "offsetDays" integer DEFAULT 0 NOT NULL,
    "taskId" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "occurrenceDate" date NOT NULL
);


--
-- Name: internalWorkTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."internalWorkTask_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internalWorkTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."internalWorkTask_id_seq" OWNED BY public."internalWorkTask".id;


--
-- Name: invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice (
    id integer NOT NULL,
    "invoiceNo" character varying(50) NOT NULL,
    "contractId" integer NOT NULL,
    "tenantId" integer,
    "branchId" integer,
    "invoiceMonth" character varying(7) NOT NULL,
    "issueDate" date,
    "dueDate" date,
    "expectedPayDate" date,
    "totalAmount" numeric(12,2) DEFAULT 0,
    "paidAmount" numeric(12,2) DEFAULT 0,
    balance numeric(12,2),
    status character varying(20) DEFAULT 'INACTIVE'::character varying,
    "approvedBy" integer,
    "approvedAt" timestamp with time zone,
    remarks character varying(2000),
    type character varying(30) DEFAULT 'OTHER'::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "payerType" character varying(20) DEFAULT 'TENANT'::character varying NOT NULL,
    "ownerId" integer,
    CONSTRAINT invoice_payer_valid CHECK ((((("payerType")::text = 'TENANT'::text) AND ("tenantId" IS NOT NULL) AND ("ownerId" IS NULL)) OR ((("payerType")::text = 'OWNER'::text) AND ("ownerId" IS NOT NULL) AND ("tenantId" IS NULL))))
);


--
-- Name: COLUMN invoice."invoiceMonth"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice."invoiceMonth" IS 'YYYY-MM';


--
-- Name: COLUMN invoice."expectedPayDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice."expectedPayDate" IS 'User planned payment date';


--
-- Name: COLUMN invoice.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.type IS 'REGULAR, INSURANCE, MAINTENANCE, OTHER, CUSTOM, MONTHLY';


--
-- Name: invoiceBucket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceBucket" (
    id integer NOT NULL,
    "invoiceIds" integer[],
    "totalAmount" numeric(20,2),
    "branchId" integer,
    "contractId" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: invoiceBucket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoiceBucket_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoiceBucket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoiceBucket_id_seq" OWNED BY public."invoiceBucket".id;


--
-- Name: invoiceItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceItem" (
    id integer NOT NULL,
    "invoiceId" integer NOT NULL,
    "roomId" integer,
    "contractRoomId" integer,
    description character varying(2000),
    "calculatedArea" numeric(12,2),
    amount numeric(12,2) DEFAULT 0,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "invoiceItem"."roomId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItem"."roomId" IS 'Room linked to this invoice item';


--
-- Name: COLUMN "invoiceItem"."contractRoomId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItem"."contractRoomId" IS 'Reference to contractRoom record';


--
-- Name: COLUMN "invoiceItem"."calculatedArea"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItem"."calculatedArea" IS 'Snapshot of room area used for billing';


--
-- Name: COLUMN "invoiceItem".amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItem".amount IS 'Total amount for this invoice item';


--
-- Name: invoiceItemService; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceItemService" (
    id integer NOT NULL,
    "invoiceItemId" integer NOT NULL,
    "serviceId" integer,
    "serviceName" character varying(100),
    unit character varying(10),
    description character varying(100),
    "unitPrice" numeric(14,2) DEFAULT 0 NOT NULL,
    formula character varying(500),
    "prevQuantity" numeric(12,3) DEFAULT 0,
    "currentQuantity" numeric(12,3) DEFAULT 0,
    quantity numeric(12,3) DEFAULT 0,
    amount numeric(14,2) DEFAULT 0,
    "totalAmount" numeric(14,2) DEFAULT 0,
    "hasVat" boolean DEFAULT true,
    "vatAmount" numeric(14,2) DEFAULT 0,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "lossDiff" numeric(12,3) DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN "invoiceItemService"."serviceName"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItemService"."serviceName" IS 'Name snapshot of the billed service';


--
-- Name: COLUMN "invoiceItemService".unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceItemService".unit IS 'unit snapshot of the billed service';


--
-- Name: invoiceItemService_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoiceItemService_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoiceItemService_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoiceItemService_id_seq" OWNED BY public."invoiceItemService".id;


--
-- Name: invoiceItem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoiceItem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoiceItem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoiceItem_id_seq" OWNED BY public."invoiceItem".id;


--
-- Name: invoiceLateFee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceLateFee" (
    id integer NOT NULL,
    "invoiceId" integer NOT NULL,
    amount numeric(20,2),
    "lateFeeRate" numeric(5,3),
    "calculatedAt" timestamp with time zone,
    "daysLate" integer,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "paidAmount" numeric(20,2) DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN "invoiceLateFee".amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceLateFee".amount IS 'Late fee amount';


--
-- Name: COLUMN "invoiceLateFee"."lateFeeRate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceLateFee"."lateFeeRate" IS 'Late fee rate as percentage';


--
-- Name: COLUMN "invoiceLateFee"."daysLate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceLateFee"."daysLate" IS 'Number of days the invoice is late';


--
-- Name: COLUMN "invoiceLateFee".status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoiceLateFee".status IS 'Status of the late fee (e.g., PENDING, APPLIED, WAIVED)';


--
-- Name: invoiceLateFee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoiceLateFee_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoiceLateFee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoiceLateFee_id_seq" OWNED BY public."invoiceLateFee".id;


--
-- Name: invoicePayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoicePayment" (
    id integer NOT NULL,
    "invoiceId" integer NOT NULL,
    "paymentId" integer,
    "appliedAmount" numeric(12,2) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "lateFeeId" integer,
    "lateFeeAmount" numeric(12,2) DEFAULT 0 NOT NULL
);


--
-- Name: COLUMN "invoicePayment"."paymentId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."invoicePayment"."paymentId" IS 'Nullable for applications coming from tenantBalance or deposits';


--
-- Name: invoicePayment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoicePayment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoicePayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoicePayment_id_seq" OWNED BY public."invoicePayment".id;


--
-- Name: invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_id_seq OWNED BY public.invoice.id;


--
-- Name: message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message (
    id integer NOT NULL,
    "contractId" integer,
    "tenantId" integer,
    "branchId" integer,
    "ownerId" integer,
    "workerId" integer,
    message character varying(160),
    phone character varying(10),
    "recipentType" character varying(30) NOT NULL,
    "deliveryStatus" character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    type character varying(50) NOT NULL,
    "externalMessageId" character varying(120),
    "responseMessage" character varying(1000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN message."recipentType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.message."recipentType" IS 'TENANT, WORKER, OWNER etc';


--
-- Name: COLUMN message."deliveryStatus"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.message."deliveryStatus" IS 'PENDING, SENT, FAILED';


--
-- Name: COLUMN message.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.message.type IS 'INVOICE, PAID';


--
-- Name: message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_id_seq OWNED BY public.message.id;


--
-- Name: meter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meter (
    id integer NOT NULL,
    "buildingId" integer NOT NULL,
    "blockId" integer,
    "floorId" integer,
    "roomId" integer,
    "serviceId" integer,
    commodity character varying(20) NOT NULL,
    "meterType" character varying(30) NOT NULL,
    "serialNo" character varying(64) NOT NULL,
    manufacturer character varying(80),
    model character varying(80),
    "firmwareVersion" character varying(40),
    unit character varying(16) NOT NULL,
    multiplier numeric(12,4) DEFAULT 0,
    "readingDirection" character varying(16) DEFAULT 'FORWARD'::character varying,
    "installDate" date,
    "calibrationDate" date,
    "calibrationDueDate" date,
    "reportIntervalMinutes" integer,
    "valveSupported" boolean DEFAULT false,
    "valveState" character varying(16),
    "lastValveActionAt" timestamp with time zone,
    "networkType" character varying(20),
    rssi numeric(6,2),
    snr numeric(6,2),
    "batteryLevel" numeric(6,2),
    "devEui" character varying(32),
    "appEui" character varying(32),
    "devAddr" character varying(16),
    "appKey" character varying(64),
    iccid character varying(32),
    imsi character varying(32),
    apn character varying(64),
    "locationNote" character varying(2000),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "lastReadingValue" numeric(18,6),
    "lastReadingAt" timestamp with time zone,
    extra jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "branchId" integer,
    "contractRoomServiceId" integer,
    "externalProvider" character varying(30),
    "externalPublicId" character varying(100),
    "externalServiceId" character varying(100),
    "externalSyncedAt" timestamp with time zone
);


--
-- Name: TABLE meter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.meter IS 'Smart meters across buildings/blocks/floors/rooms with network & billing linkage';


--
-- Name: COLUMN meter.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.id IS 'Primary key';


--
-- Name: COLUMN meter."buildingId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."buildingId" IS 'FK to buildings.id';


--
-- Name: COLUMN meter."blockId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."blockId" IS 'FK to blocks.id';


--
-- Name: COLUMN meter."floorId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."floorId" IS 'FK to floors.id';


--
-- Name: COLUMN meter."roomId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."roomId" IS 'FK to rooms.id';


--
-- Name: COLUMN meter."serviceId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."serviceId" IS 'FK to services.id (billing link)';


--
-- Name: COLUMN meter.commodity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.commodity IS 'ELECTRICITY | WATER | HEAT | GAS';


--
-- Name: COLUMN meter."meterType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."meterType" IS 'LORAWAN | NBIOT | MBUS | MANUAL';


--
-- Name: COLUMN meter."serialNo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."serialNo" IS 'Unique meter serial';


--
-- Name: COLUMN meter.manufacturer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.manufacturer IS 'Vendor / brand';


--
-- Name: COLUMN meter.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.model IS 'Model name or code';


--
-- Name: COLUMN meter."firmwareVersion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."firmwareVersion" IS 'Firmware version';


--
-- Name: COLUMN meter.unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.unit IS 'kWh | m3 | GJ etc.';


--
-- Name: COLUMN meter.multiplier; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.multiplier IS 'Pulse/transform factor';


--
-- Name: COLUMN meter."readingDirection"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."readingDirection" IS 'FORWARD | REVERSE | NET';


--
-- Name: COLUMN meter."installDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."installDate" IS 'Installation date';


--
-- Name: COLUMN meter."calibrationDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."calibrationDate" IS 'Last calibration date';


--
-- Name: COLUMN meter."calibrationDueDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."calibrationDueDate" IS 'Next calibration due';


--
-- Name: COLUMN meter."reportIntervalMinutes"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."reportIntervalMinutes" IS 'Telemetry report interval';


--
-- Name: COLUMN meter."valveSupported"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."valveSupported" IS 'Supports remote valve';


--
-- Name: COLUMN meter."valveState"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."valveState" IS 'OPEN | CLOSED | UNKNOWN';


--
-- Name: COLUMN meter."lastValveActionAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."lastValveActionAt" IS 'Last valve actuation time';


--
-- Name: COLUMN meter."networkType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."networkType" IS 'LORA | NB-IOT | MBUS';


--
-- Name: COLUMN meter.rssi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.rssi IS 'Signal RSSI';


--
-- Name: COLUMN meter.snr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.snr IS 'Signal SNR';


--
-- Name: COLUMN meter."batteryLevel"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."batteryLevel" IS 'Battery level % or V';


--
-- Name: COLUMN meter."devEui"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."devEui" IS 'LoRaWAN DevEUI';


--
-- Name: COLUMN meter."appEui"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."appEui" IS 'LoRaWAN AppEUI/JoinEUI';


--
-- Name: COLUMN meter."devAddr"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."devAddr" IS 'LoRaWAN DevAddr';


--
-- Name: COLUMN meter."appKey"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."appKey" IS 'LoRaWAN AppKey (encrypt in DB)';


--
-- Name: COLUMN meter.iccid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.iccid IS 'SIM ICCID';


--
-- Name: COLUMN meter.imsi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.imsi IS 'Subscriber IMSI';


--
-- Name: COLUMN meter.apn; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.apn IS 'Cellular APN';


--
-- Name: COLUMN meter."locationNote"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."locationNote" IS 'Physical location notes (shaft, riser, etc.)';


--
-- Name: COLUMN meter.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.status IS 'ACTIVE | INACTIVE | MAINTENANCE | RETIRED';


--
-- Name: COLUMN meter."lastReadingValue"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."lastReadingValue" IS 'Cached last cumulative index';


--
-- Name: COLUMN meter."lastReadingAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter."lastReadingAt" IS 'Timestamp of last reading';


--
-- Name: COLUMN meter.extra; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.meter.extra IS 'Vendor-specific fields';


--
-- Name: meterReading; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."meterReading" (
    id integer NOT NULL,
    "meterId" integer NOT NULL,
    "readingAt" timestamp with time zone NOT NULL,
    value numeric(18,6) NOT NULL,
    delta numeric(18,6),
    unit character varying(16) NOT NULL,
    quality character varying(20) DEFAULT 'GOOD'::character varying,
    "rawPayload" jsonb,
    "gatewayId" character varying(64),
    rssi numeric(6,2),
    snr numeric(6,2),
    "batteryLevel" numeric(6,2),
    "createdAt" timestamp with time zone,
    "invoiceMonth" character varying(7)
);


--
-- Name: TABLE "meterReading"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."meterReading" IS 'Time-series readings for smart meters';


--
-- Name: COLUMN "meterReading".id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".id IS 'Primary key';


--
-- Name: COLUMN "meterReading"."meterId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."meterId" IS 'FK to meters.id';


--
-- Name: COLUMN "meterReading"."readingAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."readingAt" IS 'Timestamp of the reading';


--
-- Name: COLUMN "meterReading".value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".value IS 'Cumulative register value';


--
-- Name: COLUMN "meterReading".delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".delta IS 'Computed consumption for the interval';


--
-- Name: COLUMN "meterReading".unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".unit IS 'Unit at read time (kWh, m3, etc.)';


--
-- Name: COLUMN "meterReading".quality; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".quality IS 'GOOD | ESTIMATED | MISSING | ERROR';


--
-- Name: COLUMN "meterReading"."rawPayload"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."rawPayload" IS 'Raw frame/payload for audit';


--
-- Name: COLUMN "meterReading"."gatewayId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."gatewayId" IS 'Receiver gateway identifier (optional)';


--
-- Name: COLUMN "meterReading".rssi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".rssi IS 'RSSI at reception';


--
-- Name: COLUMN "meterReading".snr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading".snr IS 'SNR at reception';


--
-- Name: COLUMN "meterReading"."batteryLevel"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."batteryLevel" IS 'Battery at read time';


--
-- Name: COLUMN "meterReading"."createdAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."meterReading"."createdAt" IS 'Created timestamp';


--
-- Name: meterReading_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."meterReading_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meterReading_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."meterReading_id_seq" OWNED BY public."meterReading".id;


--
-- Name: meter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meter_id_seq OWNED BY public.meter.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    description character varying(500),
    content text,
    "imageUrl" character varying(1000),
    "startDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "isActive" boolean DEFAULT true,
    priority integer DEFAULT 0,
    "createdByWorkerId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "imageUrls" jsonb,
    "branchIds" jsonb
);


--
-- Name: newsRead; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."newsRead" (
    id integer NOT NULL,
    "newsId" integer NOT NULL,
    "workerId" integer NOT NULL,
    "hiddenAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: newsRead_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."newsRead_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsRead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."newsRead_id_seq" OWNED BY public."newsRead".id;


--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_id_seq OWNED BY public.news.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    "branchId" integer,
    "workerId" integer,
    type character varying(50) DEFAULT 'GENERAL'::character varying NOT NULL,
    title character varying(200) NOT NULL,
    body text,
    metadata jsonb,
    status public.enum_notification_status DEFAULT 'UNREAD'::public.enum_notification_status NOT NULL,
    "readAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: onboardingRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."onboardingRequest" (
    id integer NOT NULL,
    email character varying(150) NOT NULL,
    "codeHash" character varying(255) NOT NULL,
    "stateToken" character varying(120) NOT NULL,
    status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    "attemptCount" integer DEFAULT 0 NOT NULL,
    "expiresAt" timestamp with time zone NOT NULL,
    "verifiedAt" timestamp with time zone,
    "completedAt" timestamp with time zone,
    "branchId" integer,
    "workerId" integer,
    meta jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: onboardingRequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."onboardingRequest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onboardingRequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."onboardingRequest_id_seq" OWNED BY public."onboardingRequest".id;


--
-- Name: owner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.owner (
    id integer NOT NULL,
    "branchId" integer,
    "userId" integer,
    name character varying(150) NOT NULL,
    type character varying(20) DEFAULT 'INDIVIDUAL'::character varying,
    "registerNo" character varying(50),
    phone character varying(30),
    email character varying(100),
    address character varying(2000),
    "contactPerson" character varying(100),
    note character varying(2000),
    "ownershipType" character varying(20) DEFAULT 'FULL'::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: TABLE owner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.owner IS 'Property or unit owner registry for office management';


--
-- Name: COLUMN owner.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.id IS 'Primary key ID of the owner record';


--
-- Name: COLUMN owner."branchId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner."branchId" IS 'Branch that manages this owner';


--
-- Name: COLUMN owner."userId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner."userId" IS 'User ID of entire system';


--
-- Name: COLUMN owner.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.name IS 'Full name or company name of the owner';


--
-- Name: COLUMN owner.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.type IS 'Owner type: INDIVIDUAL or COMPANY';


--
-- Name: COLUMN owner."registerNo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner."registerNo" IS 'Registration number or ID number';


--
-- Name: COLUMN owner.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.phone IS 'Primary contact phone';


--
-- Name: COLUMN owner.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.email IS 'Primary contact email';


--
-- Name: COLUMN owner.address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.address IS 'Mailing or billing address';


--
-- Name: COLUMN owner."contactPerson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner."contactPerson" IS 'Contact person name (for company owners)';


--
-- Name: COLUMN owner.note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner.note IS 'Additional notes about the owner';


--
-- Name: COLUMN owner."ownershipType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.owner."ownershipType" IS 'Ownership type: FULL / SHARED / LEASED';


--
-- Name: ownerHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ownerHistory" (
    id integer NOT NULL,
    "ownerId" integer NOT NULL,
    "workerId" integer,
    action character varying(30) NOT NULL,
    snapshot jsonb,
    "prevSnapshot" jsonb,
    note character varying(1000),
    "createdAt" timestamp with time zone NOT NULL
);


--
-- Name: ownerHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ownerHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ownerHistory_id_seq" OWNED BY public."ownerHistory".id;


--
-- Name: owner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.owner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: owner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.owner_id_seq OWNED BY public.owner.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    "paymentDate" date,
    "paidAmount" numeric(12,2) NOT NULL,
    "totalAmount" numeric(12,2) NOT NULL,
    "tenantId" integer,
    "ownerId" integer,
    "branchId" integer,
    "contractId" integer,
    "lateFeeAmount" numeric(12,2),
    "depositUsedAmount" numeric(12,2),
    method character varying(30),
    "referenceNo" character varying(100),
    status character varying(20) DEFAULT 'CONFIRMED'::character varying,
    description character varying(255),
    "workerId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone
);


--
-- Name: paymentReverseHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."paymentReverseHistory" (
    id integer NOT NULL,
    "paymentId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer,
    "contractId" integer,
    "contractNo" character varying(100),
    "tenantId" integer,
    "tenantName" character varying(255),
    "paymentDate" date,
    "paidAmount" numeric(12,2),
    "totalAmount" numeric(12,2),
    method character varying(30),
    description character varying(255),
    "referenceNo" character varying(100),
    "reversedBy" integer NOT NULL,
    "reverseReason" character varying(1000) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "reversalDetails" jsonb
);


--
-- Name: paymentReverseHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."paymentReverseHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paymentReverseHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."paymentReverseHistory_id_seq" OWNED BY public."paymentReverseHistory".id;


--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "ownerId" integer,
    title character varying(200) NOT NULL,
    description text,
    horizon character varying(20) DEFAULT 'MONTHLY'::character varying NOT NULL,
    "periodStart" date NOT NULL,
    "periodEnd" date NOT NULL,
    status character varying(20) DEFAULT 'ON_TRACK'::character varying NOT NULL,
    progress double precision DEFAULT '0'::double precision NOT NULL,
    color character varying(20),
    notes text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: planGoal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."planGoal" (
    id integer NOT NULL,
    "planId" integer NOT NULL,
    title character varying(200) NOT NULL,
    kpi character varying(200),
    "metricUnit" character varying(60),
    "targetValue" character varying(120),
    "currentValue" character varying(120),
    "responsibleWorkerId" integer,
    "responsibleName" character varying(150),
    deadline date,
    status character varying(20) DEFAULT 'ON_TRACK'::character varying NOT NULL,
    progress double precision DEFAULT '0'::double precision NOT NULL,
    notes text,
    "displayOrder" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: planGoal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."planGoal_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planGoal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."planGoal_id_seq" OWNED BY public."planGoal".id;


--
-- Name: plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plan_id_seq OWNED BY public.plan.id;


--
-- Name: poll; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poll (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    "startDate" date,
    "endDate" date,
    "isActive" boolean DEFAULT true NOT NULL,
    "imageUrls" jsonb,
    "createdBy" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pollAnswer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."pollAnswer" (
    id integer NOT NULL,
    "responseId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "optionId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pollAnswer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."pollAnswer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pollAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."pollAnswer_id_seq" OWNED BY public."pollAnswer".id;


--
-- Name: pollOption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."pollOption" (
    id integer NOT NULL,
    "questionId" integer NOT NULL,
    label character varying(300) NOT NULL,
    "imageUrl" character varying(1000),
    "order" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pollOption_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."pollOption_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pollOption_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."pollOption_id_seq" OWNED BY public."pollOption".id;


--
-- Name: pollQuestion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."pollQuestion" (
    id integer NOT NULL,
    "pollId" integer NOT NULL,
    question character varying(500) NOT NULL,
    description text,
    "imageUrls" jsonb,
    "order" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pollQuestion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."pollQuestion_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pollQuestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."pollQuestion_id_seq" OWNED BY public."pollQuestion".id;


--
-- Name: pollResponse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."pollResponse" (
    id integer NOT NULL,
    "pollId" integer NOT NULL,
    "workerId" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pollResponse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."pollResponse_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pollResponse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."pollResponse_id_seq" OWNED BY public."pollResponse".id;


--
-- Name: poll_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_id_seq OWNED BY public.poll.id;


--
-- Name: qpayHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."qpayHistory" (
    id integer NOT NULL,
    "invoiceBucketId" integer NOT NULL,
    "postData" json,
    "qpayId" character varying(100) NOT NULL,
    stage character varying(20) DEFAULT 'CREATED'::character varying NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "qpayHistory"."postData"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."qpayHistory"."postData" IS 'Data sent to QPay when creating the invoice';


--
-- Name: COLUMN "qpayHistory"."qpayId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."qpayHistory"."qpayId" IS 'Unique identifier returned by QPay for the created invoice';


--
-- Name: COLUMN "qpayHistory".stage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."qpayHistory".stage IS 'Current processing stage of the QPay invoice';


--
-- Name: qpayHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."qpayHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qpayHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."qpayHistory_id_seq" OWNED BY public."qpayHistory".id;


--
-- Name: recurringInvoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."recurringInvoice" (
    id integer NOT NULL,
    "tenantId" integer NOT NULL,
    "contractId" integer,
    frequency character varying(20) NOT NULL,
    "intervalValue" integer DEFAULT 1 NOT NULL,
    "startDate" date NOT NULL,
    "nextRunDate" date NOT NULL,
    amount numeric(12,2) NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    description character varying(2000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: recurringInvoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."recurringInvoice_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurringInvoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."recurringInvoice_id_seq" OWNED BY public."recurringInvoice".id;


--
-- Name: rentalAgreement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."rentalAgreement" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "roomId" integer NOT NULL,
    "managementContractId" integer NOT NULL,
    "ownerId" integer NOT NULL,
    "tenantId" integer NOT NULL,
    "agreementNo" character varying(50) NOT NULL,
    "startDate" date NOT NULL,
    "endDate" date NOT NULL,
    "rentAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "depositAmount" numeric(12,2) DEFAULT 0 NOT NULL,
    "paymentDueDay" integer DEFAULT 10 NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    "contractFileUrl" character varying(500),
    note character varying(2000),
    "createdBy" integer,
    "terminatedAt" timestamp with time zone,
    "terminatedBy" integer,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT rental_agreement_dates_valid CHECK (("endDate" > "startDate")),
    CONSTRAINT rental_agreement_due_day_valid CHECK ((("paymentDueDay" >= 1) AND ("paymentDueDay" <= 31)))
);


--
-- Name: rentalAgreement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."rentalAgreement_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rentalAgreement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."rentalAgreement_id_seq" OWNED BY public."rentalAgreement".id;


--
-- Name: room; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room (
    id integer NOT NULL,
    "buildingId" integer NOT NULL,
    "blockId" integer,
    "floorId" integer,
    code character varying(50) NOT NULL,
    name character varying(100),
    "doorNo" character varying(50),
    area numeric(12,2),
    type character varying(30) DEFAULT 'OFFICE'::character varying,
    "usageStatus" character varying(30) DEFAULT 'VACANT'::character varying,
    "tenantId" integer,
    "contractId" integer,
    "hasMeter" boolean DEFAULT false,
    remark character varying(2000),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "ownerId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    height numeric(12,2),
    volume numeric(14,2)
);


--
-- Name: roomBooking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."roomBooking" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "buildingId" integer,
    "blockId" integer,
    "floorId" integer,
    "roomId" integer NOT NULL,
    "tenantId" integer,
    "bookerName" character varying(150),
    "bookerPhone" character varying(50),
    "bookerEmail" character varying(120),
    "startTime" timestamp with time zone NOT NULL,
    "endTime" timestamp with time zone NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    purpose character varying(255),
    notes text,
    "createdByWorkerId" integer,
    source character varying(20) DEFAULT 'ADMIN'::character varying NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "bookerRole" character varying(20),
    "bookerSubjectId" integer,
    "hourlyPrice" numeric(15,2) DEFAULT 0 NOT NULL,
    "totalPrice" numeric(15,2) DEFAULT 0 NOT NULL,
    "cancelledAt" timestamp with time zone,
    "cancelReason" character varying(500),
    "cancelledByWorkerId" integer,
    "confirmedByWorkerId" integer,
    "confirmedAt" timestamp with time zone
);


--
-- Name: COLUMN "roomBooking".status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomBooking".status IS 'PENDING, CONFIRMED, CANCELLED, COMPLETED';


--
-- Name: COLUMN "roomBooking".source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomBooking".source IS 'ADMIN, TENANT, EXTERNAL';


--
-- Name: roomBookingSetting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."roomBookingSetting" (
    "roomId" integer NOT NULL,
    "branchId" integer NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    capacity integer DEFAULT 1 NOT NULL,
    "hourlyPrice" numeric(15,2) DEFAULT 0 NOT NULL,
    "openTime" character varying(5) DEFAULT '09:00'::character varying NOT NULL,
    "closeTime" character varying(5) DEFAULT '18:00'::character varying NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT "roomBookingSetting_check" CHECK (((capacity > 0) AND ("hourlyPrice" >= (0)::numeric))),
    CONSTRAINT "roomBookingSetting_check1" CHECK ((("openTime")::text < ("closeTime")::text))
);


--
-- Name: roomBooking_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."roomBooking_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roomBooking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."roomBooking_id_seq" OWNED BY public."roomBooking".id;


--
-- Name: roomHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."roomHistory" (
    id integer NOT NULL,
    "roomId" integer NOT NULL,
    "actionType" character varying(20) NOT NULL,
    description character varying(2000),
    "relatedRoomIds" json,
    "performedBy" integer,
    "dataBefore" json,
    "dataAfter" json,
    "createdAt" timestamp with time zone
);


--
-- Name: COLUMN "roomHistory".description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomHistory".description IS 'Detailed explanation of the action';


--
-- Name: COLUMN "roomHistory"."relatedRoomIds"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomHistory"."relatedRoomIds" IS 'For split/merge — array of affected room IDs';


--
-- Name: COLUMN "roomHistory"."performedBy"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomHistory"."performedBy" IS 'Worker or user ID who performed the action';


--
-- Name: COLUMN "roomHistory"."dataBefore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomHistory"."dataBefore" IS 'Room data before change';


--
-- Name: COLUMN "roomHistory"."dataAfter"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."roomHistory"."dataAfter" IS 'Room data after change';


--
-- Name: roomHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."roomHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roomHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."roomHistory_id_seq" OWNED BY public."roomHistory".id;


--
-- Name: roomType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."roomType" (
    id integer NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(100) NOT NULL,
    color character varying(30),
    "order" integer DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roomType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."roomType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roomType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."roomType_id_seq" OWNED BY public."roomType".id;


--
-- Name: room_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_id_seq OWNED BY public.room.id;


--
-- Name: service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service (
    id integer NOT NULL,
    name character varying(100),
    unit character varying(20),
    "order" integer DEFAULT 0,
    "defaultPrice" numeric(15,2) DEFAULT 0 NOT NULL,
    "isMetered" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "contractType" character varying(20) DEFAULT 'USAGE'::character varying NOT NULL
);


--
-- Name: servicePack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."servicePack" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    "branchId" integer,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "contractType" character varying(20) DEFAULT 'USAGE'::character varying NOT NULL,
    "buildingId" integer,
    "rentPrice" numeric(12,2),
    "depositAmount" numeric(12,2)
);


--
-- Name: COLUMN "servicePack".description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."servicePack".description IS 'Parking pack, Cooling pack, Heating pack, etc.';


--
-- Name: servicePackItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."servicePackItem" (
    id integer NOT NULL,
    "servicePackId" integer NOT NULL,
    "serviceId" integer NOT NULL,
    price numeric(15,2) DEFAULT 0 NOT NULL,
    quantity numeric(12,3) DEFAULT 0 NOT NULL,
    "hasVat" boolean DEFAULT false NOT NULL,
    formula character varying(500),
    "order" integer DEFAULT 1 NOT NULL,
    "lossDiff" numeric(12,3) DEFAULT 0 NOT NULL
);


--
-- Name: servicePackItem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."servicePackItem_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: servicePackItem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."servicePackItem_id_seq" OWNED BY public."servicePackItem".id;


--
-- Name: servicePackSyncTask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."servicePackSyncTask" (
    id integer NOT NULL,
    "servicePackId" integer NOT NULL,
    "branchId" integer NOT NULL,
    "workerId" integer NOT NULL,
    "packName" character varying(100) NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    items jsonb NOT NULL,
    "contractIds" jsonb,
    "failedContractIds" jsonb DEFAULT '[]'::jsonb NOT NULL,
    cursor integer DEFAULT 0 NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    completed integer DEFAULT 0 NOT NULL,
    failed integer DEFAULT 0 NOT NULL,
    "lastError" text,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: servicePackSyncTask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."servicePackSyncTask_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: servicePackSyncTask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."servicePackSyncTask_id_seq" OWNED BY public."servicePackSyncTask".id;


--
-- Name: servicePack_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."servicePack_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: servicePack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."servicePack_id_seq" OWNED BY public."servicePack".id;


--
-- Name: service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.service_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_id_seq OWNED BY public.service.id;


--
-- Name: task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "tenantId" integer,
    "createdByWorkerId" integer,
    "assignedWorkerId" integer,
    title character varying(200) NOT NULL,
    description text,
    category character varying(100),
    priority public.enum_task_priority DEFAULT 'MEDIUM'::public.enum_task_priority NOT NULL,
    status public.enum_task_status DEFAULT 'OPEN'::public.enum_task_status NOT NULL,
    attachments jsonb,
    meta jsonb,
    "resolvedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: taskActivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."taskActivity" (
    id integer NOT NULL,
    "taskId" integer NOT NULL,
    "workerId" integer,
    "activityType" public."enum_taskActivity_activityType" DEFAULT 'COMMENT'::public."enum_taskActivity_activityType" NOT NULL,
    note text,
    attachments jsonb,
    "fromStatus" character varying(30),
    "toStatus" character varying(30),
    meta jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: taskActivity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."taskActivity_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taskActivity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."taskActivity_id_seq" OWNED BY public."taskActivity".id;


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;


--
-- Name: tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "branchId" integer,
    code character varying(50),
    "organizationName" character varying(150),
    type character varying(20) DEFAULT 'INDIVIDUAL'::character varying,
    "registerNo" character varying(50),
    address character varying(2000),
    "contactPerson" character varying(100),
    "contactPhone" character varying(30),
    "contactEmail" character varying(100),
    note character varying(2000),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "easyRegisterNo" character varying(50),
    "contactPersonLastName" character varying(100)
);


--
-- Name: TABLE tenant; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tenant IS 'Tenant registry linking to central user service by userId';


--
-- Name: COLUMN tenant.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.id IS 'Primary key ID of tenant record';


--
-- Name: COLUMN tenant."userId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."userId" IS 'Reference ID from User Service (global user unique by phone)';


--
-- Name: COLUMN tenant."branchId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."branchId" IS 'Branch that manages this tenant';


--
-- Name: COLUMN tenant.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.code IS 'Internal tenant code or alias';


--
-- Name: COLUMN tenant."organizationName"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."organizationName" IS 'Company name if tenant is corporate client';


--
-- Name: COLUMN tenant.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.type IS 'Tenant type: INDIVIDUAL or COMPANY';


--
-- Name: COLUMN tenant."registerNo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."registerNo" IS 'Company register number or ID number';


--
-- Name: COLUMN tenant.address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.address IS 'Mailing or billing address';


--
-- Name: COLUMN tenant."contactPerson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."contactPerson" IS 'Contact person name (for company tenants)';


--
-- Name: COLUMN tenant."contactPhone"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."contactPhone" IS 'Contact phone (if different from user)';


--
-- Name: COLUMN tenant."contactEmail"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."contactEmail" IS 'Contact email (if different from user)';


--
-- Name: COLUMN tenant.note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.note IS 'Additional notes or remarks about tenant';


--
-- Name: COLUMN tenant.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant.status IS 'ACTIVE / INACTIVE / BLACKLISTED';


--
-- Name: COLUMN tenant."createdAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."createdAt" IS 'Record creation timestamp';


--
-- Name: COLUMN tenant."updatedAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."updatedAt" IS 'Record last update timestamp';


--
-- Name: COLUMN tenant."easyRegisterNo"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."easyRegisterNo" IS 'Easy accounting register number';


--
-- Name: COLUMN tenant."contactPersonLastName"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tenant."contactPersonLastName" IS 'Contact person last name (for company tenants)';


--
-- Name: tenantBalance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."tenantBalance" (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    "prevBalance" numeric(12,2) DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: COLUMN "tenantBalance".balance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantBalance".balance IS 'Positive balance = available credit. Never negative.';


--
-- Name: COLUMN "tenantBalance"."prevBalance"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantBalance"."prevBalance" IS 'Snapshot before last update';


--
-- Name: tenantBalanceHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."tenantBalanceHistory" (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    payment_id integer,
    delta numeric(12,2) DEFAULT 0 NOT NULL,
    "prevBalance" numeric(12,2) DEFAULT 0 NOT NULL,
    balance numeric(12,2) DEFAULT 0 NOT NULL,
    reason character varying(120),
    created_at timestamp with time zone NOT NULL,
    "invoiceId" integer
);


--
-- Name: COLUMN "tenantBalanceHistory".payment_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantBalanceHistory".payment_id IS 'Nullable when balance is consumed automatically without a payment record';


--
-- Name: COLUMN "tenantBalanceHistory".delta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantBalanceHistory".delta IS 'Positive = credit added, negative = credit consumed';


--
-- Name: tenantBalanceHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."tenantBalanceHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenantBalanceHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."tenantBalanceHistory_id_seq" OWNED BY public."tenantBalanceHistory".id;


--
-- Name: tenantBalance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."tenantBalance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenantBalance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."tenantBalance_id_seq" OWNED BY public."tenantBalance".id;


--
-- Name: tenantHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."tenantHistory" (
    id integer NOT NULL,
    "tenantId" integer NOT NULL,
    "workerId" integer,
    action character varying(30) NOT NULL,
    snapshot jsonb,
    "prevSnapshot" jsonb,
    note character varying(1000),
    "createdAt" timestamp with time zone NOT NULL
);


--
-- Name: tenantHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."tenantHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenantHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."tenantHistory_id_seq" OWNED BY public."tenantHistory".id;


--
-- Name: tenantMember; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."tenantMember" (
    id integer NOT NULL,
    "tenantId" integer NOT NULL,
    "userId" integer NOT NULL,
    role character varying(30) DEFAULT 'WORKER'::character varying,
    "position" character varying(100),
    "accessLevel" character varying(30) DEFAULT 'NORMAL'::character varying,
    "joinDate" date,
    "leaveDate" date,
    "isActive" boolean DEFAULT true,
    remark character varying(2000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: TABLE "tenantMember"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."tenantMember" IS 'Stores workers/users who belong to a tenant (company or individual)';


--
-- Name: COLUMN "tenantMember".id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember".id IS 'Primary key ID of tenant member record';


--
-- Name: COLUMN "tenantMember"."tenantId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."tenantId" IS 'Reference to the tenant company this member belongs to';


--
-- Name: COLUMN "tenantMember"."userId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."userId" IS 'Reference to user in User Service (unique phone-based user)';


--
-- Name: COLUMN "tenantMember".role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember".role IS 'Role inside the tenant organization: WORKER / MANAGER / REPRESENTATIVE';


--
-- Name: COLUMN "tenantMember"."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."position" IS 'Job position or title of the member (e.g. Engineer, Security)';


--
-- Name: COLUMN "tenantMember"."accessLevel"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."accessLevel" IS 'Access permission: NORMAL / LIMITED / ADMIN';


--
-- Name: COLUMN "tenantMember"."joinDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."joinDate" IS 'Date when this member joined the tenant organization';


--
-- Name: COLUMN "tenantMember"."leaveDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."leaveDate" IS 'Date when member left or access revoked';


--
-- Name: COLUMN "tenantMember"."isActive"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember"."isActive" IS 'Whether the member currently has access to the property';


--
-- Name: COLUMN "tenantMember".remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."tenantMember".remark IS 'Additional notes (access permissions, parking card, etc.)';


--
-- Name: tenantMember_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."tenantMember_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenantMember_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."tenantMember_id_seq" OWNED BY public."tenantMember".id;


--
-- Name: tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_id_seq OWNED BY public.tenant.id;


--
-- Name: userNotification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userNotification" (
    id integer NOT NULL,
    "contractId" integer NOT NULL,
    "tenantId" integer,
    "ownerId" integer,
    "branchId" integer,
    "workerId" integer,
    type character varying(50) NOT NULL,
    "deliveryStatus" character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    body json,
    "responseMessage" character varying(5000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "invoiceId" integer
);


--
-- Name: COLUMN "userNotification".type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."userNotification".type IS 'Type of email, e.g., INVOICE, CONTRACT, NOTIFICATION';


--
-- Name: COLUMN "userNotification"."deliveryStatus"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."userNotification"."deliveryStatus" IS 'PENDING, SENT, FAILED';


--
-- Name: userNotification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userNotification_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userNotification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userNotification_id_seq" OWNED BY public."userNotification".id;


--
-- Name: vat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vat (
    id integer NOT NULL,
    "branchId" integer,
    "paymentId" integer,
    "requestJSON" json,
    "qrJSON" json DEFAULT '0'::json NOT NULL,
    status character varying(20) DEFAULT 'CREATED'::character varying NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "invoiceId" integer
);


--
-- Name: vat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vat_id_seq OWNED BY public.vat.id;


--
-- Name: worker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker (
    id integer NOT NULL,
    "branchId" integer,
    "userName" character varying(100) NOT NULL,
    "fullName" character varying(150),
    phone character varying(30),
    email character varying(100),
    "passwordHash" character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'EMPLOYEE'::character varying NOT NULL,
    "position" character varying(100),
    "avatarUrl" character varying(500),
    "isActive" boolean DEFAULT true NOT NULL,
    "lastLoginAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "buildingId" integer,
    "firstName" character varying(100),
    "lastName" character varying(100),
    "registerNo" character varying(50)
);


--
-- Name: COLUMN worker."branchId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."branchId" IS 'Reference to branch this worker belongs to';


--
-- Name: COLUMN worker."userName"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."userName" IS 'Worker login username or email';


--
-- Name: COLUMN worker."fullName"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."fullName" IS 'Full name of the worker';


--
-- Name: COLUMN worker.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker.phone IS 'Contact number';


--
-- Name: COLUMN worker.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker.email IS 'Email address';


--
-- Name: COLUMN worker."passwordHash"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."passwordHash" IS 'Hashed password using bcrypt';


--
-- Name: COLUMN worker.role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker.role IS 'System role and access level';


--
-- Name: COLUMN worker."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."position" IS 'Job position or title';


--
-- Name: COLUMN worker."avatarUrl"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."avatarUrl" IS 'Profile photo URL stored in cloud storage';


--
-- Name: COLUMN worker."isActive"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."isActive" IS 'Whether worker account is active or suspended';


--
-- Name: COLUMN worker."lastLoginAt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker."lastLoginAt" IS 'Last login timestamp';


--
-- Name: workerAction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."workerAction" (
    id integer NOT NULL,
    "workerId" integer,
    "actionId" integer
);


--
-- Name: workerAction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."workerAction_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workerAction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."workerAction_id_seq" OWNED BY public."workerAction".id;


--
-- Name: workerBuilding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."workerBuilding" (
    id integer NOT NULL,
    "workerId" integer NOT NULL,
    "buildingId" integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workerBuilding_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."workerBuilding_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workerBuilding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."workerBuilding_id_seq" OWNED BY public."workerBuilding".id;


--
-- Name: workerDeviceToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."workerDeviceToken" (
    id integer NOT NULL,
    "workerId" integer NOT NULL,
    "branchId" integer,
    token character varying(500) NOT NULL,
    platform character varying(30),
    "deviceId" character varying(150),
    "appVersion" character varying(50),
    "isActive" boolean DEFAULT true NOT NULL,
    "lastSeenAt" timestamp with time zone DEFAULT now() NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workerDeviceToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."workerDeviceToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workerDeviceToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."workerDeviceToken_id_seq" OWNED BY public."workerDeviceToken".id;


--
-- Name: workerLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."workerLog" (
    id integer NOT NULL,
    "workerId" integer NOT NULL,
    "updatedBy" integer,
    "branchId" integer,
    changes jsonb DEFAULT '[]'::jsonb NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: workerLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."workerLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workerLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."workerLog_id_seq" OWNED BY public."workerLog".id;


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
-- Name: action id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action ALTER COLUMN id SET DEFAULT nextval('public.action_id_seq'::regclass);


--
-- Name: archiveFile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."archiveFile" ALTER COLUMN id SET DEFAULT nextval('public."archiveFile_id_seq"'::regclass);


--
-- Name: bankStatement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatement" ALTER COLUMN id SET DEFAULT nextval('public."bankStatement_id_seq"'::regclass);


--
-- Name: bankStatementPayment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatementPayment" ALTER COLUMN id SET DEFAULT nextval('public."bankStatementPayment_id_seq"'::regclass);


--
-- Name: block id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block ALTER COLUMN id SET DEFAULT nextval('public.block_id_seq'::regclass);


--
-- Name: branch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch ALTER COLUMN id SET DEFAULT nextval('public.branch_id_seq'::regclass);


--
-- Name: branchBuilding id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuilding" ALTER COLUMN id SET DEFAULT nextval('public."branchBuilding_id_seq"'::regclass);


--
-- Name: branchBuildingCorporate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingCorporate" ALTER COLUMN id SET DEFAULT nextval('public."branchBuildingCorporate_id_seq"'::regclass);


--
-- Name: branchBuildingMessageFormat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingMessageFormat" ALTER COLUMN id SET DEFAULT nextval('public."branchBuildingMessageFormat_id_seq"'::regclass);


--
-- Name: branchBuildingPaymentInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingPaymentInfo" ALTER COLUMN id SET DEFAULT nextval('public."branchBuildingPaymentInfo_id_seq"'::regclass);


--
-- Name: branchBuildingVatInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingVatInfo" ALTER COLUMN id SET DEFAULT nextval('public."branchBuildingVatInfo_id_seq"'::regclass);


--
-- Name: branchCorporate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchCorporate" ALTER COLUMN id SET DEFAULT nextval('public."branchCorporate_id_seq"'::regclass);


--
-- Name: branchInvoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice" ALTER COLUMN id SET DEFAULT nextval('public."branchInvoice_id_seq"'::regclass);


--
-- Name: branchInvoiceHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoiceHistory" ALTER COLUMN id SET DEFAULT nextval('public."branchInvoiceHistory_id_seq"'::regclass);


--
-- Name: branchMessageFormat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchMessageFormat" ALTER COLUMN id SET DEFAULT nextval('public."branchMessageFormat_id_seq"'::regclass);


--
-- Name: branchPaymentInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchPaymentInfo" ALTER COLUMN id SET DEFAULT nextval('public."branchPaymentInfo_id_seq"'::regclass);


--
-- Name: branchRegistration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistration" ALTER COLUMN id SET DEFAULT nextval('public."branchRegistration_id_seq"'::regclass);


--
-- Name: branchRegistrationStep id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistrationStep" ALTER COLUMN id SET DEFAULT nextval('public."branchRegistrationStep_id_seq"'::regclass);


--
-- Name: branchSupportVar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchSupportVar" ALTER COLUMN id SET DEFAULT nextval('public."branchSupportVar_id_seq"'::regclass);


--
-- Name: branchVatInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchVatInfo" ALTER COLUMN id SET DEFAULT nextval('public."branchVatInfo_id_seq"'::regclass);


--
-- Name: branchWallet id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet" ALTER COLUMN id SET DEFAULT nextval('public."branchWallet_id_seq"'::regclass);


--
-- Name: branchWalletTransaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWalletTransaction" ALTER COLUMN id SET DEFAULT nextval('public."branchWalletTransaction_id_seq"'::regclass);


--
-- Name: branchWorkReport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWorkReport" ALTER COLUMN id SET DEFAULT nextval('public."branchWorkReport_id_seq"'::regclass);


--
-- Name: building id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building ALTER COLUMN id SET DEFAULT nextval('public.building_id_seq'::regclass);


--
-- Name: capitalCategory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory" ALTER COLUMN id SET DEFAULT nextval('public."capitalCategory_id_seq"'::regclass);


--
-- Name: capitalDisposal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalDisposal" ALTER COLUMN id SET DEFAULT nextval('public."capitalDisposal_id_seq"'::regclass);


--
-- Name: capitalItem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalItem" ALTER COLUMN id SET DEFAULT nextval('public."capitalItem_id_seq"'::regclass);


--
-- Name: capitalLocation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalLocation" ALTER COLUMN id SET DEFAULT nextval('public."capitalLocation_id_seq"'::regclass);


--
-- Name: capitalMaintenance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalMaintenance" ALTER COLUMN id SET DEFAULT nextval('public."capitalMaintenance_id_seq"'::regclass);


--
-- Name: contract id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract ALTER COLUMN id SET DEFAULT nextval('public.contract_id_seq'::regclass);


--
-- Name: contractBalance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalance" ALTER COLUMN id SET DEFAULT nextval('public."contractBalance_id_seq"'::regclass);


--
-- Name: contractBalanceHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalanceHistory" ALTER COLUMN id SET DEFAULT nextval('public."contractBalanceHistory_id_seq"'::regclass);


--
-- Name: contractDepositHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractDepositHistory" ALTER COLUMN id SET DEFAULT nextval('public."contractDepositHistory_id_seq"'::regclass);


--
-- Name: contractDepositInvoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractDepositInvoice" ALTER COLUMN id SET DEFAULT nextval('public."contractDepositInvoice_id_seq"'::regclass);


--
-- Name: contractHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractHistory" ALTER COLUMN id SET DEFAULT nextval('public."contractHistory_id_seq"'::regclass);


--
-- Name: contractRemainReason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRemainReason" ALTER COLUMN id SET DEFAULT nextval('public."contractRemainReason_id_seq"'::regclass);


--
-- Name: contractRoom id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoom" ALTER COLUMN id SET DEFAULT nextval('public."contractRoom_id_seq"'::regclass);


--
-- Name: contractRoomService id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoomService" ALTER COLUMN id SET DEFAULT nextval('public."contractRoomService_id_seq"'::regclass);


--
-- Name: contractTemplate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractTemplate" ALTER COLUMN id SET DEFAULT nextval('public."contractTemplate_id_seq"'::regclass);


--
-- Name: ekontorCredential id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ekontorCredential" ALTER COLUMN id SET DEFAULT nextval('public."ekontorCredential_id_seq"'::regclass);


--
-- Name: email id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email ALTER COLUMN id SET DEFAULT nextval('public.email_id_seq'::regclass);


--
-- Name: floor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floor ALTER COLUMN id SET DEFAULT nextval('public.floor_id_seq'::regclass);


--
-- Name: helpRequest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."helpRequest" ALTER COLUMN id SET DEFAULT nextval('public."helpRequest_id_seq"'::regclass);


--
-- Name: internalMilestone id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalMilestone" ALTER COLUMN id SET DEFAULT nextval('public."internalMilestone_id_seq"'::regclass);


--
-- Name: internalPlan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalPlan" ALTER COLUMN id SET DEFAULT nextval('public."internalPlan_id_seq"'::regclass);


--
-- Name: internalWorkTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalWorkTask" ALTER COLUMN id SET DEFAULT nextval('public."internalWorkTask_id_seq"'::regclass);


--
-- Name: invoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice ALTER COLUMN id SET DEFAULT nextval('public.invoice_id_seq'::regclass);


--
-- Name: invoiceBucket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceBucket" ALTER COLUMN id SET DEFAULT nextval('public."invoiceBucket_id_seq"'::regclass);


--
-- Name: invoiceItem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem" ALTER COLUMN id SET DEFAULT nextval('public."invoiceItem_id_seq"'::regclass);


--
-- Name: invoiceItemService id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItemService" ALTER COLUMN id SET DEFAULT nextval('public."invoiceItemService_id_seq"'::regclass);


--
-- Name: invoiceLateFee id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceLateFee" ALTER COLUMN id SET DEFAULT nextval('public."invoiceLateFee_id_seq"'::regclass);


--
-- Name: invoicePayment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoicePayment" ALTER COLUMN id SET DEFAULT nextval('public."invoicePayment_id_seq"'::regclass);


--
-- Name: message id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message ALTER COLUMN id SET DEFAULT nextval('public.message_id_seq'::regclass);


--
-- Name: meter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter ALTER COLUMN id SET DEFAULT nextval('public.meter_id_seq'::regclass);


--
-- Name: meterReading id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."meterReading" ALTER COLUMN id SET DEFAULT nextval('public."meterReading_id_seq"'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news ALTER COLUMN id SET DEFAULT nextval('public.news_id_seq'::regclass);


--
-- Name: newsRead id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."newsRead" ALTER COLUMN id SET DEFAULT nextval('public."newsRead_id_seq"'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: onboardingRequest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."onboardingRequest" ALTER COLUMN id SET DEFAULT nextval('public."onboardingRequest_id_seq"'::regclass);


--
-- Name: owner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owner ALTER COLUMN id SET DEFAULT nextval('public.owner_id_seq'::regclass);


--
-- Name: ownerHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ownerHistory" ALTER COLUMN id SET DEFAULT nextval('public."ownerHistory_id_seq"'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: paymentReverseHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paymentReverseHistory" ALTER COLUMN id SET DEFAULT nextval('public."paymentReverseHistory_id_seq"'::regclass);


--
-- Name: plan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan ALTER COLUMN id SET DEFAULT nextval('public.plan_id_seq'::regclass);


--
-- Name: planGoal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."planGoal" ALTER COLUMN id SET DEFAULT nextval('public."planGoal_id_seq"'::regclass);


--
-- Name: poll id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll ALTER COLUMN id SET DEFAULT nextval('public.poll_id_seq'::regclass);


--
-- Name: pollAnswer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollAnswer" ALTER COLUMN id SET DEFAULT nextval('public."pollAnswer_id_seq"'::regclass);


--
-- Name: pollOption id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollOption" ALTER COLUMN id SET DEFAULT nextval('public."pollOption_id_seq"'::regclass);


--
-- Name: pollQuestion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollQuestion" ALTER COLUMN id SET DEFAULT nextval('public."pollQuestion_id_seq"'::regclass);


--
-- Name: pollResponse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollResponse" ALTER COLUMN id SET DEFAULT nextval('public."pollResponse_id_seq"'::regclass);


--
-- Name: qpayHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qpayHistory" ALTER COLUMN id SET DEFAULT nextval('public."qpayHistory_id_seq"'::regclass);


--
-- Name: recurringInvoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."recurringInvoice" ALTER COLUMN id SET DEFAULT nextval('public."recurringInvoice_id_seq"'::regclass);


--
-- Name: rentalAgreement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."rentalAgreement" ALTER COLUMN id SET DEFAULT nextval('public."rentalAgreement_id_seq"'::regclass);


--
-- Name: room id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room ALTER COLUMN id SET DEFAULT nextval('public.room_id_seq'::regclass);


--
-- Name: roomBooking id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomBooking" ALTER COLUMN id SET DEFAULT nextval('public."roomBooking_id_seq"'::regclass);


--
-- Name: roomHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomHistory" ALTER COLUMN id SET DEFAULT nextval('public."roomHistory_id_seq"'::regclass);


--
-- Name: roomType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomType" ALTER COLUMN id SET DEFAULT nextval('public."roomType_id_seq"'::regclass);


--
-- Name: service id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service ALTER COLUMN id SET DEFAULT nextval('public.service_id_seq'::regclass);


--
-- Name: servicePack id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePack" ALTER COLUMN id SET DEFAULT nextval('public."servicePack_id_seq"'::regclass);


--
-- Name: servicePackItem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePackItem" ALTER COLUMN id SET DEFAULT nextval('public."servicePackItem_id_seq"'::regclass);


--
-- Name: servicePackSyncTask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePackSyncTask" ALTER COLUMN id SET DEFAULT nextval('public."servicePackSyncTask_id_seq"'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);


--
-- Name: taskActivity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."taskActivity" ALTER COLUMN id SET DEFAULT nextval('public."taskActivity_id_seq"'::regclass);


--
-- Name: tenant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant ALTER COLUMN id SET DEFAULT nextval('public.tenant_id_seq'::regclass);


--
-- Name: tenantBalance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantBalance" ALTER COLUMN id SET DEFAULT nextval('public."tenantBalance_id_seq"'::regclass);


--
-- Name: tenantBalanceHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantBalanceHistory" ALTER COLUMN id SET DEFAULT nextval('public."tenantBalanceHistory_id_seq"'::regclass);


--
-- Name: tenantHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantHistory" ALTER COLUMN id SET DEFAULT nextval('public."tenantHistory_id_seq"'::regclass);


--
-- Name: tenantMember id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantMember" ALTER COLUMN id SET DEFAULT nextval('public."tenantMember_id_seq"'::regclass);


--
-- Name: userNotification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification" ALTER COLUMN id SET DEFAULT nextval('public."userNotification_id_seq"'::regclass);


--
-- Name: vat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vat ALTER COLUMN id SET DEFAULT nextval('public.vat_id_seq'::regclass);


--
-- Name: worker id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker ALTER COLUMN id SET DEFAULT nextval('public.worker_id_seq'::regclass);


--
-- Name: workerAction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerAction" ALTER COLUMN id SET DEFAULT nextval('public."workerAction_id_seq"'::regclass);


--
-- Name: workerBuilding id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerBuilding" ALTER COLUMN id SET DEFAULT nextval('public."workerBuilding_id_seq"'::regclass);


--
-- Name: workerDeviceToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerDeviceToken" ALTER COLUMN id SET DEFAULT nextval('public."workerDeviceToken_id_seq"'::regclass);


--
-- Name: workerLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerLog" ALTER COLUMN id SET DEFAULT nextval('public."workerLog_id_seq"'::regclass);


--
-- Name: action action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action
    ADD CONSTRAINT action_pkey PRIMARY KEY (id);


--
-- Name: archiveFile archiveFile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."archiveFile"
    ADD CONSTRAINT "archiveFile_pkey" PRIMARY KEY (id);


--
-- Name: bankStatementPayment bankStatementPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatementPayment"
    ADD CONSTRAINT "bankStatementPayment_pkey" PRIMARY KEY (id);


--
-- Name: bankStatement bankStatement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatement"
    ADD CONSTRAINT "bankStatement_pkey" PRIMARY KEY (id);


--
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT block_pkey PRIMARY KEY (id);


--
-- Name: branchBuildingCorporate branchBuildingCorporate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingCorporate"
    ADD CONSTRAINT "branchBuildingCorporate_pkey" PRIMARY KEY (id);


--
-- Name: branchBuildingMessageFormat branchBuildingMessageFormat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingMessageFormat"
    ADD CONSTRAINT "branchBuildingMessageFormat_pkey" PRIMARY KEY (id);


--
-- Name: branchBuildingPaymentInfo branchBuildingPaymentInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingPaymentInfo"
    ADD CONSTRAINT "branchBuildingPaymentInfo_pkey" PRIMARY KEY (id);


--
-- Name: branchBuildingVatInfo branchBuildingVatInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuildingVatInfo"
    ADD CONSTRAINT "branchBuildingVatInfo_pkey" PRIMARY KEY (id);


--
-- Name: branchBuilding branchBuilding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuilding"
    ADD CONSTRAINT "branchBuilding_pkey" PRIMARY KEY (id);


--
-- Name: branchCorporate branchCorporate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchCorporate"
    ADD CONSTRAINT "branchCorporate_pkey" PRIMARY KEY (id);


--
-- Name: branchInvoiceHistory branchInvoiceHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoiceHistory"
    ADD CONSTRAINT "branchInvoiceHistory_pkey" PRIMARY KEY (id);


--
-- Name: branchInvoice branchInvoice_invoiceNo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key1" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key10" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key100; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key100" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key101; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key101" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key102; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key102" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key103; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key103" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key104; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key104" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key105; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key105" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key106; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key106" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key107; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key107" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key108; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key108" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key109; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key109" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key11; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key11" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key110; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key110" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key111; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key111" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key112; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key112" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key113; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key113" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key114; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key114" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key115; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key115" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key116; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key116" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key117; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key117" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key118; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key118" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key119; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key119" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key12; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key12" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key120; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key120" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key121; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key121" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key122; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key122" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key123; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key123" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key124; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key124" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key125; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key125" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key126; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key126" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key127; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key127" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key128; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key128" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key129; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key129" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key13; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key13" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key130; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key130" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key131; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key131" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key132; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key132" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key133; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key133" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key134; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key134" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key135; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key135" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key136; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key136" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key137; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key137" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key138; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key138" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key139; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key139" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key14; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key14" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key140; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key140" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key141; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key141" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key142; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key142" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key143; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key143" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key144; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key144" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key145; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key145" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key146; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key146" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key147; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key147" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key148; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key148" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key149; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key149" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key15; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key15" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key150; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key150" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key151; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key151" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key152; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key152" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key153; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key153" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key154; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key154" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key155; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key155" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key156; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key156" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key157; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key157" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key158; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key158" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key159; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key159" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key16; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key16" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key160; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key160" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key161; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key161" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key162; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key162" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key163; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key163" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key164; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key164" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key165; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key165" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key166; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key166" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key167; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key167" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key168; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key168" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key169; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key169" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key17; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key17" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key170; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key170" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key171; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key171" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key172; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key172" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key173; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key173" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key174; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key174" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key175; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key175" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key176; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key176" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key177; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key177" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key178; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key178" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key179; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key179" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key18; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key18" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key180; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key180" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key181; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key181" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key182; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key182" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key183; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key183" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key184; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key184" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key185; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key185" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key186; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key186" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key187; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key187" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key188; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key188" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key189; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key189" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key19; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key19" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key190; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key190" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key191; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key191" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key192; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key192" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key193; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key193" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key194; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key194" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key195; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key195" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key196; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key196" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key197; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key197" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key198; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key198" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key199; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key199" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key2" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key20; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key20" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key200; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key200" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key201; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key201" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key202; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key202" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key203; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key203" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key204; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key204" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key205; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key205" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key206; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key206" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key207; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key207" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key208; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key208" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key209; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key209" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key21; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key21" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key210; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key210" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key211; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key211" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key212; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key212" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key213; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key213" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key214; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key214" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key215; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key215" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key216; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key216" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key217; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key217" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key218; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key218" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key219; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key219" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key22" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key220; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key220" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key221; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key221" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key222; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key222" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key223; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key223" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key224; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key224" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key225; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key225" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key226; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key226" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key227; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key227" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key228; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key228" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key229; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key229" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key23; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key23" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key230; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key230" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key231; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key231" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key232; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key232" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key233; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key233" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key234; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key234" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key235; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key235" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key236; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key236" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key237; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key237" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key238; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key238" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key239; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key239" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key24; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key24" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key240; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key240" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key241; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key241" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key242; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key242" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key243; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key243" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key244; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key244" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key245; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key245" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key246; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key246" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key247; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key247" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key248; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key248" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key249; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key249" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key25; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key25" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key250; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key250" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key251; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key251" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key252; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key252" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key253; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key253" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key254; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key254" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key255; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key255" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key256; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key256" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key257; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key257" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key258; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key258" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key259; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key259" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key26; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key26" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key260; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key260" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key261; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key261" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key262; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key262" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key263; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key263" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key264; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key264" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key265; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key265" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key266; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key266" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key267; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key267" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key268; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key268" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key269; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key269" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key27" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key270; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key270" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key271; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key271" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key272; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key272" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key273; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key273" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key274; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key274" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key275; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key275" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key276; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key276" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key277; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key277" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key278; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key278" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key279; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key279" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key28; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key28" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key280; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key280" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key281; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key281" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key282; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key282" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key283; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key283" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key284; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key284" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key285; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key285" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key286; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key286" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key287; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key287" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key288; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key288" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key289; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key289" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key29" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key290; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key290" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key291; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key291" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key292; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key292" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key293; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key293" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key294; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key294" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key295; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key295" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key296; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key296" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key297; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key297" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key298; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key298" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key299; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key299" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key3" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key30; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key30" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key300; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key300" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key301; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key301" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key302; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key302" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key303; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key303" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key304; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key304" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key305; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key305" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key306; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key306" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key307; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key307" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key308; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key308" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key309; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key309" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key31; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key31" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key310; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key310" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key311; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key311" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key312; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key312" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key313; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key313" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key314; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key314" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key315; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key315" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key316; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key316" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key317; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key317" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key318; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key318" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key319; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key319" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key32" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key320; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key320" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key321; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key321" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key322; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key322" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key323; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key323" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key324; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key324" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key325; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key325" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key326; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key326" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key327; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key327" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key328; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key328" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key329; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key329" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key33; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key33" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key330; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key330" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key331; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key331" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key332; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key332" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key333; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key333" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key334; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key334" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key335; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key335" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key336; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key336" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key337; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key337" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key338; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key338" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key339; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key339" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key34; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key34" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key340; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key340" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key341; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key341" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key342; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key342" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key343; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key343" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key344; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key344" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key345; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key345" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key346; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key346" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key347; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key347" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key348; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key348" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key349; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key349" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key35; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key35" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key350; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key350" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key351; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key351" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key352; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key352" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key353; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key353" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key354; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key354" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key355; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key355" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key356; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key356" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key357; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key357" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key358; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key358" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key359; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key359" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key36; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key36" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key360; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key360" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key361; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key361" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key362; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key362" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key363; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key363" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key364; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key364" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key365; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key365" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key366; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key366" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key367; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key367" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key368; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key368" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key369; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key369" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key37" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key370; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key370" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key371; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key371" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key372; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key372" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key373; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key373" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key374; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key374" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key375; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key375" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key376; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key376" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key377; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key377" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key378; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key378" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key379; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key379" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key38; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key38" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key380; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key380" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key381; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key381" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key382; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key382" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key383; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key383" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key384; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key384" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key385; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key385" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key386; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key386" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key387; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key387" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key388; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key388" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key389; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key389" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key39" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key390; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key390" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key391; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key391" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key392; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key392" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key393; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key393" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key394; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key394" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key395; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key395" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key396; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key396" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key397; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key397" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key398; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key398" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key4" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key40" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key41; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key41" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key42" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key43; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key43" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key44; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key44" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key45; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key45" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key46; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key46" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key47; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key47" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key48" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key49; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key49" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key5" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key50" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key51; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key51" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key52; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key52" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key53; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key53" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key54; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key54" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key55; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key55" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key56" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key57; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key57" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key58" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key59; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key59" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key6" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key60" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key61" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key62; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key62" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key63; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key63" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key64; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key64" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key65; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key65" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key66; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key66" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key67" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key68; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key68" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key69" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key7" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key70; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key70" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key71; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key71" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key72" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key73" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key74; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key74" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key75; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key75" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key76; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key76" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key77; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key77" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key78; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key78" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key79" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key8" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key80; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key80" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key81; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key81" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key82" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key83; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key83" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key84; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key84" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key85; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key85" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key86; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key86" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key87; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key87" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key88; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key88" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key89; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key89" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key9" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key90; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key90" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key91; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key91" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key92; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key92" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key93; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key93" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key94; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key94" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key95; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key95" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key96" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key97; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key97" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key98; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key98" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_invoiceNo_key99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_invoiceNo_key99" UNIQUE ("invoiceNo");


--
-- Name: branchInvoice branchInvoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchInvoice"
    ADD CONSTRAINT "branchInvoice_pkey" PRIMARY KEY (id);


--
-- Name: branchMessageFormat branchMessageFormat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchMessageFormat"
    ADD CONSTRAINT "branchMessageFormat_pkey" PRIMARY KEY (id);


--
-- Name: branchPaymentInfo branchPaymentInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchPaymentInfo"
    ADD CONSTRAINT "branchPaymentInfo_pkey" PRIMARY KEY (id);


--
-- Name: branchRegistrationStep branchRegistrationStep_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistrationStep"
    ADD CONSTRAINT "branchRegistrationStep_pkey" PRIMARY KEY (id);


--
-- Name: branchRegistration branchRegistration_branchId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistration"
    ADD CONSTRAINT "branchRegistration_branchId_key" UNIQUE ("branchId");


--
-- Name: branchRegistration branchRegistration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistration"
    ADD CONSTRAINT "branchRegistration_pkey" PRIMARY KEY (id);


--
-- Name: branchSupportVar branchSupportVar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchSupportVar"
    ADD CONSTRAINT "branchSupportVar_pkey" PRIMARY KEY (id);


--
-- Name: branchVatInfo branchVatInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchVatInfo"
    ADD CONSTRAINT "branchVatInfo_pkey" PRIMARY KEY (id);


--
-- Name: branchWalletTransaction branchWalletTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWalletTransaction"
    ADD CONSTRAINT "branchWalletTransaction_pkey" PRIMARY KEY (id);


--
-- Name: branchWallet branchWallet_branchId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key1" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key10" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key100; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key100" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key101; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key101" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key102; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key102" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key103; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key103" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key104; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key104" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key105; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key105" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key106; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key106" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key107; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key107" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key108; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key108" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key109; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key109" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key11; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key11" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key110; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key110" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key111; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key111" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key112; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key112" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key113; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key113" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key114; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key114" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key115; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key115" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key116; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key116" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key117; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key117" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key118; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key118" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key119; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key119" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key12; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key12" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key120; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key120" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key121; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key121" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key122; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key122" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key123; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key123" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key124; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key124" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key125; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key125" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key126; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key126" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key127; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key127" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key128; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key128" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key129; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key129" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key13; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key13" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key130; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key130" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key131; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key131" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key132; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key132" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key133; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key133" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key134; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key134" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key135; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key135" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key136; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key136" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key137; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key137" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key138; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key138" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key139; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key139" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key14; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key14" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key140; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key140" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key141; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key141" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key142; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key142" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key143; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key143" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key144; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key144" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key145; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key145" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key146; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key146" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key147; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key147" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key148; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key148" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key149; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key149" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key15; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key15" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key150; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key150" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key151; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key151" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key152; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key152" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key153; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key153" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key154; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key154" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key155; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key155" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key156; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key156" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key157; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key157" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key158; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key158" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key159; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key159" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key16; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key16" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key160; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key160" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key161; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key161" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key162; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key162" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key163; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key163" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key164; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key164" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key165; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key165" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key166; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key166" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key167; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key167" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key168; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key168" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key169; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key169" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key17; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key17" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key170; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key170" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key171; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key171" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key172; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key172" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key173; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key173" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key174; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key174" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key175; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key175" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key176; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key176" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key177; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key177" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key178; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key178" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key179; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key179" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key18; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key18" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key180; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key180" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key181; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key181" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key182; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key182" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key183; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key183" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key184; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key184" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key185; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key185" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key186; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key186" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key187; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key187" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key188; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key188" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key189; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key189" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key19; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key19" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key190; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key190" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key191; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key191" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key192; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key192" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key193; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key193" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key194; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key194" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key195; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key195" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key196; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key196" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key197; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key197" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key198; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key198" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key199; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key199" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key2" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key20; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key20" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key200; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key200" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key201; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key201" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key202; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key202" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key203; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key203" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key204; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key204" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key205; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key205" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key206; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key206" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key207; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key207" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key208; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key208" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key209; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key209" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key21; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key21" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key210; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key210" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key211; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key211" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key212; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key212" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key213; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key213" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key214; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key214" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key215; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key215" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key216; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key216" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key217; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key217" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key218; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key218" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key219; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key219" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key22" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key220; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key220" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key221; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key221" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key222; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key222" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key223; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key223" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key224; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key224" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key225; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key225" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key226; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key226" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key227; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key227" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key228; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key228" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key229; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key229" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key23; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key23" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key230; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key230" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key231; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key231" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key232; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key232" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key233; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key233" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key234; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key234" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key235; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key235" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key236; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key236" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key237; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key237" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key238; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key238" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key239; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key239" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key24; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key24" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key240; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key240" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key241; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key241" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key242; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key242" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key243; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key243" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key244; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key244" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key245; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key245" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key246; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key246" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key247; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key247" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key248; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key248" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key249; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key249" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key25; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key25" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key250; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key250" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key251; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key251" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key252; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key252" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key253; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key253" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key254; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key254" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key255; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key255" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key256; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key256" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key257; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key257" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key258; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key258" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key259; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key259" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key26; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key26" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key260; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key260" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key261; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key261" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key262; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key262" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key263; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key263" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key264; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key264" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key265; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key265" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key266; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key266" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key267; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key267" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key268; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key268" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key269; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key269" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key27" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key270; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key270" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key271; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key271" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key272; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key272" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key273; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key273" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key274; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key274" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key275; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key275" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key276; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key276" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key277; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key277" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key278; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key278" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key279; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key279" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key28; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key28" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key280; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key280" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key281; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key281" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key282; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key282" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key283; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key283" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key284; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key284" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key285; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key285" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key286; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key286" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key287; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key287" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key288; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key288" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key289; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key289" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key29" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key290; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key290" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key291; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key291" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key292; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key292" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key293; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key293" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key294; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key294" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key295; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key295" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key296; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key296" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key297; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key297" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key298; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key298" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key299; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key299" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key3" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key30; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key30" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key300; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key300" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key301; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key301" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key302; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key302" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key303; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key303" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key304; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key304" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key305; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key305" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key306; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key306" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key307; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key307" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key308; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key308" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key309; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key309" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key31; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key31" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key310; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key310" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key311; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key311" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key312; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key312" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key313; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key313" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key314; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key314" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key315; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key315" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key316; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key316" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key317; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key317" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key318; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key318" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key319; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key319" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key32" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key320; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key320" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key321; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key321" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key322; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key322" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key323; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key323" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key324; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key324" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key325; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key325" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key326; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key326" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key327; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key327" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key328; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key328" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key329; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key329" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key33; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key33" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key330; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key330" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key331; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key331" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key332; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key332" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key333; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key333" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key334; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key334" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key335; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key335" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key336; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key336" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key337; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key337" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key338; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key338" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key339; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key339" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key34; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key34" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key340; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key340" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key341; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key341" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key342; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key342" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key343; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key343" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key344; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key344" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key345; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key345" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key346; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key346" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key347; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key347" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key348; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key348" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key349; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key349" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key35; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key35" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key350; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key350" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key351; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key351" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key352; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key352" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key353; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key353" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key354; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key354" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key355; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key355" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key356; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key356" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key357; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key357" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key358; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key358" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key359; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key359" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key36; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key36" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key360; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key360" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key361; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key361" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key362; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key362" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key363; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key363" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key364; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key364" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key365; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key365" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key366; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key366" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key367; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key367" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key368; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key368" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key369; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key369" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key37" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key370; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key370" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key371; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key371" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key372; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key372" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key373; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key373" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key374; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key374" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key375; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key375" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key376; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key376" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key377; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key377" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key378; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key378" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key379; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key379" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key38; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key38" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key380; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key380" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key381; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key381" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key382; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key382" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key383; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key383" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key384; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key384" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key385; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key385" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key386; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key386" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key387; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key387" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key388; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key388" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key389; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key389" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key39" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key390; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key390" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key391; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key391" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key392; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key392" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key393; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key393" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key394; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key394" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key395; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key395" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key396; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key396" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key4" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key40" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key41; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key41" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key42" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key43; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key43" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key44; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key44" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key45; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key45" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key46; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key46" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key47; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key47" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key48" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key49; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key49" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key5" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key50" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key51; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key51" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key52; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key52" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key53; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key53" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key54; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key54" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key55; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key55" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key56" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key57; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key57" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key58" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key59; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key59" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key6" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key60" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key61" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key62; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key62" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key63; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key63" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key64; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key64" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key65; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key65" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key66; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key66" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key67" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key68; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key68" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key69" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key7" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key70; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key70" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key71; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key71" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key72" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key73" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key74; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key74" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key75; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key75" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key76; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key76" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key77; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key77" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key78; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key78" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key79" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key8" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key80; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key80" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key81; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key81" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key82" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key83; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key83" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key84; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key84" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key85; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key85" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key86; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key86" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key87; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key87" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key88; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key88" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key89; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key89" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key9" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key90; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key90" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key91; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key91" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key92; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key92" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key93; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key93" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key94; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key94" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key95; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key95" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key96" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key97; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key97" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key98; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key98" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_branchId_key99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_branchId_key99" UNIQUE ("branchId");


--
-- Name: branchWallet branchWallet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWallet"
    ADD CONSTRAINT "branchWallet_pkey" PRIMARY KEY (id);


--
-- Name: branchWorkReport branchWorkReport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWorkReport"
    ADD CONSTRAINT "branchWorkReport_pkey" PRIMARY KEY (id);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- Name: building building_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_pkey PRIMARY KEY (id);


--
-- Name: capitalCategory capitalCategory_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key1" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key10" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key100; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key100" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key101; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key101" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key102; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key102" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key103; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key103" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key104; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key104" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key105; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key105" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key106; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key106" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key107; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key107" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key108; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key108" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key109; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key109" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key11; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key11" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key110; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key110" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key111; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key111" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key112; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key112" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key113; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key113" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key114; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key114" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key115; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key115" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key116; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key116" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key117; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key117" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key118; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key118" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key119; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key119" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key12; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key12" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key120; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key120" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key121; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key121" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key122; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key122" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key123; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key123" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key124; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key124" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key125; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key125" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key126; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key126" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key127; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key127" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key128; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key128" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key129; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key129" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key13; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key13" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key130; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key130" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key131; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key131" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key132; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key132" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key133; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key133" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key134; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key134" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key135; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key135" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key136; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key136" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key137; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key137" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key138; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key138" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key139; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key139" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key14; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key14" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key140; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key140" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key141; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key141" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key142; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key142" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key143; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key143" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key144; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key144" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key145; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key145" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key146; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key146" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key147; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key147" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key148; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key148" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key149; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key149" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key15; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key15" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key150; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key150" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key151; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key151" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key152; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key152" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key153; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key153" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key154; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key154" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key155; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key155" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key156; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key156" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key157; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key157" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key158; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key158" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key159; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key159" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key16; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key16" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key160; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key160" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key161; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key161" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key162; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key162" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key163; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key163" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key164; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key164" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key165; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key165" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key166; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key166" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key167; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key167" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key168; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key168" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key169; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key169" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key17; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key17" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key170; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key170" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key171; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key171" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key172; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key172" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key173; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key173" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key174; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key174" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key175; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key175" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key176; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key176" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key177; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key177" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key178; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key178" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key179; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key179" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key18; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key18" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key180; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key180" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key181; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key181" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key182; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key182" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key183; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key183" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key184; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key184" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key185; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key185" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key186; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key186" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key187; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key187" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key188; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key188" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key189; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key189" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key19; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key19" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key190; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key190" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key191; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key191" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key192; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key192" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key193; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key193" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key194; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key194" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key195; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key195" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key196; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key196" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key197; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key197" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key198; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key198" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key199; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key199" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key2" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key20; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key20" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key200; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key200" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key201; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key201" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key202; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key202" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key203; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key203" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key204; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key204" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key205; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key205" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key206; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key206" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key207; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key207" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key208; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key208" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key209; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key209" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key21; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key21" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key210; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key210" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key211; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key211" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key212; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key212" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key213; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key213" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key214; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key214" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key215; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key215" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key216; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key216" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key217; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key217" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key218; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key218" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key219; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key219" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key22" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key220; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key220" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key221; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key221" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key222; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key222" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key223; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key223" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key224; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key224" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key225; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key225" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key226; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key226" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key227; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key227" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key228; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key228" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key229; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key229" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key23; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key23" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key230; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key230" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key231; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key231" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key232; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key232" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key233; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key233" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key234; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key234" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key235; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key235" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key236; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key236" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key237; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key237" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key238; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key238" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key239; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key239" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key24; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key24" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key240; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key240" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key241; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key241" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key242; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key242" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key243; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key243" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key244; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key244" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key245; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key245" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key246; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key246" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key247; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key247" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key248; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key248" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key249; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key249" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key25; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key25" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key250; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key250" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key251; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key251" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key252; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key252" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key253; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key253" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key254; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key254" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key255; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key255" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key256; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key256" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key257; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key257" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key258; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key258" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key259; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key259" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key26; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key26" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key260; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key260" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key261; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key261" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key262; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key262" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key263; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key263" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key264; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key264" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key265; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key265" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key266; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key266" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key267; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key267" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key268; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key268" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key269; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key269" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key27" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key270; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key270" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key271; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key271" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key272; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key272" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key273; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key273" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key274; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key274" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key275; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key275" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key276; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key276" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key277; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key277" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key278; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key278" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key279; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key279" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key28; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key28" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key280; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key280" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key281; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key281" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key282; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key282" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key283; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key283" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key284; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key284" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key285; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key285" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key286; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key286" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key287; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key287" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key288; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key288" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key289; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key289" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key29" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key290; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key290" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key291; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key291" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key292; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key292" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key293; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key293" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key294; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key294" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key295; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key295" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key296; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key296" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key297; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key297" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key298; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key298" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key299; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key299" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key3" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key30; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key30" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key300; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key300" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key301; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key301" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key302; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key302" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key303; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key303" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key304; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key304" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key305; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key305" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key306; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key306" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key307; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key307" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key308; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key308" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key309; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key309" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key31; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key31" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key310; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key310" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key311; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key311" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key312; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key312" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key313; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key313" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key314; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key314" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key315; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key315" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key316; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key316" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key317; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key317" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key318; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key318" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key319; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key319" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key32" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key320; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key320" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key321; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key321" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key322; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key322" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key323; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key323" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key324; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key324" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key325; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key325" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key326; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key326" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key327; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key327" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key328; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key328" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key329; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key329" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key33; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key33" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key330; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key330" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key331; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key331" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key332; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key332" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key333; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key333" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key334; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key334" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key335; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key335" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key336; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key336" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key337; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key337" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key338; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key338" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key339; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key339" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key34; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key34" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key340; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key340" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key341; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key341" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key342; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key342" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key343; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key343" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key344; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key344" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key345; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key345" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key346; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key346" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key347; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key347" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key348; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key348" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key349; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key349" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key35; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key35" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key350; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key350" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key351; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key351" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key352; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key352" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key353; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key353" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key354; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key354" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key355; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key355" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key356; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key356" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key357; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key357" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key358; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key358" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key359; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key359" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key36; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key36" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key360; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key360" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key361; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key361" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key362; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key362" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key363; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key363" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key364; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key364" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key365; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key365" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key366; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key366" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key367; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key367" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key368; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key368" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key369; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key369" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key37" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key370; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key370" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key371; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key371" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key372; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key372" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key373; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key373" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key374; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key374" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key375; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key375" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key376; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key376" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key377; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key377" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key378; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key378" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key379; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key379" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key38; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key38" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key380; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key380" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key381; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key381" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key382; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key382" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key383; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key383" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key384; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key384" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key385; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key385" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key386; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key386" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key387; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key387" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key388; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key388" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key389; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key389" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key39" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key390; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key390" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key391; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key391" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key392; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key392" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key393; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key393" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key394; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key394" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key395; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key395" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key396; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key396" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key397; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key397" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key398; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key398" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key399; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key399" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key4" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key40" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key400; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key400" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key401; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key401" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key402; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key402" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key403; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key403" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key404; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key404" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key405; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key405" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key406; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key406" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key407; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key407" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key408; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key408" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key409; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key409" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key41; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key41" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key410; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key410" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key411; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key411" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key412; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key412" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key413; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key413" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key414; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key414" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key415; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key415" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key416; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key416" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key417; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key417" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key418; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key418" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key419; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key419" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key42" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key420; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key420" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key421; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key421" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key422; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key422" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key423; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key423" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key424; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key424" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key425; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key425" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key426; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key426" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key427; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key427" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key428; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key428" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key429; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key429" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key43; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key43" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key430; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key430" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key431; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key431" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key432; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key432" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key433; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key433" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key434; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key434" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key435; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key435" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key436; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key436" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key437; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key437" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key438; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key438" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key439; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key439" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key44; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key44" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key440; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key440" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key441; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key441" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key442; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key442" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key443; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key443" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key444; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key444" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key445; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key445" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key446; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key446" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key447; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key447" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key448; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key448" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key449; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key449" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key45; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key45" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key450; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key450" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key451; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key451" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key452; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key452" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key453; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key453" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key454; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key454" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key455; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key455" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key456; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key456" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key457; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key457" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key458; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key458" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key459; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key459" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key46; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key46" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key460; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key460" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key461; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key461" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key462; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key462" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key463; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key463" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key464; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key464" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key465; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key465" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key466; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key466" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key467; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key467" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key468; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key468" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key469; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key469" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key47; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key47" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key470; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key470" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key471; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key471" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key472; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key472" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key473; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key473" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key474; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key474" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key475; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key475" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key476; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key476" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key477; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key477" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key478; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key478" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key479; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key479" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key48" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key480; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key480" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key481; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key481" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key482; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key482" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key483; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key483" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key484; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key484" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key485; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key485" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key486; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key486" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key487; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key487" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key488; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key488" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key489; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key489" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key49; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key49" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key490; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key490" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key491; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key491" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key492; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key492" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key493; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key493" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key494; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key494" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key495; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key495" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key496; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key496" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key497; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key497" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key498; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key498" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key499; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key499" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key5" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key50" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key500; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key500" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key501; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key501" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key502; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key502" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key503; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key503" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key504; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key504" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key505; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key505" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key506; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key506" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key507; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key507" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key508; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key508" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key509; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key509" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key51; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key51" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key510; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key510" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key52; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key52" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key53; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key53" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key54; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key54" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key55; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key55" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key56" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key57; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key57" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key58" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key59; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key59" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key6" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key60" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key61" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key62; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key62" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key63; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key63" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key64; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key64" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key65; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key65" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key66; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key66" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key67" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key68; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key68" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key69" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key7" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key70; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key70" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key71; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key71" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key72" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key73" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key74; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key74" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key75; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key75" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key76; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key76" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key77; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key77" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key78; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key78" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key79" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key8" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key80; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key80" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key81; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key81" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key82" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key83; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key83" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key84; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key84" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key85; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key85" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key86; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key86" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key87; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key87" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key88; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key88" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key89; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key89" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key9" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key90; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key90" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key91; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key91" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key92; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key92" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key93; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key93" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key94; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key94" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key95; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key95" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key96" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key97; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key97" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key98; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key98" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_name_key99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_name_key99" UNIQUE (name);


--
-- Name: capitalCategory capitalCategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalCategory"
    ADD CONSTRAINT "capitalCategory_pkey" PRIMARY KEY (id);


--
-- Name: capitalDisposal capitalDisposal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalDisposal"
    ADD CONSTRAINT "capitalDisposal_pkey" PRIMARY KEY (id);


--
-- Name: capitalItem capitalItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalItem"
    ADD CONSTRAINT "capitalItem_pkey" PRIMARY KEY (id);


--
-- Name: capitalLocation capitalLocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalLocation"
    ADD CONSTRAINT "capitalLocation_pkey" PRIMARY KEY (id);


--
-- Name: capitalMaintenance capitalMaintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."capitalMaintenance"
    ADD CONSTRAINT "capitalMaintenance_pkey" PRIMARY KEY (id);


--
-- Name: contractBalanceHistory contractBalanceHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalanceHistory"
    ADD CONSTRAINT "contractBalanceHistory_pkey" PRIMARY KEY (id);


--
-- Name: contractBalance contractBalance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalance"
    ADD CONSTRAINT "contractBalance_pkey" PRIMARY KEY (id);


--
-- Name: contractDepositHistory contractDepositHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractDepositHistory"
    ADD CONSTRAINT "contractDepositHistory_pkey" PRIMARY KEY (id);


--
-- Name: contractDepositInvoice contractDepositInvoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractDepositInvoice"
    ADD CONSTRAINT "contractDepositInvoice_pkey" PRIMARY KEY (id);


--
-- Name: contractHistory contractHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractHistory"
    ADD CONSTRAINT "contractHistory_pkey" PRIMARY KEY (id);


--
-- Name: contractRemainReason contractRemainReason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRemainReason"
    ADD CONSTRAINT "contractRemainReason_pkey" PRIMARY KEY (id);


--
-- Name: contractRoomService contractRoomService_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoomService"
    ADD CONSTRAINT "contractRoomService_pkey" PRIMARY KEY (id);


--
-- Name: contractRoom contractRoom_contractId_roomId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoom"
    ADD CONSTRAINT "contractRoom_contractId_roomId_key" UNIQUE ("contractId", "roomId");


--
-- Name: contractRoom contractRoom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoom"
    ADD CONSTRAINT "contractRoom_pkey" PRIMARY KEY (id);


--
-- Name: contractTemplate contractTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractTemplate"
    ADD CONSTRAINT "contractTemplate_pkey" PRIMARY KEY (id);


--
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (id);


--
-- Name: ekontorCredential ekontorCredential_branchId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ekontorCredential"
    ADD CONSTRAINT "ekontorCredential_branchId_key" UNIQUE ("branchId");


--
-- Name: ekontorCredential ekontorCredential_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ekontorCredential"
    ADD CONSTRAINT "ekontorCredential_pkey" PRIMARY KEY (id);


--
-- Name: email email_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_pkey PRIMARY KEY (id);


--
-- Name: floor floor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floor
    ADD CONSTRAINT floor_pkey PRIMARY KEY (id);


--
-- Name: helpRequest helpRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."helpRequest"
    ADD CONSTRAINT "helpRequest_pkey" PRIMARY KEY (id);


--
-- Name: internalMilestone internalMilestone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalMilestone"
    ADD CONSTRAINT "internalMilestone_pkey" PRIMARY KEY (id);


--
-- Name: internalPlan internalPlan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalPlan"
    ADD CONSTRAINT "internalPlan_pkey" PRIMARY KEY (id);


--
-- Name: internalWorkTask internalWorkTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalWorkTask"
    ADD CONSTRAINT "internalWorkTask_pkey" PRIMARY KEY (id);


--
-- Name: invoiceBucket invoiceBucket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceBucket"
    ADD CONSTRAINT "invoiceBucket_pkey" PRIMARY KEY (id);


--
-- Name: invoiceItemService invoiceItemService_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItemService"
    ADD CONSTRAINT "invoiceItemService_pkey" PRIMARY KEY (id);


--
-- Name: invoiceItem invoiceItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_pkey" PRIMARY KEY (id);


--
-- Name: invoiceLateFee invoiceLateFee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceLateFee"
    ADD CONSTRAINT "invoiceLateFee_pkey" PRIMARY KEY (id);


--
-- Name: invoicePayment invoicePayment_invoiceId_paymentId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoicePayment"
    ADD CONSTRAINT "invoicePayment_invoiceId_paymentId_key" UNIQUE ("invoiceId", "paymentId");


--
-- Name: invoicePayment invoicePayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoicePayment"
    ADD CONSTRAINT "invoicePayment_pkey" PRIMARY KEY (id);


--
-- Name: invoice invoice_invoiceNo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key1" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key10" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key100; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key100" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key101; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key101" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key102; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key102" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key103; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key103" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key104; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key104" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key105; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key105" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key106; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key106" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key107; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key107" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key108; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key108" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key109; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key109" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key11; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key11" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key110; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key110" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key111; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key111" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key112; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key112" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key113; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key113" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key114; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key114" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key115; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key115" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key116; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key116" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key117; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key117" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key118; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key118" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key119; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key119" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key12; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key12" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key120; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key120" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key121; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key121" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key122; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key122" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key123; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key123" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key124; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key124" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key125; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key125" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key126; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key126" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key127; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key127" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key128; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key128" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key129; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key129" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key13; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key13" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key130; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key130" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key131; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key131" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key132; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key132" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key133; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key133" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key134; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key134" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key135; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key135" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key136; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key136" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key137; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key137" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key138; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key138" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key139; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key139" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key14; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key14" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key140; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key140" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key141; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key141" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key142; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key142" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key143; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key143" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key144; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key144" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key145; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key145" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key146; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key146" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key147; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key147" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key148; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key148" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key149; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key149" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key15; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key15" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key150; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key150" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key151; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key151" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key152; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key152" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key153; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key153" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key154; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key154" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key155; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key155" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key156; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key156" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key157; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key157" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key158; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key158" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key159; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key159" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key16; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key16" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key160; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key160" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key161; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key161" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key162; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key162" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key163; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key163" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key164; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key164" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key165; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key165" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key166; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key166" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key167; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key167" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key168; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key168" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key169; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key169" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key17; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key17" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key170; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key170" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key171; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key171" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key172; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key172" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key173; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key173" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key174; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key174" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key175; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key175" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key176; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key176" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key177; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key177" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key178; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key178" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key179; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key179" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key18; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key18" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key180; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key180" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key181; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key181" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key182; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key182" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key183; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key183" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key184; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key184" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key185; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key185" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key186; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key186" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key187; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key187" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key188; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key188" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key189; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key189" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key19; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key19" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key190; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key190" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key191; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key191" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key192; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key192" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key193; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key193" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key194; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key194" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key195; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key195" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key196; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key196" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key197; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key197" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key198; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key198" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key199; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key199" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key2" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key20; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key20" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key200; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key200" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key201; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key201" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key202; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key202" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key203; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key203" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key204; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key204" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key205; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key205" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key206; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key206" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key207; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key207" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key208; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key208" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key209; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key209" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key21; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key21" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key210; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key210" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key211; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key211" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key212; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key212" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key213; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key213" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key214; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key214" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key215; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key215" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key216; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key216" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key217; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key217" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key218; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key218" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key219; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key219" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key22" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key220; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key220" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key221; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key221" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key222; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key222" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key223; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key223" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key224; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key224" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key225; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key225" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key226; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key226" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key227; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key227" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key228; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key228" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key229; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key229" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key23; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key23" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key230; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key230" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key231; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key231" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key232; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key232" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key233; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key233" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key234; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key234" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key235; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key235" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key236; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key236" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key237; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key237" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key238; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key238" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key239; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key239" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key24; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key24" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key240; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key240" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key241; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key241" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key242; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key242" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key243; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key243" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key244; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key244" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key245; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key245" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key246; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key246" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key247; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key247" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key248; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key248" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key249; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key249" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key25; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key25" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key250; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key250" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key251; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key251" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key252; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key252" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key253; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key253" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key254; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key254" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key255; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key255" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key256; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key256" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key257; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key257" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key258; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key258" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key259; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key259" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key26; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key26" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key260; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key260" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key27; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key27" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key28; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key28" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key29" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key3" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key30; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key30" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key31; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key31" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key32" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key33; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key33" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key34; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key34" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key35; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key35" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key36; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key36" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key37" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key38; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key38" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key39; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key39" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key4" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key40; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key40" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key41; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key41" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key42; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key42" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key43; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key43" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key44; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key44" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key45; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key45" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key46; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key46" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key47; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key47" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key48" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key49; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key49" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key5" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key50" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key51; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key51" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key52; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key52" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key53; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key53" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key54; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key54" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key55; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key55" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key56" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key57; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key57" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key58" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key59; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key59" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key6" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key60" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key61" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key62; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key62" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key63; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key63" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key64; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key64" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key65; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key65" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key66; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key66" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key67" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key68; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key68" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key69" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key7" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key70; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key70" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key71; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key71" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key72" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key73" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key74; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key74" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key75; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key75" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key76; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key76" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key77; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key77" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key78; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key78" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key79" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key8" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key80; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key80" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key81; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key81" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key82" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key83; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key83" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key84; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key84" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key85; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key85" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key86; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key86" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key87; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key87" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key88; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key88" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key89; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key89" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key9; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key9" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key90; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key90" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key91; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key91" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key92; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key92" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key93; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key93" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key94; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key94" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key95; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key95" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key96" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key97; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key97" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key98; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key98" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_invoiceNo_key99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_invoiceNo_key99" UNIQUE ("invoiceNo");


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: meterReading meterReading_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."meterReading"
    ADD CONSTRAINT "meterReading_pkey" PRIMARY KEY (id);


--
-- Name: meter meter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT meter_pkey PRIMARY KEY (id);


--
-- Name: newsRead newsRead_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."newsRead"
    ADD CONSTRAINT "newsRead_pkey" PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: onboardingRequest onboardingRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."onboardingRequest"
    ADD CONSTRAINT "onboardingRequest_pkey" PRIMARY KEY (id);


--
-- Name: ownerHistory ownerHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ownerHistory"
    ADD CONSTRAINT "ownerHistory_pkey" PRIMARY KEY (id);


--
-- Name: owner owner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pkey PRIMARY KEY (id);


--
-- Name: paymentReverseHistory paymentReverseHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paymentReverseHistory"
    ADD CONSTRAINT "paymentReverseHistory_pkey" PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: planGoal planGoal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."planGoal"
    ADD CONSTRAINT "planGoal_pkey" PRIMARY KEY (id);


--
-- Name: plan plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan
    ADD CONSTRAINT plan_pkey PRIMARY KEY (id);


--
-- Name: pollAnswer pollAnswer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollAnswer"
    ADD CONSTRAINT "pollAnswer_pkey" PRIMARY KEY (id);


--
-- Name: pollOption pollOption_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollOption"
    ADD CONSTRAINT "pollOption_pkey" PRIMARY KEY (id);


--
-- Name: pollQuestion pollQuestion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollQuestion"
    ADD CONSTRAINT "pollQuestion_pkey" PRIMARY KEY (id);


--
-- Name: pollResponse pollResponse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollResponse"
    ADD CONSTRAINT "pollResponse_pkey" PRIMARY KEY (id);


--
-- Name: poll poll_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT poll_pkey PRIMARY KEY (id);


--
-- Name: qpayHistory qpayHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qpayHistory"
    ADD CONSTRAINT "qpayHistory_pkey" PRIMARY KEY (id);


--
-- Name: recurringInvoice recurringInvoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."recurringInvoice"
    ADD CONSTRAINT "recurringInvoice_pkey" PRIMARY KEY (id);


--
-- Name: rentalAgreement rentalAgreement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."rentalAgreement"
    ADD CONSTRAINT "rentalAgreement_pkey" PRIMARY KEY (id);


--
-- Name: roomBookingSetting roomBookingSetting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomBookingSetting"
    ADD CONSTRAINT "roomBookingSetting_pkey" PRIMARY KEY ("roomId");


--
-- Name: roomBooking roomBooking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomBooking"
    ADD CONSTRAINT "roomBooking_pkey" PRIMARY KEY (id);


--
-- Name: roomHistory roomHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomHistory"
    ADD CONSTRAINT "roomHistory_pkey" PRIMARY KEY (id);


--
-- Name: roomType roomType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomType"
    ADD CONSTRAINT "roomType_pkey" PRIMARY KEY (id);


--
-- Name: room room_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (id);


--
-- Name: servicePackItem servicePackItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePackItem"
    ADD CONSTRAINT "servicePackItem_pkey" PRIMARY KEY (id);


--
-- Name: servicePackItem servicePackItem_servicePackId_order_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePackItem"
    ADD CONSTRAINT "servicePackItem_servicePackId_order_key" UNIQUE ("servicePackId", "order");


--
-- Name: servicePackSyncTask servicePackSyncTask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePackSyncTask"
    ADD CONSTRAINT "servicePackSyncTask_pkey" PRIMARY KEY (id);


--
-- Name: servicePack servicePack_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."servicePack"
    ADD CONSTRAINT "servicePack_pkey" PRIMARY KEY (id);


--
-- Name: service service_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (id);


--
-- Name: taskActivity taskActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."taskActivity"
    ADD CONSTRAINT "taskActivity_pkey" PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: tenantBalanceHistory tenantBalanceHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantBalanceHistory"
    ADD CONSTRAINT "tenantBalanceHistory_pkey" PRIMARY KEY (id);


--
-- Name: tenantBalance tenantBalance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantBalance"
    ADD CONSTRAINT "tenantBalance_pkey" PRIMARY KEY (id);


--
-- Name: tenantHistory tenantHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantHistory"
    ADD CONSTRAINT "tenantHistory_pkey" PRIMARY KEY (id);


--
-- Name: tenantMember tenantMember_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."tenantMember"
    ADD CONSTRAINT "tenantMember_pkey" PRIMARY KEY (id);


--
-- Name: tenant tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (id);


--
-- Name: userNotification userNotification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_pkey" PRIMARY KEY (id);


--
-- Name: vat vat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vat
    ADD CONSTRAINT vat_pkey PRIMARY KEY (id);


--
-- Name: workerAction workerAction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerAction"
    ADD CONSTRAINT "workerAction_pkey" PRIMARY KEY (id);


--
-- Name: workerBuilding workerBuilding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerBuilding"
    ADD CONSTRAINT "workerBuilding_pkey" PRIMARY KEY (id);


--
-- Name: workerDeviceToken workerDeviceToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerDeviceToken"
    ADD CONSTRAINT "workerDeviceToken_pkey" PRIMARY KEY (id);


--
-- Name: workerLog workerLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerLog"
    ADD CONSTRAINT "workerLog_pkey" PRIMARY KEY (id);


--
-- Name: worker worker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_pkey PRIMARY KEY (id);


--
-- Name: PRIMARY; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PRIMARY" ON public.building USING btree (id);


--
-- Name: archive_file_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX archive_file_branch_id ON public."archiveFile" USING btree ("branchId");


--
-- Name: bankStatementPayment_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatementPayment_contract_idx" ON public."bankStatementPayment" USING btree ("contractId");


--
-- Name: bankStatementPayment_payment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatementPayment_payment_idx" ON public."bankStatementPayment" USING btree ("paymentId");


--
-- Name: bankStatementPayment_statement_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatementPayment_statement_idx" ON public."bankStatementPayment" USING btree ("bankStatementId");


--
-- Name: bankStatement_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatement_branch_idx" ON public."bankStatement" USING btree ("branchId");


--
-- Name: bankStatement_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatement_date_idx" ON public."bankStatement" USING btree ("transactionDate");


--
-- Name: bankStatement_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "bankStatement_status_idx" ON public."bankStatement" USING btree (status);


--
-- Name: bankStatement_unique_tx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "bankStatement_unique_tx" ON public."bankStatement" USING btree ("accountNumber", "externalId");


--
-- Name: block_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX block_code_unique ON public.block USING btree (code);


--
-- Name: branchBuildingCorporate_branch_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchBuildingCorporate_branch_building_idx" ON public."branchBuildingCorporate" USING btree ("branchId", "buildingId");


--
-- Name: branchBuildingMessageFormat_branch_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchBuildingMessageFormat_branch_building_idx" ON public."branchBuildingMessageFormat" USING btree ("branchId", "buildingId");


--
-- Name: branchBuildingPaymentInfo_branch_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchBuildingPaymentInfo_branch_building_idx" ON public."branchBuildingPaymentInfo" USING btree ("branchId", "buildingId");


--
-- Name: branchBuildingVatInfo_branchId_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchBuildingVatInfo_branchId_index" ON public."branchBuildingVatInfo" USING btree ("branchId", "buildingId");


--
-- Name: branchCorporate_branchId_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchCorporate_branchId_index" ON public."branchCorporate" USING btree ("branchId");


--
-- Name: branchInvoiceHistory_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoiceHistory_action_idx" ON public."branchInvoiceHistory" USING btree (action);


--
-- Name: branchInvoiceHistory_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoiceHistory_branch_idx" ON public."branchInvoiceHistory" USING btree ("branchId");


--
-- Name: branchInvoiceHistory_invoice_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoiceHistory_invoice_idx" ON public."branchInvoiceHistory" USING btree ("branchInvoiceId");


--
-- Name: branchInvoice_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoice_branch_idx" ON public."branchInvoice" USING btree ("branchId");


--
-- Name: branchInvoice_branch_period_system_fee_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "branchInvoice_branch_period_system_fee_unique" ON public."branchInvoice" USING btree ("branchId", "periodMonth") WHERE ((meta ->> 'type'::text) = 'SYSTEM_FEE'::text);


--
-- Name: branchInvoice_period_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoice_period_idx" ON public."branchInvoice" USING btree ("periodMonth");


--
-- Name: branchInvoice_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchInvoice_status_idx" ON public."branchInvoice" USING btree (status);


--
-- Name: branchMessageFormat_branchId_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchMessageFormat_branchId_index" ON public."branchMessageFormat" USING btree ("branchId");


--
-- Name: branchPaymentInfo_branchId_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchPaymentInfo_branchId_index" ON public."branchPaymentInfo" USING btree ("branchId");


--
-- Name: branchVatInfo_branchId_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchVatInfo_branchId_index" ON public."branchVatInfo" USING btree ("branchId");


--
-- Name: branchWalletTx_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchWalletTx_branch_idx" ON public."branchWalletTransaction" USING btree ("branchId");


--
-- Name: branchWalletTx_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchWalletTx_type_idx" ON public."branchWalletTransaction" USING btree (type);


--
-- Name: branchWalletTx_wallet_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchWalletTx_wallet_idx" ON public."branchWalletTransaction" USING btree ("walletId");


--
-- Name: branchWallet_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "branchWallet_branch_idx" ON public."branchWallet" USING btree ("branchId");


--
-- Name: branchWallet_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "branchWallet_status_idx" ON public."branchWallet" USING btree (status);


--
-- Name: branch_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_id_index ON public.building USING btree ("branchId");


--
-- Name: branch_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_name_index ON public.branch USING btree (name);


--
-- Name: branch_registration_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_registration_status_idx ON public."branchRegistration" USING btree (status);


--
-- Name: branch_registration_step_branch_step_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX branch_registration_step_branch_step_idx ON public."branchRegistrationStep" USING btree ("branchId", "stepCode");


--
-- Name: branch_support_var_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_support_var_branch_idx ON public."branchSupportVar" USING btree ("branchId");


--
-- Name: branch_support_var_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX branch_support_var_name_idx ON public."branchSupportVar" USING btree ("branchId", "variableName");


--
-- Name: branch_work_report_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX branch_work_report_branch_idx ON public."branchWorkReport" USING btree ("branchId");


--
-- Name: building_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX building_code_unique ON public.building USING btree (code);


--
-- Name: building_id_index_block; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX building_id_index_block ON public.block USING btree ("buildingId");


--
-- Name: capital_code_branch_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX capital_code_branch_unique ON public."capitalItem" USING btree ("branchId", code);


--
-- Name: contract_balance_contract_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_balance_contract_unique_idx ON public."contractBalance" USING btree (contract_id);


--
-- Name: contract_balance_history_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_balance_history_contract_idx ON public."contractBalanceHistory" USING btree (contract_id);


--
-- Name: contract_balance_history_payment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_balance_history_payment_idx ON public."contractBalanceHistory" USING btree (payment_id);


--
-- Name: contract_branch_no_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_branch_no_unique ON public.contract USING btree ("branchId", "contractNo");


--
-- Name: contract_counterparty_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_counterparty_type_idx ON public.contract USING btree ("counterpartyType");


--
-- Name: contract_date_range_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_date_range_idx ON public.contract USING btree ("startDate", "endDate");


--
-- Name: contract_deposit_history_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_history_contract_idx ON public."contractDepositHistory" USING btree ("contractId");


--
-- Name: contract_deposit_history_invoice_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_history_invoice_idx ON public."contractDepositHistory" USING btree ("contractDepositInvoiceId");


--
-- Name: contract_deposit_history_payment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_history_payment_idx ON public."contractDepositHistory" USING btree ("paymentId");


--
-- Name: contract_deposit_history_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_history_type_idx ON public."contractDepositHistory" USING btree (type);


--
-- Name: contract_deposit_invoice_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_invoice_contract_idx ON public."contractDepositInvoice" USING btree ("contractId");


--
-- Name: contract_deposit_invoice_no_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_deposit_invoice_no_uidx ON public."contractDepositInvoice" USING btree ("invoiceNo");


--
-- Name: contract_deposit_invoice_payment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_invoice_payment_idx ON public."contractDepositInvoice" USING btree ("paymentId");


--
-- Name: contract_deposit_invoice_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_deposit_invoice_status_idx ON public."contractDepositInvoice" USING btree (status);


--
-- Name: contract_invoice_recipient_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_invoice_recipient_owner_idx ON public.contract USING btree ("invoiceRecipientOwnerId");


--
-- Name: contract_invoice_recipient_rental_agreement_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_invoice_recipient_rental_agreement_idx ON public.contract USING btree ("invoiceRecipientRentalAgreementId");


--
-- Name: contract_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_owner_idx ON public.contract USING btree ("ownerId");


--
-- Name: contract_remain_reason_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX contract_remain_reason_contract_idx ON public."contractRemainReason" USING btree (contract_id);


--
-- Name: contract_room_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_room_index ON public."contractRoom" USING btree ("contractId", "roomId");


--
-- Name: contract_room_service_pack_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_room_service_pack_contract_idx ON public."contractRoom" USING btree ("servicePackId", "contractId");


--
-- Name: contract_room_service_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_room_service_room_idx ON public."contractRoomService" USING btree ("contractRoomId");


--
-- Name: contract_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_status_idx ON public.contract USING btree (status);


--
-- Name: contract_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contract_tenant_idx ON public.contract USING btree ("tenantId");


--
-- Name: email_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX email_branch_id ON public.email USING btree ("branchId");


--
-- Name: email_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX email_contract_id ON public.email USING btree ("contractId");


--
-- Name: email_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX email_tenant_id ON public.email USING btree ("tenantId");


--
-- Name: floor_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX floor_block_idx ON public.floor USING btree ("blockId");


--
-- Name: floor_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX floor_building_idx ON public.floor USING btree ("buildingId");


--
-- Name: internal_milestone_plan_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX internal_milestone_plan_idx ON public."internalMilestone" USING btree ("planId");


--
-- Name: internal_plan_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX internal_plan_branch_idx ON public."internalPlan" USING btree ("branchId");


--
-- Name: internal_work_task_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX internal_work_task_unique ON public."internalWorkTask" USING btree ("milestoneId", "workerId", "offsetDays", "occurrenceDate");


--
-- Name: invoice_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_branch_idx ON public.invoice USING btree ("branchId");


--
-- Name: invoice_branch_month_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_branch_month_idx ON public.invoice USING btree ("branchId", "invoiceMonth");


--
-- Name: invoice_branch_month_no_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_branch_month_no_idx ON public.invoice USING btree ("branchId", "invoiceMonth", "invoiceNo");


--
-- Name: invoice_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_contract_idx ON public.invoice USING btree ("contractId");


--
-- Name: invoice_contract_month_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_contract_month_idx ON public.invoice USING btree ("contractId", "invoiceMonth");


--
-- Name: invoice_contract_status_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_contract_status_type_idx ON public.invoice USING btree ("contractId", status, type);


--
-- Name: invoice_due_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_due_date_idx ON public.invoice USING btree ("dueDate");


--
-- Name: invoice_item_contract_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_contract_room_idx ON public."invoiceItem" USING btree ("contractRoomId");


--
-- Name: invoice_item_invoice_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_invoice_idx ON public."invoiceItem" USING btree ("invoiceId");


--
-- Name: invoice_item_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_room_idx ON public."invoiceItem" USING btree ("roomId");


--
-- Name: invoice_item_service_invoice_item_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_service_invoice_item_idx ON public."invoiceItemService" USING btree ("invoiceItemId");


--
-- Name: invoice_item_service_invoice_service_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_service_invoice_service_idx ON public."invoiceItemService" USING btree ("invoiceItemId", "serviceId");


--
-- Name: invoice_item_service_service_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_item_service_service_idx ON public."invoiceItemService" USING btree ("serviceId");


--
-- Name: invoice_month_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_month_idx ON public.invoice USING btree ("invoiceMonth");


--
-- Name: invoice_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_owner_idx ON public.invoice USING btree ("ownerId");


--
-- Name: invoice_payer_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_payer_type_idx ON public.invoice USING btree ("payerType");


--
-- Name: invoice_payment_invoice_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_payment_invoice_idx ON public."invoicePayment" USING btree ("invoiceId");


--
-- Name: invoice_payment_payment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_payment_payment_idx ON public."invoicePayment" USING btree ("paymentId");


--
-- Name: invoice_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_status_idx ON public.invoice USING btree (status);


--
-- Name: invoice_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_tenant_idx ON public.invoice USING btree ("tenantId");


--
-- Name: invoice_tenant_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_tenant_status_idx ON public.invoice USING btree ("tenantId", status);


--
-- Name: invoice_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoice_type_idx ON public.invoice USING btree (type);


--
-- Name: meter_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_block_idx ON public.meter USING btree ("blockId");


--
-- Name: meter_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_branch_idx ON public.meter USING btree ("branchId");


--
-- Name: meter_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_building_idx ON public.meter USING btree ("buildingId");


--
-- Name: meter_contract_room_service_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_contract_room_service_idx ON public.meter USING btree ("contractRoomServiceId");


--
-- Name: meter_external_public_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX meter_external_public_unique ON public.meter USING btree ("externalProvider", "externalPublicId") WHERE ("externalPublicId" IS NOT NULL);


--
-- Name: meter_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_room_idx ON public.meter USING btree ("roomId");


--
-- Name: meter_serial_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX meter_serial_unique ON public.meter USING btree ("serialNo");


--
-- Name: meter_service_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_service_idx ON public.meter USING btree ("serviceId");


--
-- Name: meter_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meter_status_idx ON public.meter USING btree (status);


--
-- Name: mr_meter_month_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mr_meter_month_unique ON public."meterReading" USING btree ("meterId", "invoiceMonth") WHERE ("invoiceMonth" IS NOT NULL);


--
-- Name: mr_meter_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mr_meter_time_idx ON public."meterReading" USING btree ("meterId", "readingAt");


--
-- Name: news_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_end_date ON public.news USING btree ("endDate");


--
-- Name: news_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_is_active ON public.news USING btree ("isActive");


--
-- Name: news_read_news_id_worker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX news_read_news_id_worker_id ON public."newsRead" USING btree ("newsId", "workerId");


--
-- Name: news_read_worker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_read_worker_id ON public."newsRead" USING btree ("workerId");


--
-- Name: news_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_start_date ON public.news USING btree ("startDate");


--
-- Name: notification_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_branch_idx ON public.notification USING btree ("branchId");


--
-- Name: notification_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_status_idx ON public.notification USING btree (status);


--
-- Name: notification_worker_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_worker_idx ON public.notification USING btree ("workerId");


--
-- Name: onboarding_request_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX onboarding_request_email ON public."onboardingRequest" USING btree (email);


--
-- Name: onboarding_request_state_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX onboarding_request_state_token ON public."onboardingRequest" USING btree ("stateToken");


--
-- Name: onboarding_request_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX onboarding_request_status ON public."onboardingRequest" USING btree (status);


--
-- Name: ownerHistory_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ownerHistory_action_idx" ON public."ownerHistory" USING btree (action);


--
-- Name: ownerHistory_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ownerHistory_owner_idx" ON public."ownerHistory" USING btree ("ownerId");


--
-- Name: owner_branch_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX owner_branch_index ON public.owner USING btree ("branchId");


--
-- Name: owner_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX owner_name_index ON public.owner USING btree (name);


--
-- Name: plan_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_branch_id ON public.plan USING btree ("branchId");


--
-- Name: plan_goal_deadline; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_goal_deadline ON public."planGoal" USING btree (deadline);


--
-- Name: plan_goal_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_goal_plan_id ON public."planGoal" USING btree ("planId");


--
-- Name: plan_goal_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_goal_status ON public."planGoal" USING btree (status);


--
-- Name: plan_horizon; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_horizon ON public.plan USING btree (horizon);


--
-- Name: plan_period_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_period_start ON public.plan USING btree ("periodStart");


--
-- Name: plan_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plan_status ON public.plan USING btree (status);


--
-- Name: poll_answer_question_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_answer_question_idx ON public."pollAnswer" USING btree ("questionId");


--
-- Name: poll_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_branch_idx ON public.poll USING btree ("branchId");


--
-- Name: poll_option_question_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_option_question_idx ON public."pollOption" USING btree ("questionId");


--
-- Name: poll_question_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_question_poll_idx ON public."pollQuestion" USING btree ("pollId");


--
-- Name: poll_response_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_response_poll_idx ON public."pollResponse" USING btree ("pollId");


--
-- Name: rental_agreement_branch_no_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rental_agreement_branch_no_unique ON public."rentalAgreement" USING btree ("branchId", "agreementNo");


--
-- Name: rental_agreement_one_active_room; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rental_agreement_one_active_room ON public."rentalAgreement" USING btree ("roomId") WHERE ((status)::text = 'ACTIVE'::text);


--
-- Name: rental_agreement_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rental_agreement_owner_idx ON public."rentalAgreement" USING btree ("ownerId");


--
-- Name: rental_agreement_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rental_agreement_room_idx ON public."rentalAgreement" USING btree ("roomId");


--
-- Name: rental_agreement_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rental_agreement_tenant_idx ON public."rentalAgreement" USING btree ("tenantId");


--
-- Name: roomBooking_branch_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "roomBooking_branch_start" ON public."roomBooking" USING btree ("branchId", "startTime");


--
-- Name: roomBooking_room_interval; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "roomBooking_room_interval" ON public."roomBooking" USING btree ("roomId", "startTime", "endTime");


--
-- Name: room_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_block_idx ON public.room USING btree ("blockId");


--
-- Name: room_booking_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_booking_branch_id ON public."roomBooking" USING btree ("branchId");


--
-- Name: room_booking_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_booking_room_id ON public."roomBooking" USING btree ("roomId");


--
-- Name: room_booking_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_booking_start_time ON public."roomBooking" USING btree ("startTime");


--
-- Name: room_booking_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_booking_status ON public."roomBooking" USING btree (status);


--
-- Name: room_building_block_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_building_block_idx ON public.room USING btree ("buildingId", "blockId");


--
-- Name: room_building_floor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_building_floor_idx ON public.room USING btree ("buildingId", "floorId");


--
-- Name: room_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_building_idx ON public.room USING btree ("buildingId");


--
-- Name: room_building_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_building_status_idx ON public.room USING btree ("buildingId", status);


--
-- Name: room_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX room_code_unique ON public.room USING btree (code);


--
-- Name: room_contract_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_contract_idx ON public.room USING btree ("contractId");


--
-- Name: room_floor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_floor_idx ON public.room USING btree ("floorId");


--
-- Name: room_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_owner_idx ON public.room USING btree ("ownerId");


--
-- Name: room_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_status_idx ON public.room USING btree (status);


--
-- Name: room_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_tenant_idx ON public.room USING btree ("tenantId");


--
-- Name: servicePack_buildingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "servicePack_buildingId_idx" ON public."servicePack" USING btree ("buildingId");


--
-- Name: service_pack_sync_pack_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_pack_sync_pack_id ON public."servicePackSyncTask" USING btree ("servicePackId", id);


--
-- Name: service_pack_sync_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_pack_sync_status_id ON public."servicePackSyncTask" USING btree (status, id);


--
-- Name: service_pack_sync_worker; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_pack_sync_worker ON public."servicePackSyncTask" USING btree ("branchId", "workerId", "createdAt");


--
-- Name: task_assigned_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_assigned_idx ON public.task USING btree ("assignedWorkerId");


--
-- Name: task_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_branch_idx ON public.task USING btree ("branchId");


--
-- Name: task_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_status_idx ON public.task USING btree (status);


--
-- Name: tenantHistory_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tenantHistory_action_idx" ON public."tenantHistory" USING btree (action);


--
-- Name: tenantHistory_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tenantHistory_tenant_idx" ON public."tenantHistory" USING btree ("tenantId");


--
-- Name: tenant_balance_history_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_balance_history_tenant_idx ON public."tenantBalanceHistory" USING btree (tenant_id);


--
-- Name: tenant_balance_tenant_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tenant_balance_tenant_unique_idx ON public."tenantBalance" USING btree (tenant_id);


--
-- Name: tenant_branch_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_branch_index ON public.tenant USING btree ("branchId");


--
-- Name: tenant_member_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_member_tenant_idx ON public."tenantMember" USING btree ("tenantId");


--
-- Name: tenant_member_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_member_user_idx ON public."tenantMember" USING btree ("userId");


--
-- Name: tenant_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_user_index ON public.tenant USING btree ("userId");


--
-- Name: user_notification_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_branch_id ON public."userNotification" USING btree ("branchId");


--
-- Name: user_notification_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_contract_id ON public."userNotification" USING btree ("contractId");


--
-- Name: user_notification_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_tenant_id ON public."userNotification" USING btree ("tenantId");


--
-- Name: workerBuilding_building_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "workerBuilding_building_idx" ON public."workerBuilding" USING btree ("buildingId");


--
-- Name: workerBuilding_worker_building_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "workerBuilding_worker_building_unique" ON public."workerBuilding" USING btree ("workerId", "buildingId");


--
-- Name: workerBuilding_worker_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "workerBuilding_worker_idx" ON public."workerBuilding" USING btree ("workerId");


--
-- Name: workerDeviceToken_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "workerDeviceToken_branch_idx" ON public."workerDeviceToken" USING btree ("branchId");


--
-- Name: workerDeviceToken_token_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "workerDeviceToken_token_unique" ON public."workerDeviceToken" USING btree (token);


--
-- Name: workerDeviceToken_worker_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "workerDeviceToken_worker_idx" ON public."workerDeviceToken" USING btree ("workerId");


--
-- Name: worker_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_branch_id ON public.worker USING btree ("branchId");


--
-- Name: worker_user_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_user_name ON public.worker USING btree ("userName");


--
-- Name: bankStatementPayment bankStatementPayment_bankStatementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatementPayment"
    ADD CONSTRAINT "bankStatementPayment_bankStatementId_fkey" FOREIGN KEY ("bankStatementId") REFERENCES public."bankStatement"(id) ON DELETE CASCADE;


--
-- Name: bankStatementPayment bankStatementPayment_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatementPayment"
    ADD CONSTRAINT "bankStatementPayment_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public.contract(id) ON DELETE SET NULL;


--
-- Name: bankStatementPayment bankStatementPayment_paymentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankStatementPayment"
    ADD CONSTRAINT "bankStatementPayment_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES public.payment(id) ON DELETE CASCADE;


--
-- Name: block block_buildingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT "block_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES public.building(id) ON DELETE CASCADE;


--
-- Name: branchBuilding branchBuilding_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuilding"
    ADD CONSTRAINT "branchBuilding_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: branchBuilding branchBuilding_buildingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchBuilding"
    ADD CONSTRAINT "branchBuilding_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES public.building(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: branchRegistrationStep branchRegistrationStep_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistrationStep"
    ADD CONSTRAINT "branchRegistrationStep_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: branchRegistrationStep branchRegistrationStep_completedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistrationStep"
    ADD CONSTRAINT "branchRegistrationStep_completedBy_fkey" FOREIGN KEY ("completedBy") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: branchRegistration branchRegistration_activatedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistration"
    ADD CONSTRAINT "branchRegistration_activatedBy_fkey" FOREIGN KEY ("activatedBy") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: branchRegistration branchRegistration_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchRegistration"
    ADD CONSTRAINT "branchRegistration_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: branchWorkReport branchWorkReport_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWorkReport"
    ADD CONSTRAINT "branchWorkReport_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: branchWorkReport branchWorkReport_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."branchWorkReport"
    ADD CONSTRAINT "branchWorkReport_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: contractBalanceHistory contractBalanceHistory_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalanceHistory"
    ADD CONSTRAINT "contractBalanceHistory_contract_id_fkey" FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON DELETE CASCADE;


--
-- Name: contractBalanceHistory contractBalanceHistory_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalanceHistory"
    ADD CONSTRAINT "contractBalanceHistory_payment_id_fkey" FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON DELETE SET NULL;


--
-- Name: contractBalance contractBalance_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractBalance"
    ADD CONSTRAINT "contractBalance_contract_id_fkey" FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON DELETE CASCADE;


--
-- Name: contractRemainReason contractRemainReason_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRemainReason"
    ADD CONSTRAINT "contractRemainReason_contract_id_fkey" FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON DELETE CASCADE;


--
-- Name: contractRemainReason contractRemainReason_worker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRemainReason"
    ADD CONSTRAINT "contractRemainReason_worker_id_fkey" FOREIGN KEY (worker_id) REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: contractRoom contractRoom_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoom"
    ADD CONSTRAINT "contractRoom_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public.contract(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: contractRoom contractRoom_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."contractRoom"
    ADD CONSTRAINT "contractRoom_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.room(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: internalMilestone internalMilestone_planId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalMilestone"
    ADD CONSTRAINT "internalMilestone_planId_fkey" FOREIGN KEY ("planId") REFERENCES public."internalPlan"(id) ON DELETE CASCADE;


--
-- Name: internalPlan internalPlan_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalPlan"
    ADD CONSTRAINT "internalPlan_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: internalPlan internalPlan_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalPlan"
    ADD CONSTRAINT "internalPlan_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: internalWorkTask internalWorkTask_milestoneId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalWorkTask"
    ADD CONSTRAINT "internalWorkTask_milestoneId_fkey" FOREIGN KEY ("milestoneId") REFERENCES public."internalMilestone"(id) ON DELETE CASCADE;


--
-- Name: internalWorkTask internalWorkTask_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalWorkTask"
    ADD CONSTRAINT "internalWorkTask_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.task(id) ON DELETE SET NULL;


--
-- Name: internalWorkTask internalWorkTask_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."internalWorkTask"
    ADD CONSTRAINT "internalWorkTask_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON DELETE CASCADE;


--
-- Name: meterReading meterReading_meterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."meterReading"
    ADD CONSTRAINT "meterReading_meterId_fkey" FOREIGN KEY ("meterId") REFERENCES public.meter(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: meter meter_blockId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT "meter_blockId_fkey" FOREIGN KEY ("blockId") REFERENCES public.block(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: meter meter_buildingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT "meter_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES public.building(id) ON UPDATE CASCADE;


--
-- Name: meter meter_floorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT "meter_floorId_fkey" FOREIGN KEY ("floorId") REFERENCES public.floor(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: meter meter_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT "meter_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.room(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: meter meter_serviceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meter
    ADD CONSTRAINT "meter_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES public.service(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: planGoal planGoal_planId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."planGoal"
    ADD CONSTRAINT "planGoal_planId_fkey" FOREIGN KEY ("planId") REFERENCES public.plan(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pollAnswer pollAnswer_optionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollAnswer"
    ADD CONSTRAINT "pollAnswer_optionId_fkey" FOREIGN KEY ("optionId") REFERENCES public."pollOption"(id) ON DELETE CASCADE;


--
-- Name: pollAnswer pollAnswer_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollAnswer"
    ADD CONSTRAINT "pollAnswer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."pollQuestion"(id) ON DELETE CASCADE;


--
-- Name: pollAnswer pollAnswer_responseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollAnswer"
    ADD CONSTRAINT "pollAnswer_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES public."pollResponse"(id) ON DELETE CASCADE;


--
-- Name: pollOption pollOption_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollOption"
    ADD CONSTRAINT "pollOption_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."pollQuestion"(id) ON DELETE CASCADE;


--
-- Name: pollQuestion pollQuestion_pollId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollQuestion"
    ADD CONSTRAINT "pollQuestion_pollId_fkey" FOREIGN KEY ("pollId") REFERENCES public.poll(id) ON DELETE CASCADE;


--
-- Name: pollResponse pollResponse_pollId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollResponse"
    ADD CONSTRAINT "pollResponse_pollId_fkey" FOREIGN KEY ("pollId") REFERENCES public.poll(id) ON DELETE CASCADE;


--
-- Name: pollResponse pollResponse_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."pollResponse"
    ADD CONSTRAINT "pollResponse_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: poll poll_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT "poll_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: poll poll_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT "poll_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public.worker(id) ON DELETE SET NULL;


--
-- Name: roomHistory roomHistory_roomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."roomHistory"
    ADD CONSTRAINT "roomHistory_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES public.room(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room room_blockId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_blockId_fkey" FOREIGN KEY ("blockId") REFERENCES public.block(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: room room_buildingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES public.building(id) ON UPDATE CASCADE;


--
-- Name: room room_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public.contract(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: room room_floorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_floorId_fkey" FOREIGN KEY ("floorId") REFERENCES public.floor(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: room room_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: room room_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT "room_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public.tenant(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: workerAction workerAction_actionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerAction"
    ADD CONSTRAINT "workerAction_actionId_fkey" FOREIGN KEY ("actionId") REFERENCES public.action(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: workerAction workerAction_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerAction"
    ADD CONSTRAINT "workerAction_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: workerBuilding workerBuilding_buildingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerBuilding"
    ADD CONSTRAINT "workerBuilding_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES public.building(id) ON DELETE CASCADE;


--
-- Name: workerBuilding workerBuilding_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerBuilding"
    ADD CONSTRAINT "workerBuilding_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON DELETE CASCADE;


--
-- Name: workerDeviceToken workerDeviceToken_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerDeviceToken"
    ADD CONSTRAINT "workerDeviceToken_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public.branch(id) ON DELETE SET NULL;


--
-- Name: workerDeviceToken workerDeviceToken_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerDeviceToken"
    ADD CONSTRAINT "workerDeviceToken_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON DELETE CASCADE;


--
-- Name: workerLog workerLog_updatedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerLog"
    ADD CONSTRAINT "workerLog_updatedBy_fkey" FOREIGN KEY ("updatedBy") REFERENCES public.worker(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: workerLog workerLog_workerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."workerLog"
    ADD CONSTRAINT "workerLog_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES public.worker(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Zq0S6AWHahuthdRsvOU6b0VAwr1n7p8cLfUIT6GFhJ2PUO0fESoqIdOPbZGuNUF

