---
title: 'BasePorts'
description: 'In diesem HowTo wird step-by-step die Installation einiger BasePorts für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
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
    - BasePorts
---

# BasePorts

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Installation einiger Ports (Packages / Pakete) welche auf keinem [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem auf einem dedizierten Server fehlen sollten.

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/remote_install/)

Unsere BasePorts werden am Ende folgende Dienste umfassen.

- Perl 5.32.1
- OpenSSL 1.1.1
- LUA 5.2.4
- TCL 8.6.11
- SQLite 3.34.1
- Python 3.7.10
- Berkeley DB 5.3.28
- Ruby 2.7.2
- SUDO 1.9.5

## Einloggen und zu *root* werden

``` powershell
putty -ssh -P 2222 -i "%USERPROFILE%\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## Portstree einrichten

Um unser Basissystem um sinnvolle Programme erweitern zu können, fehlt uns noch der sogenannte Portstree. Diesen laden wir uns nun mittels `portsnap` herunter (kann durchaus eine Stunde oder länger dauern).

``` bash
portsnap fetch extract
```

Damit ist der Portstree einsatzbereit. Um den Tree künftig zu aktualisieren genügt der folgende Befehl.

``` bash
portsnap fetch update
```

Wichtige Informationen zu neuen Paketversionen finden sich in `/usr/ports/UPDATING` und sollten dringend beachtet werden.

``` bash
less /usr/ports/UPDATING
```

## Software installieren

???+ important

    An diesem Punkt müssen wir uns entscheiden, ob wir die Pakete/Ports in Zukunft bequem als vorkompiliertes Binary-Paket per `pkg install <category/portname>` mit den Default-Optionen installieren wollen oder ob wir die Optionen und somit auch den Funktionsumfang beziehungsweise die Features unserer Pakete/Ports selbst bestimmen wollen.

In diesem HowTo werden wir uns für die zweite Variante entscheiden, da uns dies viele Probleme durch unnötige oder fehlende Features und Abhängigkeiten ersparen wird. Andererseits verlieren wir dadurch den Komfort von `pkg` bei der Installation und den Updates der Pakete/Ports. Ebenso müssen wir zwangsweise für alle Pakete/Ports die gewünschten Optionen manuell setzen und die Pakete/Ports auch selbst kompilieren.

Dieses Vorgehen ist deutlich zeitaufwendiger und erfordert auch etwas mehr Wissen über die jeweiligen Pakete/Ports und deren Features, dafür entschädigt es uns aber mit einem schlankeren, schnelleren und stabileren System und bietet uns gegebenenfalls nützliche/erforderliche zusätzliche Funktionen und Sicherheitsfeatures. Auch die potentielle Gefahr für Sicherheitslücken sinkt dadurch, da wir unnütze Pakete/Ports gar nicht erst als Abhängigkeiten mitinstallieren müssen.

Wir deaktivieren also zuerst das Default-Repository von `pkg`, um versehentlichen Installationen von Binary-Paketen durch `pkg` vorzubeugen.

``` bash
mkdir -p /usr/local/etc/pkg/repos
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
```

So ganz ohne komfortable Tools ist das Basis-System etwas mühselig zu administrieren. Deshalb werden wir aus den Ports nun ein paar etwas häufiger benötigte Anwendungen installiert.

Die von uns jeweils gewünschten Build-Optionen der Ports legen wir dabei mittels der `options`-Files des neuen Portkonfigurationsframeworks `OptionsNG` fest.

Wir installieren `ports-mgmt/pkg` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/ports-mgmt/pkg
make all install clean-depends clean

pkg check -B -d -a
```

Die `/etc/periodic.conf` wird um folgenden Inhalt erweitert.

``` bash
cat >> /etc/periodic.conf << "EOF"
daily_backup_pkg_enable="YES"
daily_status_pkg_changes_enable="YES"
weekly_status_pkg_enable="YES"
security_status_pkgaudit_enable="YES"
security_status_pkgchecksum_enable="YES"
"EOF"
```

Dieser Cronjob prüft täglich um 7:00 Uhr ob es Updates für die installierten Pakete gibt und ob darin gegebenenfalls wichtige Sicherheitsupdates enthalten sind. Das Ergebnis wird automatisch per Mail an `root` (siehe `/etc/mail/aliases`) gesendet.

