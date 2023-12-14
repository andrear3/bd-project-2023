--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

-- Started on 2023-12-14 01:02:08

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
-- TOC entry 4947 (class 0 OID 16624)
-- Dependencies: 222
-- Data for Name: location; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.location (location_name, x_coordinates, y_coordinates, photo_count) FROM stdin;
Roma	41.9	12.49	1
Napoli	40.85	14.26	5
Palermo	38.11	13.36	4
Genova	44.4	8.94	2
Milano	45.46	9.18	4
\.


--
-- TOC entry 4941 (class 0 OID 16554)
-- Dependencies: 216
-- Data for Name: utente; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.utente (nickname, birthdate, gender) FROM stdin;
FastWing	2002-02-01	F
Chrls16	1999-01-11	M
Deleted User	\N	\N
Table13	2000-03-20	M
Franco01	1980-04-01	M
Pippo	1982-09-05	M
Butterfly99	2002-12-10	F
\.


--
-- TOC entry 4950 (class 0 OID 16678)
-- Dependencies: 225
-- Data for Name: photo; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.photo (photo_code, scope, nickname, location_name, device, photo_date) FROM stdin;
34	Public	Table13	Palermo	Samsung Galaxy A23	2021-04-15
22	Private	Deleted User	Palermo	iPhone 15	2021-05-20
23	Private	Deleted User	Palermo	iPhone 15	2021-06-20
38	Public	Butterfly99	Milano	iPhone 14	2023-02-17
39	Public	Butterfly99	Milano	iPhone 14	2023-02-17
36	Public	Pippo	Genova	iPhone 14	2022-06-23
35	Public	Franco01	Genova	iPhone 14	2022-06-23
14	Private	FastWing	Napoli	Samsung Galaxy A34	2022-11-10
28	Public	Deleted User	Palermo	iPhone 15	2021-06-20
4	Private	Chrls16	Milano	Canon EOS 4000D	2022-06-04
11	Private	Deleted User	Napoli	Cell	2010-10-10
12	Public	Deleted User	Napoli	Cell	2010-10-11
13	Private	Deleted User	Napoli	Cell	2010-01-01
5	Eliminated	Chrls16	Milano	Samsung Galaxy S5	2022-06-04
2	Public	FastWing	Napoli	Iphone 14	2022-02-24
\.


--
-- TOC entry 4946 (class 0 OID 16608)
-- Dependencies: 221
-- Data for Name: video; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.video (video_code, video_length, video_desc, video_title, nickname) FROM stdin;
1	01:12:00	Vacanza in giro	Vacanza	Chrls16
2	00:30:00	Vacanza con mio fratello a Genova	Vacanza	Franco01
\.


--
-- TOC entry 4953 (class 0 OID 16812)
-- Dependencies: 228
-- Data for Name: is_in_video; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.is_in_video (video_code, photo_code) FROM stdin;
1	4
1	5
2	35
2	36
\.


--
-- TOC entry 4943 (class 0 OID 16587)
-- Dependencies: 218
-- Data for Name: public_collection; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.public_collection (collection_name) FROM stdin;
Collezione 1
Vacanza Zeruno
\.


--
-- TOC entry 4944 (class 0 OID 16592)
-- Dependencies: 219
-- Data for Name: partecipating_users; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.partecipating_users (join_date, nickname, collection_name) FROM stdin;
2021-04-02	FastWing	Collezione 1
2021-11-27	Chrls16	Collezione 1
2023-11-22	Table13	Collezione 1
2023-11-22	Butterfly99	Collezione 1
2023-11-22	Pippo	Vacanza Zeruno
2023-11-22	Franco01	Vacanza Zeruno
2023-11-22	Franco01	Collezione 1
\.


--
-- TOC entry 4954 (class 0 OID 17093)
-- Dependencies: 229
-- Data for Name: tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.tag (tag_name) FROM stdin;
Selfie
Paesaggio
Evento
Luogo di Interesse
Oggetto
Ritratto
\.


--
-- TOC entry 4955 (class 0 OID 17098)
-- Dependencies: 230
-- Data for Name: photo_tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.photo_tag (tag_name, photo_code) FROM stdin;
Luogo di Interesse	35
Luogo di Interesse	36
Selfie	36
Ritratto	38
Oggetto	38
Selfie	39
Evento	39
\.


--
-- TOC entry 4948 (class 0 OID 16645)
-- Dependencies: 223
-- Data for Name: shared_photo; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.shared_photo (collection_name, photo_code) FROM stdin;
Vacanza Zeruno	36
Vacanza Zeruno	35
Collezione 1	35
Collezione 1	2
Collezione 1	5
Collezione 1	34
Collezione 1	39
Collezione 1	38
\.


--
-- TOC entry 4942 (class 0 OID 16572)
-- Dependencies: 217
-- Data for Name: user_tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.user_tag (photo_code, nickname) FROM stdin;
22	FastWing
28	FastWing
36	Franco01
\.


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 227
-- Name: is_in_video_photo_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.is_in_video_photo_code_seq', 1, false);


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 226
-- Name: is_in_video_video_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.is_in_video_video_code_seq', 1, false);


--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 224
-- Name: photo_photo_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.photo_photo_code_seq', 39, true);


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 220
-- Name: video_video_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.video_video_code_seq', 1, true);


-- Completed on 2023-12-14 01:02:09

--
-- PostgreSQL database dump complete
--

