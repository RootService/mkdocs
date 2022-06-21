---
title: 'OpenDMARC'
description: 'In diesem HowTo wird step-by-step die Installation von OpenDMARC für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-06-21'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
tags:
    - FreeBSD
    - OpenDMARC
---

# OpenDMARC

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird um folgende Dienste erweitert.

- OpenDMARC 1.4.2 (SPF2, FailureReports)

## Installation

Wir installieren `mail/opendmarc` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_p5-DBI
cat > /var/db/ports/databases_p5-DBI/options << "EOF"
_OPTIONS_READ=p5-DBI-1.643
_FILE_COMPLETE_OPTIONS_LIST=PROXY
OPTIONS_FILE_UNSET+=PROXY
"EOF"

mkdir -p /var/db/ports/databases_p5-DBD-mysql
cat > /var/db/ports/databases_p5-DBD-mysql/options << "EOF"
_OPTIONS_READ=p5-DBD-mysql-4.050
_FILE_COMPLETE_OPTIONS_LIST=SSL
OPTIONS_FILE_SET+=SSL
"EOF"

mkdir -p /var/db/ports/mail_opendmarc
cat > /var/db/ports/mail_opendmarc/options << "EOF"
_OPTIONS_READ=opendmarc-1.4.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS SPF
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=SPF
"EOF"


cd /usr/ports/mail/opendmarc
make all install clean-depends clean


sysrc opendmarc_enable=YES
sysrc opendmarc_socket="inet:8893@localhost"
```

``` bash
mkdir -p /data/db/opendmarc

chown -R mailnull:mailnull /data/db/opendmarc
```

## Konfigurieren

`opendmarc.conf` einrichten.

``` bash
sed -e 's|^#[[:space:]]\(AuthservID\)[[:space:]].*$|\1 mail.example.com|g' \
    -e 's|^#[[:space:]]\(AutoRestart\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(AutoRestartRate\)[[:space:]].*$|\1 10/1h|g' \
    -e 's|^#[[:space:]]\(CopyFailuresTo\)[[:space:]].*$|# \1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]\(FailureReports\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(FailureReportsBcc\)[[:space:]].*$|# \1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]\(FailureReportsOnNone\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(FailureReportsSentBy\)[[:space:]].*$|\1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]\(HistoryFile\)[[:space:]].*$|\1 /data/db/opendmarc/opendmarc.dat|g' \
    -e 's|^#[[:space:]]\(IgnoreAuthenticatedClients\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(IgnoreHosts\)[[:space:]].*$|\1 /data/db/opendmarc/ignorehosts|g' \
    -e 's|^#[[:space:]]\(PidFile\)[[:space:]].*$|# \1 /var/run/opendmarc/pid|g' \
    -e 's|^#[[:space:]]\(PublicSuffixList\)[[:space:]].*$|\1 /usr/local/share/public_suffix_list/public_suffix_list.dat|g' \
    -e 's|^#[[:space:]]\(RejectFailures\)[[:space:]].*$|\1 false|g' \
    -e 's|^#[[:space:]]\(Socket\)[[:space:]]*inet.*$|\1 inet:8893@localhost|g' \
    -e 's|^#[[:space:]]\(SPFIgnoreResults\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(SPFSelfValidate\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(Syslog\)[[:space:]].*$|\1 true|g' \
    -e 's|^#[[:space:]]\(TrustedAuthservIDs\)[[:space:]].*$|\1 mail.example.com|g' \
    -e 's|^#[[:space:]]\(UMask\)[[:space:]].*$|\1 022|g' \
    -e 's|^#[[:space:]]\(UserID\)[[:space:]].*$|\1 mailnull:mailnull|g' \
    /usr/local/etc/mail/opendmarc.conf.sample > /usr/local/etc/mail/opendmarc.conf
```

IgnoreHosts anlegen.

``` bash
cat > /data/db/opendmarc/ignorehosts << "EOF"
::1
127.0.0.1
localhost
"EOF"

ifconfig `route -n get -inet default | \
    awk '/interface/ {print $2}'` inet | \
    awk '/inet / {if(substr($2,1,3)!=127) print $2}' \
    >> /data/db/opendmarc/ignorehosts
ifconfig `route -n get -inet6 default | \
    awk '/interface/ {print $2}'` inet6 | \
    awk '/inet6 / {if(substr($2,1,1)!="f") print $2}' \
    >> /data/db/opendmarc/ignorehosts

cat >> /data/db/opendmarc/ignorehosts << "EOF"
example.com
*.example.com
"EOF"
```

``` bash
chown -R mailnull:mailnull /data/db/opendmarc
```

Es muss noch ein DNS-Record angelegt werden, sofern er noch nicht existiert, oder entsprechend geändert werden, sofern er bereits existiert.

``` dns-zone
_dmarc.example.com.     IN  TXT     ( "v=DMARC1; p=none; sp=none; adkim=r; aspf=r; fo=1; rua=mailto:postmaster@example.com; ruf=mailto:postmaster@example.com" )
```

## Abschluss

OpenDMARC kann nun gestartet werden.

``` bash
service opendmarc start
```
