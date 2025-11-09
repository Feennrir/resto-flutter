--
-- PostgreSQL database dump
--

\restrict G4jYi5doCIWx7ntVPqZbl5dxEtNfqg7TQVqjr5LMAC0ScsZ2eulGtwUf3LOrQ1b

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

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
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishes (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category character varying(100) NOT NULL,
    image_url text,
    is_available boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.dishes OWNER TO postgres;

--
-- Name: dishes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dishes_id_seq OWNER TO postgres;

--
-- Name: dishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishes_id_seq OWNED BY public.dishes.id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservations (
    id integer NOT NULL,
    user_id integer,
    restaurant_id integer,
    reservation_date date NOT NULL,
    reservation_time time without time zone NOT NULL,
    party_size integer NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    special_requests text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reservations OWNER TO postgres;

--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reservations_id_seq OWNER TO postgres;

--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;


--
-- Name: restaurant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.restaurant (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    max_capacity integer DEFAULT 50 NOT NULL,
    opening_time time without time zone DEFAULT '10:00:00'::time without time zone NOT NULL,
    closing_time time without time zone DEFAULT '22:00:00'::time without time zone NOT NULL,
    service_duration integer DEFAULT 120 NOT NULL,
    phone character varying(20),
    address text,
    description text,
    image_url text,
    latitude numeric(10,8),
    longitude numeric(11,8),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.restaurant OWNER TO postgres;

--
-- Name: restaurant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.restaurant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.restaurant_id_seq OWNER TO postgres;

--
-- Name: restaurant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.restaurant_id_seq OWNED BY public.restaurant.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(20),
    is_admin boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: dishes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes ALTER COLUMN id SET DEFAULT nextval('public.dishes_id_seq'::regclass);


--
-- Name: reservations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);


--
-- Name: restaurant id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurant ALTER COLUMN id SET DEFAULT nextval('public.restaurant_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishes (id, name, description, price, category, image_url, is_available, created_at) FROM stdin;
1	Burger Classique	Pain brioché, steak haché, cheddar, salade, tomate, oignon	12.90	Plats	https://images.unsplash.com/photo-1568901346375-23c9450c58cd	t	2025-11-09 16:49:44.436538
2	Burger Bacon	Pain brioché, steak haché, bacon croustillant, cheddar, sauce BBQ	14.90	Plats	https://images.unsplash.com/photo-1553979459-d2229ba7433b	t	2025-11-09 16:49:44.436538
3	Burger Végétarien	Pain complet, steak végétal, avocat, tomate, oignon rouge	13.90	Plats	https://images.unsplash.com/photo-1520072959219-c595dc870360	t	2025-11-09 16:49:44.436538
4	Pizza Margherita	Sauce tomate, mozzarella, basilic frais	11.90	Plats	https://images.unsplash.com/photo-1574071318508-1cdbab80d002	t	2025-11-09 16:49:44.436538
5	Pizza 4 Fromages	Mozzarella, gorgonzola, parmesan, chèvre	13.90	Plats	https://images.unsplash.com/photo-1513104890138-7c749659a591	t	2025-11-09 16:49:44.436538
6	Pizza Pepperoni	Sauce tomate, mozzarella, pepperoni	12.90	Plats	https://images.unsplash.com/photo-1628840042765-356cda07504e	t	2025-11-09 16:49:44.436538
7	Salade César	Laitue romaine, poulet grillé, croûtons, parmesan, sauce césar	10.90	Entrees	https://images.unsplash.com/photo-1546793665-c74683f339c1	t	2025-11-09 16:49:44.436538
8	Salade Grecque	Tomates, concombre, olives, feta, oignon rouge	9.90	Entrees	https://images.unsplash.com/photo-1540189549336-e6e99c3679fe	t	2025-11-09 16:49:44.436538
9	Tiramisu	Dessert italien traditionnel au café et mascarpone	6.90	Desserts	https://images.unsplash.com/photo-1571877227200-a0d98ea607e9	t	2025-11-09 16:49:44.436538
10	Brownie Chocolat	Brownie au chocolat noir, glace vanille	5.90	Desserts	https://images.unsplash.com/photo-1606313564200-e75d5e30476c	t	2025-11-09 16:49:44.436538
11	Tarte Citron	Tarte au citron meringuée	6.50	Desserts	https://images.unsplash.com/photo-1519915028121-7d3463d20b13	t	2025-11-09 16:49:44.436538
12	Coca-Cola	Boisson gazeuse 33cl	2.90	Boissons	https://images.unsplash.com/photo-1554866585-cd94860890b7	t	2025-11-09 16:49:44.436538
13	Jus d'Orange	Jus d'orange pressé 25cl	3.90	Boissons	https://images.unsplash.com/photo-1600271886742-f049cd451bba	t	2025-11-09 16:49:44.436538
14	Eau Minérale	Eau minérale plate 50cl	2.50	Boissons	https://images.unsplash.com/photo-1548839140-29a749e1cf4d	t	2025-11-09 16:49:44.436538
\.


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservations (id, user_id, restaurant_id, reservation_date, reservation_time, party_size, status, special_requests, created_at) FROM stdin;
2	2	1	2025-11-11	12:00:00	4	confirmed		2025-11-09 16:54:11.007701
1	2	1	2025-11-12	12:00:00	3	canceled		2025-11-09 16:53:35.704643
3	2	1	2025-11-16	11:30:00	2	pending		2025-11-09 16:58:27.330081
\.


--
-- Data for Name: restaurant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.restaurant (id, name, max_capacity, opening_time, closing_time, service_duration, phone, address, description, image_url, latitude, longitude, created_at) FROM stdin;
1	Le Petit Bistrot	40	11:00:00	13:30:00	120	+33 1 42 86 87 88	61 Rue Mercière, 69002 Lyon, France	Depuis 1985, Le Petit Bistrot vous accueille dans un cadre élégant et chaleureux. Notre chef, formé dans les plus grandes maisons françaises, vous propose une cuisine raffinée mêlant tradition et modernité.	https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800	45.76178800	4.83305600	2025-11-09 16:49:44.432954
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, phone, is_admin, created_at, updated_at) FROM stdin;
1	Administrateur	admin@restaurant.com	$2a$10$/VLQqnaep1n97Rg.ICsb4u9KhndntUUr9Npiwgs4h9rnqsPG4De12	+33612345678	t	2025-11-09 16:49:44.433323	2025-11-09 16:49:44.433323
2	Nathan	nathan@gmail.com	$2b$10$rcTt0P3UD217zH/FACGeNeruHUaozPNCh3NViWZ5rYgsXIy.Oofne	4444	f	2025-11-09 16:53:29.868892	2025-11-09 17:00:12.992615
\.


--
-- Name: dishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishes_id_seq', 14, true);


--
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_id_seq', 3, true);


--
-- Name: restaurant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.restaurant_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: restaurant restaurant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurant
    ADD CONSTRAINT restaurant_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_dishes_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dishes_category ON public.dishes USING btree (category);


--
-- Name: idx_reservations_date_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_date_time ON public.reservations USING btree (reservation_date, reservation_time);


--
-- Name: idx_reservations_restaurant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_restaurant ON public.reservations USING btree (restaurant_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_is_admin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_is_admin ON public.users USING btree (is_admin);


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: reservations reservations_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurant(id);


--
-- Name: reservations reservations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict G4jYi5doCIWx7ntVPqZbl5dxEtNfqg7TQVqjr5LMAC0ScsZ2eulGtwUf3LOrQ1b

