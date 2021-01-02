#include <mysql/mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#define clear() printf("\033[H\033[J")

MYSQL *conn;
MYSQL_RES *res;
MYSQL_ROW row;
char *server = "localhost";
char *user = "knjiznicar";
char *password = "jaSamKnjiznicar123"; /* set me first */
char *database = "knjiznica";
int day, month, year;
char *status;

void greska(MYSQL *conn) {
    if(mysql_errno(conn) == 1644) {
        fprintf(stderr, "%s\n", mysql_error(conn));
	sleep(2);
	return;
        }
    fprintf(stderr, "%s\n", mysql_error(conn));
    mysql_close(conn);
    exit(1);
}

void pretraga(int x) {
    char prezime[30];
    char ime[30];
    char knjigaAutor[500];
    char zahtjev[1000];
    char izbor;
    switch(x) {
        case 1:
            printf("Unesite prezime korisnika koji posuđuje knjigu\n");
        scanf("%s", prezime);
        sprintf(zahtjev, "SELECT korisnik_id, prezime, ime, adresa, telefon, email FROM korisnik WHERE prezime = '%s'", prezime);

        if (mysql_query(conn, zahtjev)) {
            greska(conn);
        }

        res = mysql_use_result(conn);
        printf("ID\tPrezime\tIme\tAdresa\t\t\tTelefon\t\te-mail\n");
        while ((row = mysql_fetch_row(res)) != NULL)
            printf("\n%s\t%s\t%s\t%s\t%s\t%s\n", row[0], row[1], row[2], row[3], row[4], row[5]);

        printf("Filtrirati dalje po imenu? [d/n]\n");
        scanf(" %c", &izbor);
        if (izbor == 'd') {
        printf("Unesite ime korisnika koji posuđuje knjigu\n");
        scanf("%s", ime);
        sprintf(zahtjev, "SELECT korisnik_id, prezime, ime, adresa, telefon, email FROM korisnik WHERE prezime = '%s' AND ime = '%s'", prezime, ime);

        if (mysql_query(conn, zahtjev)) {
            greska(conn);
        }

        res = mysql_use_result(conn);
        printf("ID\tPrezime\tIme\tAdresa\t\t\tTelefon\t\te-mail\n");
        while ((row = mysql_fetch_row(res)) != NULL)
            printf("\n%s\t%s\t%s\t%s\t%s\t%s\n", row[0], row[1], row[2], row[3], row[4], row[5]);
        }
    break;
    case 2:
        printf("Naziv knjige ili autor?\n");
        scanf("%s", knjigaAutor);
        sprintf(zahtjev, "SELECT p.primjerak_id, k.naslov, a.ime, a.prezime FROM knjiga_primjerak p JOIN knjiga k ON p.isbn = k.isbn JOIN autori a ON k.autor_id = a.autor_id WHERE (a.ime LIKE '%%%s%%' OR a.prezime LIKE '%s' OR k.naslov LIKE '%%%s%%') AND (p.jePosudjen = 0 AND p.jeOstecen = 0)", knjigaAutor, knjigaAutor, knjigaAutor);

        if (mysql_query(conn, zahtjev)) {
            greska(conn);
        }

        res = mysql_use_result(conn);
        printf("ID\tNaslov\t\t\t\tAutor\n");
        while ((row = mysql_fetch_row(res)) != NULL)
            printf("\n%s\t%s\t%s\t%s %s\n", row[0], row[1], row[2], row[3], row[4]);
    }
}

void posudba() {
    char zahtjev[1000];
    char izbor;
    int idKorisnik, idPrimjerak;
    time_t now;
    time(&now);
    struct tm *local = localtime(&now);
    day = local->tm_mday;
    month = local->tm_mon + 1;
    year = local->tm_year + 1900;

    printf("Pretraga korisnika? [d/n]\n");
    scanf(" %c", &izbor);
    if (izbor == 'd') {
	    pretraga(1);
    }
    printf("Pretraga dostupnih knjiga? [d/n]\n");
    scanf(" %c", &izbor);
    if (izbor == 'd') {
	    pretraga(2);
    }
    printf("Unesite id korisnika.\n");
    scanf("%d", &idKorisnik);
    printf("Unesite id primjerka.\n");
    scanf("%d", &idPrimjerak);
    sprintf(zahtjev, "INSERT INTO posudba VALUES (%d, %d, '%d-%d-%d', DEFAULT)", idKorisnik, idPrimjerak, year, month, day);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }
    status = "Posudba zaprimljena";
}

void vracanje() {
    char zahtjev[1000];
    char izbor;
    int idKorisnik, idPrimjerak;
    printf("Pretraga? [d/n]\n");
    scanf(" %c", &izbor);
    if (izbor == 'd') {
	    pretraga(1);
    }
    printf("Unesite id korisnika.\n");
    scanf("%d", &idKorisnik);
    sprintf(zahtjev, "SELECT kp.primjerak_id, k.naslov FROM knjiga k JOIN knjiga_primjerak kp ON kp.isbn = k.isbn JOIN posudba p ON p.primjerak_id = kp.primjerak_id WHERE p.korisnik_id = %d", idKorisnik);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }

    res = mysql_use_result(conn);
    printf("Korisnik je posudio: \n");
    printf("ID\tNaslov\n");
    while ((row = mysql_fetch_row(res)) != NULL)
        printf("%s\t%s\n", row[0], row[1]);
    printf("Unesite id primjerka.\n");
    scanf("%d", &idPrimjerak);
    sprintf(zahtjev, "DELETE FROM posudba WHERE korisnik_id = %d AND primjerak_id = %d", idKorisnik, idPrimjerak);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }
    status = "Knjiga vracena";
}

