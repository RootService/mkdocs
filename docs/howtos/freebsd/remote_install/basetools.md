---
title: 'BaseTools'
description: 'In diesem HowTo wird step-by-step die Installation einiger BaseTools für ein FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-06-20'
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

- Sudo 1.9.11
- cURL 7.83.1
- GIT 2.36.1
- Portmaster 3.23
- SMARTmontools 7.3
- Bash 5.1.16
- Nano 6.2
- w3m 0.5.3
- GnuPG 2.3.3
- GDBM 1.23
- SVN 1.14.2

## Einloggen und zu root werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## Software installieren

Wir installieren `security/sudo` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_sudo
cat > /var/db/ports/security_sudo/options << "EOF"
_OPTIONS_READ=sudo-1.9.11
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

Wir installieren `ftp/curl` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/archivers_brotli
cat > /var/db/ports/archivers_brotli/options << "EOF"
_OPTIONS_READ=brotli-1.0.9
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_libunistring
cat > /var/db/ports/devel_libunistring/options << "EOF"
_OPTIONS_READ=libunistring-1.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/security_libssh2
cat > /var/db/ports/security_libssh2/options << "EOF"
_OPTIONS_READ=libssh2-1.10.0
_FILE_COMPLETE_OPTIONS_LIST=GCRYPT TRACE ZLIB
OPTIONS_FILE_UNSET+=GCRYPT
OPTIONS_FILE_UNSET+=TRACE
OPTIONS_FILE_SET+=ZLIB
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

mkdir -p /var/db/ports/archivers_zstd
cat > /var/db/ports/archivers_zstd/options << "EOF"
_OPTIONS_READ=zstd-1.5.2
_FILE_COMPLETE_OPTIONS_LIST=LZ4 OPTIMIZED_CFLAGS TEST
OPTIONS_FILE_SET+=LZ4
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/devel_ninja
cat > /var/db/ports/devel_ninja/options << "EOF"
_OPTIONS_READ=ninja-1.10.2
_FILE_COMPLETE_OPTIONS_LIST=BASH DOCS ZSH
OPTIONS_FILE_SET+=BASH
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ZSH
"EOF"

mkdir -p /var/db/ports/archivers_liblz4
cat > /var/db/ports/archivers_liblz4/options << "EOF"
_OPTIONS_READ=liblz4-1.9.3
_FILE_COMPLETE_OPTIONS_LIST=TEST
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/ftp_curl
cat > /var/db/ports/ftp_curl/options << "EOF"
_OPTIONS_READ=curl-7.83.1
_FILE_COMPLETE_OPTIONS_LIST=ALTSVC BROTLI CA_BUNDLE COOKIES CURL_DEBUG DEBUG DOCS EXAMPLES IDN IPV6 NTLM PROXY PSL STATIC TLS_SRP ZSTD GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT GSSAPI_NONE CARES THREADED_RESOLVER GNUTLS OPENSSL WOLFSSL DICT FTP GOPHER HTTP HTTP2 IMAP LDAP LDAPS LIBSSH2 MQTT POP3 RTMP RTSP SMB SMTP TELNET TFTP
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
OPTIONS_FILE_SET+=NTLM
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_SET+=PSL
OPTIONS_FILE_SET+=STATIC
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
OPTIONS_FILE_UNSET+=DICT
OPTIONS_FILE_SET+=FTP
OPTIONS_FILE_UNSET+=GOPHER
OPTIONS_FILE_SET+=HTTP
OPTIONS_FILE_SET+=HTTP2
OPTIONS_FILE_UNSET+=IMAP
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LDAPS
OPTIONS_FILE_SET+=LIBSSH2
OPTIONS_FILE_UNSET+=MQTT
OPTIONS_FILE_UNSET+=POP3
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_SET+=RTSP
OPTIONS_FILE_UNSET+=SMB
OPTIONS_FILE_UNSET+=SMTP
OPTIONS_FILE_SET+=TELNET
OPTIONS_FILE_SET+=TFTP
"EOF"


