---
title: 'Unbound'
description: 'In diesem HowTo wird step-by-step die Installation von Unbound für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Unbound

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- Unbound 1.23.0 (DNScrypt, DNS over TLS)

## Inhaltsverzeichnis
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Konfiguration](#konfiguration)
- [Abschluss](#abschluss)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `dns/unbound` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_libsodium
cat <<'EOF' > /var/db/ports/security_libsodium/options
--8<-- "ports/security_libsodium/options"
EOF

mkdir -p /var/db/ports/devel_libevent
cat <<'EOF' > /var/db/ports/devel_libevent/options
--8<-- "ports/devel_libevent/options"
EOF

mkdir -p /var/db/ports/dns_unbound
cat <<'EOF' > /var/db/ports/dns_unbound/options
--8<-- "ports/dns_unbound/options"
EOF


portmaster -w -B -g --force-config dns/unbound  -n


sysrc local_unbound_enable=NO
sysrc unbound_enable=YES
```

## Konfiguration

Wir konfigurieren Unbound:

``` bash
cat <<'EOF' > /usr/local/etc/unbound/unbound.conf
--8<-- "configs/usr/local/etc/unbound/unbound.conf"
EOF

curl -o "/usr/local/etc/unbound/root.hints" -L "https://www.internic.net/domain/named.root"
chown unbound /usr/local/etc/unbound/root.hints

sudo -u unbound unbound-anchor -a "/usr/local/etc/unbound/root.key"

sudo -u unbound unbound-control-setup
```

## Abschluss

Unbound kann nun gestartet werden.

``` bash
service local_unbound onestop

service unbound start
```
