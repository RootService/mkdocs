---
title: 'CertBot'
description: 'In diesem HowTo wird step-by-step die Installation von CertBot für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-05-31'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# CertBot

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- CertBot 2.6.0 (LetsEncrypt ACME API 2.0)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `security/py-certbot` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_py-certbot
cat << "EOF" > /var/db/ports/security_py-certbot/options
_OPTIONS_READ=py39-certbot-2.6.0
_FILE_COMPLETE_OPTIONS_LIST=MANPAGES
OPTIONS_FILE_SET+=MANPAGES
"EOF"


cd /usr/ports/security/py-certbot
make all install clean-depends clean


cat << "EOF" >> /etc/periodic.conf
weekly_certbot_enable="YES"
"EOF"
```

## Konfiguration

Es müssen zuerst noch zwei DNS-Records angelegt werden, sofern sie noch nicht existieren, oder entsprechend geändert werden, sofern sie bereits existieren.

``` dns-zone
example.com.            IN  CAA     ( 0 issue "letsencrypt.org" )
example.com.            IN  CAA     ( 0 issuewild "letsencrypt.org" )
```

Wir beziehen nun erstmal die für dieses HowTo benötigten Zertifikate:

``` bash
certbot register --standalone --agree-tos --no-eff-email -m admin@example.com

certbot certonly --standalone --key-type=ecdsa --elliptic-curve=secp384r1 -d devnull.example.com -d example.com
certbot certonly --standalone --key-type=ecdsa --elliptic-curve=secp384r1 -d mail.example.com
certbot certonly --standalone --key-type=ecdsa --elliptic-curve=secp384r1 -d www.example.com
```

Wir konfigurieren CertBot für den Bezug unserer Zertifikate:

``` bash
mkdir -p /usr/local/etc/letsencrypt
cat << "EOF" > /usr/local/etc/letsencrypt/cli.ini
key-type = ecdsa
elliptic-curve = secp384r1
rsa-key-size = 4096
email = admin@example.com
authenticator = webroot
webroot-path = /data/www/acme
server = https://acme-v02.api.letsencrypt.org/directory
text = true
agree-tos = true
preferred-challenges = http
"EOF"
```

## Abschluss

Weitere Zertifikate für einzelne Domains können, sobald der Webserver Apache installiert und gestartet ist, dann künftig so erstellt werden:

``` bash
certbot certonly -d subdomain.example.com
```
