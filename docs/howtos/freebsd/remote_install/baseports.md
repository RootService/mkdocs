---
title: 'BasePorts'
description: 'In diesem HowTo wird step-by-step die Installation einiger BasePorts für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-02-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# BasePorts

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Installation einiger Ports (Packages / Pakete) welche auf keinem [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem auf einem dedizierten Server fehlen sollten.

Unsere BasePorts werden am Ende folgende Dienste umfassen.

- Perl 5.36.3
- OpenSSL 3.0.13
- LUA 5.4.6
- TCL 8.6.13
- Python 3.9.18
- Ruby 3.1.4

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Remote Installation](/howtos/freebsd/remote_install/)

## Einloggen und zu *root* werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_ed25519.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## Software installieren

???+ important

    An diesem Punkt müssen wir uns entscheiden, ob wir die Pakete/Ports in Zukunft bequem als vorkompiliertes Binary-Paket per `pkg install <category/portname>` mit den Default-Optionen installieren wollen oder ob wir die Optionen und somit auch den Funktionsumfang beziehungsweise die Features unserer Pakete/Ports selbst bestimmen wollen.

In diesem HowTo werden wir uns für die zweite Variante entscheiden, da uns dies viele Probleme durch unnötige oder fehlende Features und Abhängigkeiten ersparen wird. Andererseits verlieren wir dadurch den Komfort von `pkg` bei der Installation und den Updates der Pakete/Ports. Ebenso müssen wir zwangsweise für alle Pakete/Ports die gewünschten Optionen manuell setzen und die Pakete/Ports auch selbst kompilieren.

Dieses Vorgehen ist deutlich zeitaufwendiger und erfordert auch etwas mehr Wissen über die jeweiligen Pakete/Ports und deren Features, dafür entschädigt es uns aber mit einem schlankeren, schnelleren und stabileren System und bietet uns gegebenenfalls nützliche/erforderliche zusätzliche Funktionen und Sicherheitsfeatures. Auch die potentielle Gefahr für Sicherheitslücken sinkt dadurch, da wir unnütze Pakete/Ports gar nicht erst als Abhängigkeiten mitinstallieren müssen.

Wir deaktivieren also zuerst das Default-Repository von `pkg`, um versehentlichen Installationen von Binary-Paketen durch `pkg` vorzubeugen.

``` bash
mkdir -p /usr/local/etc/pkg/repos
sed -e 's|quarterly|latest|g' /etc/pkg/FreeBSD.conf > /usr/local/etc/pkg/repos/FreeBSD.conf
sed -e 's|\(enabled:\)[[:space:]]*yes|\1 no|g' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
```

So ganz ohne komfortable Tools ist das Basis-System etwas mühselig zu administrieren. Deshalb werden wir aus den Ports nun ein paar etwas häufiger benötigte Anwendungen installiert.

Die von uns jeweils gewünschten Build-Optionen der Ports legen wir dabei mittels der `options`-Files des Portkonfigurationsframeworks `OptionsNG` fest.

Dieser Cronjob prüft täglich um 7:00 Uhr ob es Updates für die installierten Pakete gibt und ob darin gegebenenfalls wichtige Sicherheitsupdates enthalten sind. Das Ergebnis wird automatisch per Mail an `root` (siehe `/etc/mail/aliases`) gesendet.

``` bash
cat << "EOF" >> /etc/crontab
0       7       *       *       *       root    /usr/local/bin/git -C /usr/ports pull --rebase --quiet && /usr/bin/make -C /usr/ports fetchindex && /usr/local/sbin/pkg version -vIL= && /usr/local/sbin/pkg audit -F
"EOF"
```

Wir installieren `sysutils/cpu-microcode-intel` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/sysutils_cpu-microcode-intel
cat << "EOF" > /var/db/ports/sysutils_cpu-microcode-intel/options
_OPTIONS_READ=cpu-microcode-intel-20231114
_FILE_COMPLETE_OPTIONS_LIST=RC SPLIT
OPTIONS_FILE_SET+=RC
OPTIONS_FILE_SET+=SPLIT
"EOF"