cd /usr/ports/ftp/curl
make all install clean-depends clean
```

Wir installieren `devel/git` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_ruby-gems
cat > /var/db/ports/devel_ruby-gems/options << "EOF"
_OPTIONS_READ=ruby30-gems-3.3.16
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
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

mkdir -p /var/db/ports/shells_bash
cat > /var/db/ports/shells_bash/options << "EOF"
_OPTIONS_READ=bash-5.1.16
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
cat > /var/db/ports/devel_bison/options << "EOF"
_OPTIONS_READ=bison-3.8.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/misc_getopt
cat > /var/db/ports/misc_getopt/options << "EOF"
_OPTIONS_READ=getopt-1.1.6
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/textproc_libxml2
cat > /var/db/ports/textproc_libxml2/options << "EOF"
_OPTIONS_READ=libxml2-2.9.13
_FILE_COMPLETE_OPTIONS_LIST=DOCS ICU MEM_DEBUG READLINE THREAD_ALLOC
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=MEM_DEBUG
OPTIONS_FILE_SET+=READLINE
OPTIONS_FILE_UNSET+=THREAD_ALLOC
"EOF"

mkdir -p /var/db/ports/textproc_libxslt
cat > /var/db/ports/textproc_libxslt/options << "EOF"
_OPTIONS_READ=libxslt-1.1.35
_FILE_COMPLETE_OPTIONS_LIST=CRYPTO MEM_DEBUG
OPTIONS_FILE_SET+=CRYPTO
OPTIONS_FILE_UNSET+=MEM_DEBUG
"EOF"

mkdir -p /var/db/ports/security_libgcrypt
cat > /var/db/ports/security_libgcrypt/options << "EOF"
_OPTIONS_READ=libgcrypt-1.9.4
_FILE_COMPLETE_OPTIONS_LIST=DOCS INFO STATIC
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=INFO
OPTIONS_FILE_SET+=STATIC
"EOF"

mkdir -p /var/db/ports/security_libgpg-error
cat > /var/db/ports/security_libgpg-error/options << "EOF"
_OPTIONS_READ=libgpg-error-1.45
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS TEST
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/textproc_docbook-xsl
cat > /var/db/ports/textproc_docbook-xsl/options << "EOF"
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
OPTIONS_FILE_SET+=TESTS
OPTIONS_FILE_SET+=TOOLS
OPTIONS_FILE_SET+=WEBSITE
OPTIONS_FILE_SET+=XHTML11
"EOF"

mkdir -p /var/db/ports/textproc_xmlcatmgr
cat > /var/db/ports/textproc_xmlcatmgr/options << "EOF"
_OPTIONS_READ=xmlcatmgr-2.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/www_w3m
cat > /var/db/ports/www_w3m/options << "EOF"
_OPTIONS_READ=w3m-0.5.3.20220429
_FILE_COMPLETE_OPTIONS_LIST=DOCS INLINE_IMAGE JAPANESE KEY_LYNX NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=INLINE_IMAGE
OPTIONS_FILE_UNSET+=JAPANESE
OPTIONS_FILE_UNSET+=KEY_LYNX
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/devel_boehm-gc
cat > /var/db/ports/devel_boehm-gc/options << "EOF"
_OPTIONS_READ=boehm-gc-8.0.6
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DOCS
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_libatomic_ops
cat > /var/db/ports/devel_libatomic_ops/options << "EOF"
_OPTIONS_READ=libatomic_ops-7.6.12
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_expat2
cat > /var/db/ports/textproc_expat2/options << "EOF"
_OPTIONS_READ=expat-2.4.8
_FILE_COMPLETE_OPTIONS_LIST=DOCS STATIC TEST
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=STATIC
OPTIONS_FILE_UNSET+=TEST
"EOF"

mkdir -p /var/db/ports/security_p5-Authen-SASL
cat > /var/db/ports/security_p5-Authen-SASL/options << "EOF"
_OPTIONS_READ=p5-Authen-SASL-2.16
_FILE_COMPLETE_OPTIONS_LIST=KERBEROS
OPTIONS_FILE_UNSET+=KERBEROS
"EOF"

mkdir -p /var/db/ports/security_p5-IO-Socket-SSL
cat > /var/db/ports/security_p5-IO-Socket-SSL/options << "EOF"
_OPTIONS_READ=p5-IO-Socket-SSL-2.074
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES IDN IPV6
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=IDN
OPTIONS_FILE_SET+=IPV6
"EOF"

mkdir -p /var/db/ports/security_p5-Net-SSLeay
cat > /var/db/ports/security_p5-Net-SSLeay/options << "EOF"
_OPTIONS_READ=p5-Net-SSLeay-1.92
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/devel_git
cat > /var/db/ports/devel_git/options << "EOF"
_OPTIONS_READ=git-2.36.1
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
cat > /var/db/ports/ports-mgmt_portmaster/options << "EOF"
_OPTIONS_READ=portmaster-3.21
_FILE_COMPLETE_OPTIONS_LIST=BASH ZSH
OPTIONS_FILE_UNSET+=BASH
OPTIONS_FILE_UNSET+=ZSH
"EOF"


cd /usr/ports/ports-mgmt/portmaster
make all install clean-depends clean
```