``` bash
cat >> /etc/crontab << "EOF"
0       7       *       *       *       root    /usr/sbin/portsnap -I cron update && /usr/local/sbin/pkg version -vIL= && /usr/local/sbin/pkg audit -F
"EOF"
```

Wir installieren `sysutils/devcpu-data` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/sysutils/devcpu-data
make LICENSES_ACCEPTED=EULA config-recursive all install clean-depends clean

sed -e 's/^#\(cpu_microcode_\)/\1/g' -i '' /boot/loader.conf


echo 'microcode_update_enable="YES"' >> /etc/rc.conf
```

Wir installieren `devel/re2c` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/devel/re2c
make all install clean-depends clean
```

Wir installieren `devel/pcre` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_pcre
cat > /var/db/ports/devel_pcre/options << "EOF"
_OPTIONS_READ=pcre-8.44
_FILE_COMPLETE_OPTIONS_LIST=DOCS MAN3 STACK_RECURSION LIBEDIT READLINE
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=MAN3
OPTIONS_FILE_SET+=STACK_RECURSION
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
"EOF"


cd /usr/ports/devel/pcre
make all install clean-depends clean
```

Wir installieren `lang/perl5.30` und dessen Abhängigkeiten.

``` bash
cat >> /etc/make.conf << "EOF"
DEFAULT_VERSIONS+=perl5=5.32
"EOF"

mkdir -p /var/db/ports/lang_perl5.32
cat > /var/db/ports/lang_perl5.32/options << "EOF"
_OPTIONS_READ=perl5-5.32.1
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DOT_INC DTRACE GDBM MULTIPLICITY PERL_64BITINT PERL_MALLOC SITECUSTOMIZE THREADS
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DOT_INC
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_UNSET+=GDBM
OPTIONS_FILE_SET+=MULTIPLICITY
OPTIONS_FILE_SET+=PERL_64BITINT
OPTIONS_FILE_UNSET+=PERL_MALLOC
OPTIONS_FILE_UNSET+=SITECUSTOMIZE
OPTIONS_FILE_SET+=THREADS
"EOF"


cd /usr/ports/lang/perl5.32
make all install clean-depends clean
```

Wir installieren `security/openssl` und dessen Abhängigkeiten.

``` bash
cat >> /etc/make.conf << "EOF"
DEFAULT_VERSIONS+=ssl=openssl
"EOF"


mkdir -p /var/db/ports/security_openssl
cat > /var/db/ports/security_openssl/options << "EOF"
_OPTIONS_READ=openssl-1.1.1j
_FILE_COMPLETE_OPTIONS_LIST=ASYNC CT MAN3 RFC3779 SHARED ZLIB ARIA DES GOST IDEA SM4 RC2 RC4 RC5 WEAK-SSL-CIPHERS MD2 MD4 MDC2 RMD160 SM2 SM3 ASM SSE2 THREADS EC NEXTPROTONEG SCTP SSL3 TLS1 TLS1_1 TLS1_2
OPTIONS_FILE_SET+=ASYNC
OPTIONS_FILE_SET+=CT
OPTIONS_FILE_SET+=MAN3
OPTIONS_FILE_UNSET+=RFC3779
OPTIONS_FILE_SET+=SHARED
OPTIONS_FILE_UNSET+=ZLIB
OPTIONS_FILE_UNSET+=ARIA
OPTIONS_FILE_SET+=DES
OPTIONS_FILE_SET+=GOST
OPTIONS_FILE_UNSET+=IDEA
OPTIONS_FILE_UNSET+=SM4
OPTIONS_FILE_SET+=RC2
OPTIONS_FILE_SET+=RC4
OPTIONS_FILE_UNSET+=RC5
OPTIONS_FILE_UNSET+=WEAK-SSL-CIPHERS
OPTIONS_FILE_UNSET+=MD2
OPTIONS_FILE_SET+=MD4
OPTIONS_FILE_UNSET+=MDC2
OPTIONS_FILE_SET+=RMD160
OPTIONS_FILE_UNSET+=SM2
OPTIONS_FILE_UNSET+=SM3
OPTIONS_FILE_SET+=ASM
OPTIONS_FILE_SET+=SSE2
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_SET+=EC
OPTIONS_FILE_SET+=NEXTPROTONEG
OPTIONS_FILE_SET+=SCTP
OPTIONS_FILE_UNSET+=SSL3
OPTIONS_FILE_SET+=TLS1
OPTIONS_FILE_SET+=TLS1_1
OPTIONS_FILE_SET+=TLS1_2
"EOF"


