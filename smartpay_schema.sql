--
-- PostgreSQL database dump
--

\restrict MrtYB8v9MJpZNVxMjWXKEFSZbJhkzOtCS7SfxIxvUZCXfKoot1eyUwQMe0PQXlL

-- Dumped from database version 16.11 (Debian 16.11-1.pgdg13+1)
-- Dumped by pg_dump version 16.11 (Debian 16.11-1.pgdg13+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin (
    id integer NOT NULL,
    username character varying(50),
    password character varying(200),
    name character varying(50),
    email character varying(255),
    phone character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: admin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_id_seq OWNED BY public.admin.id;


--
-- Name: aiFunctionCall; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."aiFunctionCall" (
    id integer NOT NULL,
    answer character varying(2000),
    name character varying(500),
    description character varying(1000),
    image character varying(500),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: aiFunctionCall_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."aiFunctionCall_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aiFunctionCall_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."aiFunctionCall_id_seq" OWNED BY public."aiFunctionCall".id;


--
-- Name: bankTransactionLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."bankTransactionLog" (
    id integer NOT NULL,
    "bankName" character varying(50),
    "trnDate" timestamp with time zone,
    "relatedAccount" character varying(30),
    "journalNo" character varying(30),
    "recordId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "accountNumber" character varying(30) NOT NULL,
    amount numeric(20,2),
    description character varying(255),
    remain numeric(25,2)
);


--
-- Name: bankTransactionLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."bankTransactionLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bankTransactionLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."bankTransactionLog_id_seq" OWNED BY public."bankTransactionLog".id;


--
-- Name: card; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card (
    id integer NOT NULL,
    "userId" integer,
    tokenid integer,
    brand character varying(50),
    bankname character varying(255),
    expdate character varying(20),
    maskedpan character varying(255),
    status character varying(50),
    "cardName" character varying(255),
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    approved boolean
);


--
-- Name: card_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.card_id_seq OWNED BY public.card.id;


--
-- Name: faq; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.faq (
    id integer NOT NULL,
    question character varying(500),
    "gotAnswer" boolean DEFAULT false,
    type character varying(100),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "aiFunctionCallId" integer
);


--
-- Name: faq_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.faq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: faq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.faq_id_seq OWNED BY public.faq.id;


--
-- Name: incomeTransaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."incomeTransaction" (
    id integer NOT NULL,
    "merchantId" integer,
    "accountNumber" character varying(50),
    "bankCode" character varying(10),
    "merchantSettleId" integer,
    status character varying(20),
    "settledAt" timestamp with time zone,
    "journalNo" character varying(50),
    amount numeric(20,2),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "fromAccountNumber" character varying(30),
    fee numeric(20,2)
);


--
-- Name: incomeTransaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."incomeTransaction_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incomeTransaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."incomeTransaction_id_seq" OWNED BY public."incomeTransaction".id;


--
-- Name: invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice (
    id integer NOT NULL,
    "userId" integer,
    phone character varying(8),
    "merchantId" integer,
    description character varying(100),
    "returnUrl" character varying(300),
    "successCallback" character varying(300),
    "callBackResponse" character varying(100),
    amount numeric(20,2),
    status character varying(50),
    "productPaymentType" character varying(20),
    "secureId" character varying(100),
    "feeAmount" numeric(20,2) DEFAULT 0,
    "totalAmount" numeric(25,2) DEFAULT 0,
    "invoiceItemCount" integer DEFAULT 1,
    "subMerchantRegister" character varying(20) DEFAULT 1,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "paymentMethodId" integer
);


--
-- Name: invoiceItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceItem" (
    id integer NOT NULL,
    "accountNumber" character varying(255),
    amount numeric(20,2),
    description character varying(100),
    status character varying(50),
    "successCallback" character varying(300),
    "bankCode" character varying(10),
    "callBackResponse" character varying(300),
    "invoiceId" integer,
    "productTypeId" integer,
    "vatInfoId" integer,
    "transactionId" integer,
    data json,
    "subMerchantRegister" character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: invoiceItemVatInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."invoiceItemVatInfo" (
    id integer NOT NULL,
    "merchantRegister" character varying(20) NOT NULL,
    type character varying(20) NOT NULL,
    "companyRegister" character varying(20),
    "easyRegister" character varying(20),
    "qrJson" json,
    status character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "requestData" json,
    "time" numeric(7,2)
);


--
-- Name: invoiceItemVatInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."invoiceItemVatInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoiceItemVatInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."invoiceItemVatInfo_id_seq" OWNED BY public."invoiceItemVatInfo".id;


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
-- Name: log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log (
    id integer NOT NULL,
    "merchantId" integer,
    ip character varying(50),
    data json,
    description character varying(500),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: merchant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    email character varying(50),
    phone character varying(15) NOT NULL,
    phone2 character varying(15),
    register character varying(10),
    "authUsername" character varying(50),
    "authPassword" character varying(100),
    address character varying(100),
    "productTypeId" integer,
    "feePercent" numeric(10,2) DEFAULT 10,
    "spayFeePercent" numeric(10,2) DEFAULT 1,
    "accountNumber" character varying(50) DEFAULT 1,
    "bankCode" character varying(10),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userFee" numeric(10,2) DEFAULT 0,
    "userFeeType" character varying(10) DEFAULT 'PERCENT'::character varying,
    "iconPath" character varying(100),
    slogan character varying(300),
    pack character varying(30)
);


--
-- Name: merchantBillings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantBillings" (
    id integer NOT NULL,
    "merchantId" integer,
    "billFeeType" character varying(100) DEFAULT 'PER'::character varying NOT NULL,
    "billFee" numeric(20,2) DEFAULT 0,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: merchantBillings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantBillings_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantBillings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantBillings_id_seq" OWNED BY public."merchantBillings".id;


--
-- Name: merchantInvoiceCountDetails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantInvoiceCountDetails" (
    id integer NOT NULL,
    description character varying(1000),
    count integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "merchantInvoiceId" integer,
    rate numeric(20,2),
    total numeric(20,2)
);


--
-- Name: merchantInvoiceCountDetails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantInvoiceCountDetails_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantInvoiceCountDetails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantInvoiceCountDetails_id_seq" OWNED BY public."merchantInvoiceCountDetails".id;


--
-- Name: merchantInvoiceItems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantInvoiceItems" (
    id integer NOT NULL,
    description character varying(255) NOT NULL,
    quantity integer NOT NULL,
    rate numeric(10,2) NOT NULL,
    amount numeric(12,2) NOT NULL,
    "merchantInvoiceId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: merchantInvoiceItems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantInvoiceItems_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantInvoiceItems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantInvoiceItems_id_seq" OWNED BY public."merchantInvoiceItems".id;


--
-- Name: merchantInvoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantInvoices" (
    id integer NOT NULL,
    "dueDate" date,
    total numeric(12,2) NOT NULL,
    paid numeric(12,2) DEFAULT 0,
    status character varying(255) DEFAULT 'CREATED'::character varying,
    "merchantId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "paidJournalNo" character varying,
    "paidDate" date,
    description character varying(1000),
    "validUntil" date,
    "vatLogId" integer,
    amount numeric(12,2),
    "vatAmount" numeric(12,2)
);


--
-- Name: merchantInvoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantInvoices_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantInvoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantInvoices_id_seq" OWNED BY public."merchantInvoices".id;


--
-- Name: merchantPermission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantPermission" (
    id integer NOT NULL,
    "merchantId" integer NOT NULL,
    "permissionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: merchantPermission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantPermission_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantPermission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantPermission_id_seq" OWNED BY public."merchantPermission".id;


--
-- Name: merchantSettle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."merchantSettle" (
    id integer NOT NULL,
    "merchantId" integer,
    amount numeric(20,2),
    count integer,
    "spayFeePercent" numeric(10,2),
    status character varying(50),
    "settledAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "settledType" character varying(50),
    "subMerchantAmount" numeric(20,2),
    "merchantAmount" numeric(20,2),
    "xpayAmount" numeric(20,2),
    "processingAmount" numeric(20,2)
);


--
-- Name: merchantSettle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."merchantSettle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchantSettle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."merchantSettle_id_seq" OWNED BY public."merchantSettle".id;


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
-- Name: negdiHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."negdiHistory" (
    id integer NOT NULL,
    "invoiceId" integer,
    checkid character varying(100),
    tranid character varying(100),
    status character varying(50),
    "settleId" integer,
    "paymentType" character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: negdiHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."negdiHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: negdiHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."negdiHistory_id_seq" OWNED BY public."negdiHistory".id;


--
-- Name: negdiJoinCardHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."negdiJoinCardHistory" (
    id integer NOT NULL,
    "userId" integer,
    checkid character varying(100),
    tranid character varying(100),
    status character varying(100),
    "cancelStatus" character varying(20),
    "cancelApprovalCode" character varying(20),
    amount numeric(10,2),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: negdiJoinCardHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."negdiJoinCardHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: negdiJoinCardHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."negdiJoinCardHistory_id_seq" OWNED BY public."negdiJoinCardHistory".id;


--
-- Name: passwordResetToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."passwordResetToken" (
    id integer NOT NULL,
    "merchantId" integer,
    token character varying(255),
    expires_at timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: passwordResetToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."passwordResetToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passwordResetToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."passwordResetToken_id_seq" OWNED BY public."passwordResetToken".id;


--
-- Name: paymentMethod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."paymentMethod" (
    id integer NOT NULL,
    name character varying(50),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: paymentMethod_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."paymentMethod_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paymentMethod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."paymentMethod_id_seq" OWNED BY public."paymentMethod".id;


--
-- Name: permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    description character varying(200),
    type character varying(20) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_id_seq OWNED BY public.permission.id;


--
-- Name: pos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pos (
    id integer NOT NULL,
    supplier character varying(50),
    mark character varying(50),
    status character varying(50),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "vatMerchantId" integer,
    "transactionName" character varying(100)
);


--
-- Name: pos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pos_id_seq OWNED BY public.pos.id;


--
-- Name: productType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."productType" (
    id integer NOT NULL,
    name character varying(100),
    "paymentType" character varying(100),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "settleType" character varying(30) NOT NULL
);


--
-- Name: productType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."productType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: productType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."productType_id_seq" OWNED BY public."productType".id;


--
-- Name: qpayHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."qpayHistory" (
    id integer NOT NULL,
    "invoiceId" integer,
    "qpayId" character varying(200),
    "callBackUrl" character varying(200),
    status character varying(20),
    checked boolean,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "qpayType" character varying
);


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
-- Name: sbIncome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."sbIncome" (
    id integer NOT NULL,
    date date NOT NULL,
    total numeric(20,2),
    commission numeric(20,2) NOT NULL,
    "merchantFee" numeric(20,2),
    "billingSubs" numeric(20,2),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: sbIncomeByMerchant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."sbIncomeByMerchant" (
    id integer NOT NULL,
    "merchantId" integer,
    date date NOT NULL,
    total numeric(20,2),
    commission numeric(20,2) NOT NULL,
    "merchantFee" numeric(20,2),
    "billingSubs" numeric(20,2),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "sbIncomeId" integer
);


--
-- Name: sbIncomeByMerchant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."sbIncomeByMerchant_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sbIncomeByMerchant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."sbIncomeByMerchant_id_seq" OWNED BY public."sbIncomeByMerchant".id;


--
-- Name: sbIncome_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."sbIncome_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sbIncome_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."sbIncome_id_seq" OWNED BY public."sbIncome".id;


--
-- Name: settle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settle (
    id integer NOT NULL,
    type character varying(30),
    "recordId" integer,
    amount numeric(25,2),
    "rawJson" text,
    extracted integer,
    status character varying(30),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: settle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settle_id_seq OWNED BY public.settle.id;


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket (
    id integer NOT NULL,
    "merchantId" integer,
    problem character varying(1500),
    "problemTypeId" integer,
    stage character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ticketComment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ticketComment" (
    id integer NOT NULL,
    "ticketId" integer,
    comment character varying(1500),
    notified character varying(150),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: ticketComment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ticketComment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketComment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ticketComment_id_seq" OWNED BY public."ticketComment".id;


--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_id_seq OWNED BY public.ticket.id;


--
-- Name: token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token (
    id integer NOT NULL,
    token character varying(1000),
    type character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_id_seq OWNED BY public.token.id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    "invoiceItemId" integer,
    "accountNumber" character varying(30),
    "bankCode" character varying(10),
    description character varying(100),
    status character varying(100),
    "settledAt" timestamp with time zone,
    "journalNo" character varying(50),
    "settleType" character varying(50),
    amount numeric(20,2),
    "merchantFee" numeric(20,2),
    "spayFee" numeric(20,2),
    "merchantSettleId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "fromAccountNumber" character varying,
    "merchantFeePercent" numeric(5,2),
    "xpayFee" numeric(20,2),
    "xpayFeePercent" numeric(5,2),
    "afterFeeAmount" numeric(20,2),
    "processingFee" numeric(20,2),
    "processingFeePercent" numeric(5,2),
    type character varying(30)
);


--
-- Name: transactionBucket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."transactionBucket" (
    id integer NOT NULL,
    "transactionIds" character varying(5000),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "totalAmount" numeric(20,2),
    "totalCount" numeric,
    "accountNumber" character varying(30) NOT NULL,
    "bankCode" character varying(10) NOT NULL,
    "merchantId" numeric NOT NULL,
    status character varying,
    "fromAccountNumber" character varying(50),
    "totalFee" numeric(20,2)
);


--
-- Name: transactionBucket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."transactionBucket_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactionBucket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."transactionBucket_id_seq" OWNED BY public."transactionBucket".id;


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: userPin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userPin" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "tranPin" character varying(1000) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userPin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userPin_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userPin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userPin_id_seq" OWNED BY public."userPin".id;


--
-- Name: vatLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."vatLog" (
    id integer NOT NULL,
    "merchantId" integer,
    ip character varying(30),
    "qrJson" json,
    "requestData" json,
    status character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "time" numeric(7,2)
);


--
-- Name: vatLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."vatLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vatLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."vatLog_id_seq" OWNED BY public."vatLog".id;


--
-- Name: vatMerchant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."vatMerchant" (
    id integer NOT NULL,
    name character varying(100),
    "createrMerchantId" integer,
    register character varying(10),
    "serviceName" character varying(200),
    "serviceCode" character varying(20),
    "vatDistrictCode" character varying(4),
    "taxType" character varying(20),
    "merchantTin" character varying(20),
    "taxProductCode" character varying(20),
    approved character varying(20),
    status character varying(20),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "feePercent" numeric(5,2),
    "accountNumber" character varying(30),
    "bankCode" character varying(8),
    individual boolean
);


--
-- Name: vatMerchantPos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."vatMerchantPos" (
    id integer NOT NULL,
    "posId" integer,
    "vatMerchantId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "poId" integer
);


--
-- Name: vatMerchantPos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."vatMerchantPos_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vatMerchantPos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."vatMerchantPos_id_seq" OWNED BY public."vatMerchantPos".id;


--
-- Name: vatMerchant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."vatMerchant_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vatMerchant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."vatMerchant_id_seq" OWNED BY public."vatMerchant".id;


--
-- Name: admin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin ALTER COLUMN id SET DEFAULT nextval('public.admin_id_seq'::regclass);


--
-- Name: aiFunctionCall id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."aiFunctionCall" ALTER COLUMN id SET DEFAULT nextval('public."aiFunctionCall_id_seq"'::regclass);


--
-- Name: bankTransactionLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankTransactionLog" ALTER COLUMN id SET DEFAULT nextval('public."bankTransactionLog_id_seq"'::regclass);


--
-- Name: card id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card ALTER COLUMN id SET DEFAULT nextval('public.card_id_seq'::regclass);


--
-- Name: faq id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faq ALTER COLUMN id SET DEFAULT nextval('public.faq_id_seq'::regclass);


--
-- Name: incomeTransaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."incomeTransaction" ALTER COLUMN id SET DEFAULT nextval('public."incomeTransaction_id_seq"'::regclass);


--
-- Name: invoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice ALTER COLUMN id SET DEFAULT nextval('public.invoice_id_seq'::regclass);


--
-- Name: invoiceItem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem" ALTER COLUMN id SET DEFAULT nextval('public."invoiceItem_id_seq"'::regclass);


--
-- Name: invoiceItemVatInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItemVatInfo" ALTER COLUMN id SET DEFAULT nextval('public."invoiceItemVatInfo_id_seq"'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: merchant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant ALTER COLUMN id SET DEFAULT nextval('public.merchant_id_seq'::regclass);


--
-- Name: merchantBillings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantBillings" ALTER COLUMN id SET DEFAULT nextval('public."merchantBillings_id_seq"'::regclass);


--
-- Name: merchantInvoiceCountDetails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceCountDetails" ALTER COLUMN id SET DEFAULT nextval('public."merchantInvoiceCountDetails_id_seq"'::regclass);


--
-- Name: merchantInvoiceItems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceItems" ALTER COLUMN id SET DEFAULT nextval('public."merchantInvoiceItems_id_seq"'::regclass);


--
-- Name: merchantInvoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoices" ALTER COLUMN id SET DEFAULT nextval('public."merchantInvoices_id_seq"'::regclass);


--
-- Name: merchantPermission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantPermission" ALTER COLUMN id SET DEFAULT nextval('public."merchantPermission_id_seq"'::regclass);


--
-- Name: merchantSettle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantSettle" ALTER COLUMN id SET DEFAULT nextval('public."merchantSettle_id_seq"'::regclass);


--
-- Name: negdiHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."negdiHistory" ALTER COLUMN id SET DEFAULT nextval('public."negdiHistory_id_seq"'::regclass);


--
-- Name: negdiJoinCardHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."negdiJoinCardHistory" ALTER COLUMN id SET DEFAULT nextval('public."negdiJoinCardHistory_id_seq"'::regclass);


--
-- Name: passwordResetToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."passwordResetToken" ALTER COLUMN id SET DEFAULT nextval('public."passwordResetToken_id_seq"'::regclass);


--
-- Name: paymentMethod id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paymentMethod" ALTER COLUMN id SET DEFAULT nextval('public."paymentMethod_id_seq"'::regclass);


--
-- Name: permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission ALTER COLUMN id SET DEFAULT nextval('public.permission_id_seq'::regclass);


--
-- Name: pos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos ALTER COLUMN id SET DEFAULT nextval('public.pos_id_seq'::regclass);


--
-- Name: productType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."productType" ALTER COLUMN id SET DEFAULT nextval('public."productType_id_seq"'::regclass);


--
-- Name: qpayHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qpayHistory" ALTER COLUMN id SET DEFAULT nextval('public."qpayHistory_id_seq"'::regclass);


--
-- Name: sbIncome id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."sbIncome" ALTER COLUMN id SET DEFAULT nextval('public."sbIncome_id_seq"'::regclass);


--
-- Name: sbIncomeByMerchant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."sbIncomeByMerchant" ALTER COLUMN id SET DEFAULT nextval('public."sbIncomeByMerchant_id_seq"'::regclass);


--
-- Name: settle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settle ALTER COLUMN id SET DEFAULT nextval('public.settle_id_seq'::regclass);


--
-- Name: ticket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);


--
-- Name: ticketComment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ticketComment" ALTER COLUMN id SET DEFAULT nextval('public."ticketComment_id_seq"'::regclass);


--
-- Name: token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token ALTER COLUMN id SET DEFAULT nextval('public.token_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Name: transactionBucket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."transactionBucket" ALTER COLUMN id SET DEFAULT nextval('public."transactionBucket_id_seq"'::regclass);


--
-- Name: userPin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userPin" ALTER COLUMN id SET DEFAULT nextval('public."userPin_id_seq"'::regclass);


--
-- Name: vatLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatLog" ALTER COLUMN id SET DEFAULT nextval('public."vatLog_id_seq"'::regclass);


--
-- Name: vatMerchant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatMerchant" ALTER COLUMN id SET DEFAULT nextval('public."vatMerchant_id_seq"'::regclass);


--
-- Name: vatMerchantPos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatMerchantPos" ALTER COLUMN id SET DEFAULT nextval('public."vatMerchantPos_id_seq"'::regclass);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id);


--
-- Name: aiFunctionCall aiFunctionCall_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."aiFunctionCall"
    ADD CONSTRAINT "aiFunctionCall_pkey" PRIMARY KEY (id);


--
-- Name: bankTransactionLog bankTransactionLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."bankTransactionLog"
    ADD CONSTRAINT "bankTransactionLog_pkey" PRIMARY KEY (id);


--
-- Name: card card_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id);


--
-- Name: faq faq_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faq
    ADD CONSTRAINT faq_pkey PRIMARY KEY (id);


--
-- Name: incomeTransaction incomeTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."incomeTransaction"
    ADD CONSTRAINT "incomeTransaction_pkey" PRIMARY KEY (id);


--
-- Name: invoiceItemVatInfo invoiceItemVatInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItemVatInfo"
    ADD CONSTRAINT "invoiceItemVatInfo_pkey" PRIMARY KEY (id);


--
-- Name: invoiceItem invoiceItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_pkey" PRIMARY KEY (id);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: merchantBillings merchantBillings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantBillings"
    ADD CONSTRAINT "merchantBillings_pkey" PRIMARY KEY (id);


--
-- Name: merchantInvoiceCountDetails merchantInvoiceCountDetails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceCountDetails"
    ADD CONSTRAINT "merchantInvoiceCountDetails_pkey" PRIMARY KEY (id);


--
-- Name: merchantInvoiceItems merchantInvoiceItems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceItems"
    ADD CONSTRAINT "merchantInvoiceItems_pkey" PRIMARY KEY (id);


--
-- Name: merchantInvoices merchantInvoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoices"
    ADD CONSTRAINT "merchantInvoices_pkey" PRIMARY KEY (id);


--
-- Name: merchantPermission merchantPermission_merchantId_permissionId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantPermission"
    ADD CONSTRAINT "merchantPermission_merchantId_permissionId_key" UNIQUE ("merchantId", "permissionId");


--
-- Name: merchantPermission merchantPermission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantPermission"
    ADD CONSTRAINT "merchantPermission_pkey" PRIMARY KEY (id);


--
-- Name: merchantSettle merchantSettle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantSettle"
    ADD CONSTRAINT "merchantSettle_pkey" PRIMARY KEY (id);


--
-- Name: merchant merchant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_pkey PRIMARY KEY (id);


--
-- Name: negdiHistory negdiHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."negdiHistory"
    ADD CONSTRAINT "negdiHistory_pkey" PRIMARY KEY (id);


--
-- Name: negdiJoinCardHistory negdiJoinCardHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."negdiJoinCardHistory"
    ADD CONSTRAINT "negdiJoinCardHistory_pkey" PRIMARY KEY (id);


--
-- Name: passwordResetToken passwordResetToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."passwordResetToken"
    ADD CONSTRAINT "passwordResetToken_pkey" PRIMARY KEY (id);


--
-- Name: paymentMethod paymentMethod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paymentMethod"
    ADD CONSTRAINT "paymentMethod_pkey" PRIMARY KEY (id);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (id);


--
-- Name: pos pos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos
    ADD CONSTRAINT pos_pkey PRIMARY KEY (id);


--
-- Name: productType productType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."productType"
    ADD CONSTRAINT "productType_pkey" PRIMARY KEY (id);


--
-- Name: qpayHistory qpayHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."qpayHistory"
    ADD CONSTRAINT "qpayHistory_pkey" PRIMARY KEY (id);


--
-- Name: sbIncomeByMerchant sbIncomeByMerchant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."sbIncomeByMerchant"
    ADD CONSTRAINT "sbIncomeByMerchant_pkey" PRIMARY KEY (id);


--
-- Name: sbIncome sbIncome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."sbIncome"
    ADD CONSTRAINT "sbIncome_pkey" PRIMARY KEY (id);


--
-- Name: settle settle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settle
    ADD CONSTRAINT settle_pkey PRIMARY KEY (id);


--
-- Name: ticketComment ticketComment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ticketComment"
    ADD CONSTRAINT "ticketComment_pkey" PRIMARY KEY (id);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- Name: transactionBucket transactionBucket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."transactionBucket"
    ADD CONSTRAINT "transactionBucket_pkey" PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: userPin userPin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userPin"
    ADD CONSTRAINT "userPin_pkey" PRIMARY KEY (id);


--
-- Name: userPin userPin_userId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userPin"
    ADD CONSTRAINT "userPin_userId_key" UNIQUE ("userId");


--
-- Name: vatLog vatLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatLog"
    ADD CONSTRAINT "vatLog_pkey" PRIMARY KEY (id);


--
-- Name: vatMerchantPos vatMerchantPos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatMerchantPos"
    ADD CONSTRAINT "vatMerchantPos_pkey" PRIMARY KEY (id);


--
-- Name: vatMerchantPos vatMerchantPos_vatMerchantId_poId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatMerchantPos"
    ADD CONSTRAINT "vatMerchantPos_vatMerchantId_poId_key" UNIQUE ("vatMerchantId", "poId");


--
-- Name: vatMerchant vatMerchant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."vatMerchant"
    ADD CONSTRAINT "vatMerchant_pkey" PRIMARY KEY (id);


--
-- Name: DATE; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DATE" ON public."merchantSettle" USING btree ("createdAt");


--
-- Name: INVOICE_ID; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "INVOICE_ID" ON public."invoiceItem" USING btree ("invoiceId");


--
-- Name: MERCHANT; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MERCHANT" ON public."merchantSettle" USING btree ("merchantId");


--
-- Name: PRIMARY; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PRIMARY" ON public."invoiceItem" USING btree (id);


--
-- Name: REGISTER; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "REGISTER" ON public.merchant USING btree (register);


--
-- Name: STATUS; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "STATUS" ON public."merchantSettle" USING btree (status);


--
-- Name: USERID; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "USERID" ON public.card USING btree ("userId");


--
-- Name: id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX id ON public."paymentMethod" USING btree (id);


--
-- Name: idx_accountNumber; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_accountNumber" ON public."bankTransactionLog" USING btree ("accountNumber");


--
-- Name: idx_log_merchantId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_log_merchantId" ON public.log USING btree ("merchantId");


--
-- Name: idx_merchantsettle_merchantid_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_merchantsettle_merchantid_desc ON public."merchantSettle" USING btree ("merchantId" DESC);


--
-- Name: idx_merchantsettle_merchantsettleid_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_merchantsettle_merchantsettleid_desc ON public.transaction USING btree ("merchantSettleId" DESC);


--
-- Name: idx_merchantsettle_status_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_merchantsettle_status_desc ON public."merchantSettle" USING btree (status DESC);


--
-- Name: idx_trnDesc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_trnDesc" ON public."bankTransactionLog" USING btree (description COLLATE "C.utf8" bpchar_pattern_ops) WITH (deduplicate_items='true');


--
-- Name: invoiceId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "invoiceId" ON public."negdiHistory" USING btree ("invoiceId");


--
-- Name: merchantId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "merchantId" ON public."incomeTransaction" USING btree ("merchantId");


--
-- Name: merchantSettleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "merchantSettleId" ON public."incomeTransaction" USING btree ("merchantSettleId");


--
-- Name: merchant_billings_merchant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchant_billings_merchant_id ON public."merchantBillings" USING btree ("merchantId");


--
-- Name: merchant_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchant_index ON public."vatMerchant" USING btree ("createrMerchantId");


--
-- Name: merchant_invoice_count_details_merchant_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchant_invoice_count_details_merchant_invoice_id ON public."merchantInvoiceCountDetails" USING btree ("merchantInvoiceId");


--
-- Name: merchant_invoice_items_merchant_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchant_invoice_items_merchant_invoice_id ON public."merchantInvoiceItems" USING btree ("merchantInvoiceId");


--
-- Name: merchant_invoices_merchant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchant_invoices_merchant_id ON public."merchantInvoices" USING btree ("merchantId");


--
-- Name: merchant_permission_merchant_id_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX merchant_permission_merchant_id_permission_id ON public."merchantPermission" USING btree ("merchantId", "permissionId");


--
-- Name: phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX phone ON public.merchant USING btree (phone);


--
-- Name: register_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX register_index ON public."vatMerchant" USING btree (register);


--
-- Name: status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX status ON public."negdiHistory" USING btree (status);


--
-- Name: invoiceItem invoiceItem_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public.invoice(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoiceItem invoiceItem_productTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_productTypeId_fkey" FOREIGN KEY ("productTypeId") REFERENCES public."productType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoiceItem invoiceItem_transactionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES public.transaction(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoiceItem invoiceItem_vatInfoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."invoiceItem"
    ADD CONSTRAINT "invoiceItem_vatInfoId_fkey" FOREIGN KEY ("vatInfoId") REFERENCES public."invoiceItemVatInfo"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoice invoice_merchantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES public.merchant(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoice invoice_paymentMethodId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT "invoice_paymentMethodId_fkey" FOREIGN KEY ("paymentMethodId") REFERENCES public."paymentMethod"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: merchantBillings merchantBillings_merchantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantBillings"
    ADD CONSTRAINT "merchantBillings_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES public.merchant(id) ON UPDATE CASCADE;


--
-- Name: merchantInvoiceCountDetails merchantInvoiceCountDetails_merchantInvoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceCountDetails"
    ADD CONSTRAINT "merchantInvoiceCountDetails_merchantInvoiceId_fkey" FOREIGN KEY ("merchantInvoiceId") REFERENCES public."merchantInvoices"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: merchantInvoiceItems merchantInvoiceItems_merchantInvoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoiceItems"
    ADD CONSTRAINT "merchantInvoiceItems_merchantInvoiceId_fkey" FOREIGN KEY ("merchantInvoiceId") REFERENCES public."merchantInvoices"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: merchantInvoices merchantInvoices_merchantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."merchantInvoices"
    ADD CONSTRAINT "merchantInvoices_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES public.merchant(id) ON UPDATE CASCADE;


--
-- Name: ticketComment ticketComment_ticketId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ticketComment"
    ADD CONSTRAINT "ticketComment_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES public.ticket(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ticket ticket_merchantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "ticket_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES public.merchant(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: transaction transaction_merchantSettleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT "transaction_merchantSettleId_fkey" FOREIGN KEY ("merchantSettleId") REFERENCES public."merchantSettle"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict MrtYB8v9MJpZNVxMjWXKEFSZbJhkzOtCS7SfxIxvUZCXfKoot1eyUwQMe0PQXlL

