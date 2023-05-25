---
title: 'BaseTools'
description: 'In diesem HowTo wird step-by-step die Installation einiger BaseTools für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-05-25'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# BaseTools

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Installation einiger Tools (Ports / Packages / Pakete) welche auf keinem [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem auf einem dedizierten Server fehlen sollten.

Unsere BaseTools werden am Ende folgende Dienste umfassen.

- Sudo 1.9.13p3
- cURL 8.1.1
- wget 1.21.3
- Bash 5.2.15
- GIT 2.40.1
- Portmaster 3.23
- SMARTmontools 7.3
- Nano 7.2
- SQLite 3.41.2
- GnuPG 2.3.8
- Subversion 1.14.2

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Remote Installation](/howtos/freebsd/remote_install/)

## Einloggen und zu root werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_ed25519.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## Software installieren

Wir installieren `security/sudo` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_sudo
cat << "EOF" > /var/db/ports/security_sudo/options
_OPTIONS_READ=sudo-1.9.13p3
_FILE_COMPLETE_OPTIONS_LIST=AUDIT DISABLE_AUTH DISABLE_ROOT_SUDO DOCS EXAMPLES INSULTS LDAP NLS NOARGS_SHELL OPIE PAM PYTHON SSSD GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT
OPTIONS_FILE_SET+=AUDIT
OPTIONS_FILE_UNSET+=DISABLE_AUTH
OPTIONS_FILE_UNSET+=DISABLE_ROOT_SUDO
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_UNSET+=INSULTS
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=NOARGS_SHELL
OPTIONS_FILE_UNSET+=OPIE
OPTIONS_FILE_SET+=PAM
OPTIONS_FILE_UNSET+=PYTHON
OPTIONS_FILE_UNSET+=SSSD
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
"EOF"


