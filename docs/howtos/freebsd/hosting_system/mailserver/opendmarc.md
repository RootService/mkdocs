---
title: 'OpenDMARC'
description: 'In diesem HowTo wird step-by-step die Installation von OpenDMARC für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# OpenDMARC

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- OpenDMARC 1.4.2 (SPF2, FailureReports)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/opendmarc` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_p5-DBI
cat <<'EOF' > /var/db/ports/databases_p5-DBI/options
--8<-- "ports/databases_p5-DBI/options"
EOF

mkdir -p /var/db/ports/mail_opendmarc
cat <<'EOF' > /var/db/ports/mail_opendmarc/options
--8<-- "ports/mail_opendmarc/options"
EOF


portmaster -w -B -g --force-config mail/opendmarc  -n


sysrc opendmarc_enable=YES
sysrc opendmarc_socketspec="inet:8895@localhost"
```

``` bash
mkdir -p /data/db/opendmarc

chown -R mailnull:mailnull /data/db/opendmarc
```

## Konfigurieren

`opendmarc.conf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/mail/opendmarc.conf
--8<-- "configs/usr/local/etc/mail/opendmarc.conf"
EOF
```

IgnoreHosts anlegen.

``` bash
cat <<'EOF' > /data/db/opendmarc/ignorehosts
::1
127.0.0.1
fe80::/10
ff02::/16
10.0.0.0/8
__IPADDR4__
__IPADDR6__
localhost
example.com
*.example.com
EOF
```

``` bash
chown -R mailnull:mailnull /data/db/opendmarc
```

## Abschluss

OpenDMARC kann nun gestartet werden.

``` bash
service opendmarc start
```
