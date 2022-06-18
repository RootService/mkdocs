---
title: 'BaseTools'
description: 'In diesem HowTo wird step-by-step die Installation einiger BaseTools für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
    - 'Eckhard Doll'
    - 'Olaf Uecker'
tags:
    - FreeBSD
    - BaseTools
---

# BaseTools

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Installation einiger Tools (Ports / Packages / Pakete) welche auf keinem [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem auf einem dedizierten Server fehlen sollten.

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/remote_install/)

Unsere BaseTools werden am Ende folgende Dienste umfassen.

- cURL 7.75.0
- Portmaster 3.19
- SMARTmontools 7.2
- Bash 5.1.4
- Nano 5.5
- w3m 0.5.3
- GnuPG 2.2.27
- GDBM 1.19
- SVN 1.14.1
- GIT 2.30.1

## Einloggen und zu root werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## Software installieren

Wir installieren `ftp/curl` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/archivers_zstd
cat > /var/db/ports/archivers_zstd/options << "EOF"
_OPTIONS_READ=zstd-1.4.8
_FILE_COMPLETE_OPTIONS_LIST=LZ4 OPTIMIZED_CFLAGS TEST
OPTIONS_FILE_SET+=LZ4
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/devel_ninja
cat > /var/db/ports/devel_ninja/options << "EOF"
_OPTIONS_READ=ninja-1.10.2
_FILE_COMPLETE_OPTIONS_LIST=BASH DOCS ZSH
OPTIONS_FILE_UNSET+=BASH
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=ZSH
"EOF"

mkdir -p /var/db/ports/dns_libpsl
cat > /var/db/ports/dns_libpsl/options << "EOF"
_OPTIONS_READ=libpsl-0.21.1
_FILE_COMPLETE_OPTIONS_LIST=NLS ICU IDN IDN2
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_UNSET+=IDN2
"EOF"

mkdir -p /var/db/ports/security_libssh2
cat > /var/db/ports/security_libssh2/options << "EOF"
_OPTIONS_READ=libssh2-1.9.0
_FILE_COMPLETE_OPTIONS_LIST=GCRYPT TRACE ZLIB
OPTIONS_FILE_UNSET+=GCRYPT
OPTIONS_FILE_UNSET+=TRACE
OPTIONS_FILE_SET+=ZLIB
"EOF"

mkdir -p /var/db/ports/textproc_libxml2
cat > /var/db/ports/textproc_libxml2/options << "EOF"
_OPTIONS_READ=libxml2-2.9.10
_FILE_COMPLETE_OPTIONS_LIST=MEM_DEBUG SCHEMA THREADS THREAD_ALLOC VALID XMLLINT_HIST
OPTIONS_FILE_UNSET+=MEM_DEBUG
OPTIONS_FILE_SET+=SCHEMA
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=THREAD_ALLOC
OPTIONS_FILE_SET+=VALID
OPTIONS_FILE_UNSET+=XMLLINT_HIST
"EOF"

mkdir -p /var/db/ports/textproc_libxslt
cat > /var/db/ports/textproc_libxslt/options << "EOF"
_OPTIONS_READ=libxslt-1.1.34
_FILE_COMPLETE_OPTIONS_LIST=CRYPTO MEM_DEBUG
OPTIONS_FILE_SET+=CRYPTO
OPTIONS_FILE_UNSET+=MEM_DEBUG
"EOF"

