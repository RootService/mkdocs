---
title: 'NodeJS'
description: 'In diesem HowTo wird step-by-step die Installation des NodeJS Servers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-07'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# NodeJS

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- NodeJS 18.15.0 (NPM, YARN)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `www/node` und dessen Abhängigkeiten.

``` bash
cat >> /etc/make.conf << "EOF"
#DEFAULT_VERSIONS+=nodejs=lts
"EOF"


mkdir -p /var/db/ports/dns_c-ares
cat > /var/db/ports/dns_c-ares/options << "EOF"
_OPTIONS_READ=c-ares-1.19.0
_FILE_COMPLETE_OPTIONS_LIST=TEST
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/devel_binutils
cat > /var/db/ports/devel_binutils/options << "EOF"
_OPTIONS_READ=binutils-2.40
_FILE_COMPLETE_OPTIONS_LIST=NLS RELRO
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=RELRO
"EOF"

mkdir -p /var/db/ports/math_mpfr
cat > /var/db/ports/math_mpfr/options << "EOF"
_OPTIONS_READ=mpfr-4.2.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/www_node18
cat > /var/db/ports/www_node18/options << "EOF"
_OPTIONS_READ=node18-18.15.0
_FILE_COMPLETE_OPTIONS_LIST=BUNDLED_SSL DOCS DTRACE NLS
OPTIONS_FILE_UNSET+=BUNDLED_SSL
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=NLS
"EOF"


cd /usr/ports/www/node
make all install clean-depends clean


sysrc node_enable=YES
```

Wir installieren `www/npm` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/www/npm
make all install clean-depends clean
```

Wir installieren `www/yarn` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_yarn-node18
cat > /var/db/ports/www_yarn-node18/options << "EOF"
_OPTIONS_READ=yarn-node18-1.22.19
_FILE_COMPLETE_OPTIONS_LIST=HADOOPCOMPAT
OPTIONS_FILE_UNSET+=HADOOPCOMPAT
"EOF"


cd /usr/ports/www/yarn
make all install clean-depends clean
```
