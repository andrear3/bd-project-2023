--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

-- Started on 2023-12-06 17:27:39 CET

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
-- TOC entry 6 (class 2615 OID 16528)
-- Name: photogallery; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA photogallery;


ALTER SCHEMA photogallery OWNER TO postgres;

--
-- TOC entry 873 (class 1247 OID 16530)
-- Name: fullname; Type: DOMAIN; Schema: photogallery; Owner: postgres
--

CREATE DOMAIN photogallery.fullname AS character varying(32)
	CONSTRAINT fullname_check CHECK (((VALUE)::text ~ '^[a-zA-Z ]*$'::text));


ALTER DOMAIN photogallery.fullname OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 16532)
-- Name: Delete_Photo(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Delete_Photo"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN

IF(NEW.scope = 'Eliminated')
THEN
UPDATE photogallery.photo
SET scope = 'Eliminated', nickname = 'Deleted User'
WHERE photo_code = NEW.photo_code;

END IF;
RETURN NULL;
END;$$;


ALTER FUNCTION photogallery."Delete_Photo"() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16533)
-- Name: Delete_User(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Delete_User"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

fotoUtentedaEliminare CURSOR FOR
(SELECT photo_code
FROM photogallery.photo
WHERE (Nickname = OLD.Nickname) AND Photo_Code NOT IN
(SELECT PH1.Photo_Code
FROM photogallery.user_tag AS U JOIN photogallery.photo AS PH1 ON U.photo_code = PH1.photo_code
WHERE PH1.Nickname = OLD.Nickname AND U.Photo_Code = PH1.Photo_Code)
);

fotoUtentedaModificare CURSOR FOR
(SELECT photo_code
FROM photogallery.photo
WHERE (Nickname = OLD.Nickname) AND Photo_Code IN
(SELECT PH1.Photo_Code
FROM photogallery.user_tag AS U JOIN photogallery.photo AS PH1 ON U.photo_code = PH1.photo_code
WHERE PH1.Nickname = OLD.Nickname AND U.Photo_Code = PH1.Photo_Code)
);

FotodaEliminare integer;
FotodaModificare integer;

BEGIN 

OPEN fotoUtentedaModificare;

LOOP
FETCH fotoUtentedaModificare INTO FotodaModificare;
UPDATE photogallery.photo
SET nickname = 'Deleted User'
WHERE (photo_code = FotodaModificare);
IF(NOT FOUND)
THEN EXIT;
END IF;
END LOOP;
CLOSE fotoUtentedaModificare;

OPEN fotoUtentedaEliminare;

LOOP
FETCH fotoUtentedaEliminare INTO FotodaEliminare;
DELETE FROM photogallery.photo_tag
WHERE (photo_code = FotodaEliminare);
DELETE FROM photogallery.is_in_video
WHERE (photo_code = FotodaEliminare);
DELETE FROM photogallery.photo
WHERE (photo_code = FotodaEliminare);
IF(NOT FOUND)
THEN EXIT;
END IF;
END LOOP;

DELETE FROM photogallery.video
WHERE (OLD.Nickname = Nickname);

CLOSE fotoUtentedaEliminare;

RETURN NULL;
END;$$;


ALTER FUNCTION photogallery."Delete_User"() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16534)
-- Name: Location_Count(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Location_Count"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

location_add photogallery.location.location_name%TYPE;

BEGIN

SELECT L.Location_Name INTO location_add
FROM photogallery.photo as PH JOIN photogallery.location as L on L.Location_Name = PH.Location_Name
WHERE PH.Location_Name = L.Location_Name AND PH.Photo_Code IN
(
SELECT PH1.Photo_Code
FROM photogallery.photo as PH1
GROUP BY (PH1.Photo_Code)
ORDER BY PH1.Photo_Code DESC
LIMIT 1);


UPDATE photogallery.location
SET photo_count = photo_count+1
WHERE (location_name = location_add);
RETURN NULL;
END;

$$;


ALTER FUNCTION photogallery."Location_Count"() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16535)
-- Name: Location_Count_Subtract(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Location_Count_Subtract"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

location_add photogallery.location.location_name%TYPE;

BEGIN

SELECT L.Location_Name INTO location_add
FROM photogallery.photo as PH JOIN photogallery.location as L on L.Location_Name = PH.Location_Name
WHERE PH.Location_Name = OLD.Location_Name;


UPDATE photogallery.location
SET photo_count = photo_count-1
WHERE (location_name = location_add);
RETURN NULL;
END;

$$;


ALTER FUNCTION photogallery."Location_Count_Subtract"() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16536)
-- Name: NewUser_Collection(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."NewUser_Collection"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

add_user photogallery.photo.nickname%TYPE;

BEGIN

SELECT PH.nickname INTO add_user
FROM photogallery.photo as PH 
WHERE PH.photo_code = NEW.photo_code
AND (PH.nickname, NEW.collection_name) NOT IN
(SELECT nickname, collection_name
FROM photogallery.partecipating_users);


IF(add_user IS NOT NULL)
THEN
INSERT INTO photogallery.partecipating_users
VALUES (current_date, add_user, NEW.collection_name);
END IF;
RETURN NULL;

END;$$;


ALTER FUNCTION photogallery."NewUser_Collection"() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16537)
-- Name: Photo_Tag_Check(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Photo_Tag_Check"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

new_photo photogallery.photo.photo_code%TYPE;
new_tag photogallery.tag.tag_name%TYPE;

BEGIN

SELECT T.tag_name INTO new_tag
FROM photogallery.TAG as T
WHERE NEW.tag_name = T.tag_name;

SELECT PH.Photo_Code INTO new_photo
FROM photogallery.photo as PH
WHERE NEW.photo_code = PH.photo_code;

IF
(new_photo IS NOT NULL AND new_tag IS NOT NULL)
THEN
INSERT INTO photogallery.photo_tag
VALUES (new_tag, new_photo);
END IF;
RETURN NULL;
END;$$;


ALTER FUNCTION photogallery."Photo_Tag_Check"() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16538)
-- Name: Public_Photo(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."Public_Photo"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

scope_test photogallery.photo.photo_code%TYPE;

BEGIN

SELECT PH.photo_code into scope_test
FROM photogallery.photo as PH JOIN photogallery.shared_photo as SP on SP.photo_code = PH.photo_code
WHERE PH.Scope = 'Private' and PH.Photo_Code = SP.Photo_Code;

IF scope_test IS NOT NULL
THEN
UPDATE photogallery.photo
SET scope = 'Public'
WHERE (photogallery.photo.photo_code = scope_test);
END IF;
RETURN NULL;
END;$$;


ALTER FUNCTION photogallery."Public_Photo"() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16539)
-- Name: UPDATE_CollezionePubblica(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."UPDATE_CollezionePubblica"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

scope_test photogallery.photo.photo_code%TYPE;

BEGIN

SELECT PH.photo_code into scope_test
FROM photogallery.photo as PH JOIN photogallery.shared_photo as SP on SP.photo_code = PH.photo_code
WHERE PH.Scope = 'Private' and PH.Photo_Code = SP.Photo_Code;

IF scope_test IS NOT NULL
THEN
DELETE FROM photogallery.shared_photo
WHERE (photogallery.shared_photo.photo_code = scope_test);
END IF;
RETURN NULL;
END;




$$;


ALTER FUNCTION photogallery."UPDATE_CollezionePubblica"() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16540)
-- Name: User_Tag_Check(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery."User_Tag_Check"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE

new_photo photogallery.photo.photo_code%TYPE;
new_user photogallery.user.nickname%TYPE;

BEGIN

SELECT U.Nickname INTO new_user
FROM photogallery.user as U
WHERE NEW.nickname = U.Nickname
LIMIT 1;

SELECT PH.Photo_Code INTO new_photo
FROM photogallery.photo as PH
WHERE NEW.photo_code = PH.photo_code
LIMIT 1;

INSERT INTO photogallery.user_tag
VALUES(new_photo, new_user);
RETURN NULL;
END;$$;


ALTER FUNCTION photogallery."User_Tag_Check"() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16541)
-- Name: elimina_foto(integer); Type: PROCEDURE; Schema: photogallery; Owner: postgres
--

