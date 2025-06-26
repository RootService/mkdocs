---
title: 'ClamAV'
description: 'In diesem HowTo wird step-by-step die Installation von ClamAV für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# ClamAV

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- ClamAV

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `security/clamav` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_clamav
cat <<'EOF' > /var/db/ports/security_clamav/options
--8<-- "ports/security_clamav/options"
EOF


portmaster -w -B -g --force-config security/clamav  -n


sysrc clamav_clamd_enable="YES"
sysrc clamav_freshclam_enable="YES"
```

## Konfigurieren

`clamav.conf` einrichten.

``` bash
```

## Abschluss

ClamAV kann nun gestartet werden.

``` bash

service clamav_freshclam onestart

freshclam

service clamav_clamd start
```