mkdir -p /var/db/ports/ftp_curl
cat > /var/db/ports/ftp_curl/options << "EOF"
_OPTIONS_READ=curl-7.75.0
_FILE_COMPLETE_OPTIONS_LIST=ALTSVC BROTLI CA_BUNDLE COOKIES CURL_DEBUG DEBUG DOCS EXAMPLES IDN IPV6 METALINK NTLM PROXY PSL TLS_SRP ZSTD GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT GSSAPI_NONE CARES THREADED_RESOLVER GNUTLS NSS OPENSSL WOLFSSL DICT FTP GOPHER HTTP HTTP2 IMAP LDAP LDAPS LIBSSH2 POP3 RTMP RTSP SMB SMTP TELNET TFTP
OPTIONS_FILE_SET+=ALTSVC
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=CA_BUNDLE
OPTIONS_FILE_SET+=COOKIES
OPTIONS_FILE_UNSET+=CURL_DEBUG
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=METALINK
OPTIONS_FILE_SET+=NTLM
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_SET+=PSL
OPTIONS_FILE_SET+=TLS_SRP
OPTIONS_FILE_SET+=ZSTD
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
OPTIONS_FILE_SET+=GSSAPI_NONE
OPTIONS_FILE_UNSET+=CARES
OPTIONS_FILE_SET+=THREADED_RESOLVER
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_UNSET+=NSS
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_UNSET+=WOLFSSL
OPTIONS_FILE_UNSET+=DICT
OPTIONS_FILE_SET+=FTP
OPTIONS_FILE_UNSET+=GOPHER
OPTIONS_FILE_SET+=HTTP
OPTIONS_FILE_SET+=HTTP2
OPTIONS_FILE_UNSET+=IMAP
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LDAPS
OPTIONS_FILE_SET+=LIBSSH2
OPTIONS_FILE_UNSET+=POP3
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_SET+=RTSP
OPTIONS_FILE_UNSET+=SMB
OPTIONS_FILE_UNSET+=SMTP
OPTIONS_FILE_UNSET+=TELNET
OPTIONS_FILE_UNSET+=TFTP
"EOF"


cd /usr/ports/ftp/curl
make all install clean-depends clean
```

Wir installieren `ports-mgmt/portmaster` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/ports-mgmt_portmaster
cat > /var/db/ports/ports-mgmt_portmaster/options << "EOF"
_OPTIONS_READ=portmaster-3.19
_FILE_COMPLETE_OPTIONS_LIST=BASH ZSH
OPTIONS_FILE_UNSET+=BASH
OPTIONS_FILE_UNSET+=ZSH
"EOF"


cd /usr/ports/ports-mgmt/portmaster
make all install clean-depends clean
```

Wir installieren `sysutils/smartmontools` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/sysutils/smartmontools
make all install clean-depends clean
```

Wir konfigurieren `smartmontools`.

``` bash
sed 's/^DEVICESCAN/#DEVICESCAN/' /usr/local/etc/smartd.conf.sample > /usr/local/etc/smartd.conf
echo '/dev/ada0 -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf
echo '/dev/ada1 -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf

echo 'smartd_enable="YES"' >> /etc/rc.conf
```

Die `/etc/periodic.conf` wird um folgenden Inhalt erweitert.

``` bash
cat >> /etc/periodic.conf << "EOF"
daily_status_smart_enable="YES"
daily_status_smart_devices="/dev/ada0 /dev/ada1"
"EOF"
```

Wir installieren `shells/bash` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/shells_bash
cat > /var/db/ports/shells_bash/options << "EOF"
_OPTIONS_READ=bash-5.1.4
_FILE_COMPLETE_OPTIONS_LIST=DOCS FDESCFS HELP NLS PORTS_READLINE STATIC SYSBASHRC SYSLOG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=FDESCFS
OPTIONS_FILE_SET+=HELP
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PORTS_READLINE
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=SYSBASHRC
OPTIONS_FILE_UNSET+=SYSLOG
"EOF"


cd /usr/ports/shells/bash
make all install clean-depends clean
```

Wir installieren `editors/nano` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/editors/nano
make all install clean-depends clean
```

Wir installieren `www/w3m` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_w3m
cat > /var/db/ports/www_w3m/options << "EOF"
_OPTIONS_READ=w3m-0.5.3.20210206
_FILE_COMPLETE_OPTIONS_LIST=DOCS INLINE_IMAGE JAPANESE KEY_LYNX NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=INLINE_IMAGE
OPTIONS_FILE_UNSET+=JAPANESE
OPTIONS_FILE_UNSET+=KEY_LYNX
OPTIONS_FILE_SET+=NLS
"EOF"


cd /usr/ports/www/w3m
make all install clean-depends clean
```

Wir installieren `security/gnupg` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_pinentry
cat > /var/db/ports/security_pinentry/options << "EOF"
_OPTIONS_READ=pinentry-1.1.1
_FILE_COMPLETE_OPTIONS_LIST= TTY NCURSES EFL FLTK GTK2 QT5 GNOME3
OPTIONS_FILE_SET+=TTY
OPTIONS_FILE_UNSET+=NCURSES
OPTIONS_FILE_UNSET+=EFL
OPTIONS_FILE_UNSET+=FLTK
OPTIONS_FILE_UNSET+=GTK2
OPTIONS_FILE_UNSET+=QT5
OPTIONS_FILE_UNSET+=GNOME3
"EOF"

