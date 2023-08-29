# moto_gp


## Opis

Aplikacija koja prikazuje trenutni nagib mobilnog uređaja uzimajući u obzir početnu kalibraciju položaja uređaja. Namijenjena je korištenju prilikom vožnje vozila sa dva kotača koji iskazuju veliku mogućnost naginjanja u stranu tijekom vožnje. 

Aplikacija ovisi o mobilnom uređaju na kojem je pokrenuta te ne može garantirati točnost podataka koje prikazuje zbog akumuliraih grešaka senzora koji se koriste (gyro, accelero, magneto - putem rotation sensor izračuna na Android OS-u). Iz toga razloga, korištenje je namjenjeno striktno u istraživačke svrhe, kako bi se vidjelo koliko ispravno se mogu dobiti podaci bez korištenja vanjskih, preciznijih modula.

Aplikacije se pokreće prateći ove korake:
1. Ovisno o platformi na kojoj se pokreće (Windows ili MacOS), navigirati u datoteku "pubspec.yaml" u root-u projekta i izmjeniti path paketa position_sensor da pokazuje na lokalan paket u "lib" folderu (pripremljeni su primjeri koje je potrebno zakomentirat/otkomentirat)
2. Navigirati u foldere "position_sensors" i "position_sensors_platform_interface" i u svakom zasebno pokrenuti komandu "flutter/dart pub get"
3. Pokrenut komandu "flutter/dart pub get" u glavnom root folderu projekta
4. Pokrenuti jednu od konfiguracija pripremljenih za izradu aplikacije (debug, profile ili release) - prilikom testiranja i praćenja rada aplikacije koristi se debug koji omogućava prekide izvođenja aplikacije, dok se za izradu apk datoteke koristi release konfiguracija.