cd /usr/ports/security/sudo
make all install clean-depends clean
```

Wir konfigurieren `sudo` und erlauben Mitgliedern der Gruppe `wheel` beliebige Kommandos als beliebiger User ohne Passwortabfrage auszuführen.

``` bash
cat << "EOF" > /usr/local/etc/sudoers.d/00_defaults
## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
Defaults targetpw  # Ask for the password of the target user
ALL ALL=(ALL:ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

## Uncomment to show on password prompt which users' password is being expected
Defaults passprompt="%p's password:"
"EOF"
chmod 0440 /usr/local/etc/sudoers.d/00_defaults

cat << "EOF" > /usr/local/etc/sudoers.d/01_wheel
%wheel ALL = (ALL:ALL) NOPASSWD: ALL
"EOF"
chmod 0440 /usr/local/etc/sudoers.d/01_wheel
```

Wir installieren `ftp/curl` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/archivers_brotli
cat << "EOF" > /var/db/ports/archivers_brotli/options
_OPTIONS_READ=brotli-1.0.9
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_cmake-core
cat << "EOF" > /var/db/ports/devel_cmake-core/options
_OPTIONS_READ=cmake-core-3.26.1
_FILE_COMPLETE_OPTIONS_LIST=CPACK DOCS
OPTIONS_FILE_SET+=CPACK
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_expat2
cat << "EOF" > /var/db/ports/textproc_expat2/options
_OPTIONS_READ=expat-2.5.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS STATIC TEST
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/devel_ninja
cat << "EOF" > /var/db/ports/devel_ninja/options
_OPTIONS_READ=ninja-1.11.1
_FILE_COMPLETE_OPTIONS_LIST=BASH DOCS ZSH
OPTIONS_FILE_SET+=BASH
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ZSH
"EOF"

mkdir -p /var/db/ports/archivers_zstd
cat << "EOF" > /var/db/ports/archivers_zstd/options
_OPTIONS_READ=zstd-1.5.4
_FILE_COMPLETE_OPTIONS_LIST=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
"EOF"

mkdir -p /var/db/ports/archivers_liblz4
cat << "EOF" > /var/db/ports/archivers_liblz4/options
_OPTIONS_READ=liblz4-1.9.4
_FILE_COMPLETE_OPTIONS_LIST=TEST
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/security_libssh2
cat << "EOF" > /var/db/ports/security_libssh2/options
_OPTIONS_READ=libssh2-1.10.0
_FILE_COMPLETE_OPTIONS_LIST=GCRYPT TRACE ZLIB
OPTIONS_FILE_UNSET+=GCRYPT
OPTIONS_FILE_UNSET+=TRACE
OPTIONS_FILE_SET+=ZLIB
"EOF"

mkdir -p /var/db/ports/dns_libpsl
cat << "EOF" > /var/db/ports/dns_libpsl/options
_OPTIONS_READ=libpsl-0.21.2
_FILE_COMPLETE_OPTIONS_LIST= ICU IDN IDN2
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_UNSET+=IDN2
"EOF"

mkdir -p /var/db/ports/security_rhash
cat << "EOF" > /var/db/ports/security_rhash/options
_OPTIONS_READ=rhash-1.4.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/ftp_curl
cat << "EOF" > /var/db/ports/ftp_curl/options
_OPTIONS_READ=curl-8.1.1
_FILE_COMPLETE_OPTIONS_LIST=ALTSVC BROTLI CA_BUNDLE COOKIES CURL_DEBUG DEBUG DOCS EXAMPLES IDN IPV6 NTLM PROXY PSL STATIC TLS_SRP ZSTD GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT GSSAPI_NONE CARES THREADED_RESOLVER GNUTLS OPENSSL WOLFSSL DICT FTP GOPHER HTTP HTTP2 IMAP LDAP LDAPS LIBSSH LIBSSH2 MQTT POP3 RTMP RTSP SMB SMTP TELNET TFTP WEBSOCKET
OPTIONS_FILE_SET+=ALTSVC
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=CA_BUNDLE
OPTIONS_FILE_SET+=COOKIES
OPTIONS_FILE_UNSET+=CURL_DEBUG
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=NTLM
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_SET+=PSL
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_SET+=TLS_SRP
OPTIONS_FILE_SET+=ZSTD
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
OPTIONS_FILE_SET+=GSSAPI_NONE
OPTIONS_FILE_UNSET+=CARES
OPTIONS_FILE_SET+=THREADED_RESOLVER
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_UNSET+=WOLFSSL
OPTIONS_FILE_SET+=DICT
OPTIONS_FILE_SET+=FTP
OPTIONS_FILE_SET+=GOPHER
OPTIONS_FILE_SET+=HTTP
OPTIONS_FILE_SET+=HTTP2
OPTIONS_FILE_SET+=IMAP
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LDAPS
OPTIONS_FILE_UNSET+=LIBSSH
OPTIONS_FILE_SET+=LIBSSH2
OPTIONS_FILE_UNSET+=MQTT
OPTIONS_FILE_SET+=POP3
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_SET+=RTSP
OPTIONS_FILE_UNSET+=SMB
OPTIONS_FILE_SET+=SMTP
OPTIONS_FILE_SET+=TELNET
OPTIONS_FILE_SET+=TFTP
OPTIONS_FILE_UNSET+=WEBSOCKET
"EOF"


cd /usr/ports/ftp/curl
make all install clean-depends clean
```

Wir installieren `ftp/wget` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_libunistring
cat << "EOF" > /var/db/ports/devel_libunistring/options
_OPTIONS_READ=libunistring-1.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/ftp_wget
cat << "EOF" > /var/db/ports/ftp_wget/options
_OPTIONS_READ=wget-1.21.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS IDN IPV6 MANPAGES METALINK NLS NTLM PSL GNUTLS OPENSSL PCRE1 PCRE2
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=MANPAGES
OPTIONS_FILE_UNSET+=METALINK
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=NTLM
OPTIONS_FILE_SET+=PSL
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_UNSET+=PCRE1
OPTIONS_FILE_SET+=PCRE2
"EOF"


cd /usr/ports/ftp/wget
make all install clean-depends clean
```

Wir installieren `devel/git` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/shells_bash
cat << "EOF" > /var/db/ports/shells_bash/options
_OPTIONS_READ=bash-5.2.15
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

mkdir -p /var/db/ports/devel_bison
cat << "EOF" > /var/db/ports/devel_bison/options
_OPTIONS_READ=bison-3.8.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/textproc_xmlto
cat << "EOF" > /var/db/ports/textproc_xmlto/options
_OPTIONS_READ=xmlto-0.0.28
_FILE_COMPLETE_OPTIONS_LIST=DOCS DBLATEX FOP PASSIVETEX
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=DBLATEX
OPTIONS_FILE_UNSET+=FOP
OPTIONS_FILE_UNSET+=PASSIVETEX
"EOF"

mkdir -p /var/db/ports/misc_getopt
cat << "EOF" > /var/db/ports/misc_getopt/options
_OPTIONS_READ=getopt-1.1.6
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/textproc_docbook-xsl
cat << "EOF" > /var/db/ports/textproc_docbook-xsl/options
_OPTIONS_READ=docbook-xsl-1.79.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS ECLIPSE EPUB EXTENSIONS HIGHLIGHTING HTMLHELP JAVAHELP PROFILING ROUNDTRIP SLIDES TEMPLATE TESTS TOOLS WEBSITE XHTML11
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ECLIPSE
OPTIONS_FILE_SET+=EPUB
OPTIONS_FILE_SET+=EXTENSIONS
OPTIONS_FILE_SET+=HIGHLIGHTING
OPTIONS_FILE_SET+=HTMLHELP
OPTIONS_FILE_SET+=JAVAHELP
OPTIONS_FILE_SET+=PROFILING
OPTIONS_FILE_SET+=ROUNDTRIP
OPTIONS_FILE_SET+=SLIDES
OPTIONS_FILE_SET+=TEMPLATE
OPTIONS_FILE_UNSET+=TESTS
OPTIONS_FILE_SET+=TOOLS
OPTIONS_FILE_SET+=WEBSITE
OPTIONS_FILE_SET+=XHTML11
"EOF"

mkdir -p /var/db/ports/textproc_xmlcatmgr
cat << "EOF" > /var/db/ports/textproc_xmlcatmgr/options
_OPTIONS_READ=xmlcatmgr-2.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/www_w3m
cat << "EOF" > /var/db/ports/www_w3m/options
_OPTIONS_READ=w3m-0.5.3.20230129
_FILE_COMPLETE_OPTIONS_LIST=DOCS INLINE_IMAGE JAPANESE KEY_LYNX NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=INLINE_IMAGE
OPTIONS_FILE_UNSET+=JAPANESE
OPTIONS_FILE_UNSET+=KEY_LYNX
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_boehm-gc
cat << "EOF" > /var/db/ports/devel_boehm-gc/options
_OPTIONS_READ=boehm-gc-8.2.2
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DOCS
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_libatomic_ops
cat << "EOF" > /var/db/ports/devel_libatomic_ops/options
_OPTIONS_READ=libatomic_ops-7.8.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/security_p5-Authen-SASL
cat << "EOF" > /var/db/ports/security_p5-Authen-SASL/options
_OPTIONS_READ=p5-Authen-SASL-2.16
_FILE_COMPLETE_OPTIONS_LIST=KERBEROS
OPTIONS_FILE_UNSET+=KERBEROS
"EOF"

mkdir -p /var/db/ports/security_p5-IO-Socket-SSL
cat << "EOF" > /var/db/ports/security_p5-IO-Socket-SSL/options
_OPTIONS_READ=p5-IO-Socket-SSL-2.083
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES IDN IPV6
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
"EOF"

mkdir -p /var/db/ports/security_p5-Net-SSLeay
cat << "EOF" > /var/db/ports/security_p5-Net-SSLeay/options
_OPTIONS_READ=p5-Net-SSLeay-1.92
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/devel_git
cat << "EOF" > /var/db/ports/devel_git/options
_OPTIONS_READ=git-2.40.1
_FILE_COMPLETE_OPTIONS_LIST=CONTRIB CURL GITWEB HTMLDOCS ICONV NLS PCRE2 PERL SEND_EMAIL SUBTREE
OPTIONS_FILE_SET+=CONTRIB
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_UNSET+=GITWEB
OPTIONS_FILE_UNSET+=HTMLDOCS
OPTIONS_FILE_SET+=ICONV
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PCRE2
OPTIONS_FILE_SET+=PERL
OPTIONS_FILE_SET+=SEND_EMAIL
OPTIONS_FILE_SET+=SUBTREE
"EOF"


cd /usr/ports/devel/git
make all install clean-depends clean
```

Wir installieren `ports-mgmt/portmaster` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/ports-mgmt_portmaster
cat << "EOF" > /var/db/ports/ports-mgmt_portmaster/options
_OPTIONS_READ=portmaster-3.23
_FILE_COMPLETE_OPTIONS_LIST=BASH ZSH
OPTIONS_FILE_SET+=BASH
OPTIONS_FILE_SET+=ZSH
"EOF"


cd /usr/ports/ports-mgmt/portmaster
make all install clean-depends clean
```

Wir installieren `sysutils/smartmontools` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/sysutils_smartmontools
cat << "EOF" > /var/db/ports/sysutils_smartmontools/options
_OPTIONS_READ=smartmontools-7.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"


cd /usr/ports/sysutils/smartmontools
make all install clean-depends clean
```

Wir konfigurieren `smartmontools`.

``` bash
sed 's/^DEVICESCAN/#DEVICESCAN/' /usr/local/etc/smartd.conf.sample > /usr/local/etc/smartd.conf
echo '/dev/nvme0 -d nvme -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf
echo '/dev/nvme1 -d nvme -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf


sysrc smartd_enable=YES
```

Die `/etc/periodic.conf` wird um folgenden Inhalt erweitert.

``` bash
cat << "EOF" >> /etc/periodic.conf
daily_status_smart_enable="YES"
daily_status_smart_devices="/dev/nvme0 /dev/nvme1"
"EOF"
```

Wir installieren `editors/nano` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/editors_nano
cat << "EOF" > /var/db/ports/editors_nano/options
_OPTIONS_READ=nano-7.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=NLS
"EOF"


cd /usr/ports/editors/nano
make all install clean-depends clean
```

Wir installieren `databases/sqlite3` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_sqlite3
cat << "EOF" > /var/db/ports/databases_sqlite3/options
_OPTIONS_READ=sqlite3-3.41.2
_FILE_COMPLETE_OPTIONS_LIST=ARMOR DBPAGE DBSTAT DIRECT_READ DQS EXAMPLES EXTENSION FTS3_TOKEN FTS4 FTS5 LIKENOTBLOB MEMMAN METADATA NORMALIZE NULL_TRIM RBU SECURE_DELETE SORT_REF STATIC STMT STRIP TCL THREADS TRUSTED_SCHEMA UNKNOWN_SQL UNLOCK_NOTIFY UPDATE_LIMIT URI URI_AUTHORITY TS0 TS1 TS2 TS3 STAT3 STAT4 LIBEDIT READLINE SESSION OFFSET SOUNDEX GEOPOLY RTREE RTREE_INT ICU UNICODE61
OPTIONS_FILE_UNSET+=ARMOR
OPTIONS_FILE_SET+=DBPAGE
OPTIONS_FILE_SET+=DBSTAT
OPTIONS_FILE_UNSET+=DIRECT_READ
OPTIONS_FILE_SET+=DQS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=EXTENSION
OPTIONS_FILE_SET+=FTS3_TOKEN
OPTIONS_FILE_SET+=FTS4
OPTIONS_FILE_SET+=FTS5
OPTIONS_FILE_UNSET+=LIKENOTBLOB
OPTIONS_FILE_UNSET+=MEMMAN
OPTIONS_FILE_SET+=METADATA
OPTIONS_FILE_UNSET+=NORMALIZE
OPTIONS_FILE_UNSET+=NULL_TRIM
OPTIONS_FILE_UNSET+=RBU
OPTIONS_FILE_SET+=SECURE_DELETE
OPTIONS_FILE_UNSET+=SORT_REF
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=STMT
OPTIONS_FILE_SET+=STRIP
OPTIONS_FILE_UNSET+=TCL
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=TRUSTED_SCHEMA
OPTIONS_FILE_UNSET+=UNKNOWN_SQL
OPTIONS_FILE_SET+=UNLOCK_NOTIFY
OPTIONS_FILE_UNSET+=UPDATE_LIMIT
OPTIONS_FILE_SET+=URI
OPTIONS_FILE_UNSET+=URI_AUTHORITY
OPTIONS_FILE_UNSET+=TS0
OPTIONS_FILE_SET+=TS1
OPTIONS_FILE_UNSET+=TS2
OPTIONS_FILE_UNSET+=TS3
OPTIONS_FILE_UNSET+=STAT3
OPTIONS_FILE_UNSET+=STAT4
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
OPTIONS_FILE_UNSET+=SESSION
OPTIONS_FILE_UNSET+=OFFSET
OPTIONS_FILE_UNSET+=SOUNDEX
OPTIONS_FILE_UNSET+=GEOPOLY
OPTIONS_FILE_SET+=RTREE
OPTIONS_FILE_UNSET+=RTREE_INT
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_SET+=UNICODE61
"EOF"


cd /usr/ports/databases/sqlite3
make all install clean-depends clean
```

Wir installieren `security/gnupg` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_pinentry
cat << "EOF" > /var/db/ports/security_pinentry/options
_OPTIONS_READ=pinentry-1.2.1
_FILE_COMPLETE_OPTIONS_LIST= EFL FLTK GNOME GTK2 NCURSES QT5 TTY
OPTIONS_FILE_UNSET+=EFL
OPTIONS_FILE_UNSET+=FLTK
OPTIONS_FILE_UNSET+=GNOME
OPTIONS_FILE_UNSET+=GTK2
OPTIONS_FILE_UNSET+=NCURSES
OPTIONS_FILE_UNSET+=QT5
OPTIONS_FILE_SET+=TTY
"EOF"

mkdir -p /var/db/ports/security_pinentry-tty
cat << "EOF" > /var/db/ports/security_pinentry-tty/options
_OPTIONS_READ=pinentry-tty-1.2.1
_FILE_COMPLETE_OPTIONS_LIST=LIBSECRET
OPTIONS_FILE_UNSET+=LIBSECRET
"EOF"

mkdir -p /var/db/ports/security_gnupg
cat << "EOF" > /var/db/ports/security_gnupg/options
_OPTIONS_READ=gnupg-2.3.8
_FILE_COMPLETE_OPTIONS_LIST=DOCS GNUTLS LARGE_RSA LDAP NLS SCDAEMON SUID_GPG WKS_SERVER
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_SET+=LARGE_RSA
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=SCDAEMON
OPTIONS_FILE_UNSET+=SUID_GPG
OPTIONS_FILE_UNSET+=WKS_SERVER
"EOF"


cd /usr/ports/security/gnupg
make all install clean-depends clean
```

Wir installieren `devel/subversion` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_apr1
cat << "EOF" > /var/db/ports/devel_apr1/options
_OPTIONS_READ=apr-1.7.3.1.6.3
_FILE_COMPLETE_OPTIONS_LIST=IPV6 BDB BDB5 SSL NSS GDBM LDAP MYSQL NDBM ODBC PGSQL SQLITE
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_UNSET+=BDB5
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=NSS
OPTIONS_FILE_UNSET+=GDBM
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=NDBM
OPTIONS_FILE_UNSET+=ODBC
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SQLITE
"EOF"

mkdir -p /var/db/ports/textproc_utf8proc
cat << "EOF" > /var/db/ports/textproc_utf8proc/options
_OPTIONS_READ=utf8proc-2.8.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/www_serf
cat << "EOF" > /var/db/ports/www_serf/options
_OPTIONS_READ=serf-1.3.9
_FILE_COMPLETE_OPTIONS_LIST=DOCS GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
"EOF"

mkdir -p /var/db/ports/devel_subversion
cat << "EOF" > /var/db/ports/devel_subversion/options
_OPTIONS_READ=subversion-1.14.2
_FILE_COMPLETE_OPTIONS_LIST=BDB DOCS GPG_AGENT NLS SASL SERF STATIC SVNSERVE_WRAPPER TEST TOOLS
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_SET+=DOCS
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

Wenn wir ein Programm nicht kennen, dann finden wir zu jedem Port eine Datei `pkg-descr`, die eine kurze Beschreibung sowie (meistens) einen Link zur Projekt-Homepage der Software enthält. Für `smartmontools` zum Beispiel würden wir die Beschreibung unter `/usr/ports/sysutils/smartmontools/pkg-descr` finden.

## Software updaten

???+ important

    Da wir die Pakete/Ports nicht als vorkompilierte Binary-Pakete installieren sondern selbst kompilieren, müssen wir natürlich auch die Updates der Ports selbst kompilieren. Um uns das dazu notwendige Auflösen der Abhängigkeiten und etwas Tipparbeit zu ersparen, überlassen wir dies künftig einfach einem kleinen Shell-Script. Dieses Script können wir einfach mittels `update-ports` ausführen und es erledigt dann folgende Arbeiten für uns:

- Aktualisieren des Portstree mittels `git`
- Anzeigen neuer Einträge in `/usr/ports/UPDATING`
- Ermitteln der zu aktualisierenden Ports und deren Abhängigkeiten
- Aktualisieren der Ports und Abhängigkeiten mittels portmaster
- Aufräumen des Portstree und der Distfiles mittels portmaster

``` bash
cat << "EOF" > /usr/local/sbin/update-ports
#!/bin/sh

git -C /usr/ports pull --rebase
make -C /usr/ports fetchindex

printf "\v================================================================================\v\n"

pkg updating -d `date -u -v-3m "+%Y%m%d"`

printf "\v================================================================================\v\n"

read -p "Update ports? [y/N] " REPLY

if [ "x$REPLY" != "xy" ]
then
  exit 0
fi

pkg check -Ba -da -sa -ra

portmaster --no-confirm --index-first -g -d -w -R -a -y

#portmaster --no-confirm --no-term-title --no-index-fetch --index-first --clean-distfiles -y

#portmaster --no-confirm --no-term-title --no-index-fetch --index-first --clean-packages -y

portmaster --no-confirm --no-term-title --no-index-fetch --index-first --check-depends -y

#portmaster --no-confirm --no-term-title --check-port-dbdir -y

exit 0
"EOF"

chmod 0755 /usr/local/sbin/update-ports
```

## Wie geht es weiter?

Viel Spass mit den neuen FreeBSD BaseTools.
