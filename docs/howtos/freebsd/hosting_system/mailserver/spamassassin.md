---
title: 'SpamAssassin'
description: 'In diesem HowTo wird step-by-step die Installation von SpamAssassin für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-07'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# SpamAssassin

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- SpamAssassin 4.0.0 (SpamAss-Milter)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/spamassassin` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_p5-Moo
cat > /var/db/ports/devel_p5-Moo/options << "EOF"
_OPTIONS_READ=p5-Moo-2.005005
_FILE_COMPLETE_OPTIONS_LIST=XS
OPTIONS_FILE_SET+=XS
"EOF"

mkdir -p /var/db/ports/devel_p5-Class-C3
cat > /var/db/ports/devel_p5-Class-C3/options << "EOF"
_OPTIONS_READ=p5-Class-C3-0.35
_FILE_COMPLETE_OPTIONS_LIST=XS
OPTIONS_FILE_SET+=XS
"EOF"

mkdir -p /var/db/ports/devel_p5-strictures
cat > /var/db/ports/devel_p5-strictures/options << "EOF"
_OPTIONS_READ=p5-strictures-2.000006
_FILE_COMPLETE_OPTIONS_LIST=STRICTURES_EXTRA
OPTIONS_FILE_SET+=STRICTURES_EXTRA
"EOF"

mkdir -p /var/db/ports/devel_p5-Data-Dumper-Concise
cat > /var/db/ports/devel_p5-Data-Dumper-Concise/options << "EOF"
_OPTIONS_READ=p5-Data-Dumper-Concise-2.023
_FILE_COMPLETE_OPTIONS_LIST=ARGNAMES
OPTIONS_FILE_SET+=ARGNAMES
"EOF"

mkdir -p /var/db/ports/dns_p5-Net-DNS
cat > /var/db/ports/dns_p5-Net-DNS/options << "EOF"
_OPTIONS_READ=p5-Net-DNS-1.37
_FILE_COMPLETE_OPTIONS_LIST=IDN IDN2 IPV6 SSHFP TSIG
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_UNSET+=IDN2
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=SSHFP
OPTIONS_FILE_SET+=TSIG
"EOF"

mkdir -p /var/db/ports/devel_p5-Test-NoWarnings
cat > /var/db/ports/devel_p5-Test-NoWarnings/options << "EOF"
_OPTIONS_READ=p5-Test-NoWarnings-1.06
_FILE_COMPLETE_OPTIONS_LIST=DEVEL_STACKTRACE
OPTIONS_FILE_UNSET+=DEVEL_STACKTRACE
"EOF"

mkdir -p /var/db/ports/dns_libidn
cat > /var/db/ports/dns_libidn/options << "EOF"
_OPTIONS_READ=libidn-1.38
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_re2c
cat > /var/db/ports/devel_re2c/options << "EOF"
_OPTIONS_READ=re2c-3.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES LIBRE2C RE2GO RE2RUST
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=LIBRE2C
OPTIONS_FILE_SET+=RE2GO
OPTIONS_FILE_SET+=RE2RUST
"EOF"

mkdir -p /var/db/ports/security_gnupg1
cat > /var/db/ports/security_gnupg1/options << "EOF"
_OPTIONS_READ=gnupg1-1.4.23
_FILE_COMPLETE_OPTIONS_LIST=CURL DOCS ICONV LDAP LIBUSB NLS SUID_GPG
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=ICONV
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LIBUSB
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=SUID_GPG
"EOF"

mkdir -p /var/db/ports/dns_p5-Net-DNS-Resolver-Programmable
cat > /var/db/ports/dns_p5-Net-DNS-Resolver-Programmable/options << "EOF"
_OPTIONS_READ=p5-Net-DNS-Resolver-Programmable-0.009
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/mail_spamassassin
cat > /var/db/ports/mail_spamassassin/options << "EOF"
_OPTIONS_READ=spamassassin-4.0.0
_FILE_COMPLETE_OPTIONS_LIST=AS_ROOT DOCS SSL GNUPG_NONE GNUPG GNUPG2 MYSQL PGSQL DCC DKIM PYZOR RAZOR RELAY_COUNTRY RLIMIT SPF_QUERY
OPTIONS_FILE_SET+=AS_ROOT
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=GNUPG_NONE
OPTIONS_FILE_SET+=GNUPG
OPTIONS_FILE_UNSET+=GNUPG2
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=DCC
OPTIONS_FILE_SET+=DKIM
OPTIONS_FILE_UNSET+=PYZOR
OPTIONS_FILE_UNSET+=RAZOR
OPTIONS_FILE_SET+=RELAY_COUNTRY
OPTIONS_FILE_UNSET+=RLIMIT
OPTIONS_FILE_SET+=SPF_QUERY
"EOF"


cd /usr/ports/mail/spamassassin
make all install clean-depends clean


sysrc spamd_enable="YES"
sysrc spamd_flags="-c -u spamd -H /var/spool/spamd"
```

