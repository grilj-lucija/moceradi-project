--
-- PostgreSQL database dump
--

\restrict xb7R6qnyjdukRCr190RIDAuHRIh87nZXc95ClqG2c9WfLrVqW9Gnabvfaq2nENy

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3

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
-- Name: activity_name; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_name (
    id integer CONSTRAINT set_name_id_not_null NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.activity_name OWNER TO postgres;

--
-- Name: dish; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    calorie_count integer
);


ALTER TABLE public.dish OWNER TO postgres;

--
-- Name: dish_has_ingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish_has_ingredient (
    id integer NOT NULL,
    ingredient_id integer NOT NULL,
    dish_id integer NOT NULL
);


ALTER TABLE public.dish_has_ingredient OWNER TO postgres;

--
-- Name: dish_has_ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dish_has_ingredient ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dish_has_ingredient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: dish_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dish ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dish_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    calorie_count integer
);


ALTER TABLE public.ingredient OWNER TO postgres;

--
-- Name: ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ingredient ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ingredient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: meal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal (
    id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    calorie_count integer,
    user_id integer NOT NULL,
    dish_id integer NOT NULL
);


ALTER TABLE public.meal OWNER TO postgres;

--
-- Name: meal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.meal ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.meal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: set_name_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.activity_name ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.set_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(20) NOT NULL
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_activity (
    id integer CONSTRAINT user_set_id_not_null NOT NULL,
    average_activity_id integer NOT NULL,
    workout_id integer NOT NULL,
    calorie_burn_actual integer
);


ALTER TABLE public.user_activity OWNER TO postgres;

--
-- Name: user_average_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_average_activity (
    id integer CONSTRAINT user_average_set_id_not_null NOT NULL,
    user_id integer NOT NULL,
    activity_id integer NOT NULL,
    avg_calorie_burn integer
);


ALTER TABLE public.user_average_activity OWNER TO postgres;

--
-- Name: user_average_set_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_average_activity ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_average_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_average_walk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_average_walk (
    id integer NOT NULL,
    calorie_burn integer,
    duration interval,
    length integer,
    steps integer,
    delta_altitude_up integer,
    delta_altitude_down integer,
    user_id integer NOT NULL
);


ALTER TABLE public.user_average_walk OWNER TO postgres;

--
-- Name: user_average_walk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_average_walk ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_average_walk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_set_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_activity ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: walk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.walk (
    id integer NOT NULL,
    user_id integer NOT NULL,
    calorie_burn_actual integer,
    duration interval,
    length integer,
    steps integer,
    delta_altitude_up integer,
    delta_altitude_down integer
);


ALTER TABLE public.walk OWNER TO postgres;

--
-- Name: walk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.walk ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.walk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: walk_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.walk_node (
    id integer NOT NULL,
    walk_id integer NOT NULL,
    prev_node_id integer,
    next_node_id integer,
    calorie_burn_actual integer,
    sample_time_from timestamp without time zone NOT NULL,
    sample_time_to timestamp without time zone NOT NULL,
    steps integer,
    delta_altitude_up integer,
    delta_altitude_down integer,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL
);


ALTER TABLE public.walk_node OWNER TO postgres;

--
-- Name: walk_node_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.walk_node ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.walk_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workout (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    calorie_burn_actual integer,
    user_id integer NOT NULL
);


ALTER TABLE public.workout OWNER TO postgres;

--
-- Name: workout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.workout ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.workout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: activity_name; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_name (id, name) FROM stdin;
\.


--
-- Data for Name: dish; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dish (id, name, calorie_count) FROM stdin;
\.


--
-- Data for Name: dish_has_ingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dish_has_ingredient (id, ingredient_id, dish_id) FROM stdin;
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredient (id, name, calorie_count) FROM stdin;
\.


--
-- Data for Name: meal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meal (id, "time", calorie_count, user_id, dish_id) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, username) FROM stdin;
\.


--
-- Data for Name: user_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_activity (id, average_activity_id, workout_id, calorie_burn_actual) FROM stdin;
\.


--
-- Data for Name: user_average_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_average_activity (id, user_id, activity_id, avg_calorie_burn) FROM stdin;
\.


--
-- Data for Name: user_average_walk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_average_walk (id, calorie_burn, duration, length, steps, delta_altitude_up, delta_altitude_down, user_id) FROM stdin;
\.


