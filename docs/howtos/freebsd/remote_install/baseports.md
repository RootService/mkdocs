---
title: 'BasePorts'
description: 'In diesem HowTo wird step-by-step die Installation einiger BasePorts für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
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
- TCL 8.6.14
- Python 3.9.19
- cURL 8.7.1
- Ruby 3.2.4
- Rust 1.78.0

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
cat <<'EOF' >> /etc/crontab
0       7       *       *       *       root    /usr/local/bin/git -C /usr/ports pull --rebase --quiet && /usr/bin/make -C /usr/ports fetchindex && /usr/local/sbin/pkg version -vIL= && /usr/local/sbin/pkg audit -F
EOF
```

Wir installieren `sysutils/cpu-microcode` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/sysutils_cpu-microcode-intel
cat <<'EOF' > /var/db/ports/sysutils_cpu-microcode-intel/options
_OPTIONS_READ=cpu-microcode-intel-20231114
_FILE_COMPLETE_OPTIONS_LIST=RC SPLIT
OPTIONS_FILE_SET+=RC
OPTIONS_FILE_SET+=SPLIT
EOF


cd /usr/ports/sysutils/cpu-microcode
make LICENSES_ACCEPTED=EULA config-recursive all install clean-depends clean


sysrc microcode_update_enable=YES
```

Wir installieren `lang/perl5.36` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=perl5=5.36
EOF


mkdir -p /var/db/ports/lang_perl5.36
cat <<'EOF' > /var/db/ports/lang_perl5.36/options
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
EOF


cd /usr/ports/lang/perl5.36
make all install clean-depends clean
```

Wir installieren `security/openssl` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
DEFAULT_VERSIONS+=ssl=openssl
EOF


mkdir -p /var/db/ports/security_openssl
cat <<'EOF' > /var/db/ports/security_openssl/options
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
EOF


cd /usr/ports/security/openssl
make all install clean-depends clean
```

Wir installieren `security/ca_root_nss` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_ca_root_nss
cat <<'EOF' > /var/db/ports/security_ca_root_nss/options
_OPTIONS_READ=ca_root_nss-3.93
_FILE_COMPLETE_OPTIONS_LIST=ETCSYMLINK
OPTIONS_FILE_SET+=ETCSYMLINK
EOF


cd /usr/ports/security/ca_root_nss
make all install clean-depends clean
```

Wir installieren `devel/pcre2` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_pkgconf
cat <<'EOF' > /var/db/ports/devel_pkgconf/options
_OPTIONS_READ=pkgconf-2.2.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_autoconf
cat <<'EOF' > /var/db/ports/devel_autoconf/options
_OPTIONS_READ=autoconf-2.72
_FILE_COMPLETE_OPTIONS_LIST=INFO
OPTIONS_FILE_UNSET+=INFO
EOF

mkdir -p /var/db/ports/devel_m4
cat <<'EOF' > /var/db/ports/devel_m4/options
_OPTIONS_READ=m4-1.4.19
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES INFO LIBSIGSEGV NLS
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_UNSET+=INFO
OPTIONS_FILE_UNSET+=LIBSIGSEGV
OPTIONS_FILE_SET+=NLS
EOF

mkdir -p /var/db/ports/devel_gettext-tools
cat <<'EOF' > /var/db/ports/devel_gettext-tools/options
_OPTIONS_READ=gettext-tools-0.22.5
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES THREADS
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_SET+=THREADS
EOF

mkdir -p /var/db/ports/devel_libtextstyle
cat <<'EOF' > /var/db/ports/devel_libtextstyle/options
_OPTIONS_READ=libtextstyle-0.22.5
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_gettext-runtime
cat <<'EOF' > /var/db/ports/devel_gettext-runtime/options
_OPTIONS_READ=gettext-runtime-0.22.5
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_gmake
cat <<'EOF' > /var/db/ports/devel_gmake/options
_OPTIONS_READ=gmake-4.4.1
_FILE_COMPLETE_OPTIONS_LIST=NLS
OPTIONS_FILE_SET+=NLS
EOF

mkdir -p /var/db/ports/devel_automake
cat <<'EOF' > /var/db/ports/devel_automake/options
_OPTIONS_READ=automake-1.16.5
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_pcre2
cat <<'EOF' > /var/db/ports/devel_pcre2/options
_OPTIONS_READ=pcre2-10.43
_FILE_COMPLETE_OPTIONS_LIST=DOCS LIBBZ2 LIBZ LIBEDIT READLINE
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=LIBBZ2
OPTIONS_FILE_SET+=LIBZ
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
EOF


cd /usr/ports/devel/pcre2
make all install clean-depends clean
```

