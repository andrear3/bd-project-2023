PGDMP  5    1                {            nome    16.0    16.0 O    W           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            X           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            Y           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            Z           1262    16398    nome    DATABASE     w   CREATE DATABASE nome WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Italian_Italy.1252';
    DROP DATABASE nome;
                postgres    false                        2615    16399    photogallery    SCHEMA        CREATE SCHEMA photogallery;
    DROP SCHEMA photogallery;
                postgres    false            �           1247    17746    fullname    DOMAIN     �   CREATE DOMAIN photogallery.fullname AS character varying(32)
	CONSTRAINT fullname_check CHECK (((VALUE)::text ~ '^[a-zA-Z ]*$'::text));
 #   DROP DOMAIN photogallery.fullname;
       photogallery          postgres    false    6                       1255    17172    Delete_Photo()    FUNCTION       CREATE FUNCTION photogallery."Delete_Photo"() RETURNS trigger
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
 -   DROP FUNCTION photogallery."Delete_Photo"();
       photogallery          postgres    false    6            �            1255    17146    Delete_User()    FUNCTION     �  CREATE FUNCTION photogallery."Delete_User"() RETURNS trigger
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
 ,   DROP FUNCTION photogallery."Delete_User"();
       photogallery          postgres    false    6            �            1255    17127    Location_Count()    FUNCTION     e  CREATE FUNCTION photogallery."Location_Count"() RETURNS trigger
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
 /   DROP FUNCTION photogallery."Location_Count"();
       photogallery          postgres    false    6                       1255    17152    Location_Count_Subtract()    FUNCTION     �  CREATE FUNCTION photogallery."Location_Count_Subtract"() RETURNS trigger
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
 8   DROP FUNCTION photogallery."Location_Count_Subtract"();
       photogallery          postgres    false    6                       1255    17246    NewUser_Collection()    FUNCTION       CREATE FUNCTION photogallery."NewUser_Collection"() RETURNS trigger
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
 3   DROP FUNCTION photogallery."NewUser_Collection"();
       photogallery          postgres    false    6                       1255    17160    Photo_Tag_Check()    FUNCTION        CREATE FUNCTION photogallery."Photo_Tag_Check"() RETURNS trigger
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
 0   DROP FUNCTION photogallery."Photo_Tag_Check"();
       photogallery          postgres    false    6            �            1255    17114    Public_Photo()    FUNCTION       CREATE FUNCTION photogallery."Public_Photo"() RETURNS trigger
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
 -   DROP FUNCTION photogallery."Public_Photo"();
       photogallery          postgres    false    6            �            1255    16846    UPDATE_CollezionePubblica()    FUNCTION       CREATE FUNCTION photogallery."UPDATE_CollezionePubblica"() RETURNS trigger
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
 :   DROP FUNCTION photogallery."UPDATE_CollezionePubblica"();
       photogallery          postgres    false    6                       1255    17156    User_Tag_Check()    FUNCTION     �  CREATE FUNCTION photogallery."User_Tag_Check"() RETURNS trigger
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
 /   DROP FUNCTION photogallery."User_Tag_Check"();
       photogallery          postgres    false    6            �            1255    17744    elimina_foto(integer) 	   PROCEDURE     �   CREATE PROCEDURE photogallery.elimina_foto(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Eliminated'
WHERE ph_code = PHOTO_CODE
$$;
 >   DROP PROCEDURE photogallery.elimina_foto(IN ph_code integer);
       photogallery          postgres    false    6                        1255    17116    foto_stesso_luogo(text)    FUNCTION     K  CREATE FUNCTION photogallery.foto_stesso_luogo(luogo text) RETURNS TABLE(photo_code text, nickname text, location_name text, device text, photo_date date)
    LANGUAGE sql
    AS $$
  SELECT PH.photo_code, PH.nickname, PH.location_name, PH.device, PH.photo_date
  FROM photogallery.PHOTO AS PH
  WHERE PH.location_name = luogo
$$;
 :   DROP FUNCTION photogallery.foto_stesso_luogo(luogo text);
       photogallery          postgres    false    6            �            1255    17117    foto_stesso_soggetto(text)    FUNCTION     �  CREATE FUNCTION photogallery.foto_stesso_soggetto(soggetto text) RETURNS TABLE(photo_code text, nickname text, location_name text, device text, photo_date date)
    LANGUAGE sql
    AS $$
  SELECT PH.photo_code, PH.nickname, PH.location_name, PH.device, PH.photo_date
  FROM photogallery.PHOTO AS PH JOIN photogallery.photo_tag AS PT ON PH.photo_code = PT.photo_code
  WHERE PT.photo_code = PH.photo_code AND PT.tag_name = soggetto
$$;
 @   DROP FUNCTION photogallery.foto_stesso_soggetto(soggetto text);
       photogallery          postgres    false    6            �            1255    17237    galleriapersonale(text)    FUNCTION       CREATE FUNCTION photogallery.galleriapersonale(nick text) RETURNS TABLE(photo_code integer)
    LANGUAGE sql
    AS $$
SELECT PH.photo_code
FROM photogallery.photo as PH JOIN photogallery.user as U ON PH.nickname = U.nickname
WHERE U.nickname = nick AND PH.scope <> 'Eliminated'$$;
 9   DROP FUNCTION photogallery.galleriapersonale(nick text);
       photogallery          postgres    false    6                       1255    17240    galleriapersonalevideo(text)    FUNCTION     d  CREATE FUNCTION photogallery.galleriapersonalevideo(nick text) RETURNS TABLE(video_code integer, video_title text, video_lenght text, video_desc text)
    LANGUAGE sql
    AS $$
SELECT V.video_code, V.video_title, V.video_length, V.video_desc
FROM photogallery.video as V JOIN photogallery.user as U ON V.nickname = U.nickname
WHERE V.nickname = nick 
$$;
 >   DROP FUNCTION photogallery.galleriapersonalevideo(nick text);
       photogallery          postgres    false    6            �            1255    16841    rendi_foto_privata(integer) 	   PROCEDURE     �   CREATE PROCEDURE photogallery.rendi_foto_privata(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Private'
WHERE ph_code = PHOTO_CODE
$$;
 D   DROP PROCEDURE photogallery.rendi_foto_privata(IN ph_code integer);
       photogallery          postgres    false    6            �            1255    16842    rendi_foto_pubblica(integer) 	   PROCEDURE     �   CREATE PROCEDURE photogallery.rendi_foto_pubblica(IN ph_code integer)
    LANGUAGE sql
    AS $$UPDATE photogallery.PHOTO
SET SCOPE = 'Public'
WHERE ph_code = PHOTO_CODE$$;
 E   DROP PROCEDURE photogallery.rendi_foto_pubblica(IN ph_code integer);
       photogallery          postgres    false    6            �            1255    16793    testdevice()    FUNCTION     �   CREATE FUNCTION photogallery.testdevice() RETURNS TABLE(name text)
    LANGUAGE sql
    AS $$
  SELECT PH.DEVICE
  FROM photogallery.PHOTO AS PH
$$;
 )   DROP FUNCTION photogallery.testdevice();
       photogallery          postgres    false    6            �            1255    17228    top_3_luoghi()    FUNCTION     �   CREATE FUNCTION photogallery.top_3_luoghi() RETURNS TABLE(location_name text, photo_count integer)
    LANGUAGE sql
    AS $$
SELECT location_name, photo_count
FROM photogallery.location
ORDER BY photo_count DESC
LIMIT 3;
$$;
 +   DROP FUNCTION photogallery.top_3_luoghi();
       photogallery          postgres    false    6            �            1255    16831    video_foto(integer)    FUNCTION     N  CREATE FUNCTION photogallery.video_foto(video_cod integer) RETURNS TABLE(video_title text, video_code text, photo_code text)
    LANGUAGE sql
    AS $$
	SELECT V.video_title, I.video_code, I.photo_code
	FROM photogallery.is_in_video as I JOIN photogallery.video as V on I.video_code = V.video_code
	WHERE V.video_code = video_cod
$$;
 :   DROP FUNCTION photogallery.video_foto(video_cod integer);
       photogallery          postgres    false    6            �            1259    16812    is_in_video    TABLE     l   CREATE TABLE photogallery.is_in_video (
    video_code integer NOT NULL,
    photo_code integer NOT NULL
);
 %   DROP TABLE photogallery.is_in_video;
       photogallery         heap    postgres    false    6            �            1259    16811    is_in_video_photo_code_seq    SEQUENCE     �   CREATE SEQUENCE photogallery.is_in_video_photo_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE photogallery.is_in_video_photo_code_seq;
       photogallery          postgres    false    228    6            [           0    0    is_in_video_photo_code_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE photogallery.is_in_video_photo_code_seq OWNED BY photogallery.is_in_video.photo_code;
          photogallery          postgres    false    227            �            1259    16810    is_in_video_video_code_seq    SEQUENCE     �   CREATE SEQUENCE photogallery.is_in_video_video_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE photogallery.is_in_video_video_code_seq;
       photogallery          postgres    false    6    228            \           0    0    is_in_video_video_code_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE photogallery.is_in_video_video_code_seq OWNED BY photogallery.is_in_video.video_code;
          photogallery          postgres    false    226            �            1259    16624    location    TABLE     �   CREATE TABLE photogallery.location (
    location_name character varying(64) NOT NULL,
    x_coordinates double precision,
    y_coordinates double precision,
    photo_count integer
);
 "   DROP TABLE photogallery.location;
       photogallery         heap    postgres    false    6            �            1259    16592    partecipating_users    TABLE     �   CREATE TABLE photogallery.partecipating_users (
    join_date date NOT NULL,
    nickname character varying(32) NOT NULL,
    collection_name character varying(32) NOT NULL
);
 -   DROP TABLE photogallery.partecipating_users;
       photogallery         heap    postgres    false    6            �            1259    16678    photo    TABLE     3  CREATE TABLE photogallery.photo (
    photo_code integer NOT NULL,
    scope character varying(16) DEFAULT 'Private'::character varying NOT NULL,
    nickname character varying(32) NOT NULL,
    location_name character varying(32),
    device character varying(32) NOT NULL,
    photo_date date NOT NULL
);
    DROP TABLE photogallery.photo;
       photogallery         heap    postgres    false    6            �            1259    16677    photo_photo_code_seq    SEQUENCE     �   CREATE SEQUENCE photogallery.photo_photo_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE photogallery.photo_photo_code_seq;
       photogallery          postgres    false    225    6            ]           0    0    photo_photo_code_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE photogallery.photo_photo_code_seq OWNED BY photogallery.photo.photo_code;
          photogallery          postgres    false    224            �            1259    17098 	   photo_tag    TABLE     v   CREATE TABLE photogallery.photo_tag (
    tag_name character varying(32) NOT NULL,
    photo_code integer NOT NULL
);
 #   DROP TABLE photogallery.photo_tag;
       photogallery         heap    postgres    false    6            �            1259    16587    public_collection    TABLE     d   CREATE TABLE photogallery.public_collection (
    collection_name character varying(32) NOT NULL
);
 +   DROP TABLE photogallery.public_collection;
       photogallery         heap    postgres    false    6            �            1259    16645    shared_photo    TABLE     �   CREATE TABLE photogallery.shared_photo (
    collection_name character varying(32) NOT NULL,
    photo_code integer NOT NULL
);
 &   DROP TABLE photogallery.shared_photo;
       photogallery         heap    postgres    false    6            �            1259    17093    tag    TABLE     O   CREATE TABLE photogallery.tag (
    tag_name character varying(32) NOT NULL
);
    DROP TABLE photogallery.tag;
       photogallery         heap    postgres    false    6            �            1259    16554    user    TABLE     �   CREATE TABLE photogallery."user" (
    nickname character varying(32) NOT NULL,
    name public.fullname NOT NULL,
    surname public.fullname NOT NULL,
    birthdate date,
    gender character varying(1)
);
     DROP TABLE photogallery."user";
       photogallery         heap    postgres    false    6            �            1259    16572    user_tag    TABLE     u   CREATE TABLE photogallery.user_tag (
    photo_code integer NOT NULL,
    nickname character varying(32) NOT NULL
);
 "   DROP TABLE photogallery.user_tag;
       photogallery         heap    postgres    false    6            �            1259    16608    video    TABLE     �   CREATE TABLE photogallery.video (
    video_code integer NOT NULL,
    video_length time without time zone NOT NULL,
    video_desc character varying(128),
    video_title character varying(32) NOT NULL,
    nickname character varying(32) NOT NULL
);
    DROP TABLE photogallery.video;
       photogallery         heap    postgres    false    6            �            1259    16607    video_video_code_seq    SEQUENCE     �   CREATE SEQUENCE photogallery.video_video_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE photogallery.video_video_code_seq;
       photogallery          postgres    false    6    221            ^           0    0    video_video_code_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE photogallery.video_video_code_seq OWNED BY photogallery.video.video_code;
          photogallery          postgres    false    220            �           2604    16815    is_in_video video_code    DEFAULT     �   ALTER TABLE ONLY photogallery.is_in_video ALTER COLUMN video_code SET DEFAULT nextval('photogallery.is_in_video_video_code_seq'::regclass);
 K   ALTER TABLE photogallery.is_in_video ALTER COLUMN video_code DROP DEFAULT;
       photogallery          postgres    false    228    226    228            �           2604    16816    is_in_video photo_code    DEFAULT     �   ALTER TABLE ONLY photogallery.is_in_video ALTER COLUMN photo_code SET DEFAULT nextval('photogallery.is_in_video_photo_code_seq'::regclass);
 K   ALTER TABLE photogallery.is_in_video ALTER COLUMN photo_code DROP DEFAULT;
       photogallery          postgres    false    227    228    228            �           2604    16681    photo photo_code    DEFAULT     �   ALTER TABLE ONLY photogallery.photo ALTER COLUMN photo_code SET DEFAULT nextval('photogallery.photo_photo_code_seq'::regclass);
 E   ALTER TABLE photogallery.photo ALTER COLUMN photo_code DROP DEFAULT;
       photogallery          postgres    false    224    225    225            �           2604    16611    video video_code    DEFAULT     �   ALTER TABLE ONLY photogallery.video ALTER COLUMN video_code SET DEFAULT nextval('photogallery.video_video_code_seq'::regclass);
 E   ALTER TABLE photogallery.video ALTER COLUMN video_code DROP DEFAULT;
       photogallery          postgres    false    221    220    221            �           2606    17748    user Check_Gender    CHECK CONSTRAINT     �   ALTER TABLE photogallery."user"
    ADD CONSTRAINT "Check_Gender" CHECK ((((gender)::text = 'M'::text) OR ((gender)::text = 'F'::text))) NOT VALID;
 @   ALTER TABLE photogallery."user" DROP CONSTRAINT "Check_Gender";
       photogallery          postgres    false    216    216            �           2606    16818    is_in_video is_in_video_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_pkey PRIMARY KEY (video_code, photo_code);
 L   ALTER TABLE ONLY photogallery.is_in_video DROP CONSTRAINT is_in_video_pkey;
       photogallery            postgres    false    228    228            �           2606    16628    location location_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY photogallery.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_name);
 F   ALTER TABLE ONLY photogallery.location DROP CONSTRAINT location_pkey;
       photogallery            postgres    false    222            �           2606    16596 ,   partecipating_users partecipating_users_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY photogallery.partecipating_users
    ADD CONSTRAINT partecipating_users_pkey PRIMARY KEY (nickname, collection_name);
 \   ALTER TABLE ONLY photogallery.partecipating_users DROP CONSTRAINT partecipating_users_pkey;
       photogallery            postgres    false    219    219            �           2606    16684    photo photo_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY photogallery.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (photo_code);
 @   ALTER TABLE ONLY photogallery.photo DROP CONSTRAINT photo_pkey;
       photogallery            postgres    false    225            �           2606    17102    photo_tag photo_tag_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_pkey PRIMARY KEY (tag_name, photo_code);
 H   ALTER TABLE ONLY photogallery.photo_tag DROP CONSTRAINT photo_tag_pkey;
       photogallery            postgres    false    230    230            �           2606    16591 (   public_collection public_collection_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY photogallery.public_collection
    ADD CONSTRAINT public_collection_pkey PRIMARY KEY (collection_name);
 X   ALTER TABLE ONLY photogallery.public_collection DROP CONSTRAINT public_collection_pkey;
       photogallery            postgres    false    218            �           2606    16649    shared_photo shared_photo_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY photogallery.shared_photo
    ADD CONSTRAINT shared_photo_pkey PRIMARY KEY (photo_code, collection_name);
 N   ALTER TABLE ONLY photogallery.shared_photo DROP CONSTRAINT shared_photo_pkey;
       photogallery            postgres    false    223    223            �           2606    17097    tag tag_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY photogallery.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (tag_name);
 <   ALTER TABLE ONLY photogallery.tag DROP CONSTRAINT tag_pkey;
       photogallery            postgres    false    229            �           2606    16558    user user_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY photogallery."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (nickname);
 @   ALTER TABLE ONLY photogallery."user" DROP CONSTRAINT user_pkey;
       photogallery            postgres    false    216            �           2606    16576    user_tag user_tag_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY photogallery.user_tag
    ADD CONSTRAINT user_tag_pkey PRIMARY KEY (photo_code, nickname);
 F   ALTER TABLE ONLY photogallery.user_tag DROP CONSTRAINT user_tag_pkey;
       photogallery            postgres    false    217    217            �           2606    16613    video video_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY photogallery.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (video_code);
 @   ALTER TABLE ONLY photogallery.video DROP CONSTRAINT video_pkey;
       photogallery            postgres    false    221            �           2620    17249     shared_photo Add_User_Collection    TRIGGER     �   CREATE TRIGGER "Add_User_Collection" AFTER INSERT ON photogallery.shared_photo FOR EACH ROW EXECUTE FUNCTION photogallery."NewUser_Collection"();
 A   DROP TRIGGER "Add_User_Collection" ON photogallery.shared_photo;
       photogallery          postgres    false    262    223            �           2620    17243    photo Delete_Photo    TRIGGER     �   CREATE TRIGGER "Delete_Photo" BEFORE UPDATE ON photogallery.photo FOR EACH STATEMENT EXECUTE FUNCTION photogallery."Delete_Photo"();
 3   DROP TRIGGER "Delete_Photo" ON photogallery.photo;
       photogallery          postgres    false    257    225            �           2620    17224    user Delete_User    TRIGGER     }   CREATE TRIGGER "Delete_User" AFTER DELETE ON photogallery."user" FOR EACH ROW EXECUTE FUNCTION photogallery."Delete_User"();
 3   DROP TRIGGER "Delete_User" ON photogallery."user";
       photogallery          postgres    false    253    216            �           2620    17091    photo Private_Photo    TRIGGER     �   CREATE TRIGGER "Private_Photo" AFTER INSERT OR UPDATE ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."UPDATE_CollezionePubblica"();
 4   DROP TRIGGER "Private_Photo" ON photogallery.photo;
       photogallery          postgres    false    225    246            �           2620    17252    shared_photo Public_Photo    TRIGGER     �   CREATE TRIGGER "Public_Photo" AFTER INSERT ON photogallery.shared_photo FOR EACH ROW EXECUTE FUNCTION photogallery."Public_Photo"();
 :   DROP TRIGGER "Public_Photo" ON photogallery.shared_photo;
       photogallery          postgres    false    223    244            �           2620    17218    user_tag User_Tag_Check    TRIGGER     �   CREATE TRIGGER "User_Tag_Check" BEFORE INSERT OR UPDATE ON photogallery.user_tag FOR EACH ROW EXECUTE FUNCTION photogallery."User_Tag_Check"();

ALTER TABLE photogallery.user_tag DISABLE TRIGGER "User_Tag_Check";
 8   DROP TRIGGER "User_Tag_Check" ON photogallery.user_tag;
       photogallery          postgres    false    258    217            �           2620    17129    photo photo_count_insert    TRIGGER     �   CREATE TRIGGER photo_count_insert AFTER INSERT ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."Location_Count"();
 7   DROP TRIGGER photo_count_insert ON photogallery.photo;
       photogallery          postgres    false    249    225            �           2620    17226    photo photo_count_subtract    TRIGGER     �   CREATE TRIGGER photo_count_subtract AFTER DELETE ON photogallery.photo FOR EACH ROW EXECUTE FUNCTION photogallery."Location_Count_Subtract"();
 9   DROP TRIGGER photo_count_subtract ON photogallery.photo;
       photogallery          postgres    false    225    259            �           2606    16819 '   is_in_video is_in_video_photo_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_photo_code_fkey FOREIGN KEY (photo_code) REFERENCES photogallery.photo(photo_code);
 W   ALTER TABLE ONLY photogallery.is_in_video DROP CONSTRAINT is_in_video_photo_code_fkey;
       photogallery          postgres    false    4780    228    225            �           2606    16824 '   is_in_video is_in_video_video_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.is_in_video
    ADD CONSTRAINT is_in_video_video_code_fkey FOREIGN KEY (video_code) REFERENCES photogallery.video(video_code);
 W   ALTER TABLE ONLY photogallery.is_in_video DROP CONSTRAINT is_in_video_video_code_fkey;
       photogallery          postgres    false    4774    228    221            �           2606    16602 <   partecipating_users partecipating_users_collection_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.partecipating_users
    ADD CONSTRAINT partecipating_users_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES photogallery.public_collection(collection_name);
 l   ALTER TABLE ONLY photogallery.partecipating_users DROP CONSTRAINT partecipating_users_collection_name_fkey;
       photogallery          postgres    false    219    4770    218            �           2606    16597 5   partecipating_users partecipating_users_nickname_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.partecipating_users
    ADD CONSTRAINT partecipating_users_nickname_fkey FOREIGN KEY (nickname) REFERENCES photogallery."user"(nickname);
 e   ALTER TABLE ONLY photogallery.partecipating_users DROP CONSTRAINT partecipating_users_nickname_fkey;
       photogallery          postgres    false    216    219    4766            �           2606    16690    photo photo_location_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.photo
    ADD CONSTRAINT photo_location_name_fkey FOREIGN KEY (location_name) REFERENCES photogallery.location(location_name);
 N   ALTER TABLE ONLY photogallery.photo DROP CONSTRAINT photo_location_name_fkey;
       photogallery          postgres    false    222    4776    225            �           2606    16685    photo photo_nickname_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.photo
    ADD CONSTRAINT photo_nickname_fkey FOREIGN KEY (nickname) REFERENCES photogallery."user"(nickname);
 I   ALTER TABLE ONLY photogallery.photo DROP CONSTRAINT photo_nickname_fkey;
       photogallery          postgres    false    216    4766    225            �           2606    17108 #   photo_tag photo_tag_photo_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_photo_code_fkey FOREIGN KEY (photo_code) REFERENCES photogallery.photo(photo_code);
 S   ALTER TABLE ONLY photogallery.photo_tag DROP CONSTRAINT photo_tag_photo_code_fkey;
       photogallery          postgres    false    225    4780    230            �           2606    17103 !   photo_tag photo_tag_tag_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.photo_tag
    ADD CONSTRAINT photo_tag_tag_name_fkey FOREIGN KEY (tag_name) REFERENCES photogallery.tag(tag_name);
 Q   ALTER TABLE ONLY photogallery.photo_tag DROP CONSTRAINT photo_tag_tag_name_fkey;
       photogallery          postgres    false    230    229    4784            �           2606    16655 .   shared_photo shared_photo_collection_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.shared_photo
    ADD CONSTRAINT shared_photo_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES photogallery.public_collection(collection_name);
 ^   ALTER TABLE ONLY photogallery.shared_photo DROP CONSTRAINT shared_photo_collection_name_fkey;
       photogallery          postgres    false    4770    218    223            �           2606    16582    user_tag user_tag_nickname_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.user_tag
    ADD CONSTRAINT user_tag_nickname_fkey FOREIGN KEY (nickname) REFERENCES photogallery."user"(nickname);
 O   ALTER TABLE ONLY photogallery.user_tag DROP CONSTRAINT user_tag_nickname_fkey;
       photogallery          postgres    false    217    4766    216            �           2606    16619    video video_nickname_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY photogallery.video
    ADD CONSTRAINT video_nickname_fkey FOREIGN KEY (nickname) REFERENCES photogallery."user"(nickname);
 I   ALTER TABLE ONLY photogallery.video DROP CONSTRAINT video_nickname_fkey;
       photogallery          postgres    false    216    221    4766           