Wir installieren `mail/spamass-milter` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/mail_spamass-milter
cat > /var/db/ports/mail_spamass-milter/options << "EOF"
_OPTIONS_READ=spamass-milter-0.4.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS LDAP MILTER_PORT
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=MILTER_PORT
"EOF"


cd /usr/ports/mail/spamass-milter
make all install clean-depends clean


sysrc spamass_milter_enable="YES"
sysrc spamass_milter_user="spamd"
sysrc spamass_milter_group="spamd"
sysrc spamass_milter_socket="/var/run/spamass-milter/spamass-milter.sock"
sysrc spamass_milter_socket_owner="spamd"
sysrc spamass_milter_socket_group="mail"
sysrc spamass_milter_socket_mode="660"
sysrc spamass_milter_localflags="-r 15 -f -u spamd -- -u spamd"
```

## Konfigurieren

`local.conf` einrichten.

``` bash
sed -e 's|^#[[:space:]]*\(report_contact\)[[:space:]].*$|\1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]*\(report_hostname\)[[:space:]].*$|\1 mail.example.com|g' \
    -e 's|^#[[:space:]]*\(report_safe\)[[:space:]].*$|\1 0|g' \
    /usr/local/etc/mail/spamassassin/local.conf.sample > /usr/local/etc/mail/spamassassin/local.conf

cat >> /usr/local/etc/mail/spamassassin/local.conf << "EOF"
clear_headers
add_header all Flag _YESNOCAPS_
add_header all Level _STARS(*)_
add_header all Status _YESNO_, score=_SCORE_ required=_REQD_ autolearn=_AUTOLEARN_ tests=_TESTSSCORES_
add_header all Report _REPORT_
add_header all Checker-Version SpamAssassin _VERSION_ (_SUBVERSION_) on _HOSTNAME_
"EOF"

sed -e 's|^#[[:space:]]*\(loadplugin\)[[:space:]]*\(Mail::SpamAssassin::Plugin::SpamCop\).*$|\1 \2|g' \
    /usr/local/etc/mail/spamassassin/v310.pre.sample > /usr/local/etc/mail/spamassassin/v310.pre

sed -e 's|^#[[:space:]]*\(loadplugin\)[[:space:]]*\(Mail::SpamAssassin::Plugin::Rule2XSBody\).*$|\1 \2|g' \
    -e 's|^#[[:space:]]*\(loadplugin\)[[:space:]]*\(Mail::SpamAssassin::Plugin::ASN\).*$|\1 \2|g' \
    /usr/local/etc/mail/spamassassin/v320.pre.sample > /usr/local/etc/mail/spamassassin/v320.pre

sed -e 's|^#[[:space:]]*\(loadplugin\)[[:space:]]*\(Mail::SpamAssassin::Plugin::FromNameSpoof\).*$|\1 \2|g' \
    -e 's|^#[[:space:]]*\(loadplugin\)[[:space:]]*\(Mail::SpamAssassin::Plugin::Phishing\).*$|\1 \2|g' \
    /usr/local/etc/mail/spamassassin/v342.pre.sample > /usr/local/etc/mail/spamassassin/v342.pre
```

SpamAssassin Datenbank anlegen.

``` bash
/usr/local/bin/sa-update --channel updates.spamassassin.org --refreshmirrors --verbose
/usr/local/bin/sa-update --channel updates.spamassassin.org --verbose

/usr/local/bin/sa-compile --quiet
```

SpamAssassin Datenbank updaten.

``` bash
cat > /usr/local/sbin/update-spamassassin << "EOF"
#!/bin/sh

/usr/local/bin/sa-update --channel updates.spamassassin.org --refreshmirrors --verbose
/usr/local/bin/sa-update --channel updates.spamassassin.org --verbose

/usr/local/bin/sa-compile --quiet

/usr/sbin/service sa-spamd restart
"EOF"

chmod 0755 /usr/local/sbin/update-spamassassin
```

## Abschluss

SpamAssassin kann nun gestartet werden.

``` bash
service sa-spamd start
service spamass-milter start
```