cd /usr/ports/security/openssl
make all install clean-depends clean
```

Wir installieren `security/ca_root_nss` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_ca_root_nss
cat > /var/db/ports/security_ca_root_nss/options << "EOF"
_OPTIONS_READ=ca_root_nss-3.61
_FILE_COMPLETE_OPTIONS_LIST=ETCSYMLINK
OPTIONS_FILE_SET+=ETCSYMLINK
"EOF"


cd /usr/ports/security/ca_root_nss
make all install clean-depends clean
```

Wir installieren `lang/lua52` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/lang/lua52
make all install clean-depends clean
```

Wir installieren `lang/tcl86` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/lang_tcl86
cat > /var/db/ports/lang_tcl86/options << "EOF"
_OPTIONS_READ=tcl86-8.6.11
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DTRACE TCLMAN THREADS TZDATA
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=TCLMAN
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_SET+=TZDATA
"EOF"


cd /usr/ports/lang/tcl86
make all install clean-depends clean
```

Wir installieren `lang/python37` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_sqlite3
cat > /var/db/ports/databases_sqlite3/options << "EOF"
_OPTIONS_READ=sqlite3-3.34.1
_FILE_COMPLETE_OPTIONS_LIST=ARMOR DBPAGE DBSTAT DIRECT_READ DQS EXTENSION FTS3_TOKEN FTS4 FTS5 LIKENOTBLOB MEMMAN METADATA NORMALIZE NULL_TRIM RBU SECURE_DELETE SORT_REF STMT STSHELL THREADS TRUSTED_SCHEMA UNKNOWN_SQL UNLOCK_NOTIFY URI URI_AUTHORITY TS0 TS1 TS2 TS3 STAT3 STAT4 READLINE LIBEDIT JSON1 SESSION OFFSET SER1 SOUNDEX ICU UNICODE61 RTREE RTREE_INT GEOPOLY
OPTIONS_FILE_SET+=ARMOR
OPTIONS_FILE_SET+=DBPAGE
OPTIONS_FILE_SET+=DBSTAT
OPTIONS_FILE_SET+=DIRECT_READ
OPTIONS_FILE_SET+=DQS
OPTIONS_FILE_SET+=EXTENSION
OPTIONS_FILE_SET+=FTS3_TOKEN
OPTIONS_FILE_SET+=FTS4
OPTIONS_FILE_SET+=FTS5
OPTIONS_FILE_SET+=LIKENOTBLOB
OPTIONS_FILE_SET+=MEMMAN
OPTIONS_FILE_SET+=METADATA
OPTIONS_FILE_SET+=NORMALIZE
OPTIONS_FILE_SET+=NULL_TRIM
OPTIONS_FILE_SET+=RBU
OPTIONS_FILE_SET+=SECURE_DELETE
OPTIONS_FILE_SET+=SORT_REF
OPTIONS_FILE_SET+=STMT
OPTIONS_FILE_SET+=STSHELL
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=TRUSTED_SCHEMA
OPTIONS_FILE_UNSET+=UNKNOWN_SQL
OPTIONS_FILE_SET+=UNLOCK_NOTIFY
OPTIONS_FILE_SET+=URI
OPTIONS_FILE_SET+=URI_AUTHORITY
OPTIONS_FILE_UNSET+=TS0
OPTIONS_FILE_UNSET+=TS1
OPTIONS_FILE_SET+=TS2
OPTIONS_FILE_UNSET+=TS3
OPTIONS_FILE_UNSET+=STAT3
OPTIONS_FILE_SET+=STAT4
OPTIONS_FILE_UNSET+=READLINE
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_SET+=JSON1
OPTIONS_FILE_SET+=SESSION
OPTIONS_FILE_SET+=OFFSET
OPTIONS_FILE_SET+=SER1
OPTIONS_FILE_SET+=SOUNDEX
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=UNICODE61
OPTIONS_FILE_SET+=RTREE
OPTIONS_FILE_UNSET+=RTREE_INT
OPTIONS_FILE_UNSET+=GEOPOLY
"EOF"