Wir installieren `lang/lua54` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=lua=5.4
EOF


mkdir -p /var/db/ports/lang_lua54
cat <<'EOF' > /var/db/ports/lang_lua54/options
_OPTIONS_READ=lua54-5.4.6
_FILE_COMPLETE_OPTIONS_LIST= EDITNONE LIBEDIT_DL LIBEDIT READLINE DOCS ASSERT APICHECK
OPTIONS_FILE_UNSET+=EDITNONE
OPTIONS_FILE_SET+=LIBEDIT_DL
OPTIONS_FILE_UNSET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=ASSERT
OPTIONS_FILE_UNSET+=APICHECK
EOF


cd /usr/ports/lang/lua54
make all install clean-depends clean
```

Wir installieren `lang/tcl86` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=tcltk=8.6
EOF


mkdir -p /var/db/ports/lang_tcl86
cat <<'EOF' > /var/db/ports/lang_tcl86/options
_OPTIONS_READ=tcl86-8.6.14
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DTRACE TCLMAN THREADS TZDATA
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=TCLMAN
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_SET+=TZDATA
EOF


cd /usr/ports/lang/tcl86
make all install clean-depends clean
```

Wir installieren `lang/python39` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=python=3.9
#DEFAULT_VERSIONS+=python3=3.9
EOF


mkdir -p /var/db/ports/math_mpdecimal
cat <<'EOF' > /var/db/ports/math_mpdecimal/options
_OPTIONS_READ=mpdecimal-4.0.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_readline
cat <<'EOF' > /var/db/ports/devel_readline/options
_OPTIONS_READ=readline-8.2.10
_FILE_COMPLETE_OPTIONS_LIST=BRACKETEDPASTE DOCS
OPTIONS_FILE_SET+=BRACKETEDPASTE
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/lang_python39
cat <<'EOF' > /var/db/ports/lang_python39/options
_OPTIONS_READ=python39-3.9.19
_FILE_COMPLETE_OPTIONS_LIST=DEBUG IPV6 LIBMPDEC LTO NLS PYMALLOC FNV SIPHASH
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=LIBMPDEC
OPTIONS_FILE_UNSET+=LTO
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_SET+=PYMALLOC
OPTIONS_FILE_UNSET+=FNV
OPTIONS_FILE_UNSET+=SIPHASH
EOF


cd /usr/ports/lang/python3
make all install clean-depends clean

