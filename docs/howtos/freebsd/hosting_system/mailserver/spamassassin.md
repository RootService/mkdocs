---
title: 'SpamAssassin'
description: 'In diesem HowTo wird step-by-step die Installation von SpamAssassin für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# SpamAssassin

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- SpamAssassin 4.0.1 (SpamAss-Milter)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/spamassassin` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_p5-HTTP-Tiny
cat <<'EOF' > /var/db/ports/www_p5-HTTP-Tiny/options
_OPTIONS_READ=p5-HTTP-Tiny-0.088
_FILE_COMPLETE_OPTIONS_LIST=CERTS COOKIE HTTPS IO_SOCKET_IP
OPTIONS_FILE_SET+=CERTS
OPTIONS_FILE_SET+=COOKIE
OPTIONS_FILE_SET+=HTTPS
OPTIONS_FILE_SET+=IO_SOCKET_IP
EOF

mkdir -p /var/db/ports/databases_p5-DBD-SQLite
cat <<'EOF' > /var/db/ports/databases_p5-DBD-SQLite/options
_OPTIONS_READ=p5-DBD-SQLite-1.74
_FILE_COMPLETE_OPTIONS_LIST=BUNDLED_SQLITE
OPTIONS_FILE_SET+=BUNDLED_SQLITE
EOF

mkdir -p /var/db/ports/databases_p5-DBIx-Simple
cat <<'EOF' > /var/db/ports/db/ports/databases_p5-DBIx-Simple/options
_OPTIONS_READ=p5-DBIx-Simple-1.37
_FILE_COMPLETE_OPTIONS_LIST=DBIX_XHTML_TABLE SQL_ABSTRACT SQL_INTERP TEXT_TABLE
OPTIONS_FILE_UNSET+=DBIX_XHTML_TABLE
OPTIONS_FILE_UNSET+=SQL_ABSTRACT
OPTIONS_FILE_UNSET+=SQL_INTERP
OPTIONS_FILE_UNSET+=TEXT_TABLE
EOF

mkdir -p /var/db/ports/www_p5-CGI
cat <<'EOF' > /var/db/ports/www_p5-CGI/options
_OPTIONS_READ=p5-CGI-4.64
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES
OPTIONS_FILE_UNSET+=EXAMPLES
EOF

mkdir -p /var/db/ports/devel_p5-Parse-RecDescent
cat <<'EOF' > /var/db/ports/devel_p5-Parse-RecDescent/options
_OPTIONS_READ=p5-Parse-RecDescent-1.967015
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/net_p5-Net-Server
cat <<'EOF' > /var/db/ports/net_p5-Net-Server/options
_OPTIONS_READ=p5-Net-Server-2.014
_FILE_COMPLETE_OPTIONS_LIST=IPV6
OPTIONS_FILE_SET+=IPV6
EOF

mkdir -p /var/db/ports/devel_p5-Moo
cat <<'EOF' > /var/db/ports/devel_p5-Moo/options
_OPTIONS_READ=p5-Moo-2.005005
_FILE_COMPLETE_OPTIONS_LIST=XS
OPTIONS_FILE_SET+=XS
EOF

mkdir -p /var/db/ports/devel_p5-Class-C3
cat <<'EOF' > /var/db/ports/devel_p5-Class-C3/options
_OPTIONS_READ=p5-Class-C3-0.35
_FILE_COMPLETE_OPTIONS_LIST=XS
OPTIONS_FILE_SET+=XS
EOF

mkdir -p /var/db/ports/devel_p5-Data-Dumper-Concise
cat <<'EOF' > /var/db/ports/devel_p5-Data-Dumper-Concise/options
_OPTIONS_READ=p5-Data-Dumper-Concise-2.023
_FILE_COMPLETE_OPTIONS_LIST=ARGNAMES
OPTIONS_FILE_SET+=ARGNAMES
EOF

mkdir -p /var/db/ports/dns_p5-Net-DNS
cat <<'EOF' > /var/db/ports/dns_p5-Net-DNS/options
_OPTIONS_READ=p5-Net-DNS-1.45
_FILE_COMPLETE_OPTIONS_LIST=IDN IDN2 IPV6 SSHFP TSIG
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_SET+=IDN2
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=SSHFP
OPTIONS_FILE_SET+=TSIG
EOF

mkdir -p /var/db/ports/devel_p5-Test-NoWarnings
cat <<'EOF' > /var/db/ports/devel_p5-Test-NoWarnings/options
_OPTIONS_READ=p5-Test-NoWarnings-1.06
_FILE_COMPLETE_OPTIONS_LIST=DEVEL_STACKTRACE
OPTIONS_FILE_UNSET+=DEVEL_STACKTRACE
EOF

mkdir -p /var/db/ports/dns_libidn
cat <<'EOF' > /var/db/ports/dns_libidn/options
_OPTIONS_READ=libidn-1.42
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=NLS
EOF

mkdir -p /var/db/ports/devel_re2c
cat <<'EOF' > /var/db/ports/devel_re2c/options
_OPTIONS_READ=re2c-3.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES LIBRE2C RE2GO RE2RUST
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_SET+=LIBRE2C
OPTIONS_FILE_SET+=RE2GO
OPTIONS_FILE_SET+=RE2RUST
EOF

mkdir -p /var/db/ports/mail_spamassassin
cat <<'EOF' > /var/db/ports/mail_spamassassin/options
_OPTIONS_READ=spamassassin-4.0.1
_FILE_COMPLETE_OPTIONS_LIST=AS_ROOT DOCS SSL GNUPG_NONE GNUPG GNUPG2 MYSQL PGSQL DCC DKIM PYZOR RAZOR RELAY_COUNTRY RLIMIT SPF_QUERY
OPTIONS_FILE_SET+=AS_ROOT
OPTIONS_FILE_UNSET+=DOCS
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
EOF


cd /usr/ports/net/p5-Socket6
make all install clean-depends clean


cd /usr/ports/mail/spamassassin
make all install clean-depends clean


sysrc spamd_enable="YES"
sysrc spamd_flags="-c -u spamd -H /var/spool/spamd"
```