mkdir -p /var/db/ports/security_pinentry-tty
cat > /var/db/ports/security_pinentry-tty/options << "EOF"
_OPTIONS_READ=pinentry-tty-1.1.1
_FILE_COMPLETE_OPTIONS_LIST=LIBSECRET
OPTIONS_FILE_UNSET+=LIBSECRET
"EOF"

mkdir -p /var/db/ports/security_gnupg
cat > /var/db/ports/security_gnupg/options << "EOF"
_OPTIONS_READ=gnupg-2.2.27
_FILE_COMPLETE_OPTIONS_LIST=DOCS GNUTLS LARGE_RSA LDAP NLS SCDAEMON SUID_GPG WKS_SERVER
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_SET+=LARGE_RSA
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=SCDAEMON
OPTIONS_FILE_UNSET+=SUID_GPG
OPTIONS_FILE_SET+=WKS_SERVER
"EOF"


cd /usr/ports/security/gnupg
make all install clean-depends clean
```

Wir installieren `devel/subversion` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_gdbm
cat > /var/db/ports/databases_gdbm/options << "EOF"
_OPTIONS_READ=gdbm-1.19
_FILE_COMPLETE_OPTIONS_LIST=COMPAT NLS
OPTIONS_FILE_SET+=COMPAT
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_apr1
cat > /var/db/ports/devel_apr1/options << "EOF"
_OPTIONS_READ=apr-1.7.0.1.6.1
_FILE_COMPLETE_OPTIONS_LIST=IPV6 SSL NSS BDB GDBM LDAP MYSQL NDBM ODBC PGSQL SQLITE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=NSS
OPTIONS_FILE_SET+=BDB
OPTIONS_FILE_SET+=GDBM
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=NDBM
OPTIONS_FILE_UNSET+=ODBC
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
"EOF"

mkdir -p /var/db/ports/devel_subversion
cat > /var/db/ports/devel_subversion/options << "EOF"
_OPTIONS_READ=subversion-1.14.1
_FILE_COMPLETE_OPTIONS_LIST=BDB DOCS FREEBSD_TEMPLATE GPG_AGENT NLS SASL SERF STATIC SVNSERVE_WRAPPER TEST TOOLS
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=FREEBSD_TEMPLATE
OPTIONS_FILE_SET+=GPG_AGENT
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=SASL
OPTIONS_FILE_SET+=SERF
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=SVNSERVE_WRAPPER
OPTIONS_FILE_UNSET+=TEST
OPTIONS_FILE_SET+=TOOLS
"EOF"


cd /usr/ports/devel/subversion
make all install clean-depends clean
```

Wir installieren `devel/git` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_p5-Authen-SASL
cat > /var/db/ports/security_p5-Authen-SASL/options << "EOF"
_OPTIONS_READ=p5-Authen-SASL-2.16
_FILE_COMPLETE_OPTIONS_LIST=KERBEROS
OPTIONS_FILE_UNSET+=KERBEROS
"EOF"

mkdir -p /var/db/ports/security_p5-IO-Socket-SSL
cat > /var/db/ports/security_p5-IO-Socket-SSL/options << "EOF"
_OPTIONS_READ=p5-IO-Socket-SSL-2.069
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES IDN IPV6
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
"EOF"

mkdir -p /var/db/ports/textproc_docbook-xsl
cat > /var/db/ports/textproc_docbook-xsl/options << "EOF"
_OPTIONS_READ=docbook-xsl-1.79.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS ECLIPSE EPUB EXTENSIONS HIGHLIGHTING HTMLHELP JAVAHELP PROFILING ROUNDTRIP SLIDES TEMPLATE TESTS TOOLS WEBSITE XHTML11
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=ECLIPSE
OPTIONS_FILE_SET+=EPUB
OPTIONS_FILE_SET+=EXTENSIONS
OPTIONS_FILE_SET+=HIGHLIGHTING
OPTIONS_FILE_SET+=HTMLHELP
OPTIONS_FILE_UNSET+=JAVAHELP
OPTIONS_FILE_SET+=PROFILING
OPTIONS_FILE_SET+=ROUNDTRIP
OPTIONS_FILE_SET+=SLIDES
OPTIONS_FILE_SET+=TEMPLATE
OPTIONS_FILE_UNSET+=TESTS
OPTIONS_FILE_SET+=TOOLS
OPTIONS_FILE_SET+=WEBSITE
OPTIONS_FILE_SET+=XHTML11
"EOF"

