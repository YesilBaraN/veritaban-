PGDMP                      |            mobilya_satis    17.2    17.2 t    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    16393    mobilya_satis    DATABASE     o   CREATE DATABASE mobilya_satis WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';
    DROP DATABASE mobilya_satis;
                     postgres    false            �            1255    16641    genelkarhesapla()    FUNCTION     �  CREATE FUNCTION public.genelkarhesapla() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    SiparisToplamTutar NUMERIC;
    TedarikciToplamTutar NUMERIC;
    GenelKar NUMERIC;
BEGIN
    -- Toplam Sipariş Tutarını Al
    SELECT SUM(Siparis.ToplamTutar) 
    INTO SiparisToplamTutar
    FROM Siparis;

    -- Toplam Tedarikçi Ödemesini Al
    SELECT SUM(UrunTedarikci.Tutar) 
    INTO TedarikciToplamTutar
    FROM UrunTedarikci;

    -- Genel Kar = Sipariş Toplam Tutarı - Tedarikçi Toplam Tutarı
    GenelKar := SiparisToplamTutar - TedarikciToplamTutar;

    RETURN COALESCE(GenelKar, 0); -- Eğer sonuç null ise 0 döner.
END;
$$;
 (   DROP FUNCTION public.genelkarhesapla();
       public               postgres    false            �            1255    16637    haftaliksatisraporu()    FUNCTION     N  CREATE FUNCTION public.haftaliksatisraporu() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    ToplamSatis NUMERIC;
BEGIN
    SELECT SUM(ToplamTutar)
    INTO ToplamSatis
    FROM Siparis
    WHERE SiparisTarih >= CURRENT_DATE - INTERVAL '7 days';

    RETURN COALESCE(ToplamSatis, 0); -- Eğer veri yoksa 0 döner.
END;
$$;
 ,   DROP FUNCTION public.haftaliksatisraporu();
       public               postgres    false            �            1255    16638    populerurunler()    FUNCTION     �  CREATE FUNCTION public.populerurunler() RETURNS TABLE(urunid integer, urunadi character varying, siparissayisi integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        Urun.UrunID, 
        Urun.UrunAdi, 
        COUNT(SiparisUrun.SiparisUrunID) AS SiparisSayisi
    FROM Urun
    JOIN SiparisUrun ON Urun.UrunID = SiparisUrun.UrunID
    GROUP BY Urun.UrunID, Urun.UrunAdi
    ORDER BY SiparisSayisi DESC
    LIMIT 5; -- İlk 5 popüler ürünü döner.
END;
$$;
 '   DROP FUNCTION public.populerurunler();
       public               postgres    false            �            1255    16640    tummusterileraktifsiparisler()    FUNCTION     �  CREATE FUNCTION public.tummusterileraktifsiparisler() RETURNS TABLE(siparisid integer, musteriid integer, siparistarih date, toplamtutar numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.SiparisID,   -- Tablo ismi açıkça belirtiliyor
        s.MusteriID,   
        s.SiparisTarih,
        s.ToplamTutar
    FROM Siparis s
    WHERE s.Durum = 'Aktif'; -- Sadece aktif siparişler
END;
$$;
 5   DROP FUNCTION public.tummusterileraktifsiparisler();
       public               postgres    false            �            1259    16566    depo    TABLE     �   CREATE TABLE public.depo (
    depoid integer NOT NULL,
    depoadi character varying(100),
    adres text,
    telefon character varying(15)
);
    DROP TABLE public.depo;
       public         heap r       postgres    false            �            1259    16565    depo_depoid_seq    SEQUENCE     �   CREATE SEQUENCE public.depo_depoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.depo_depoid_seq;
       public               postgres    false    235            �           0    0    depo_depoid_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.depo_depoid_seq OWNED BY public.depo.depoid;
          public               postgres    false    234            �            1259    16545    dolapvedepolama    TABLE     �   CREATE TABLE public.dolapvedepolama (
    kategoriid integer NOT NULL,
    rafsayisi integer,
    kapaksayisi integer,
    kapakturu character varying(100)
);
 #   DROP TABLE public.dolapvedepolama;
       public         heap r       postgres    false            �            1259    16517 
   islemkaydi    TABLE     �   CREATE TABLE public.islemkaydi (
    islemid integer NOT NULL,
    urunid integer,
    kullaniciid integer,
    islemtarih date,
    islemtipi character varying(50),
    aciklama text
);
    DROP TABLE public.islemkaydi;
       public         heap r       postgres    false            �            1259    16516    islemkaydi_islemid_seq    SEQUENCE     �   CREATE SEQUENCE public.islemkaydi_islemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.islemkaydi_islemid_seq;
       public               postgres    false    230            �           0    0    islemkaydi_islemid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.islemkaydi_islemid_seq OWNED BY public.islemkaydi.islemid;
          public               postgres    false    229            �            1259    16451    kategori    TABLE     �   CREATE TABLE public.kategori (
    kategoriid integer NOT NULL,
    kategoriadi character varying(100),
    aciklama text,
    renk character varying(50)
);
    DROP TABLE public.kategori;
       public         heap r       postgres    false            �            1259    16450    kategori_kategoriid_seq    SEQUENCE     �   CREATE SEQUENCE public.kategori_kategoriid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.kategori_kategoriid_seq;
       public               postgres    false    218            �           0    0    kategori_kategoriid_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.kategori_kategoriid_seq OWNED BY public.kategori.kategoriid;
          public               postgres    false    217            �            1259    16510 	   kullanici    TABLE     �   CREATE TABLE public.kullanici (
    kullaniciid integer NOT NULL,
    adsoyad character varying(100),
    kullaniciadi character varying(50),
    sifre character varying(100),
    songiristarih date
);
    DROP TABLE public.kullanici;
       public         heap r       postgres    false            �            1259    16509    kullanici_kullaniciid_seq    SEQUENCE     �   CREATE SEQUENCE public.kullanici_kullaniciid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.kullanici_kullaniciid_seq;
       public               postgres    false    228            �           0    0    kullanici_kullaniciid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.kullanici_kullaniciid_seq OWNED BY public.kullanici.kullaniciid;
          public               postgres    false    227            �            1259    16555    masavesehpa    TABLE     �   CREATE TABLE public.masavesehpa (
    kategoriid integer NOT NULL,
    boyut character varying(50),
    sekil character varying(50),
    katlanabilirmi boolean
);
    DROP TABLE public.masavesehpa;
       public         heap r       postgres    false            �            1259    16472    musteri    TABLE     �   CREATE TABLE public.musteri (
    musteriid integer NOT NULL,
    adsoyad character varying(100),
    telefon character varying(15),
    eposta character varying(100),
    adres text
);
    DROP TABLE public.musteri;
       public         heap r       postgres    false            �            1259    16471    musteri_musteriid_seq    SEQUENCE     �   CREATE SEQUENCE public.musteri_musteriid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.musteri_musteriid_seq;
       public               postgres    false    222            �           0    0    musteri_musteriid_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.musteri_musteriid_seq OWNED BY public.musteri.musteriid;
          public               postgres    false    221            �            1259    16535    oturmagrubu    TABLE     �   CREATE TABLE public.oturmagrubu (
    kategoriid integer NOT NULL,
    kapasite integer,
    yastiksayisi integer,
    dosememalzemesi character varying(100)
);
    DROP TABLE public.oturmagrubu;
       public         heap r       postgres    false            �            1259    16481    siparis    TABLE     �   CREATE TABLE public.siparis (
    siparisid integer NOT NULL,
    musteriid integer,
    siparistarih date,
    toplamtutar numeric(10,2),
    durum character varying(50)
);
    DROP TABLE public.siparis;
       public         heap r       postgres    false            �            1259    16480    siparis_siparisid_seq    SEQUENCE     �   CREATE SEQUENCE public.siparis_siparisid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.siparis_siparisid_seq;
       public               postgres    false    224            �           0    0    siparis_siparisid_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.siparis_siparisid_seq OWNED BY public.siparis.siparisid;
          public               postgres    false    223            �            1259    16493    siparisurun    TABLE     �   CREATE TABLE public.siparisurun (
    siparisurunid integer NOT NULL,
    siparisid integer,
    urunid integer,
    miktar integer,
    birimfiyat numeric(10,2),
    tutar numeric(10,2)
);
    DROP TABLE public.siparisurun;
       public         heap r       postgres    false            �            1259    16492    siparisurun_siparisurunid_seq    SEQUENCE     �   CREATE SEQUENCE public.siparisurun_siparisurunid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.siparisurun_siparisurunid_seq;
       public               postgres    false    226            �           0    0    siparisurun_siparisurunid_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.siparisurun_siparisurunid_seq OWNED BY public.siparisurun.siparisurunid;
          public               postgres    false    225            �            1259    16592 	   tedarikci    TABLE     �   CREATE TABLE public.tedarikci (
    tedarikciid integer NOT NULL,
    firmaadi character varying(100),
    telefon character varying(15),
    eposta character varying(100),
    adres text
);
    DROP TABLE public.tedarikci;
       public         heap r       postgres    false            �            1259    16591    tedarikci_tedarikciid_seq    SEQUENCE     �   CREATE SEQUENCE public.tedarikci_tedarikciid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.tedarikci_tedarikciid_seq;
       public               postgres    false    239            �           0    0    tedarikci_tedarikciid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.tedarikci_tedarikciid_seq OWNED BY public.tedarikci.tedarikciid;
          public               postgres    false    238            �            1259    16460    urun    TABLE     �   CREATE TABLE public.urun (
    urunid integer NOT NULL,
    kategoriid integer,
    eklenmetarihi date,
    urunadi character varying(200),
    birimfiyat numeric(10,2),
    stokmiktari integer
);
    DROP TABLE public.urun;
       public         heap r       postgres    false            �            1259    16459    urun_urunid_seq    SEQUENCE     �   CREATE SEQUENCE public.urun_urunid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.urun_urunid_seq;
       public               postgres    false    220            �           0    0    urun_urunid_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.urun_urunid_seq OWNED BY public.urun.urunid;
          public               postgres    false    219            �            1259    16575    urundepo    TABLE     �   CREATE TABLE public.urundepo (
    urundepoid integer NOT NULL,
    depoid integer,
    urunid integer,
    miktar integer,
    songuncelleme date
);
    DROP TABLE public.urundepo;
       public         heap r       postgres    false            �            1259    16574    urundepo_urundepoid_seq    SEQUENCE     �   CREATE SEQUENCE public.urundepo_urundepoid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.urundepo_urundepoid_seq;
       public               postgres    false    237            �           0    0    urundepo_urundepoid_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.urundepo_urundepoid_seq OWNED BY public.urundepo.urundepoid;
          public               postgres    false    236            �            1259    16618    urungorusleri    TABLE     �   CREATE TABLE public.urungorusleri (
    gorusid integer NOT NULL,
    musteriid integer,
    urunid integer,
    gorus text,
    puan integer,
    gorustarihi date
);
 !   DROP TABLE public.urungorusleri;
       public         heap r       postgres    false            �            1259    16617    urungorusleri_gorusid_seq    SEQUENCE     �   CREATE SEQUENCE public.urungorusleri_gorusid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.urungorusleri_gorusid_seq;
       public               postgres    false    243            �           0    0    urungorusleri_gorusid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.urungorusleri_gorusid_seq OWNED BY public.urungorusleri.gorusid;
          public               postgres    false    242            �            1259    16601    uruntedarikci    TABLE     �   CREATE TABLE public.uruntedarikci (
    uruntedarikciid integer NOT NULL,
    tedarikciid integer,
    urunid integer,
    tedariktarihi date,
    adet integer,
    tutar numeric(10,2)
);
 !   DROP TABLE public.uruntedarikci;
       public         heap r       postgres    false            �            1259    16600 !   uruntedarikci_uruntedarikciid_seq    SEQUENCE     �   CREATE SEQUENCE public.uruntedarikci_uruntedarikciid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.uruntedarikci_uruntedarikciid_seq;
       public               postgres    false    241            �           0    0 !   uruntedarikci_uruntedarikciid_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.uruntedarikci_uruntedarikciid_seq OWNED BY public.uruntedarikci.uruntedarikciid;
          public               postgres    false    240            �           2604    16569    depo depoid    DEFAULT     j   ALTER TABLE ONLY public.depo ALTER COLUMN depoid SET DEFAULT nextval('public.depo_depoid_seq'::regclass);
 :   ALTER TABLE public.depo ALTER COLUMN depoid DROP DEFAULT;
       public               postgres    false    234    235    235            �           2604    16520    islemkaydi islemid    DEFAULT     x   ALTER TABLE ONLY public.islemkaydi ALTER COLUMN islemid SET DEFAULT nextval('public.islemkaydi_islemid_seq'::regclass);
 A   ALTER TABLE public.islemkaydi ALTER COLUMN islemid DROP DEFAULT;
       public               postgres    false    230    229    230            �           2604    16454    kategori kategoriid    DEFAULT     z   ALTER TABLE ONLY public.kategori ALTER COLUMN kategoriid SET DEFAULT nextval('public.kategori_kategoriid_seq'::regclass);
 B   ALTER TABLE public.kategori ALTER COLUMN kategoriid DROP DEFAULT;
       public               postgres    false    217    218    218            �           2604    16513    kullanici kullaniciid    DEFAULT     ~   ALTER TABLE ONLY public.kullanici ALTER COLUMN kullaniciid SET DEFAULT nextval('public.kullanici_kullaniciid_seq'::regclass);
 D   ALTER TABLE public.kullanici ALTER COLUMN kullaniciid DROP DEFAULT;
       public               postgres    false    228    227    228            �           2604    16475    musteri musteriid    DEFAULT     v   ALTER TABLE ONLY public.musteri ALTER COLUMN musteriid SET DEFAULT nextval('public.musteri_musteriid_seq'::regclass);
 @   ALTER TABLE public.musteri ALTER COLUMN musteriid DROP DEFAULT;
       public               postgres    false    221    222    222            �           2604    16484    siparis siparisid    DEFAULT     v   ALTER TABLE ONLY public.siparis ALTER COLUMN siparisid SET DEFAULT nextval('public.siparis_siparisid_seq'::regclass);
 @   ALTER TABLE public.siparis ALTER COLUMN siparisid DROP DEFAULT;
       public               postgres    false    224    223    224            �           2604    16496    siparisurun siparisurunid    DEFAULT     �   ALTER TABLE ONLY public.siparisurun ALTER COLUMN siparisurunid SET DEFAULT nextval('public.siparisurun_siparisurunid_seq'::regclass);
 H   ALTER TABLE public.siparisurun ALTER COLUMN siparisurunid DROP DEFAULT;
       public               postgres    false    226    225    226            �           2604    16595    tedarikci tedarikciid    DEFAULT     ~   ALTER TABLE ONLY public.tedarikci ALTER COLUMN tedarikciid SET DEFAULT nextval('public.tedarikci_tedarikciid_seq'::regclass);
 D   ALTER TABLE public.tedarikci ALTER COLUMN tedarikciid DROP DEFAULT;
       public               postgres    false    238    239    239            �           2604    16463    urun urunid    DEFAULT     j   ALTER TABLE ONLY public.urun ALTER COLUMN urunid SET DEFAULT nextval('public.urun_urunid_seq'::regclass);
 :   ALTER TABLE public.urun ALTER COLUMN urunid DROP DEFAULT;
       public               postgres    false    219    220    220            �           2604    16578    urundepo urundepoid    DEFAULT     z   ALTER TABLE ONLY public.urundepo ALTER COLUMN urundepoid SET DEFAULT nextval('public.urundepo_urundepoid_seq'::regclass);
 B   ALTER TABLE public.urundepo ALTER COLUMN urundepoid DROP DEFAULT;
       public               postgres    false    237    236    237            �           2604    16621    urungorusleri gorusid    DEFAULT     ~   ALTER TABLE ONLY public.urungorusleri ALTER COLUMN gorusid SET DEFAULT nextval('public.urungorusleri_gorusid_seq'::regclass);
 D   ALTER TABLE public.urungorusleri ALTER COLUMN gorusid DROP DEFAULT;
       public               postgres    false    242    243    243            �           2604    16604    uruntedarikci uruntedarikciid    DEFAULT     �   ALTER TABLE ONLY public.uruntedarikci ALTER COLUMN uruntedarikciid SET DEFAULT nextval('public.uruntedarikci_uruntedarikciid_seq'::regclass);
 L   ALTER TABLE public.uruntedarikci ALTER COLUMN uruntedarikciid DROP DEFAULT;
       public               postgres    false    241    240    241            z          0    16566    depo 
   TABLE DATA           ?   COPY public.depo (depoid, depoadi, adres, telefon) FROM stdin;
    public               postgres    false    235   ��       w          0    16545    dolapvedepolama 
   TABLE DATA           X   COPY public.dolapvedepolama (kategoriid, rafsayisi, kapaksayisi, kapakturu) FROM stdin;
    public               postgres    false    232   �       u          0    16517 
   islemkaydi 
   TABLE DATA           c   COPY public.islemkaydi (islemid, urunid, kullaniciid, islemtarih, islemtipi, aciklama) FROM stdin;
    public               postgres    false    230   !�       i          0    16451    kategori 
   TABLE DATA           K   COPY public.kategori (kategoriid, kategoriadi, aciklama, renk) FROM stdin;
    public               postgres    false    218   ��       s          0    16510 	   kullanici 
   TABLE DATA           ]   COPY public.kullanici (kullaniciid, adsoyad, kullaniciadi, sifre, songiristarih) FROM stdin;
    public               postgres    false    228   <�       x          0    16555    masavesehpa 
   TABLE DATA           O   COPY public.masavesehpa (kategoriid, boyut, sekil, katlanabilirmi) FROM stdin;
    public               postgres    false    233   ��       m          0    16472    musteri 
   TABLE DATA           M   COPY public.musteri (musteriid, adsoyad, telefon, eposta, adres) FROM stdin;
    public               postgres    false    222   ̔       v          0    16535    oturmagrubu 
   TABLE DATA           Z   COPY public.oturmagrubu (kategoriid, kapasite, yastiksayisi, dosememalzemesi) FROM stdin;
    public               postgres    false    231   W�       o          0    16481    siparis 
   TABLE DATA           Y   COPY public.siparis (siparisid, musteriid, siparistarih, toplamtutar, durum) FROM stdin;
    public               postgres    false    224   �       q          0    16493    siparisurun 
   TABLE DATA           b   COPY public.siparisurun (siparisurunid, siparisid, urunid, miktar, birimfiyat, tutar) FROM stdin;
    public               postgres    false    226   ܕ       ~          0    16592 	   tedarikci 
   TABLE DATA           R   COPY public.tedarikci (tedarikciid, firmaadi, telefon, eposta, adres) FROM stdin;
    public               postgres    false    239   �       k          0    16460    urun 
   TABLE DATA           c   COPY public.urun (urunid, kategoriid, eklenmetarihi, urunadi, birimfiyat, stokmiktari) FROM stdin;
    public               postgres    false    220   x�       |          0    16575    urundepo 
   TABLE DATA           U   COPY public.urundepo (urundepoid, depoid, urunid, miktar, songuncelleme) FROM stdin;
    public               postgres    false    237   �       �          0    16618    urungorusleri 
   TABLE DATA           ]   COPY public.urungorusleri (gorusid, musteriid, urunid, gorus, puan, gorustarihi) FROM stdin;
    public               postgres    false    243   B�       �          0    16601    uruntedarikci 
   TABLE DATA           i   COPY public.uruntedarikci (uruntedarikciid, tedarikciid, urunid, tedariktarihi, adet, tutar) FROM stdin;
    public               postgres    false    241   ��       �           0    0    depo_depoid_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.depo_depoid_seq', 3, true);
          public               postgres    false    234            �           0    0    islemkaydi_islemid_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.islemkaydi_islemid_seq', 4, true);
          public               postgres    false    229            �           0    0    kategori_kategoriid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.kategori_kategoriid_seq', 6, true);
          public               postgres    false    217            �           0    0    kullanici_kullaniciid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.kullanici_kullaniciid_seq', 4, true);
          public               postgres    false    227            �           0    0    musteri_musteriid_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.musteri_musteriid_seq', 4, true);
          public               postgres    false    221            �           0    0    siparis_siparisid_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.siparis_siparisid_seq', 4, true);
          public               postgres    false    223            �           0    0    siparisurun_siparisurunid_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.siparisurun_siparisurunid_seq', 4, true);
          public               postgres    false    225            �           0    0    tedarikci_tedarikciid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.tedarikci_tedarikciid_seq', 1, true);
          public               postgres    false    238            �           0    0    urun_urunid_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.urun_urunid_seq', 6, true);
          public               postgres    false    219            �           0    0    urundepo_urundepoid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.urundepo_urundepoid_seq', 5, true);
          public               postgres    false    236            �           0    0    urungorusleri_gorusid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.urungorusleri_gorusid_seq', 2, true);
          public               postgres    false    242            �           0    0 !   uruntedarikci_uruntedarikciid_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.uruntedarikci_uruntedarikciid_seq', 1, true);
          public               postgres    false    240            �           2606    16573    depo depo_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.depo
    ADD CONSTRAINT depo_pkey PRIMARY KEY (depoid);
 8   ALTER TABLE ONLY public.depo DROP CONSTRAINT depo_pkey;
       public                 postgres    false    235            �           2606    16549 $   dolapvedepolama dolapvedepolama_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.dolapvedepolama
    ADD CONSTRAINT dolapvedepolama_pkey PRIMARY KEY (kategoriid);
 N   ALTER TABLE ONLY public.dolapvedepolama DROP CONSTRAINT dolapvedepolama_pkey;
       public                 postgres    false    232            �           2606    16524    islemkaydi islemkaydi_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.islemkaydi
    ADD CONSTRAINT islemkaydi_pkey PRIMARY KEY (islemid);
 D   ALTER TABLE ONLY public.islemkaydi DROP CONSTRAINT islemkaydi_pkey;
       public                 postgres    false    230            �           2606    16458    kategori kategori_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (kategoriid);
 @   ALTER TABLE ONLY public.kategori DROP CONSTRAINT kategori_pkey;
       public                 postgres    false    218            �           2606    16515    kullanici kullanici_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.kullanici
    ADD CONSTRAINT kullanici_pkey PRIMARY KEY (kullaniciid);
 B   ALTER TABLE ONLY public.kullanici DROP CONSTRAINT kullanici_pkey;
       public                 postgres    false    228            �           2606    16559    masavesehpa masavesehpa_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.masavesehpa
    ADD CONSTRAINT masavesehpa_pkey PRIMARY KEY (kategoriid);
 F   ALTER TABLE ONLY public.masavesehpa DROP CONSTRAINT masavesehpa_pkey;
       public                 postgres    false    233            �           2606    16479    musteri musteri_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT musteri_pkey PRIMARY KEY (musteriid);
 >   ALTER TABLE ONLY public.musteri DROP CONSTRAINT musteri_pkey;
       public                 postgres    false    222            �           2606    16539    oturmagrubu oturmagrubu_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.oturmagrubu
    ADD CONSTRAINT oturmagrubu_pkey PRIMARY KEY (kategoriid);
 F   ALTER TABLE ONLY public.oturmagrubu DROP CONSTRAINT oturmagrubu_pkey;
       public                 postgres    false    231            �           2606    16486    siparis siparis_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_pkey PRIMARY KEY (siparisid);
 >   ALTER TABLE ONLY public.siparis DROP CONSTRAINT siparis_pkey;
       public                 postgres    false    224            �           2606    16498    siparisurun siparisurun_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_pkey PRIMARY KEY (siparisurunid);
 F   ALTER TABLE ONLY public.siparisurun DROP CONSTRAINT siparisurun_pkey;
       public                 postgres    false    226            �           2606    16599    tedarikci tedarikci_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT tedarikci_pkey PRIMARY KEY (tedarikciid);
 B   ALTER TABLE ONLY public.tedarikci DROP CONSTRAINT tedarikci_pkey;
       public                 postgres    false    239            �           2606    16465    urun urun_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urun_pkey PRIMARY KEY (urunid);
 8   ALTER TABLE ONLY public.urun DROP CONSTRAINT urun_pkey;
       public                 postgres    false    220            �           2606    16580    urundepo urundepo_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.urundepo
    ADD CONSTRAINT urundepo_pkey PRIMARY KEY (urundepoid);
 @   ALTER TABLE ONLY public.urundepo DROP CONSTRAINT urundepo_pkey;
       public                 postgres    false    237            �           2606    16625     urungorusleri urungorusleri_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.urungorusleri
    ADD CONSTRAINT urungorusleri_pkey PRIMARY KEY (gorusid);
 J   ALTER TABLE ONLY public.urungorusleri DROP CONSTRAINT urungorusleri_pkey;
       public                 postgres    false    243            �           2606    16606     uruntedarikci uruntedarikci_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.uruntedarikci
    ADD CONSTRAINT uruntedarikci_pkey PRIMARY KEY (uruntedarikciid);
 J   ALTER TABLE ONLY public.uruntedarikci DROP CONSTRAINT uruntedarikci_pkey;
       public                 postgres    false    241            �           2606    16550 /   dolapvedepolama dolapvedepolama_kategoriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dolapvedepolama
    ADD CONSTRAINT dolapvedepolama_kategoriid_fkey FOREIGN KEY (kategoriid) REFERENCES public.kategori(kategoriid);
 Y   ALTER TABLE ONLY public.dolapvedepolama DROP CONSTRAINT dolapvedepolama_kategoriid_fkey;
       public               postgres    false    4779    218    232            �           2606    16530 &   islemkaydi islemkaydi_kullaniciid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.islemkaydi
    ADD CONSTRAINT islemkaydi_kullaniciid_fkey FOREIGN KEY (kullaniciid) REFERENCES public.kullanici(kullaniciid);
 P   ALTER TABLE ONLY public.islemkaydi DROP CONSTRAINT islemkaydi_kullaniciid_fkey;
       public               postgres    false    228    230    4789            �           2606    16525 !   islemkaydi islemkaydi_urunid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.islemkaydi
    ADD CONSTRAINT islemkaydi_urunid_fkey FOREIGN KEY (urunid) REFERENCES public.urun(urunid);
 K   ALTER TABLE ONLY public.islemkaydi DROP CONSTRAINT islemkaydi_urunid_fkey;
       public               postgres    false    220    4781    230            �           2606    16560 '   masavesehpa masavesehpa_kategoriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.masavesehpa
    ADD CONSTRAINT masavesehpa_kategoriid_fkey FOREIGN KEY (kategoriid) REFERENCES public.kategori(kategoriid);
 Q   ALTER TABLE ONLY public.masavesehpa DROP CONSTRAINT masavesehpa_kategoriid_fkey;
       public               postgres    false    218    233    4779            �           2606    16540 '   oturmagrubu oturmagrubu_kategoriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.oturmagrubu
    ADD CONSTRAINT oturmagrubu_kategoriid_fkey FOREIGN KEY (kategoriid) REFERENCES public.kategori(kategoriid);
 Q   ALTER TABLE ONLY public.oturmagrubu DROP CONSTRAINT oturmagrubu_kategoriid_fkey;
       public               postgres    false    231    4779    218            �           2606    16487    siparis siparis_musteriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_musteriid_fkey FOREIGN KEY (musteriid) REFERENCES public.musteri(musteriid);
 H   ALTER TABLE ONLY public.siparis DROP CONSTRAINT siparis_musteriid_fkey;
       public               postgres    false    224    222    4783            �           2606    16499 &   siparisurun siparisurun_siparisid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_siparisid_fkey FOREIGN KEY (siparisid) REFERENCES public.siparis(siparisid);
 P   ALTER TABLE ONLY public.siparisurun DROP CONSTRAINT siparisurun_siparisid_fkey;
       public               postgres    false    224    4785    226            �           2606    16504 #   siparisurun siparisurun_urunid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_urunid_fkey FOREIGN KEY (urunid) REFERENCES public.urun(urunid);
 M   ALTER TABLE ONLY public.siparisurun DROP CONSTRAINT siparisurun_urunid_fkey;
       public               postgres    false    220    226    4781            �           2606    16466    urun urun_kategoriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urun_kategoriid_fkey FOREIGN KEY (kategoriid) REFERENCES public.kategori(kategoriid);
 C   ALTER TABLE ONLY public.urun DROP CONSTRAINT urun_kategoriid_fkey;
       public               postgres    false    218    220    4779            �           2606    16581    urundepo urundepo_depoid_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.urundepo
    ADD CONSTRAINT urundepo_depoid_fkey FOREIGN KEY (depoid) REFERENCES public.depo(depoid);
 G   ALTER TABLE ONLY public.urundepo DROP CONSTRAINT urundepo_depoid_fkey;
       public               postgres    false    235    237    4799            �           2606    16586    urundepo urundepo_urunid_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.urundepo
    ADD CONSTRAINT urundepo_urunid_fkey FOREIGN KEY (urunid) REFERENCES public.urun(urunid);
 G   ALTER TABLE ONLY public.urundepo DROP CONSTRAINT urundepo_urunid_fkey;
       public               postgres    false    237    220    4781            �           2606    16626 *   urungorusleri urungorusleri_musteriid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urungorusleri
    ADD CONSTRAINT urungorusleri_musteriid_fkey FOREIGN KEY (musteriid) REFERENCES public.musteri(musteriid);
 T   ALTER TABLE ONLY public.urungorusleri DROP CONSTRAINT urungorusleri_musteriid_fkey;
       public               postgres    false    4783    243    222            �           2606    16631 '   urungorusleri urungorusleri_urunid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.urungorusleri
    ADD CONSTRAINT urungorusleri_urunid_fkey FOREIGN KEY (urunid) REFERENCES public.urun(urunid);
 Q   ALTER TABLE ONLY public.urungorusleri DROP CONSTRAINT urungorusleri_urunid_fkey;
       public               postgres    false    220    243    4781            �           2606    16607 ,   uruntedarikci uruntedarikci_tedarikciid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.uruntedarikci
    ADD CONSTRAINT uruntedarikci_tedarikciid_fkey FOREIGN KEY (tedarikciid) REFERENCES public.tedarikci(tedarikciid);
 V   ALTER TABLE ONLY public.uruntedarikci DROP CONSTRAINT uruntedarikci_tedarikciid_fkey;
       public               postgres    false    4803    239    241            �           2606    16612 '   uruntedarikci uruntedarikci_urunid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.uruntedarikci
    ADD CONSTRAINT uruntedarikci_urunid_fkey FOREIGN KEY (urunid) REFERENCES public.urun(urunid);
 Q   ALTER TABLE ONLY public.uruntedarikci DROP CONSTRAINT uruntedarikci_urunid_fkey;
       public               postgres    false    241    4781    220            z   P   x�3��M-�N�RpI-��<��*7�HG!�����TN#c#SS33.#�s:�e'%B�B��J�!J�͹b���� �)�      w      x�3�4�4�>��(���{�b���� U7{      u   e   x�3�4B##]C#]CS����l��{�SsrRsS9#S�2�A���9�y)�\F�ƜFp=F���%G6���Y�X�yt�BIbnbnNb^ʑ�\1z\\\ T b      i   �   x�5�1�@E��S�	L��1�4Ca²KfwI�BԞ&�v//��=�bҎ�L�{��j���W�-E��J�� � ������q�`G��y���'v�ZV���4��"�:�s��I[�~a��-iE����95+�ZL�3�| ��?�      s   I   x�3��M��M-QpN���M�F�&��FF&��F��\F��9�i
.���E��)`�������Ѐ+F��� �j      x   '   x�3�442��0PH��t��N9���$=5���+F��� ���      m   {   x�3�t��M-Q�<�1'7������������ؘ3$S�	wH�H�-�I�K���<���$1/�4GG!�����T.#N�ʣ�S�+��������r&V�fQLp��N,JD����� U'/�      v      x�3�4�4�tI-������ u�      o   M   x�3�4�4202�54�54�4500�30��H�:��('1�����".#N#�*#NCS������\ה̜�L�=... �1      q   /   x�3�4CS=S�e�i�i��zF���@a�=... �Q�      ~   M   x�3���O�̩LTp�;:O�����������ܜ3"�Z��[�������ydCqIb^Ri��B��=Eٙ��\1z\\\ nEy      k   k   x�E̱	�0���)\�pw������BK����?J���C�J����*EK��v^k1�5�N���C��IC�S�x}Lm0��/F�P��r���>����ޒ      |   ?   x�M̱  �:�˰�
�ܝ^���M�^��R�1���n�Q�'(�Gq�{�Ī 6(e�      �   e   x�3�4��s���S�N��,I��T(KU(J�H,��4�4202�54�54�2�4�4�tJ��IM�<2?37%��������QH�M���i�id����� z�!�      �   '   x�3�4B##]C#] ǀ�����@���+F��� ]A     