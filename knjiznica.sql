CREATE USER 'knjiznicar'@'localhost' IDENTIFIED BY 'jaSamKnjiznicar123';
CREATE DATABASE knjiznica;
GRANT ALL PRIVILEGES ON knjiznica.* TO 'knjiznicar'@'localhost';

CREATE TABLE kategorija (
kategorija_id serial,
naziv varchar(100) NOT NULL,
PRIMARY KEY (kategorija_id)
);

INSERT INTO kategorija VALUES (DEFAULT, 'Znanstvena literatura');
INSERT INTO kategorija VALUES (DEFAULT, 'Povijest');
INSERT INTO kategorija VALUES (DEFAULT, 'Fikcija');
INSERT INTO kategorija VALUES (DEFAULT, 'Filozofija');

CREATE TABLE autori (
autor_id serial,
ime varchar(30) NOT NULL,
prezime varchar(30),
PRIMARY KEY (autor_id)
);

INSERT INTO autori VALUES (DEFAULT, 'Francis Parker', 'Yockey');
INSERT INTO autori VALUES (DEFAULT, 'Aldous', 'Huxley');
INSERT INTO autori VALUES (DEFAULT, 'Guy', 'Debord');
INSERT INTO autori VALUES (DEFAULT, 'Martin', 'Heidegger');
INSERT INTO autori VALUES (DEFAULT, 'Friedrich', 'Nietzsche');
INSERT INTO autori VALUES (DEFAULT, 'Julius', 'Evola');
INSERT INTO autori VALUES (DEFAULT, 'Niccolo', 'Machiavelli');
INSERT INTO autori VALUES (DEFAULT, 'Pentti', 'Linkola');
INSERT INTO autori VALUES (DEFAULT, 'Theodore', 'Kaczynski');
INSERT INTO autori VALUES (DEFAULT, 'Platon', NULL);
INSERT INTO autori VALUES (DEFAULT, 'Jacques', 'Ellul');

CREATE TABLE uloga (
uloga_id serial,
uloga varchar(20) NOT NULL,
PRIMARY KEY (uloga_id)
);

INSERT INTO uloga VALUES (DEFAULT, 'Administrator');
INSERT INTO uloga VALUES (DEFAULT, 'Knjiznicar');
INSERT INTO uloga VALUES (DEFAULT, 'Korisnik');

CREATE TABLE izdavac (
izdavac_id serial,
naziv varchar(50) NOT NULL,
drzava varchar(50) NOT NULL,
PRIMARY KEY (izdavac_id)
);

INSERT INTO izdavac VALUES (DEFAULT, 'Imperium Press', 'SAD');
INSERT INTO izdavac VALUES (DEFAULT, 'Antelope Hill Publishing', 'SAD');
INSERT INTO izdavac VALUES (DEFAULT, 'Eneagram', 'Hrvatska');
INSERT INTO izdavac VALUES (DEFAULT, 'Arktos', 'Švedska');

CREATE TABLE korisnik (
korisnik_id serial,
ime varchar(30) NOT NULL,
prezime varchar(30) NOT NULL,
adresa varchar(100) NOT NULL,
email varchar(50),
telefon varchar(30),
uloga_id bigint unsigned,
PRIMARY KEY (korisnik_id),
FOREIGN KEY (uloga_id) REFERENCES uloga(uloga_id)
);

INSERT INTO korisnik VALUES (DEFAULT, 'Grgo', 'Penzic', 'Marka Marulica 14', NULL, NULL, 3);
INSERT INTO korisnik VALUES (DEFAULT, 'Ante', 'Antic', 'Bana Jelacica 11', 'ante@antic.hr', '+385123456789', 3);
INSERT INTO korisnik VALUES (DEFAULT, 'Ivo', 'Ivic', 'Bana Mazuranica 12', 'ivoivic@protonmail.com', '+385234567891', 2);
INSERT INTO korisnik VALUES (DEFAULT, 'Jozo', 'Jozic', 'Ulica dr. Ante Pavlovica 18', 'jozha@gmail.com', '+385345678912', 2);
INSERT INTO korisnik VALUES (DEFAULT, 'Marija', 'Maric', 'Ulica Stjepana Radica 55', 'admin@knjiznica.hr', '+385456789123', 1);