cd /usr/ports/sysutils/cpu-microcode-intel
make LICENSES_ACCEPTED=EULA config-recursive all install clean-depends clean


sysrc microcode_update_enable=YES
```

Wir installieren `lang/perl5.36` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=perl5=5.36
"EOF"


mkdir -p /var/db/ports/lang_perl5.36
cat << "EOF" > /var/db/ports/lang_perl5.36/options
_OPTIONS_READ=perl5-5.36.3
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


cd /usr/ports/lang/perl5.36
make all install clean-depends clean
```

Wir installieren `security/openssl` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
DEFAULT_VERSIONS+=ssl=openssl
"EOF"


mkdir -p /var/db/ports/security_openssl
cat << "EOF" > /var/db/ports/security_openssl/options
_OPTIONS_READ=openssl-3.0.13
_FILE_COMPLETE_OPTIONS_LIST=ASYNC CT KTLS MAN3 RFC3779 SHARED ZLIB ARIA DES GOST IDEA SM4 RC2 RC4 RC5 WEAK-SSL-CIPHERS MD2 MD4 MDC2 RMD160 SM2 SM3 FIPS LEGACY ASM SSE2 THREADS EC NEXTPROTONEG SCTP SSL3 TLS1 TLS1_1 TLS1_2
OPTIONS_FILE_SET+=ASYNC
OPTIONS_FILE_SET+=CT
OPTIONS_FILE_SET+=KTLS
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
OPTIONS_FILE_SET+=FIPS
OPTIONS_FILE_UNSET+=LEGACY
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
cat << "EOF" > /var/db/ports/security_ca_root_nss/options
_OPTIONS_READ=ca_root_nss-3.93
_FILE_COMPLETE_OPTIONS_LIST=ETCSYMLINK
OPTIONS_FILE_SET+=ETCSYMLINK
"EOF"


cd /usr/ports/security/ca_root_nss
make all install clean-depends clean
```

Wir installieren `devel/pcre2` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_pkgconf
cat << "EOF" > /var/db/ports/devel_pkgconf/options
_OPTIONS_READ=pkgconf-2.0.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_autoconf
cat << "EOF" > /var/db/ports/devel_autoconf/options
_OPTIONS_READ=autoconf-2.71
_FILE_COMPLETE_OPTIONS_LIST=INFO
OPTIONS_FILE_SET+=INFO
"EOF"

mkdir -p /var/db/ports/devel_m4
cat << "EOF" > /var/db/ports/devel_m4/options
_OPTIONS_READ=m4-1.4.19
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES INFO LIBSIGSEGV NLS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=INFO
OPTIONS_FILE_UNSET+=LIBSIGSEGV
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/converters_libiconv
cat << "EOF" > /var/db/ports/converters_libiconv/options
_OPTIONS_READ=libiconv-1.17
_FILE_COMPLETE_OPTIONS_LIST=DOCS ENCODINGS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ENCODINGS
"EOF"

mkdir -p /var/db/ports/print_texinfo
cat << "EOF" > /var/db/ports/print_texinfo/options
_OPTIONS_READ=texinfo-7.0.3
_FILE_COMPLETE_OPTIONS_LIST=NLS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/misc_help2man
cat << "EOF" > /var/db/ports/misc_help2man/options
_OPTIONS_READ=help2man-1.49.3
_FILE_COMPLETE_OPTIONS_LIST=NLS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_gettext-tools
cat << "EOF" > /var/db/ports/devel_gettext-tools/options
_OPTIONS_READ=gettext-tools-0.22.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES THREADS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=THREADS
"EOF"

mkdir -p /var/db/ports/devel_libtextstyle
cat << "EOF" > /var/db/ports/devel_libtextstyle/options
_OPTIONS_READ=libtextstyle-0.22.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_gettext-runtime
cat << "EOF" > /var/db/ports/devel_gettext-runtime/options
_OPTIONS_READ=gettext-runtime-0.22.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_gmake
cat << "EOF" > /var/db/ports/devel_gmake/options
_OPTIONS_READ=gmake-4.3
_FILE_COMPLETE_OPTIONS_LIST=NLS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_p5-Locale-libintl
cat << "EOF" > /var/db/ports/devel_p5-Locale-libintl/options
_OPTIONS_READ=p5-Locale-libintl-1.33
_FILE_COMPLETE_OPTIONS_LIST=NLS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_automake
cat << "EOF" > /var/db/ports/devel_automake/options
_OPTIONS_READ=automake-1.16.5
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_pcre2
cat << "EOF" > /var/db/ports/devel_pcre2/options
_OPTIONS_READ=pcre2-10.42
_FILE_COMPLETE_OPTIONS_LIST=DOCS LIBBZ2 LIBZ LIBEDIT READLINE
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=LIBBZ2
OPTIONS_FILE_SET+=LIBZ
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
"EOF"


cd /usr/ports/devel/pcre2
make all install clean-depends clean
```