CREATE PROCEDURE photogallery.elimina_foto(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Eliminated'
WHERE ph_code = PHOTO_CODE
$$;


ALTER PROCEDURE photogallery.elimina_foto(IN ph_code integer) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16542)
-- Name: foto_stesso_luogo(text); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.foto_stesso_luogo(luogo text) RETURNS TABLE(photo_code text, nickname text, location_name text, device text, photo_date date)
    LANGUAGE sql
    AS $$
  SELECT PH.photo_code, PH.nickname, PH.location_name, PH.device, PH.photo_date
  FROM photogallery.PHOTO AS PH
  WHERE PH.location_name = luogo
$$;


ALTER FUNCTION photogallery.foto_stesso_luogo(luogo text) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16543)
-- Name: foto_stesso_soggetto(text); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.foto_stesso_soggetto(soggetto text) RETURNS TABLE(photo_code text, nickname text, location_name text, device text, photo_date date)
    LANGUAGE sql
    AS $$
  SELECT PH.photo_code, PH.nickname, PH.location_name, PH.device, PH.photo_date
  FROM photogallery.PHOTO AS PH JOIN photogallery.photo_tag AS PT ON PH.photo_code = PT.photo_code
  WHERE PT.photo_code = PH.photo_code AND PT.tag_name = soggetto
