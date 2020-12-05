--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4 (Debian 10.4-2.pgdg90+1)
-- Dumped by pg_dump version 10.4 (Debian 10.4-2.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE DATABASE todos_db;

\c todos_db

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: migrations_lock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations_lock (
    index integer NOT NULL,
    is_locked integer
);


ALTER TABLE public.migrations_lock OWNER TO postgres;

--
-- Name: migrations_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_lock_index_seq OWNER TO postgres;

--
-- Name: migrations_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_lock_index_seq OWNED BY public.migrations_lock.index;


--
-- Name: todos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.todos (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    completed boolean NOT NULL,
    due_date timestamp with time zone,
    "order" integer
);


ALTER TABLE public.todos OWNER TO postgres;

--
-- Name: todos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.todos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.todos_id_seq OWNER TO postgres;

--
-- Name: todos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.todos_id_seq OWNED BY public.todos.id;


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: migrations_lock index; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations_lock ALTER COLUMN index SET DEFAULT nextval('public.migrations_lock_index_seq'::regclass);


--
-- Name: todos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todos ALTER COLUMN id SET DEFAULT nextval('public.todos_id_seq'::regclass);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, name, batch, migration_time) FROM stdin;
1	20201122205735_create_todos_table.js	1	2020-12-04 09:26:30.428+00
2	20201123104711_update_todos_table.js	1	2020-12-04 09:26:30.433+00
\.


--
-- Data for Name: migrations_lock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations_lock (index, is_locked) FROM stdin;
1	0
\.


--
-- Data for Name: todos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.todos (id, title, completed, due_date, "order") FROM stdin;
12	Learn Jenkins	f	2020-12-04 18:37:44.234+00	\N
13	Learn GitLab	t	2020-12-04 18:38:06.993+00	\N
21	Learn K8s	f	2020-12-04 19:12:16.174+00	\N
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 2, true);


--
-- Name: migrations_lock_index_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_lock_index_seq', 1, true);


--
-- Name: todos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.todos_id_seq', 21, true);


--
-- Name: migrations_lock migrations_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations_lock
    ADD CONSTRAINT migrations_lock_pkey PRIMARY KEY (index);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: todos todos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