mkdir -p /var/db/ports/textproc_xmlto
cat > /var/db/ports/textproc_xmlto/options << "EOF"
_OPTIONS_READ=xmlto-0.0.28
_FILE_COMPLETE_OPTIONS_LIST=DOCS DBLATEX FOP PASSIVETEX
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=DBLATEX
OPTIONS_FILE_UNSET+=FOP
OPTIONS_FILE_UNSET+=PASSIVETEX
"EOF"

mkdir -p /var/db/ports/devel_git
cat > /var/db/ports/devel_git/options << "EOF"
_OPTIONS_READ=git-2.30.1
_FILE_COMPLETE_OPTIONS_LIST=CONTRIB CURL CVS GITWEB GUI HTMLDOCS ICONV NLS P4 PERL SEND_EMAIL SUBTREE SVN PCRE PCRE2
OPTIONS_FILE_SET+=CONTRIB
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_SET+=CVS
OPTIONS_FILE_UNSET+=GITWEB
OPTIONS_FILE_UNSET+=GUI
OPTIONS_FILE_UNSET+=HTMLDOCS
OPTIONS_FILE_SET+=ICONV
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=P4
OPTIONS_FILE_SET+=PERL
OPTIONS_FILE_SET+=SEND_EMAIL
OPTIONS_FILE_SET+=SUBTREE
OPTIONS_FILE_SET+=SVN
OPTIONS_FILE_UNSET+=PCRE
OPTIONS_FILE_SET+=PCRE2
"EOF"


cd /usr/ports/devel/git
make all install clean-depends clean
```

Wenn wir ein Programm nicht kennen, dann finden wir zu jedem Port eine Datei `pkg-descr`, die eine kurze Beschreibung sowie (meistens) einen Link zur Projekt-Homepage der Software enthält. Für `smartmontools` zum Beispiel würden wir die Beschreibung unter `/usr/ports/sysutils/smartmontools/pkg-descr` finden.

## Software updaten

???+ important

    Da wir die Pakete/Ports nicht als vorkompilierte Binary-Pakete installieren sondern selbst kompilieren, müssen wir natürlich auch die Updates der Ports selbst kompilieren. Um uns das dazu notwendige Auflösen der Abhängigkeiten und etwas Tipparbeit zu ersparen, überlassen wir dies künftig einfach einem kleinen Shell-Script. Dieses Script können wir einfach mittels `update-ports` ausführen und es erledigt dann folgende Arbeiten für uns:

- Aktualisieren des Portstree mittels `portsnap`
- Anzeigen neuer Einträge in `/usr/ports/UPDATING`
- Ermitteln der zu aktualisierenden Ports und deren Abhängigkeiten
- Aktualisieren der Ports und Abhängigkeiten mittels portmaster
- Aufräumen des Portstree und der Distfiles mittels portmaster

``` bash
cat > /usr/local/sbin/update-ports << "EOF"
#!/bin/sh

portsnap fetch update

printf "\v================================================================================\v\n"

pkg updating -d `date -u -v-3m "+%Y%m%d"`

printf "\v================================================================================\v\n"

read -p "Update ports now? [y/N] " REPLY

if [ "x$REPLY" != "xy" ]
then
  exit 0
fi

pkg check -Ba -da -sa -ra

portmaster --no-confirm --index-first -d -w -R -a -y

portmaster --no-confirm --no-term-title --no-index-fetch --index-first --clean-distfiles -y

portmaster --no-confirm --no-term-title --no-index-fetch --index-first --clean-packages -y

portmaster --no-confirm --no-term-title --no-index-fetch --index-first --check-depends -y

portmaster --no-confirm --no-term-title --check-port-dbdir -y

exit 0
"EOF"

chmod 0755 /usr/local/sbin/update-ports
```

## Wie geht es weiter?

Viel Spass mit den neuen FreeBSD BaseTools.