cd /usr/ports/lang/python
make all install clean-depends clean
```

Wir installieren `ftp/curl` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/archivers_brotli
cat <<'EOF' > /var/db/ports/archivers_brotli/options
_OPTIONS_READ=brotli-1.1.0
_FILE_COMPLETE_OPTIONS_LIST=STATIC
OPTIONS_FILE_UNSET+=STATIC
EOF

mkdir -p /var/db/ports/devel_cmake-core
cat <<'EOF' > /var/db/ports/devel_cmake-core/options
_OPTIONS_READ=cmake-core-3.29.3
_FILE_COMPLETE_OPTIONS_LIST=CPACK DOCS
OPTIONS_FILE_SET+=CPACK
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/textproc_expat2
cat <<'EOF' > /var/db/ports/textproc_expat2/options
_OPTIONS_READ=expat-2.6.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS STATIC TEST
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=TEST
EOF

mkdir -p /var/db/ports/devel_ninja
cat <<'EOF' > /var/db/ports/devel_ninja/options
_OPTIONS_READ=ninja-1.11.1
_FILE_COMPLETE_OPTIONS_LIST=BASH DOCS ZSH
OPTIONS_FILE_SET+=BASH
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=ZSH
EOF

mkdir -p /var/db/ports/archivers_zstd
cat <<'EOF' > /var/db/ports/archivers_zstd/options
_OPTIONS_READ=zstd-1.5.6
_FILE_COMPLETE_OPTIONS_LIST=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
EOF

mkdir -p /var/db/ports/archivers_liblz4
cat <<'EOF' > /var/db/ports/archivers_liblz4/options
_OPTIONS_READ=liblz4-1.9.4
_FILE_COMPLETE_OPTIONS_LIST=TEST
OPTIONS_FILE_UNSET+=TEST
EOF

mkdir -p /var/db/ports/security_libssh2
cat <<'EOF' > /var/db/ports/security_libssh2/options
_OPTIONS_READ=libssh2-1.11.0
_FILE_COMPLETE_OPTIONS_LIST=GCRYPT TRACE ZLIB
OPTIONS_FILE_UNSET+=GCRYPT
OPTIONS_FILE_UNSET+=TRACE
OPTIONS_FILE_SET+=ZLIB
EOF

mkdir -p /var/db/ports/dns_libpsl
cat <<'EOF' > /var/db/ports/dns_libpsl/options
_OPTIONS_READ=libpsl-0.21.5
_FILE_COMPLETE_OPTIONS_LIST= ICU IDN IDN2
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=IDN
OPTIONS_FILE_UNSET+=IDN2
EOF

mkdir -p /var/db/ports/security_rhash
cat <<'EOF' > /var/db/ports/security_rhash/options
_OPTIONS_READ=rhash-1.4.4
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=NLS
EOF

mkdir -p /var/db/ports/ftp_curl
cat <<'EOF' > /var/db/ports/ftp_curl/options
_OPTIONS_READ=curl-8.7.1
_FILE_COMPLETE_OPTIONS_LIST=ALTSVC BROTLI CA_BUNDLE COOKIES CURL_DEBUG DEBUG DOCS EXAMPLES IDN IPV6 NTLM PROXY PSL STATIC TLS_SRP ZSTD GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT GSSAPI_NONE CARES THREADED_RESOLVER GNUTLS OPENSSL WOLFSSL DICT FTP GOPHER HTTP HTTP2 IMAP LDAP LDAPS LIBSSH LIBSSH2 MQTT POP3 RTMP RTSP SMB SMTP TELNET TFTP WEBSOCKET
OPTIONS_FILE_SET+=ALTSVC
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=CA_BUNDLE
OPTIONS_FILE_SET+=COOKIES
OPTIONS_FILE_UNSET+=CURL_DEBUG
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXAMPLES
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
EOF


cd /usr/ports/ftp/curl
make all install clean-depends clean
```

Wir installieren `devel/py-pip` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_py-pip
cat <<'EOF' > /var/db/ports/devel_py-pip/options
_OPTIONS_READ=py39-pip-23.3.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF


cd /usr/ports/devel/py-pip
make all install clean-depends clean
```

Wir installieren `lang/ruby32` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=ruby=3.2
EOF


mkdir -p /var/db/ports/math_gmp
cat <<'EOF' > /var/db/ports/math_gmp/options
_OPTIONS_READ=gmp-6.3.0
_FILE_COMPLETE_OPTIONS_LIST=CPU_OPTS INFO
OPTIONS_FILE_UNSET+=CPU_OPTS
OPTIONS_FILE_UNSET+=INFO
EOF

mkdir -p /var/db/ports/lang_ruby32
cat <<'EOF' > /var/db/ports/lang_ruby32/options
_OPTIONS_READ=ruby-3.2.4
_FILE_COMPLETE_OPTIONS_LIST=CAPIDOCS DEBUG DOCS EXAMPLES GMP RDOC LIBEDIT READLINE
OPTIONS_FILE_UNSET+=CAPIDOCS
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_SET+=GMP
OPTIONS_FILE_UNSET+=RDOC
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=READLINE
EOF


cd /usr/ports/lang/ruby32
make all install clean-depends clean
```

Wir installieren `devel/ruby-gems` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_ruby-gems
cat <<'EOF' > /var/db/ports/devel_ruby-gems/options
_OPTIONS_READ=ruby31-gems-3.5.10
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF


cd /usr/ports/devel/ruby-gems
make all install clean-depends clean
```

Wir installieren `lang/rust` und dessen Abhängigkeiten.

``` bash
cat <<'EOF' >> /etc/make.conf
#DEFAULT_VERSIONS+=rust=rust
EOF


mkdir -p /var/db/ports/lang_rust
cat <<'EOF' > /var/db/ports/lang_rust/options
_OPTIONS_READ=rust-1.78.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS GDB LTO PORT_LLVM SOURCES WASM
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_UNSET+=GDB
OPTIONS_FILE_UNSET+=LTO
OPTIONS_FILE_UNSET+=PORT_LLVM
OPTIONS_FILE_SET+=SOURCES
OPTIONS_FILE_SET+=WASM
EOF


cd /usr/ports/lang/rust
make all install clean-depends clean
```

## Wie geht es weiter?

Viel Spass mit den neuen FreeBSD BasePorts.
