PGDMP      2                {            nome    16.0    16.0     `           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            a           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            b           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            c           1262    16398    nome    DATABASE     w   CREATE DATABASE nome WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Italian_Italy.1252';
    DROP DATABASE nome;
                postgres    false            U          0    16624    location 
   TABLE DATA           b   COPY photogallery.location (location_name, x_coordinates, y_coordinates, photo_count) FROM stdin;
    photogallery          postgres    false    222   u       O          0    16554    user 
   TABLE DATA           R   COPY photogallery."user" (nickname, name, surname, birthdate, gender) FROM stdin;
    photogallery          postgres    false    216   �       X          0    16678    photo 
   TABLE DATA           e   COPY photogallery.photo (photo_code, scope, nickname, location_name, device, photo_date) FROM stdin;
    photogallery          postgres    false    225   �       T          0    16608    video 
   TABLE DATA           b   COPY photogallery.video (video_code, video_length, video_desc, video_title, nickname) FROM stdin;
    photogallery          postgres    false    221   �       [          0    16812    is_in_video 
   TABLE DATA           C   COPY photogallery.is_in_video (video_code, photo_code) FROM stdin;
    photogallery          postgres    false    228   `       Q          0    16587    public_collection 
   TABLE DATA           B   COPY photogallery.public_collection (collection_name) FROM stdin;
    photogallery          postgres    false    218   �       R          0    16592    partecipating_users 
   TABLE DATA           Y   COPY photogallery.partecipating_users (join_date, nickname, collection_name) FROM stdin;
    photogallery          postgres    false    219   �       \          0    17093    tag 
   TABLE DATA           -   COPY photogallery.tag (tag_name) FROM stdin;
    photogallery          postgres    false    229   R       ]          0    17098 	   photo_tag 
   TABLE DATA           ?   COPY photogallery.photo_tag (tag_name, photo_code) FROM stdin;
    photogallery          postgres    false    230   �       V          0    16645    shared_photo 
   TABLE DATA           I   COPY photogallery.shared_photo (collection_name, photo_code) FROM stdin;
    photogallery          postgres    false    223          P          0    16572    user_tag 
   TABLE DATA           >   COPY photogallery.user_tag (photo_code, nickname) FROM stdin;
    photogallery          postgres    false    217   Q       d           0    0    is_in_video_photo_code_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('photogallery.is_in_video_photo_code_seq', 1, false);
          photogallery          postgres    false    227            e           0    0    is_in_video_video_code_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('photogallery.is_in_video_video_code_seq', 1, false);
          photogallery          postgres    false    226            f           0    0    photo_photo_code_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('photogallery.photo_photo_code_seq', 39, true);
          photogallery          postgres    false    224            g           0    0    video_video_code_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('photogallery.video_video_code_seq', 1, true);
          photogallery          postgres    false    220            U   c   x��1�0D�z�0#�[�	�@5����,��������8���D��s|bЍ���TQls���������~�o���؅d�c�+�BUtz[�M3��@      O   �   x�EO�
1<�_����{���V_ ^�F��V��7��@��d*L���6^�0E93	CimYtpP��CBrc�Q.*A�8���6s
����%�i�V
��s 7�%G�s�&�maEi��l.���p$y6Q�'�v��Ys۪/�o�3�=�`���3g�[x{{� a�ژ8�_�����7�| �D�      X   *  x���]O� ���W�0�@����#^�M�����FB������li;�U��&$�s�+$J��5+���V�@����=�T^5nCʪ�=��qƁ2I!��4;Uk4�V�zM�*]��I��iQE�3��
����>4u��O��LГ�ʝy e��-����#RS-��;u��G?����K�V����p�2�UU��AϪ��\4,Z�B(�����N%��Vw��0��dD2Ʀ�A&1��RZ���6ȁ����Gm���/���p�f����za�V�ћv�X��S.����Y���      T   _   x�3�40�24�20�KLN̫JT��SH�,ʇ�9�3�r�͸�8����&��)�f�+�%�����+$*����%�5�%�%�r��qqq � �      [      x�3�4�2�4�2�4f\1z\\\ #��      Q   )   x�s���I����KU0�
KLN̫JT�J-*������� �{
�      R   ~   x�3202�50�50�tK,.	��K�t���I����KU0�2)04�52�t�(�)64Ð7�q�$&��w*-)I-J˩��ĩ& �� �3,191�*Q!*��4/Yޭ(1/9���%(v��qqq (C      \   E   x�N�I�L�
HL-NLO���r-K�+���)�O�WH�T��+I-J-.N��OOO-Je�%�1z\\\ ��5      ]   L   x��)�O�WH�T��+I-J-.N�46���"j�����	fe�%���s[p����B�0�\�e�y 1K�=... ���      V   >   x�KLN̫JT�J-*���46�
C1�r���I����KU0���r�U���-��\1z\\\ �|)K      P   (   x�32�tK,.	��K�2�@���8݊���b���� ��     