mkdir -p /var/db/ports/lang_python37
cat > /var/db/ports/lang_python37/options << "EOF"
_OPTIONS_READ=python37-3.7.10
_FILE_COMPLETE_OPTIONS_LIST=DEBUG IPV6 NLS PYMALLOC FNV SIPHASH
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PYMALLOC
OPTIONS_FILE_UNSET+=FNV
OPTIONS_FILE_SET+=SIPHASH
"EOF"


cd /usr/ports/lang/python3
make all install clean-depends clean
```

Wir installieren `lang/python` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/lang/python
make all install clean-depends clean
```

Wir installieren `databases/py-bsddb3` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_db5
cat > /var/db/ports/databases_db5/options << "EOF"
_OPTIONS_READ=db5-5.3.28
_FILE_COMPLETE_OPTIONS_LIST=CRYPTO DEBUG DOCS JAVA L10N SQL TCL
OPTIONS_FILE_SET+=CRYPTO
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=JAVA
OPTIONS_FILE_UNSET+=L10N
OPTIONS_FILE_UNSET+=SQL
OPTIONS_FILE_UNSET+=TCL
"EOF"


cd /usr/ports/databases/py-bsddb3
make all install clean-depends clean
```

Wir installieren `lang/ruby27` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_m4
cat > /var/db/ports/devel_m4/options << "EOF"
_OPTIONS_READ=m4-1.4.18
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES LIBSIGSEGV
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=LIBSIGSEGV
"EOF"

mkdir -p /var/db/ports/converters_libiconv
cat > /var/db/ports/converters_libiconv/options << "EOF"
_OPTIONS_READ=libiconv-1.16
_FILE_COMPLETE_OPTIONS_LIST=DOCS ENCODINGS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ENCODINGS
"EOF"

mkdir -p /var/db/ports/math_gmp
cat > /var/db/ports/math_gmp/options << "EOF"
_OPTIONS_READ=gmp-6.2.1
_FILE_COMPLETE_OPTIONS_LIST=CPU_OPTS
OPTIONS_FILE_UNSET+=CPU_OPTS
"EOF"

mkdir -p /var/db/ports/lang_ruby27
cat > /var/db/ports/lang_ruby27/options << "EOF"
_OPTIONS_READ=ruby-2.7.2
_FILE_COMPLETE_OPTIONS_LIST=CAPIDOCS DEBUG DOCS EXAMPLES GMP RDOC LIBEDIT READLINE
OPTIONS_FILE_UNSET+=CAPIDOCS
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=GMP
OPTIONS_FILE_SET+=RDOC
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
"EOF"


cd /usr/ports/lang/ruby27
make all install clean-depends clean
```

Wir installieren `devel/ruby-gems` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/devel/ruby-gems
make all install clean-depends clean
```

Wir installieren `databases/ruby-bdb` und dessen Abhängigkeiten.

``` bash
cd /usr/ports/databases/ruby-bdb
make all install clean-depends clean
```

Wir installieren `devel/pcre2` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_pcre2
cat > /var/db/ports/devel_pcre2/options << "EOF"
_OPTIONS_READ=pcre2-10.36
_FILE_COMPLETE_OPTIONS_LIST=DOCS LIBEDIT READLINE
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
"EOF"


cd /usr/ports/devel/pcre2
make all install clean-depends clean
```

Wir installieren `security/sudo` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_sudo
cat > /var/db/ports/security_sudo/options << "EOF"
_OPTIONS_READ=sudo-1.9.5p2
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
OPTIONS_FILE_UNSET+=PAM
OPTIONS_FILE_UNSET+=PYTHON
OPTIONS_FILE_UNSET+=SSSD
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
"EOF"


cd /usr/ports/security/sudo
make all install clean-depends clean
```

## Wie geht es weiter?

Viel Spass mit den neuen FreeBSD BasePorts.