CREATE TABLE knjiga (
isbn bigint unsigned,
naslov varchar(100),
godina int,
brojStranica int,
autor_id bigint unsigned,
izdavac_id bigint unsigned,
PRIMARY KEY (isbn),
FOREIGN KEY (autor_id) REFERENCES autori(autor_id),
FOREIGN KEY (izdavac_id) REFERENCES izdavac(izdavac_id)
);

INSERT INTO knjiga VALUES (1111111111111, 'Imperium: The Philosophy of History and Politics', 1948, 626, 1, 1);
INSERT INTO knjiga VALUES (2222222222222, 'The Perennial Philosophy', 1945, 312, 2, 2);
INSERT INTO knjiga VALUES (3333333333333, 'The Society of the Spectacle', 1967, 98, 3, 1);
INSERT INTO knjiga VALUES (4444444444444, 'Being and Time', 1927, 552, 4, 4);
INSERT INTO knjiga VALUES (5555555555555, 'Beyond Good and Evil: A Prelude to a Philosophy of the Future', 1886, 246, 5, 1);
INSERT INTO knjiga VALUES (6666666666666, 'Razmisljanja o vrhovima', 1944, 151, 6, 3);
INSERT INTO knjiga VALUES (7777777777777, 'Revolt Against the Modern World', 1941, 455, 6, 4);
INSERT INTO knjiga VALUES (8888888888888, 'Knez ili Vladar', 1791, 206, 7, 3);
INSERT INTO knjiga VALUES (9999999999999, 'Can Life Prevail?', 1998, 218, 8, 4);
INSERT INTO knjiga VALUES (1010101010101, 'Industrial Society and Its Future', 1979, 61, 9, 2);
INSERT INTO knjiga VALUES (1212121212121, 'The Technological Society', 1969, 224, 11, 2);

CREATE TABLE lokacija (
lokacija_id serial,
imeZgrade varchar(50),
odjeljak int,
polica int,
PRIMARY KEY (lokacija_id)
);

INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 1, 1);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 1, 2);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 1, 3);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 2, 1);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 2, 2);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 2, 3);
INSERT INTO lokacija VALUES (DEFAULT, 'Glavna knjiznica', 2, 4);
INSERT INTO lokacija VALUES (DEFAULT, 'Knjiznica Banfica', 1, 1);
INSERT INTO lokacija VALUES (DEFAULT, 'Knjiznica Banfica', 1, 2);
INSERT INTO lokacija VALUES (DEFAULT, 'Knjiznica Banfica', 1, 3);
INSERT INTO lokacija VALUES (DEFAULT, 'Knjiznica Banfica', 2, 1);
INSERT INTO lokacija VALUES (DEFAULT, 'Knjiznica Banfica', 2, 2);

CREATE TABLE knjiga_primjerak (
primjerak_id serial,
isbn bigint unsigned,
jePosudjen boolean,
jeOstecen boolean,
posudioKorisnik bigint unsigned,
lokacija_id bigint unsigned,
PRIMARY KEY (primjerak_id),
FOREIGN KEY (isbn) REFERENCES knjiga(isbn),
FOREIGN KEY (posudioKorisnik) REFERENCES korisnik(korisnik_id),
FOREIGN KEY (lokacija_id) REFERENCES lokacija(lokacija_id)
);

INSERT INTO knjiga_primjerak VALUES (DEFAULT, 1111111111111, 0, 1, NULL, 1);
INSERT INTO knjiga_primjerak VALUES (DEFAULT, 2222222222222, 1, 0, 1, 4);
INSERT INTO knjiga_primjerak VALUES (DEFAULT, 2222222222222, 1, 0, 1, 4);
INSERT INTO knjiga_primjerak VALUES (DEFAULT, 2222222222222, 0, 0, 2, 12);

CREATE TABLE pripada (
isbn bigint unsigned,
kategorija_id bigint unsigned,
PRIMARY KEY (isbn, kategorija_id),
FOREIGN KEY (isbn) REFERENCES knjiga(isbn),
FOREIGN KEY (kategorija_id) REFERENCES kategorija(kategorija_id)
);