$$;


ALTER FUNCTION photogallery.foto_stesso_soggetto(soggetto text) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16544)
-- Name: galleriapersonale(text); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.galleriapersonale(nick text) RETURNS TABLE(photo_code integer)
    LANGUAGE sql
    AS $$
SELECT PH.photo_code
FROM photogallery.photo as PH JOIN photogallery.user as U ON PH.nickname = U.nickname
WHERE U.nickname = nick AND PH.scope <> 'Eliminated'$$;


ALTER FUNCTION photogallery.galleriapersonale(nick text) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16545)
-- Name: galleriapersonalevideo(text); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.galleriapersonalevideo(nick text) RETURNS TABLE(video_code integer, video_title text, video_lenght text, video_desc text)
    LANGUAGE sql
    AS $$
SELECT V.video_code, V.video_title, V.video_length, V.video_desc
FROM photogallery.video as V JOIN photogallery.user as U ON V.nickname = U.nickname
WHERE V.nickname = nick 
$$;


ALTER FUNCTION photogallery.galleriapersonalevideo(nick text) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16546)
-- Name: rendi_foto_privata(integer); Type: PROCEDURE; Schema: photogallery; Owner: postgres
--

CREATE PROCEDURE photogallery.rendi_foto_privata(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Private'
WHERE ph_code = PHOTO_CODE
$$;


ALTER PROCEDURE photogallery.rendi_foto_privata(IN ph_code integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16547)
-- Name: rendi_foto_pubblica(integer); Type: PROCEDURE; Schema: photogallery; Owner: postgres
--

CREATE PROCEDURE photogallery.rendi_foto_pubblica(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Public'
WHERE ph_code = PHOTO_CODE$$;


ALTER PROCEDURE photogallery.rendi_foto_pubblica(IN ph_code integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16548)
-- Name: testdevice(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.testdevice() RETURNS TABLE(name text)
    LANGUAGE sql
    AS $$
  SELECT PH.DEVICE
  FROM photogallery.PHOTO AS PH
$$;


ALTER FUNCTION photogallery.testdevice() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16549)
-- Name: top_3_luoghi(); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.top_3_luoghi() RETURNS TABLE(location_name text, photo_count integer)
    LANGUAGE sql
    AS $$
SELECT location_name, photo_count
FROM photogallery.location
ORDER BY photo_count DESC
LIMIT 3;
$$;


ALTER FUNCTION photogallery.top_3_luoghi() OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16550)
-- Name: video_foto(integer); Type: FUNCTION; Schema: photogallery; Owner: postgres
--

CREATE FUNCTION photogallery.video_foto(video_cod integer) RETURNS TABLE(video_title text, video_code text, photo_code text)
    LANGUAGE sql
    AS $$
	SELECT V.video_title, I.video_code, I.photo_code
	FROM photogallery.is_in_video as I JOIN photogallery.video as V on I.video_code = V.video_code
	WHERE V.video_code = video_cod
$$;


ALTER FUNCTION photogallery.video_foto(video_cod integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 16551)
-- Name: is_in_video; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.is_in_video (
    video_code integer NOT NULL,
    photo_code integer NOT NULL
);


ALTER TABLE photogallery.is_in_video OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16554)
-- Name: is_in_video_photo_code_seq; Type: SEQUENCE; Schema: photogallery; Owner: postgres
--

CREATE SEQUENCE photogallery.is_in_video_photo_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE photogallery.is_in_video_photo_code_seq OWNER TO postgres;