Wir installieren `lang/lua54` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=lua=5.4
"EOF"


mkdir -p /var/db/ports/lang_lua54
cat << "EOF" > /var/db/ports/lang_lua54/options
_OPTIONS_READ=lua54-5.4.6
_FILE_COMPLETE_OPTIONS_LIST= EDITNONE LIBEDIT_DL LIBEDIT READLINE DOCS ASSERT APICHECK
OPTIONS_FILE_UNSET+=EDITNONE
OPTIONS_FILE_SET+=LIBEDIT_DL
OPTIONS_FILE_UNSET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=ASSERT
OPTIONS_FILE_UNSET+=APICHECK
"EOF"


cd /usr/ports/lang/lua54
make all install clean-depends clean
```

Wir installieren `lang/tcl86` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=tcltk=8.6
"EOF"


mkdir -p /var/db/ports/lang_tcl86
cat << "EOF" > /var/db/ports/lang_tcl86/options
_OPTIONS_READ=tcl86-8.6.13
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

Wir installieren `lang/python39` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=python=3.9
#DEFAULT_VERSIONS+=python3=3.9
"EOF"


mkdir -p /var/db/ports/math_mpdecimal
cat << "EOF" > /var/db/ports/math_mpdecimal/options
_OPTIONS_READ=mpdecimal-2.5.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_readline
cat << "EOF" > /var/db/ports/devel_readline/options
_OPTIONS_READ=readline-8.2.7
_FILE_COMPLETE_OPTIONS_LIST=BRACKETEDPASTE DOCS
OPTIONS_FILE_SET+=BRACKETEDPASTE
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/lang_python39
cat << "EOF" > /var/db/ports/lang_python39/options
_OPTIONS_READ=python39-3.9.18
_FILE_COMPLETE_OPTIONS_LIST=DEBUG IPV6 LIBMPDEC LTO NLS PYMALLOC FNV SIPHASH
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=LIBMPDEC
OPTIONS_FILE_UNSET+=LTO
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PYMALLOC
OPTIONS_FILE_UNSET+=FNV
OPTIONS_FILE_UNSET+=SIPHASH
"EOF"


cd /usr/ports/lang/python3
make all install clean-depends clean

cd /usr/ports/lang/python
make all install clean-depends clean
```

Wir installieren `devel/py-pip` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_py-beautifulsoup
cat << "EOF" > /var/db/ports/www_py-beautifulsoup/options
_OPTIONS_READ=py39-beautifulsoup-4.12.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_py-docutils
cat << "EOF" > /var/db/ports/textproc_py-docutils/options
_OPTIONS_READ=py39-docutils-0.19
_FILE_COMPLETE_OPTIONS_LIST=PYGMENTS
OPTIONS_FILE_SET+=PYGMENTS
"EOF"

mkdir -p /var/db/ports/www_py-requests
cat << "EOF" > /var/db/ports/www_py-requests/options
_OPTIONS_READ=py39-requests-2.31.0
_FILE_COMPLETE_OPTIONS_LIST=SOCKS
OPTIONS_FILE_SET+=SOCKS
"EOF"

mkdir -p /var/db/ports/net_py-urllib3
cat << "EOF" > /var/db/ports/net_py-urllib3/options
_OPTIONS_READ=py39-urllib3-1.26.18
_FILE_COMPLETE_OPTIONS_LIST=BROTLI SOCKS SSL
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=SOCKS
OPTIONS_FILE_SET+=SSL
"EOF"