INSERT INTO pripada VALUES (1111111111111,1);
INSERT INTO pripada VALUES (1111111111111,2);
INSERT INTO pripada VALUES (2222222222222,1);
INSERT INTO pripada VALUES (3333333333333,2);
INSERT INTO pripada VALUES (4444444444444,3);
INSERT INTO pripada VALUES (5555555555555,4);
INSERT INTO pripada VALUES (6666666666666,3);
INSERT INTO pripada VALUES (7777777777777,2);
INSERT INTO pripada VALUES (8888888888888,1);
INSERT INTO pripada VALUES (8888888888888,4);
INSERT INTO pripada VALUES (9999999999999,1);
INSERT INTO pripada VALUES (9999999999999,3);
INSERT INTO pripada VALUES (1010101010101,2);
INSERT INTO pripada VALUES (1212121212121,1);

CREATE TABLE posudba (
korisnik_id bigint unsigned,
primjerak_id bigint unsigned,
datumPosudbe date,
rok date DEFAULT (datumPosudbe + INTERVAL 31 DAY),
PRIMARY KEY (korisnik_id, primjerak_id),
FOREIGN KEY (korisnik_id) REFERENCES korisnik(korisnik_id),
FOREIGN KEY (primjerak_id) REFERENCES knjiga_primjerak(primjerak_id)
);

INSERT INTO posudba VALUES (1, 2, '2020-01-18', DEFAULT);
INSERT INTO posudba VALUES (1, 3, '2020-01-18', DEFAULT);
INSERT INTO posudba VALUES (2, 3, '2020-10-05', DEFAULT);

---UPITI---
---Ispis koliko knjiga je dostupno na nekoj lokaciji---
SELECT knjiga.naslov, concat(autori.ime,' ', autori.prezime) AS autor, lokacija.imeZgrade, COUNT(knjiga.naslov) AS 'broj primjeraka' FROM knjiga JOIN autori ON knjiga.autor_id = autori.autor_id JOIN knjiga_primjerak ON knjiga.isbn = knjiga_primjerak.isbn JOIN lokacija ON knjiga_primjerak.lokacija_id = lokacija.lokacija_id WHERE lokacija.imeZgrade LIKE '%Glavna%' GROUP BY knjiga.naslov;

---Broj knjiga po određenoj lokaciji
SELECT lokacija.imeZgrade, COUNT(*) FROM knjiga JOIN autori ON knjiga.autor_id = autori.autor_id JOIN knjiga_primjerak ON knjiga.isbn = knjiga_primjerak.isbn JOIN lokacija ON knjiga_primjerak.lokacija_id = lokacija.lokacija_id GROUP BY lokacija.imeZgrade;

---Pretrazivanje po imenu i prezimenu autora---
SELECT knjiga.naslov, CONCAT(autori.ime, ' ', autori.prezime) AS autor FROM knjiga JOIN autori ON knjiga.autor_id = autori.autor_id WHERE autori.prezime LIKE '%Evola%' AND autori.ime LIKE '%Julius%';

---TRIGGERI---
---Knjiga vec posudjena---
DELIMITER $$
CREATE TRIGGER nedostupna_knjiga_trigger
BEFORE INSERT ON posudba
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT k.primjerak_id FROM knjiga_primjerak k WHERE (k.jePosudjen = 1 OR k.jeOstecen = 1) AND NEW.primjerak_id = k.primjerak_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Knjiga nije dostupna za posudbu';
    END IF;
END; $$
DELIMITER ;

---updateaj jePosudjen nakon posudjivanja---
DELIMITER $$
CREATE TRIGGER updateaj_trigger
AFTER INSERT on posudba
FOR EACH ROW
BEGIN
    UPDATE knjiga_primjerak k SET k.jePosudjen = 1 WHERE NEW.primjerak_id = k.primjerak_id;
END; $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER updateaj_trigger_2
AFTER DELETE on posudba
FOR EACH ROW
BEGIN
    UPDATE knjiga_primjerak k SET k.jePosudjen = 0 WHERE OLD.primjerak_id = k.primjerak_id;
END; $$
DELIMITER ;