--
-- Data for Name: walk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.walk (id, user_id, calorie_burn_actual, duration, length, steps, delta_altitude_up, delta_altitude_down) FROM stdin;
\.


--
-- Data for Name: walk_node; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.walk_node (id, walk_id, prev_node_id, next_node_id, calorie_burn_actual, sample_time_from, sample_time_to, steps, delta_altitude_up, delta_altitude_down, latitude, longitude) FROM stdin;
\.


--
-- Data for Name: workout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workout (id, name, calorie_burn_actual, user_id) FROM stdin;
\.


--
-- Name: dish_has_ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_has_ingredient_id_seq', 1, false);


--
-- Name: dish_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_id_seq', 1, false);


--
-- Name: ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredient_id_seq', 1, false);


--
-- Name: meal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_id_seq', 1, false);


--
-- Name: set_name_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.set_name_id_seq', 1, false);


--
-- Name: user_average_set_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_average_set_id_seq', 1, false);


--
-- Name: user_average_walk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_average_walk_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 1, false);


--
-- Name: user_set_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_set_id_seq', 1, false);


--
-- Name: walk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.walk_id_seq', 1, false);


--
-- Name: walk_node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.walk_node_id_seq', 1, false);


--
-- Name: workout_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workout_id_seq', 1, false);


--
-- Name: dish_has_ingredient dish_has_ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_has_ingredient
    ADD CONSTRAINT dish_has_ingredient_pkey PRIMARY KEY (id);


--
-- Name: dish dish_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish
    ADD CONSTRAINT dish_pkey PRIMARY KEY (id);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


--
-- Name: meal meal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal
    ADD CONSTRAINT meal_pkey PRIMARY KEY (id);


--
-- Name: activity_name set_name_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_name
    ADD CONSTRAINT set_name_pkey PRIMARY KEY (id);


--
-- Name: user_average_activity user_average_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_average_activity
    ADD CONSTRAINT user_average_set_pkey PRIMARY KEY (id);


--
-- Name: user_average_walk user_average_walk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_average_walk
    ADD CONSTRAINT user_average_walk_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_activity user_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activity
    ADD CONSTRAINT user_set_pkey PRIMARY KEY (id);


--
-- Name: walk_node walk_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk_node
    ADD CONSTRAINT walk_node_pkey PRIMARY KEY (id);


--
-- Name: walk walk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk
    ADD CONSTRAINT walk_pkey PRIMARY KEY (id);


--
-- Name: workout workout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout
    ADD CONSTRAINT workout_pkey PRIMARY KEY (id);


--
-- Name: dish_has_ingredient dish_has_ingredient_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_has_ingredient
    ADD CONSTRAINT dish_has_ingredient_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(id);


--
-- Name: dish_has_ingredient dish_has_ingredient_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_has_ingredient
    ADD CONSTRAINT dish_has_ingredient_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id);


--
-- Name: meal meal_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal
    ADD CONSTRAINT meal_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(id);


--
-- Name: meal meal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal
    ADD CONSTRAINT meal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_average_activity user_average_set_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_average_activity
    ADD CONSTRAINT user_average_set_set_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity_name(id);


--
-- Name: user_average_activity user_average_set_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_average_activity
    ADD CONSTRAINT user_average_set_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_average_walk user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_average_walk
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: workout user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_activity user_set_average_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activity
    ADD CONSTRAINT user_set_average_set_id_fkey FOREIGN KEY (average_activity_id) REFERENCES public.user_average_activity(id);


--
-- Name: user_activity user_set_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activity
    ADD CONSTRAINT user_set_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workout(id);


--
-- Name: walk_node walk_node_next_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk_node
    ADD CONSTRAINT walk_node_next_node_id_fkey FOREIGN KEY (next_node_id) REFERENCES public.walk_node(id);


--
-- Name: walk_node walk_node_prev_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk_node
    ADD CONSTRAINT walk_node_prev_node_id_fkey FOREIGN KEY (prev_node_id) REFERENCES public.walk_node(id);


--
-- Name: walk_node walk_node_walk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk_node
    ADD CONSTRAINT walk_node_walk_id_fkey FOREIGN KEY (walk_id) REFERENCES public.walk(id);


--
-- Name: walk walk_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.walk
    ADD CONSTRAINT walk_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

\unrestrict xb7R6qnyjdukRCr190RIDAuHRIh87nZXc95ClqG2c9WfLrVqW9Gnabvfaq2nENy