Wir installieren `mail/spamass-milter` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/mail_spamass-milter
cat <<'EOF' > /var/db/ports/mail_spamass-milter/options
_OPTIONS_READ=spamass-milter-0.4.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS LDAP MILTER_PORT
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=MILTER_PORT
EOF


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

`local.cf` einrichten.

``` bash
sed -e 's|^#[[:space:]]*\(report_contact\)[[:space:]].*$|\1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]*\(report_hostname\)[[:space:]].*$|\1 mail.example.com|g' \
    -e 's|^#[[:space:]]*\(report_safe\)[[:space:]].*$|\1 0|g' \
    /usr/local/etc/mail/spamassassin/local.cf.sample > /usr/local/etc/mail/spamassassin/local.cf

cat <<'EOF' >> /usr/local/etc/mail/spamassassin/local.cf
clear_headers
add_header all Flag _YESNOCAPS_
add_header all Level _STARS(*)_
add_header all Status _YESNO_, score=_SCORE_ required=_REQD_ autolearn=_AUTOLEARN_ tests=_TESTSSCORES_
add_header all Report _REPORT_
add_header all Checker-Version SpamAssassin _VERSION_ (_SUBVERSION_) on _HOSTNAME_
EOF

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
cat <<'EOF' > /usr/local/sbin/update-spamassassin
#!/bin/sh

/usr/local/bin/sa-update --channel updates.spamassassin.org --refreshmirrors --verbose
/usr/local/bin/sa-update --channel updates.spamassassin.org --verbose

/usr/local/bin/sa-compile --quiet

/usr/sbin/service sa-spamd restart
EOF

chmod 0755 /usr/local/sbin/update-spamassassin
```

## Abschluss

SpamAssassin kann nun gestartet werden.

``` bash
mkdir -p /var/run/spamass-milter
chown spamd:spamd /var/run/spamass-milter

service sa-spamd start
service spamass-milter start
```
