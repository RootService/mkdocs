---
title: 'NodeJS'
description: 'In diesem HowTo wird step-by-step die Installation des NodeJS Servers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# NodeJS

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- NodeJS 22.16.0 (NPM, YARN)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `www/node` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/dns_c-ares
cat <<'EOF' > /var/db/ports/dns_c-ares/options
--8<-- "ports/dns_c-ares/options"
EOF

mkdir -p /var/db/ports/www_node22
cat <<'EOF' > /var/db/ports/www_node22/options
--8<-- "ports/www_node22/options"
EOF


portmaster -w -B -g --force-config www/node  -n


sysrc node_enable=YES
```

Wir installieren `www/npm` und dessen Abhängigkeiten.

``` bash
portmaster -w -B -g --force-config www/npm  -n
```

Wir installieren `www/yarn` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_yarn-node22
cat <<'EOF' > /var/db/ports/www_yarn-node22/options
--8<-- "www_yarn-node22/options"
EOF


portmaster -w -B -g --force-config www/yarn  -n
```