--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 217
-- Name: is_in_video_photo_code_seq; Type: SEQUENCE OWNED BY; Schema: photogallery; Owner: postgres
--

ALTER SEQUENCE photogallery.is_in_video_photo_code_seq OWNED BY photogallery.is_in_video.photo_code;


--
-- TOC entry 218 (class 1259 OID 16555)
-- Name: is_in_video_video_code_seq; Type: SEQUENCE; Schema: photogallery; Owner: postgres
--

CREATE SEQUENCE photogallery.is_in_video_video_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE photogallery.is_in_video_video_code_seq OWNER TO postgres;

--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 218
-- Name: is_in_video_video_code_seq; Type: SEQUENCE OWNED BY; Schema: photogallery; Owner: postgres
--

ALTER SEQUENCE photogallery.is_in_video_video_code_seq OWNED BY photogallery.is_in_video.video_code;


--
-- TOC entry 219 (class 1259 OID 16556)
-- Name: location; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.location (
    location_name character varying(64) NOT NULL,
    x_coordinates double precision,
    y_coordinates double precision,
    photo_count integer
);


ALTER TABLE photogallery.location OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16559)
-- Name: partecipating_users; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.partecipating_users (
    join_date date NOT NULL,
    nickname character varying(32) NOT NULL,
    collection_name character varying(32) NOT NULL
);


ALTER TABLE photogallery.partecipating_users OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16562)
-- Name: photo; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.photo (
    photo_code integer NOT NULL,
    scope character varying(16) DEFAULT 'Private'::character varying NOT NULL,
    nickname character varying(32) NOT NULL,
    location_name character varying(32),
    device character varying(32) NOT NULL,
    photo_date date NOT NULL
);


ALTER TABLE photogallery.photo OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16566)
-- Name: photo_photo_code_seq; Type: SEQUENCE; Schema: photogallery; Owner: postgres
--

CREATE SEQUENCE photogallery.photo_photo_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE photogallery.photo_photo_code_seq OWNER TO postgres;

--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 222
-- Name: photo_photo_code_seq; Type: SEQUENCE OWNED BY; Schema: photogallery; Owner: postgres
--

ALTER SEQUENCE photogallery.photo_photo_code_seq OWNED BY photogallery.photo.photo_code;


--
-- TOC entry 223 (class 1259 OID 16567)
-- Name: photo_tag; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.photo_tag (
    tag_name character varying(32) NOT NULL,
    photo_code integer NOT NULL
);


ALTER TABLE photogallery.photo_tag OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16570)
-- Name: public_collection; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.public_collection (
    collection_name character varying(32) NOT NULL
);


ALTER TABLE photogallery.public_collection OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16573)
-- Name: shared_photo; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.shared_photo (
    collection_name character varying(32) NOT NULL,
    photo_code integer NOT NULL
);


ALTER TABLE photogallery.shared_photo OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16576)
-- Name: tag; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.tag (
    tag_name character varying(32) NOT NULL
);


ALTER TABLE photogallery.tag OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16579)
-- Name: user_tag; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.user_tag (
    photo_code integer NOT NULL,
    nickname character varying(32) NOT NULL
);


ALTER TABLE photogallery.user_tag OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16582)
-- Name: video; Type: TABLE; Schema: photogallery; Owner: postgres
--

CREATE TABLE photogallery.video (
    video_code integer NOT NULL,
    video_length time without time zone NOT NULL,
    video_desc character varying(128),
    video_title character varying(32) NOT NULL,
    nickname character varying(32) NOT NULL
);


ALTER TABLE photogallery.video OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16585)
-- Name: video_video_code_seq; Type: SEQUENCE; Schema: photogallery; Owner: postgres
--

CREATE SEQUENCE photogallery.video_video_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE photogallery.video_video_code_seq OWNER TO postgres;

--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 229
-- Name: video_video_code_seq; Type: SEQUENCE OWNED BY; Schema: photogallery; Owner: postgres
--

ALTER SEQUENCE photogallery.video_video_code_seq OWNED BY photogallery.video.video_code;


--
-- TOC entry 3506 (class 2604 OID 16586)
-- Name: is_in_video video_code; Type: DEFAULT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.is_in_video ALTER COLUMN video_code SET DEFAULT nextval('photogallery.is_in_video_video_code_seq'::regclass);


