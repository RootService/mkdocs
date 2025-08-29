---
title: 'PostfixAdmin'
description: 'In diesem HowTo wird step-by-step die Installation von PostfixAdmin für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# PostfixAdmin

In diesem HowTo wird Schritt für Schritt die Installation von PostfixAdmin für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- PostfixAdmin 4.0.0 (PostgreSQL, Vacation)

## Inhaltsverzeichnis
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Abschluss](#abschluss)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/postfixadmin` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_p5-DBI
cat <<'EOF' > /var/db/ports/databases_p5-DBI/options
--8<-- "ports/databases_p5-DBI/options"
EOF

mkdir -p /var/db/ports/dns_p5-Net-DNS
cat <<'EOF' > /var/db/ports/dns_p5-Net-DNS/options
--8<-- "ports/dns_p5-Net-DNS/options"
EOF

mkdir -p /var/db/ports/dns_libidn
cat <<'EOF' > /var/db/ports/dns_libidn/options
--8<-- "ports/dns_libidn/options"
EOF

mkdir -p /var/db/ports/devel_p5-Moo
cat <<'EOF' > /var/db/ports/devel_p5-Moo/options
--8<-- "ports/devel_p5-Moo/options"
EOF

mkdir -p /var/db/ports/devel_p5-Class-C3
cat <<'EOF' > /var/db/ports/devel_p5-Class-C3/options
--8<-- "ports/devel_p5-Class-C3/options"
EOF

mkdir -p /var/db/ports/mail_postfixadmin
cat <<'EOF' > /var/db/ports/mail_postfixadmin/options
--8<-- "ports/mail_postfixadmin/options"
EOF


portmaster -w -B -g --force-config mail/postfixadmin  -n



mkdir -p /data/www/apps/postfixadmin

rm -r /data/www/apps/postfixadmin
git clone --depth 1 https://github.com/postfixadmin/postfixadmin.git /data/www/apps/postfixadmin
git -C /data/www/apps/postfixadmin pull --rebase

cd /data/www/apps/postfixadmin

sed -e 's|\(/bin/bash.*\)$|/usr/local\1|' \
    -e 's|/usr/bin/\(.*\)$|/usr/local/bin/\1|' \
    -i '' install.sh
bash install.sh
cd

chmod 0750 templates_c
chown www:www templates_c

ln -s /data/www/apps/postfixadmin/public /data/www/vhosts/_default_/data/postfixadmin


cat <<'EOF' >> /data/db/postgres/data17/pg_hba.conf
#
# postfixadmin databases
#
# TYPE  DATABASE        USER            ADDRESS                 METHOD
#
local   postfixadmin    postfix                                 scram-sha-256
host    postfixadmin    postfix         127.0.0.1/32            scram-sha-256
host    postfixadmin    postfix         ::1/128                 scram-sha-256
#
EOF

su - postgres

# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostgreSQL user postfix: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "Password: $newpw"
unset newpw


createuser -U postgres -S -D -R -P -e postfix

createdb -U postgres -E unicode -O postfix postfixadmin

psql postfixadmin

GRANT ALL PRIVILEGES ON DATABASE postfixadmin TO postfix;
QUIT;

exit


cat <<'EOF' > /data/www/apps/postfixadmin/config.local.php
--8<-- "configs/data/www/apps/postfixadmin/config.local.php"
EOF
chown www:www /data/www/apps/postfixadmin/config.local.php


# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostfixAdmin setup_hash: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "$newpw" | xargs -I % php -r "echo password_hash('%', PASSWORD_DEFAULT);" | \
    xargs -I % sed -e 's|__SETUP_HASH__|%|g' -i '' /data/www/apps/postfixadmin/config.local.php
echo "Password: $newpw"
unset newpw


awk '/^Password for PostgreSQL user postfix:/ {print $NF}' /root/_passwords | \
    xargs -I % sed -e 's|__PASSWORD_POSTFIX__|%|g' -i '' /data/www/apps/postfixadmin/config.local.php


sed -e 's|/usr/bin/perl|/usr/local/bin/perl|' \
    -i '' /data/db/postfixadmin/vacation.pl

cat <<'EOF' > /data/db/postfixadmin/vacation.conf
--8<-- "configs/data/db/postfixadmin/vacation.conf"
EOF


# Password erzeugen und in /root/_passwords speichern
chmod 0600 /root/_passwords
newpw="`openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17`"
echo "Password for PostfixAdmin user vacation: $newpw" >> /root/_passwords
chmod 0400 /root/_passwords
echo "$newpw" | xargs -I % sed -e 's|__PASSWORD_VACATION__|%|g' -i '' /data/db/postfixadmin/vacation.conf
echo "Password: $newpw"
unset newpw


chmod 0750 /data/db/postfixadmin
chmod 0750 /data/db/postfixadmin/vacation.pl
chmod 0750 /data/db/postfixadmin/vacation.conf
chown -R root:vacation /data/db/postfixadmin
```

## Abschluss

Das PostfixAdmin Setup muss nun im Browser gestartet und befolgt werden.

``` bash
https://mail.example.com/postfixadmin/setup.php
```
