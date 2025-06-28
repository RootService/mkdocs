---
title: 'OpenSSH'
description: 'In diesem HowTo wird step-by-step die Installation von OpenSSH für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# OpenSSH

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- OpenSSH 10.0p1 (Public-Key-Auth)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `security/openssh-portable` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/dns_ldns
cat <<'EOF' > /var/db/ports/dns_ldns/options
--8<-- "ports/dns_ldns/options"
EOF

mkdir -p /var/db/ports/security_libfido2
cat <<'EOF' > /var/db/ports/security_libfido2/options
--8<-- "ports/security_libfido2/options"
EOF

mkdir -p /var/db/ports/security_openssh-portable
cat <<'EOF' > /var/db/ports/security_openssh-portable/options
--8<-- "ports/security_openssh-portable/options"
EOF


portmaster -w -B -g --force-config security/openssh-portable@default  -n


sysrc openssh_dsa_enable=NO
sysrc openssh_pidfile="/var/run/opensshd.pid"
sysrc openssh_enable=YES
```

## Konfiguration

Wir konfigurieren OpenSSH:

``` bash
cat <<'EOF' > /usr/local/etc/ssh/sshd_config
--8<-- "configs/usr/local/etc/ssh/sshd_config"
EOF

rm -f /usr/local/etc/ssh/ssh_host_*_key*
ssh-keygen -q -t rsa -b 4096 -f "/usr/local/etc/ssh/ssh_host_rsa_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_rsa_key.pub"
ssh-keygen -q -t ecdsa -b 384 -f "/usr/local/etc/ssh/ssh_host_ecdsa_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_ecdsa_key.pub"
ssh-keygen -q -t ed25519 -f "/usr/local/etc/ssh/ssh_host_ed25519_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_ed25519_key.pub"
```

## Abschluss

OpenSSH kann nun gestartet werden.

``` bash
service openssh start
```