--
-- TOC entry 3507 (class 2604 OID 16587)
-- Name: is_in_video photo_code; Type: DEFAULT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.is_in_video ALTER COLUMN photo_code SET DEFAULT nextval('photogallery.is_in_video_photo_code_seq'::regclass);


--
-- TOC entry 3508 (class 2604 OID 16588)
-- Name: photo photo_code; Type: DEFAULT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo ALTER COLUMN photo_code SET DEFAULT nextval('photogallery.photo_photo_code_seq'::regclass);


--
-- TOC entry 3510 (class 2604 OID 16589)
-- Name: video video_code; Type: DEFAULT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.video ALTER COLUMN video_code SET DEFAULT nextval('photogallery.video_video_code_seq'::regclass);


--
-- TOC entry 3688 (class 0 OID 16551)
-- Dependencies: 216
-- Data for Name: is_in_video; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.is_in_video (video_code, photo_code) FROM stdin;
\.


--
-- TOC entry 3691 (class 0 OID 16556)
-- Dependencies: 219
-- Data for Name: location; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.location (location_name, x_coordinates, y_coordinates, photo_count) FROM stdin;
\.


--
-- TOC entry 3692 (class 0 OID 16559)
-- Dependencies: 220
-- Data for Name: partecipating_users; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.partecipating_users (join_date, nickname, collection_name) FROM stdin;
\.


--
-- TOC entry 3693 (class 0 OID 16562)
-- Dependencies: 221
-- Data for Name: photo; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.photo (photo_code, scope, nickname, location_name, device, photo_date) FROM stdin;
\.


--
-- TOC entry 3695 (class 0 OID 16567)
-- Dependencies: 223
-- Data for Name: photo_tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.photo_tag (tag_name, photo_code) FROM stdin;
\.


--
-- TOC entry 3696 (class 0 OID 16570)
-- Dependencies: 224
-- Data for Name: public_collection; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.public_collection (collection_name) FROM stdin;
\.


--
-- TOC entry 3697 (class 0 OID 16573)
-- Dependencies: 225
-- Data for Name: shared_photo; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.shared_photo (collection_name, photo_code) FROM stdin;
\.


--
-- TOC entry 3698 (class 0 OID 16576)
-- Dependencies: 226
-- Data for Name: tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.tag (tag_name) FROM stdin;
\.


--
-- TOC entry 3699 (class 0 OID 16579)
-- Dependencies: 227
-- Data for Name: user_tag; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.user_tag (photo_code, nickname) FROM stdin;
\.


--
-- TOC entry 3700 (class 0 OID 16582)
-- Dependencies: 228
-- Data for Name: video; Type: TABLE DATA; Schema: photogallery; Owner: postgres
--

COPY photogallery.video (video_code, video_length, video_desc, video_title, nickname) FROM stdin;
\.


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 217
-- Name: is_in_video_photo_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.is_in_video_photo_code_seq', 1, false);


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 218
-- Name: is_in_video_video_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.is_in_video_video_code_seq', 1, false);


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 222
-- Name: photo_photo_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.photo_photo_code_seq', 1, false);


--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 229
-- Name: video_video_code_seq; Type: SEQUENCE SET; Schema: photogallery; Owner: postgres
--

SELECT pg_catalog.setval('photogallery.video_video_code_seq', 1, false);


--
-- TOC entry 3512 (class 2606 OID 16591)
-- Name: is_in_video is_in_video_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_pkey PRIMARY KEY (video_code, photo_code);


--
-- TOC entry 3514 (class 2606 OID 16593)
-- Name: location location_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_name);


--
-- TOC entry 3516 (class 2606 OID 16595)
-- Name: partecipating_users partecipating_users_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.partecipating_users
    ADD CONSTRAINT partecipating_users_pkey PRIMARY KEY (nickname, collection_name);


--
-- TOC entry 3518 (class 2606 OID 16597)
-- Name: photo photo_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (photo_code);


--
-- TOC entry 3520 (class 2606 OID 16599)
-- Name: photo_tag photo_tag_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_pkey PRIMARY KEY (tag_name, photo_code);


--
-- TOC entry 3522 (class 2606 OID 16601)
-- Name: public_collection public_collection_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.public_collection
    ADD CONSTRAINT public_collection_pkey PRIMARY KEY (collection_name);