Wir installieren `sysutils/smartmontools` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/sysutils_smartmontools
cat > /var/db/ports/sysutils_smartmontools/options << "EOF"
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
echo '/dev/nvd0 -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf
echo '/dev/nvd1 -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /usr/local/etc/smartd.conf

echo 'smartd_enable="YES"' >> /etc/rc.conf
```

Die `/etc/periodic.conf` wird um folgenden Inhalt erweitert.

``` bash
cat >> /etc/periodic.conf << "EOF"
daily_status_smart_enable="YES"
daily_status_smart_devices="/dev/nvd0 /dev/nvd1"
"EOF"
```

Wir installieren `editors/nano` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/editors_nano
cat > /var/db/ports/editors_nano/options << "EOF"
_OPTIONS_READ=nano-6.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=NLS
"EOF"


cd /usr/ports/editors/nano
make all install clean-depends clean
```

Wir installieren `security/gnupg` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_sqlite3
cat > /var/db/ports/databases_sqlite3/options << "EOF"
_OPTIONS_READ=sqlite3-3.38.5
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
OPTIONS_FILE_UNSET+=UNICODE61
"EOF"

mkdir -p /var/db/ports/security_pinentry
cat > /var/db/ports/security_pinentry/options << "EOF"
_OPTIONS_READ=pinentry-1.2.0
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
cat > /var/db/ports/security_pinentry-tty/options << "EOF"
_OPTIONS_READ=pinentry-tty-1.2.0
_FILE_COMPLETE_OPTIONS_LIST=LIBSECRET
OPTIONS_FILE_UNSET+=LIBSECRET
"EOF"

mkdir -p /var/db/ports/security_gnupg
cat > /var/db/ports/security_gnupg/options << "EOF"
_OPTIONS_READ=gnupg-2.3.3
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
mkdir -p /var/db/ports/databases_gdbm
cat > /var/db/ports/databases_gdbm/options << "EOF"
_OPTIONS_READ=gdbm-1.23
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

mkdir -p /var/db/ports/textproc_utf8proc
cat > /var/db/ports/textproc_utf8proc/options << "EOF"
_OPTIONS_READ=utf8proc-2.7.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_cmake
cat > /var/db/ports/devel_cmake/options << "EOF"
_OPTIONS_READ=cmake-3.23.2
_FILE_COMPLETE_OPTIONS_LIST=CPACK DOCS MANPAGES
OPTIONS_FILE_UNSET+=CPACK
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=MANPAGES
"EOF"

