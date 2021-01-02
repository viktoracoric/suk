CC=gcc
CFLAGS=-I/usr/include/mysql -I/usr/include/mysql/mysql
LIBS=-L/usr/lib/ -lmariadb

main: main.c
	$(CC) -o suk $(CFLAGS) $(LIBS) main.c

install:
	$(CC) -o suk $(CFLAGS) $(LIBS) main.c
	cp suk /usr/bin

clean:
	rm /usr/bin/suk
