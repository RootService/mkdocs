---
title: 'PostgreSQL'
description: 'In diesem HowTo wird step-by-step die Installation des PostgreSQL Datenbanksystem für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# PostgreSQL

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- PostgreSQL 17.5

## Inhaltsverzeichnis
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Konfiguration](#konfiguration)
- [Sicherheit](#sicherheit)
- [Abschluss](#abschluss)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `databases/postgresql17-server` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_postgresql17-client
cat <<'EOF' > /var/db/ports/databases_postgresql7-client/options
--8<-- "ports/databases_postgresql17-client/options"
EOF

mkdir -p /var/db/ports/databases_postgresql17-server
cat <<'EOF' > /var/db/ports/databases_postgresql17-server/options
--8<-- "ports/databases_postgresql17-server/options"
EOF


portmaster -w -B -g --force-config databases/postgresql17-server  -n
portmaster -w -B -g --force-config databases/postgresql17-contrib  -n


cp -a /var/db/postgres* /data/db/

sysrc postgresql_enable=YES
sysrc postgresql_data="/data/db/postgres/data17"
sysrc postgresql_initdb_flags="--encoding=utf-8 --lc-collate=C --auth=scram-sha-256 --pwprompt"
```

## Konfiguration

PostgreSQL wird nun zum ersten Mal gestartet, was einige Minuten dauern kann.

``` bash
# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostgreSQL initdb: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "Password: $newpw"
unset newpw


service postgresql initdb

service postgresql start
```

## Sicherheit

``` bash
# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostgreSQL user postges: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "Password: $newpw"
unset newpw


passwd postgres


cat <<'EOF' >> /data/db/postgres/data17/pg_hba.conf
#
# test_db databases
#
# TYPE  DATABASE        USER            ADDRESS                 METHOD
#
local   test_db         admin                                   scram-sha-256
host    test_db         admin           127.0.0.1/32            scram-sha-256
host    test_db         admin           ::1/128                 scram-sha-256
#
EOF

su - postgres

# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostgreSQL user admin: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "Password: $newpw"
unset newpw


createuser -U postgres -S -D -R -P -e admin

createdb -U postgres -E unicode -O admin test_db

psql test_db

GRANT ALL PRIVILEGES ON DATABASE test_db TO admin;
QUIT;

exit
```

## Abschluss

PostgreSQL sollte abschliessend einmal neu gestartet werden.

``` bash
service postgresql restart
```