void dodajKnjigu() {
    char zahtjev[1000];
    unsigned long long int isbn;
    char naslov[100];
    int godina;
    int brojStranica;
    char izdavac[100];
    char drzava[30];
    char autorIme[30];
    char autorPrezime[30];
    int autorId;
    int izdavacId;
    int i=0;

    printf("Unesite ISBN knjige\n");
    scanf("%lld", &isbn);
    printf("Unesite naslov\n");
    scanf("%s", naslov);
    printf("Unesite ime autora\n");
    scanf("%s", autorIme);
    printf("Unesite prezime autora\n");
    scanf("%s", autorPrezime);
    printf("Unesite naziv izdavaca\n");
    scanf("%s", izdavac);
    printf("Unesite drzavu izdavanja\n");
    scanf("%s", drzava);
    printf("Unesite godinu izdanja\n");
    scanf("%d", &godina);
    printf("Unesite broj stranica\n");
    scanf("%d", &brojStranica);
    printf("Provjeravam je li autor već postoji...\n");
    sleep(1);
    sprintf(zahtjev, "SELECT a.autor_id, a.ime, a.prezime FROM autori a WHERE a.ime LIKE '%%%s%%' AND a.prezime LIKE '%%%s%%'", autorIme, autorPrezime);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }

    res = mysql_use_result(conn);
    printf("Postojeći autori: \n");
    printf("ID\tAutor\n");
    while ((row = mysql_fetch_row(res)) != NULL) {
        printf("%s\t%s %s\n", row[0], row[1], row[2]);
        i++;
    }
    if(!i) {
        sprintf(zahtjev, "INSERT INTO autori VALUES (DEFAULT, '%s', '%s')", autorIme, autorPrezime);
        if (mysql_query(conn, zahtjev)) {
            greska(conn);
        }
    }
    else {
	i=0;
        printf("Unesite id autora\n");
	scanf("%d", &autorId);
    }

    sprintf(zahtjev, "SELECT * FROM izdavac i WHERE i.naziv LIKE '%%%s%%'", izdavac);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }

    res = mysql_use_result(conn);
    printf("Postojeći izdavaci: \n");
    printf("ID\tIzdavac\tDrzava");
    while ((row = mysql_fetch_row(res)) != NULL) {
        printf("%s %s %s\n", row[0], row[1], row[2]);
        i++;
    }
    if(!i) {
        sprintf(zahtjev, "INSERT INTO izdavac VALUES (DEFAULT, '%s', '%s')", izdavac, drzava);
        if (mysql_query(conn, zahtjev)) {
            greska(conn);
        }
    }
    else {
        printf("Unesite id izdavaca\n");
        scanf("%d", &izdavacId);
    }
    sprintf(zahtjev, "INSERT INTO knjiga VALUES (%lld, '%s', %d, %d, %d, %d)", isbn, naslov, godina, brojStranica, autorId, izdavacId);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }
    status = "Knjiga umetnuta";
}

void dodajKorisnika() {
    char zahtjev[1000];
    char ime[30];
    char prezime[30];
    char adresa[100];
    char email[50];
    char telefon[30];
    int ulogaId;

    printf("Dodaj korisnika (1 - administrator, 2 - knjiznicar, 3 - korisnik)\n");
    scanf("%d", &ulogaId);
    printf("Unesite ime: \n");
    scanf("%s", ime);
    printf("Unesite prezime: \n");
    scanf("%s", prezime);
    printf("Unesite adresu: \n");
    scanf("%s", adresa);
    printf("Unesite e-mail adresu: \n");
    scanf("%s", email);
    printf("Unesite broj telefona: \n");
    scanf("%s", telefon);
    sprintf(zahtjev, "INSERT INTO korisnik VALUES (DEFAULT, '%s', '%s', '%s', '%s', '%s', %d)", ime, prezime, adresa, email, telefon, ulogaId);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }
    status = "Korisnik dodan!";
}

void urediKorisnika() {
    char zahtjev[1000];
    int korisnikId;
    char atribut[20];
    char novi[100];
    pretraga(1);
    printf("Unesite ID korisnika\n");
    scanf("%d", &korisnikId);
    printf("Koji atribut zelite izmjeniti?\n");
    scanf("%s", atribut);
    printf("Unesite novi atribut\n");
    scanf("%s", novi);
    sprintf(zahtjev, "UPDATE korisnik SET %s = '%s' WHERE korisnik_id = %d", atribut, novi, korisnikId);
    if (mysql_query(conn, zahtjev)) {
        greska(conn);
    }
    status = "Informacija izmjenjena!";

}

int main() {
    int izbor;
    conn = mysql_init(NULL);
    if (!mysql_real_connect(conn, server, user, password, database, 0, NULL, 0)) {
        greska(conn);
        }

    do {
        printf("\n1. Posudba knjige\n2. Vracanje knjige\n3. Dodaj knjigu u bazu\n4. Dodaj korisnika\n5. Izmjena korisnickih detalja\n9. Izlaz\n\n");
        scanf("%d", &izbor);

        switch(izbor) {
            case 1:
	        posudba();
                break;
            case 2:
                vracanje();
                break;
	    case 3:
	        dodajKnjigu();
		break;
	    case 4:
		dodajKorisnika();
		break;
	    case 5:
		urediKorisnika();
		break;
        }
    clear();
    if(izbor != 9) {
    printf("%s\n", status);
    }
    } while(izbor != 9);
    mysql_free_result(res);
    mysql_close(conn);
    return 0;
}