mkdir -p /var/db/ports/devel_py-Jinja2
cat > /var/db/ports/devel_py-Jinja2/options << "EOF"
_OPTIONS_READ=py38-Jinja2-3.0.1
_FILE_COMPLETE_OPTIONS_LIST=BABEL EXAMPLES
OPTIONS_FILE_SET+=BABEL
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/devel_py-babel
cat > /var/db/ports/devel_py-babel/options << "EOF"
_OPTIONS_READ=py38-Babel-2.10.2
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_py-docutils
cat > /var/db/ports/textproc_py-docutils/options << "EOF"
_OPTIONS_READ=py38-docutils-0.17.1
_FILE_COMPLETE_OPTIONS_LIST=PYGMENTS
OPTIONS_FILE_SET+=PYGMENTS
"EOF"

mkdir -p /var/db/ports/textproc_py-snowballstemmer
cat > /var/db/ports/textproc_py-snowballstemmer/options << "EOF"
_OPTIONS_READ=py38-snowballstemmer-2.2.0
_FILE_COMPLETE_OPTIONS_LIST=PYSTEMMER
OPTIONS_FILE_SET+=PYSTEMMER
"EOF"

mkdir -p /var/db/ports/www_py-requests
cat > /var/db/ports/www_py-requests/options << "EOF"
_OPTIONS_READ=py38-requests-2.28.0
_FILE_COMPLETE_OPTIONS_LIST=SOCKS
OPTIONS_FILE_SET+=SOCKS
"EOF"

mkdir -p /var/db/ports/net_py-urllib3
cat > /var/db/ports/net_py-urllib3/options << "EOF"
_OPTIONS_READ=py38-urllib3-1.26.9
_FILE_COMPLETE_OPTIONS_LIST=BROTLI SOCKS SSL
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=SOCKS
OPTIONS_FILE_SET+=SSL
"EOF"

mkdir -p /var/db/ports/devel_py-pyparsing
cat > /var/db/ports/devel_py-pyparsing/options << "EOF"
_OPTIONS_READ=py38-pyparsing-3.0.9
_FILE_COMPLETE_OPTIONS_LIST=DIAGRAMS
OPTIONS_FILE_UNSET+=DIAGRAMS
"EOF"

mkdir -p /var/db/ports/security_rhash
cat > /var/db/ports/security_rhash/options << "EOF"
_OPTIONS_READ=rhash-1.4.3
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
"EOF"

mkdir -p /var/db/ports/archivers_libarchive
cat > /var/db/ports/archivers_libarchive/options << "EOF"
_OPTIONS_READ=libarchive-3.6.1
_FILE_COMPLETE_OPTIONS_LIST=LZ4 LZO ZSTD OPENSSL MBEDTLS NETTLE
OPTIONS_FILE_SET+=LZ4
OPTIONS_FILE_SET+=LZO
OPTIONS_FILE_SET+=ZSTD
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_UNSET+=MBEDTLS
OPTIONS_FILE_UNSET+=NETTLE
"EOF"

mkdir -p /var/db/ports/archivers_lzo2
cat > /var/db/ports/archivers_lzo2/options << "EOF"
_OPTIONS_READ=lzo2-2.10_1
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/www_serf
cat > /var/db/ports/www_serf/options << "EOF"
_OPTIONS_READ=serf-1.3.9
_FILE_COMPLETE_OPTIONS_LIST=DOCS GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
"EOF"

mkdir -p /var/db/ports/devel_subversion
cat > /var/db/ports/devel_subversion/options << "EOF"
_OPTIONS_READ=subversion-1.14.2
_FILE_COMPLETE_OPTIONS_LIST=BDB DOCS FREEBSD_TEMPLATE GPG_AGENT NLS SASL SERF STATIC SVNSERVE_WRAPPER TEST TOOLS
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=FREEBSD_TEMPLATE
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
cat > /usr/local/sbin/update-ports << "EOF"
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