--
-- TOC entry 3524 (class 2606 OID 16603)
-- Name: shared_photo shared_photo_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.shared_photo
    ADD CONSTRAINT shared_photo_pkey PRIMARY KEY (photo_code, collection_name);


--
-- TOC entry 3526 (class 2606 OID 16605)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (tag_name);


--
-- TOC entry 3528 (class 2606 OID 16607)
-- Name: user_tag user_tag_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.user_tag
    ADD CONSTRAINT user_tag_pkey PRIMARY KEY (photo_code, nickname);


--
-- TOC entry 3530 (class 2606 OID 16609)
-- Name: video video_pkey; Type: CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (video_code);


--
-- TOC entry 3542 (class 2620 OID 16610)
-- Name: shared_photo Add_User_Collection; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER "Add_User_Collection" AFTER INSERT ON photogallery.shared_photo FOR EACH ROW EXECUTE FUNCTION photogallery."NewUser_Collection"();


--
-- TOC entry 3538 (class 2620 OID 16611)
-- Name: photo Delete_Photo; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER "Delete_Photo" BEFORE UPDATE ON photogallery.photo FOR EACH STATEMENT EXECUTE FUNCTION photogallery."Delete_Photo"();


--
-- TOC entry 3539 (class 2620 OID 16612)
-- Name: photo Private_Photo; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER "Private_Photo" AFTER INSERT OR UPDATE ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."UPDATE_CollezionePubblica"();


--
-- TOC entry 3543 (class 2620 OID 16613)
-- Name: shared_photo Public_Photo; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER "Public_Photo" AFTER INSERT ON photogallery.shared_photo FOR EACH ROW EXECUTE FUNCTION photogallery."Public_Photo"();


--
-- TOC entry 3544 (class 2620 OID 16614)
-- Name: user_tag User_Tag_Check; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER "User_Tag_Check" BEFORE INSERT OR UPDATE ON photogallery.user_tag FOR EACH ROW EXECUTE FUNCTION photogallery."User_Tag_Check"();

ALTER TABLE photogallery.user_tag DISABLE TRIGGER "User_Tag_Check";


--
-- TOC entry 3540 (class 2620 OID 16615)
-- Name: photo photo_count_insert; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER photo_count_insert AFTER INSERT ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."Location_Count"();


--
-- TOC entry 3541 (class 2620 OID 16616)
-- Name: photo photo_count_subtract; Type: TRIGGER; Schema: photogallery; Owner: postgres
--

CREATE TRIGGER photo_count_subtract AFTER DELETE ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."Location_Count_Subtract"();


--
-- TOC entry 3531 (class 2606 OID 16617)
-- Name: is_in_video is_in_video_photo_code_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_photo_code_fkey FOREIGN KEY (photo_code) REFERENCES photogallery.photo(photo_code);


--
-- TOC entry 3532 (class 2606 OID 16622)
-- Name: is_in_video is_in_video_video_code_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_video_code_fkey FOREIGN KEY (video_code) REFERENCES photogallery.video(video_code);


--
-- TOC entry 3533 (class 2606 OID 16627)
-- Name: partecipating_users partecipating_users_collection_name_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.partecipating_users
    ADD CONSTRAINT partecipating_users_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES photogallery.public_collection(collection_name);


--
-- TOC entry 3534 (class 2606 OID 16632)
-- Name: photo photo_location_name_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo
    ADD CONSTRAINT photo_location_name_fkey FOREIGN KEY (location_name) REFERENCES photogallery.location(location_name);


--
-- TOC entry 3535 (class 2606 OID 16637)
-- Name: photo_tag photo_tag_photo_code_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_photo_code_fkey FOREIGN KEY (photo_code) REFERENCES photogallery.photo(photo_code);


--
-- TOC entry 3536 (class 2606 OID 16642)
-- Name: photo_tag photo_tag_tag_name_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_tag_name_fkey FOREIGN KEY (tag_name) REFERENCES photogallery.tag(tag_name);


--
-- TOC entry 3537 (class 2606 OID 16647)
-- Name: shared_photo shared_photo_collection_name_fkey; Type: FK CONSTRAINT; Schema: photogallery; Owner: postgres
--

ALTER TABLE ONLY photogallery.shared_photo
    ADD CONSTRAINT shared_photo_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES photogallery.public_collection(collection_name);


-- Completed on 2023-12-06 17:27:39 CET

--
-- PostgreSQL database dump complete
--

