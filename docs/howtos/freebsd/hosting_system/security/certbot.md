---
title: 'CertBot'
description: 'In diesem HowTo wird step-by-step die Installation von CertBot für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# CertBot

In diesem HowTo wird Schritt für Schritt die Installation von CertBot für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- CertBot 4.0.0 (LetsEncrypt ACME API 2.0)

## Inhaltsverzeichnis
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Konfiguration](#konfiguration)
- [Abschluss](#abschluss)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `security/py-certbot` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/textproc_py-snowballstemmer
cat <<'EOF' > /var/db/ports/textproc_py-snowballstemmer/options
--8<-- "ports/textproc_py-snowballstemmer/options"
EOF

mkdir -p /var/db/ports/security_py-certbot
cat <<'EOF' > /var/db/ports/security_py-certbot/options
--8<-- "ports/security_py-certbot/options"
EOF


portmaster -w -B -g --force-config security/py-certbot  -n


cat <<'EOF' >> /etc/periodic.conf
weekly_certbot_enable="YES"
EOF
```

## Konfiguration

Wir konfigurieren CertBot für den Bezug unserer Zertifikate und wir beziehen auch gleich die für dieses HowTo benötigten Zertifikate:

``` bash
cat <<'EOF' >> /etc/periodic.conf
weekly_certbot_enable="YES"
weekly_certbot_service="apache24"
weekly_certbot_pre_hook="/usr/local/etc/letsencrypt/renewal-hooks/pre/hook.sh"
weekly_certbot_post_hook="/usr/local/etc/letsencrypt/renewal-hooks/post/hook.sh"
#weekly_certbot_deploy_hook="/usr/local/etc/letsencrypt/renewal-hooks/deploy/hook.sh"
EOF

mkdir -p /usr/local/etc/letsencrypt
cat <<'EOF' > /usr/local/etc/letsencrypt/cli.ini
--8<-- "configs/usr/local/etc/letsencrypt/cli.ini"
EOF

certbot register --standalone --agree-tos --no-eff-email -m admin@example.com

cat <<'EOF' > /usr/local/etc/letsencrypt/renewal-hooks/pre/hook.sh
--8<-- "configs/usr/local/etc/letsencrypt/renewal-hooks/pre/hook.sh"
EOF
chmod 0755 /usr/local/etc/letsencrypt/renewal-hooks/pre/hook.sh

cat <<'EOF' > /usr/local/etc/letsencrypt/renewal-hooks/post/hook.sh
--8<-- "configs/usr/local/etc/letsencrypt/renewal-hooks/post/hook.sh"
EOF
chmod 0755 /usr/local/etc/letsencrypt/renewal-hooks/post/hook.sh

cat <<'EOF' > /usr/local/etc/letsencrypt/renewal-hooks/deploy/hook.sh
--8<-- "configs/usr/local/etc/letsencrypt/renewal-hooks/deploy/hook.sh"
EOF
chmod 0755 /usr/local/etc/letsencrypt/renewal-hooks/deploy/hook.sh

certbot certonly --standalone -d devnull.example.com
certbot certonly --standalone -d mail.example.com
certbot certonly --standalone -d www.example.com -d example.com

sed -e 's|^#*\(pre-hook.*\)$|\1|' \
    -e 's|^#*\(post-hook.*\)$|\1|' \
    -i '' /usr/local/etc/letsencrypt/cli.ini
```

## Abschluss

Weitere Zertifikate für einzelne Domains können, sobald der Webserver Apache installiert und gestartet ist, dann künftig so erstellt werden:

``` bash
certbot certonly --standalone -d subdomain.example.com
```