mkdir -p /var/db/ports/devel_py-Jinja2
cat << "EOF" > /var/db/ports/devel_py-Jinja2/options
_OPTIONS_READ=py39-Jinja2-3.1.3
_FILE_COMPLETE_OPTIONS_LIST=BABEL EXAMPLES
OPTIONS_FILE_SET+=BABEL
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/devel_py-babel
cat << "EOF" > /var/db/ports/devel_py-babel/options
_OPTIONS_READ=py39-Babel-2.14.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_py-snowballstemmer
cat << "EOF" > /var/db/ports/textproc_py-snowballstemmer/options
_OPTIONS_READ=py39-snowballstemmer-2.2.0
_FILE_COMPLETE_OPTIONS_LIST=PYSTEMMER
OPTIONS_FILE_SET+=PYSTEMMER
"EOF"

mkdir -p /var/db/ports/devel_py-lxml
cat << "EOF" > /var/db/ports/devel_py-lxml/options
_OPTIONS_READ=py39-lxml-4.9.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_libxml2
cat << "EOF" > /var/db/ports/textproc_libxml2/options
_OPTIONS_READ=libxml2-2.10.4
_FILE_COMPLETE_OPTIONS_LIST=DOCS ICU MEM_DEBUG READLINE STATIC THREAD_ALLOC
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=MEM_DEBUG
OPTIONS_FILE_SET+=READLINE
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=THREAD_ALLOC
"EOF"

mkdir -p /var/db/ports/textproc_libxslt
cat << "EOF" > /var/db/ports/textproc_libxslt/options
_OPTIONS_READ=libxslt-1.1.37
_FILE_COMPLETE_OPTIONS_LIST=CRYPTO MEM_DEBUG STATIC
OPTIONS_FILE_SET+=CRYPTO
OPTIONS_FILE_UNSET+=MEM_DEBUG
OPTIONS_FILE_UNSET+=STATIC
"EOF"

mkdir -p /var/db/ports/security_libgcrypt
cat << "EOF" > /var/db/ports/security_libgcrypt/options
_OPTIONS_READ=libgcrypt-1.10.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS INFO STATIC
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=INFO
OPTIONS_FILE_UNSET+=STATIC
"EOF"

mkdir -p /var/db/ports/security_libgpg-error
cat << "EOF" > /var/db/ports/security_libgpg-error/options
_OPTIONS_READ=libgpg-error-1.47
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS TEST
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/devel_py-yaml
cat << "EOF" > /var/db/ports/devel_py-yaml/options
_OPTIONS_READ=py39-yaml-6.0.1
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES LIBYAML
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=LIBYAML
"EOF"

mkdir -p /var/db/ports/devel_py-pip
cat << "EOF" > /var/db/ports/devel_py-pip/options
_OPTIONS_READ=py39-pip-23.3.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"


cd /usr/ports/devel/py-pip
make all install clean-depends clean
```

Wir installieren `lang/ruby31` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=ruby=3.1
"EOF"


mkdir -p /var/db/ports/math_gmp
cat << "EOF" > /var/db/ports/math_gmp/options
_OPTIONS_READ=gmp-6.3.0
_FILE_COMPLETE_OPTIONS_LIST=CPU_OPTS
OPTIONS_FILE_UNSET+=CPU_OPTS
"EOF"

mkdir -p /var/db/ports/lang_ruby31
cat << "EOF" > /var/db/ports/lang_ruby31/options
_OPTIONS_READ=ruby-3.1.4
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


cd /usr/ports/lang/ruby31
make all install clean-depends clean
```

Wir installieren `devel/ruby-gems` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_ruby-gems
cat << "EOF" > /var/db/ports/devel_ruby-gems/options
_OPTIONS_READ=ruby31-gems-3.4.20
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"


cd /usr/ports/devel/ruby-gems
make all install clean-depends clean
```

## Wie geht es weiter?

Viel Spass mit den neuen FreeBSD BasePorts.
