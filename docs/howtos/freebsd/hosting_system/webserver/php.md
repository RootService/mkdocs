---
title: 'PHP-FPM'
description: 'In diesem HowTo wird step-by-step die Installation von PHP-FPM für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-07'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# PHP-FPM

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- PHP 8.1.17 (PHP-FPM, Composer, PEAR)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `lang/php81` und dessen Abhängigkeiten.

``` bash
cat >> /etc/make.conf << "EOF"
#DEFAULT_VERSIONS+=php=8.1
"EOF"


mkdir -p /var/db/ports/lang_php81
cat > /var/db/ports/lang_php81/options << "EOF"
_OPTIONS_READ=php81-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=CGI CLI DEBUG DTRACE EMBED FPM IPV6 LINKTHR  MYSQLND PHPDBG ZTS
OPTIONS_FILE_SET+=CGI
OPTIONS_FILE_SET+=CLI
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DTRACE
OPTIONS_FILE_SET+=EMBED
OPTIONS_FILE_SET+=FPM
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=LINKTHR
OPTIONS_FILE_SET+=MYSQLND
OPTIONS_FILE_UNSET+=PHPDBG
OPTIONS_FILE_SET+=ZTS
"EOF"


cd /usr/ports/lang/php81
make all install clean-depends clean


sysrc php_fpm_enable=YES
```

## PHP-Extensions installieren

Wir installieren `lang/php81-extensions` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_php81-dba
cat > /var/db/ports/databases_php81-dba/options << "EOF"
_OPTIONS_READ=php81-dba-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=CDB DB4 FLATFILE GDBM INIFILE LMDB QDBM TOKYO
OPTIONS_FILE_SET+=CDB
OPTIONS_FILE_UNSET+=DB4
OPTIONS_FILE_SET+=FLATFILE
OPTIONS_FILE_UNSET+=GDBM
OPTIONS_FILE_SET+=INIFILE
OPTIONS_FILE_SET+=LMDB
OPTIONS_FILE_UNSET+=QDBM
OPTIONS_FILE_UNSET+=TOKYO
"EOF"

mkdir -p /var/db/ports/graphics_php81-gd
cat > /var/db/ports/graphics_php81-gd/options << "EOF"
_OPTIONS_READ=php81-gd-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=JIS WEBP X11
OPTIONS_FILE_UNSET+=JIS
OPTIONS_FILE_SET+=WEBP
OPTIONS_FILE_UNSET+=X11
"EOF"

mkdir -p /var/db/ports/print_freetype2
cat > /var/db/ports/print_freetype2/options << "EOF"
_OPTIONS_READ=freetype2-2.12.1
_FILE_COMPLETE_OPTIONS_LIST=BROTLI DEBUG DOCS LONG_PCF_NAMES PNG TABLE_VALIDATION LCD_FILTERING LCD_RENDERING FIX_SIZE_METRICS TT_SIZE_METRICS V38 V40
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=LONG_PCF_NAMES
OPTIONS_FILE_SET+=PNG
OPTIONS_FILE_UNSET+=TABLE_VALIDATION
OPTIONS_FILE_UNSET+=LCD_FILTERING
OPTIONS_FILE_SET+=LCD_RENDERING
OPTIONS_FILE_UNSET+=FIX_SIZE_METRICS
OPTIONS_FILE_UNSET+=TT_SIZE_METRICS
OPTIONS_FILE_UNSET+=V38
OPTIONS_FILE_SET+=V40
"EOF"

mkdir -p /var/db/ports/graphics_png
cat > /var/db/ports/graphics_png/options << "EOF"
_OPTIONS_READ=png-1.6.39
_FILE_COMPLETE_OPTIONS_LIST=APNG SIMD
OPTIONS_FILE_SET+=APNG
OPTIONS_FILE_SET+=SIMD
"EOF"

mkdir -p /var/db/ports/graphics_webp
cat > /var/db/ports/graphics_webp/options << "EOF"
_OPTIONS_READ=webp-1.3.0
_FILE_COMPLETE_OPTIONS_LIST=IMGCONV X11
OPTIONS_FILE_SET+=IMGCONV
OPTIONS_FILE_UNSET+=X11
"EOF"

mkdir -p /var/db/ports/graphics_giflib
cat > /var/db/ports/graphics_giflib/options << "EOF"
_OPTIONS_READ=giflib-5.2.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/graphics_tiff
cat > /var/db/ports/graphics_tiff/options << "EOF"
_OPTIONS_READ=tiff-4.4.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/graphics_jbigkit
cat > /var/db/ports/graphics_jbigkit/options << "EOF"
_OPTIONS_READ=jbigkit-2.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/graphics_jpeg-turbo
cat > /var/db/ports/graphics_jpeg-turbo/options << "EOF"
_OPTIONS_READ=jpeg-turbo-2.1.5.1
_FILE_COMPLETE_OPTIONS_LIST=DOCS OPTIMIZED_CFLAGS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=OPTIMIZED_CFLAGS
"EOF"

mkdir -p /var/db/ports/archivers_libdeflate
cat > /var/db/ports/archivers_libdeflate/options << "EOF"
_OPTIONS_READ=libdeflate-1.18
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/devel_nasm
cat > /var/db/ports/devel_nasm/options << "EOF"
_OPTIONS_READ=nasm-2.16.01
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/graphics_gd
cat > /var/db/ports/graphics_gd/options << "EOF"
_OPTIONS_READ=libgd-2.3.3
_FILE_COMPLETE_OPTIONS_LIST=PNG JPEG WEBP TIFF XPM HEIF AVIF LIQ FREETYPE FONTCONFIG RAQM ICONV
OPTIONS_FILE_SET+=PNG
OPTIONS_FILE_SET+=JPEG
OPTIONS_FILE_SET+=WEBP
OPTIONS_FILE_SET+=TIFF
OPTIONS_FILE_UNSET+=XPM
OPTIONS_FILE_UNSET+=HEIF
OPTIONS_FILE_UNSET+=AVIF
OPTIONS_FILE_UNSET+=LIQ
OPTIONS_FILE_SET+=FREETYPE
OPTIONS_FILE_SET+=FONTCONFIG
OPTIONS_FILE_UNSET+=RAQM
OPTIONS_FILE_SET+=ICONV
"EOF"

mkdir -p /var/db/ports/x11-fonts_fontconfig
cat > /var/db/ports/x11-fonts_fontconfig/options << "EOF"
_OPTIONS_READ=fontconfig-2.14.2
_FILE_COMPLETE_OPTIONS_LIST=BITMAPS DOCS NLS TEST HINTING_NONE HINTING_SLIGHT HINTING_MEDIUM HINTING_FULL
OPTIONS_FILE_SET+=BITMAPS
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=TEST
OPTIONS_FILE_UNSET+=HINTING_NONE
OPTIONS_FILE_SET+=HINTING_SLIGHT
OPTIONS_FILE_UNSET+=HINTING_MEDIUM
OPTIONS_FILE_UNSET+=HINTING_FULL
"EOF"

mkdir -p /var/db/ports/mail_php81-imap
cat > /var/db/ports/mail_php81-imap/options << "EOF"
_OPTIONS_READ=php81-imap-8.1.17
_FILE_COMPLETE_OPTIONS_LIST= CCLIENT PANDA
OPTIONS_FILE_UNSET+=CCLIENT
OPTIONS_FILE_SET+=PANDA
"EOF"

mkdir -p /var/db/ports/mail_panda-cclient
cat > /var/db/ports/mail_panda-cclient/options << "EOF"
_OPTIONS_READ=panda-cclient-20130621
_FILE_COMPLETE_OPTIONS_LIST=IPV6 MBX_DEFAULT SSL SSL_AND_PLAINTEXT
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=MBX_DEFAULT
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_UNSET+=SSL_AND_PLAINTEXT
"EOF"

mkdir -p /var/db/ports/converters_php81-mbstring
cat > /var/db/ports/converters_php81-mbstring/options << "EOF"
_OPTIONS_READ=php81-mbstring-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=REGEX
OPTIONS_FILE_SET+=REGEX
"EOF"

mkdir -p /var/db/ports/devel_oniguruma
cat > /var/db/ports/devel_oniguruma/options << "EOF"
_OPTIONS_READ=oniguruma-6.9.8
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
"EOF"

mkdir -p /var/db/ports/databases_php81-mysqli
cat > /var/db/ports/databases_php81-mysqli/options << "EOF"
_OPTIONS_READ=php81-mysqli-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=MYSQLND
OPTIONS_FILE_SET+=MYSQLND
"EOF"

mkdir -p /var/db/ports/databases_php81-pdo_mysql
cat > /var/db/ports/databases_php81-pdo_mysql/options << "EOF"
_OPTIONS_READ=php81-pdo_mysql-8.1.17
_FILE_COMPLETE_OPTIONS_LIST=MYSQLND
OPTIONS_FILE_SET+=MYSQLND
"EOF"

mkdir -p /var/db/ports/lang_php81-extensions
cat > /var/db/ports/lang_php81-extensions/options << "EOF"
_OPTIONS_READ=php81-extensions-1.1
_FILE_COMPLETE_OPTIONS_LIST=BCMATH BZ2 CALENDAR CTYPE CURL DBA DOM ENCHANT EXIF FFI FILEINFO FILTER FTP GD GETTEXT GMP ICONV IMAP INTL LDAP MBSTRING MYSQLI ODBC OPCACHE PCNTL PDO PDO_DBLIB PDO_FIREBIRD PDO_MYSQL PDO_ODBC PDO_PGSQL PDO_SQLITE PGSQL PHAR POSIX PSPELL READLINE SESSION SHMOP SIMPLEXML SNMP SOAP SOCKETS SODIUM SQLITE3 SYSVMSG SYSVSEM SYSVSHM TIDY TOKENIZER XML XMLREADER XMLWRITER XSL ZIP ZLIB
OPTIONS_FILE_SET+=BCMATH
OPTIONS_FILE_SET+=BZ2
OPTIONS_FILE_SET+=CALENDAR
OPTIONS_FILE_SET+=CTYPE
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_SET+=DBA
OPTIONS_FILE_SET+=DOM
OPTIONS_FILE_UNSET+=ENCHANT
OPTIONS_FILE_SET+=EXIF
OPTIONS_FILE_SET+=FFI
OPTIONS_FILE_SET+=FILEINFO
OPTIONS_FILE_SET+=FILTER
OPTIONS_FILE_SET+=FTP
OPTIONS_FILE_SET+=GD
OPTIONS_FILE_SET+=GETTEXT
OPTIONS_FILE_SET+=GMP
OPTIONS_FILE_SET+=ICONV
OPTIONS_FILE_SET+=IMAP
OPTIONS_FILE_SET+=INTL
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=MBSTRING
OPTIONS_FILE_SET+=MYSQLI
OPTIONS_FILE_UNSET+=ODBC
OPTIONS_FILE_SET+=OPCACHE
OPTIONS_FILE_SET+=PCNTL
OPTIONS_FILE_SET+=PDO
OPTIONS_FILE_UNSET+=PDO_DBLIB
OPTIONS_FILE_UNSET+=PDO_FIREBIRD
OPTIONS_FILE_SET+=PDO_MYSQL
OPTIONS_FILE_UNSET+=PDO_ODBC
OPTIONS_FILE_UNSET+=PDO_PGSQL
OPTIONS_FILE_SET+=PDO_SQLITE
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=PHAR
OPTIONS_FILE_SET+=POSIX
OPTIONS_FILE_UNSET+=PSPELL
OPTIONS_FILE_SET+=READLINE
OPTIONS_FILE_SET+=SESSION
OPTIONS_FILE_SET+=SHMOP
OPTIONS_FILE_SET+=SIMPLEXML
OPTIONS_FILE_UNSET+=SNMP
OPTIONS_FILE_SET+=SOAP
OPTIONS_FILE_SET+=SOCKETS
OPTIONS_FILE_SET+=SODIUM
OPTIONS_FILE_SET+=SQLITE3
OPTIONS_FILE_SET+=SYSVMSG
OPTIONS_FILE_SET+=SYSVSEM
OPTIONS_FILE_SET+=SYSVSHM
OPTIONS_FILE_UNSET+=TIDY
OPTIONS_FILE_SET+=TOKENIZER
OPTIONS_FILE_SET+=XML
OPTIONS_FILE_SET+=XMLREADER
OPTIONS_FILE_SET+=XMLWRITER
OPTIONS_FILE_SET+=XSL
OPTIONS_FILE_SET+=ZIP
OPTIONS_FILE_SET+=ZLIB
"EOF"


cd /usr/ports/lang/php81-extensions
make all install clean-depends clean
```

## Konfiguration

Die Konfiguration entspricht weitestgehend den Empfehlungen der PHP-Entwickler und ist sowohl auf Security als auch auf Performance getrimmt.

`php.ini` einrichten.

``` bash
cat > /usr/local/etc/php.ini << "EOF"
arg_separator.input = ";&"
arg_separator.output = "&amp;"
assert.active = "0"
cli_server.color = "1"
curl.cainfo = "/usr/local/share/certs/ca-root-nss.crt"
date.default_latitude = "53.5500"
date.default_longitude = "10.0000"
date.timezone = "Europe/Berlin"
display_errors = "0"
display_startup_errors = "0"
enable_dl = "0"
error_log = "/var/log/php_error.log"
error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT"
exif.encode_jis = "UTF-8"
exif.encode_unicode = "UTF-8"
expose_php = "0"
from = "anonymous@example.com"
html_errors = "0"
iconv.input_encoding = "UTF-8"
iconv.output_encoding = "UTF-8"
iconv.internal_encoding = "UTF-8"
input_encoding = "UTF-8"
internal_encoding = "UTF-8"
log_errors = "1"
mail.add_x_header = "1"
mail.log = "/var/log/php_sendmail.log"
max_execution_time = "60"
max_input_time = "60"
mbstring.detect_order = "auto"
mbstring.strict_detection = "1"
memory_limit = "512M"
opcache.enable_cli = "1"
opcache.enable_file_override = "1"
opcache.error_log = "/var/log/php_opcache.log"
opcache.interned_strings_buffer = "16"
opcache.log_verbosity_level = "2"
opcache.max_accelerated_files = "32768"
opcache.revalidate_freq = "60"
opcache.revalidate_path = "1"
openssl.cafile = "/usr/local/share/certs/ca-root-nss.crt"
output_buffering = "4096"
output_encoding = "UTF-8"
pcre.backtrack_limit = "8000000"
pdo_mysql.cache_size = "2000"
post_max_size = "511M"
register_argc_argv = "0"
request_order = "GP"
session.cookie_httponly = "1"
session.cookie_samesite = "Strict"
session.cookie_secure = "1"
session.gc_divisor = "1000"
session.save_path = "/data/www/tmp"
session.sid_bits_per_character = "6"
session.sid_length = "48"
session.use_strict_mode = "1"
short_open_tag = "0"
soap.wsdl_cache_dir = "/data/www/tmp"
sys_temp_dir = "/data/www/tmp"
upload_max_filesize = "511M"
upload_tmp_dir = "/data/www/tmp"
url_rewriter.tags = "a=href,area=href,frame=src,form=fakeentry,input=src"
user_ini.filename = None
variables_order = "GPCS"
zend.assertions = "-1"
zend.multibyte = "1"
zend.script_encoding = "UTF-8"
"EOF"
```

`php-fpm.conf` einrichten.

``` bash
sed -e 's|^;[[:space:]]*\(events.mechanism =\).*$|;\1 kqueue|' \
    /usr/local/etc/php-fpm.conf.default > /usr/local/etc/php-fpm.conf
```

`php-fpm.d/www.conf` einrichten.

``` bash
sed -e 's|^\(listen =\).*$|\1 /var/run/fpm_www.sock|' \
    -e 's|^;\(listen.owner =\).*$|\1 www|' \
    -e 's|^;\(listen.group =\).*$|\1 www|' \
    -e 's|^;\(listen.mode =\).*$|\1 0660|' \
    -e 's|^\(pm.max_children =\).*$|\1 128|' \
    -e 's|^\(pm.start_servers =\).*$|\1 16|' \
    -e 's|^\(pm.min_spare_servers =\).*$|\1 4|' \
    -e 's|^\(pm.max_spare_servers =\).*$|\1 16|' \
    -e 's|^;\(pm.max_requests =\).*$|\1 500|' \
    /usr/local/etc/php-fpm.d/www.conf.default > /usr/local/etc/php-fpm.d/www.conf
```

Abschliessende Arbeiten.

``` bash
touch /var/log/php_{error,opcache,sendmail}.log
chmod 0664 /var/log/php_{error,opcache,sendmail}.log
chown root:www /var/log/php_{error,opcache,sendmail}.log
```

## PHP Composer installieren

Wir installieren `devel/php-composer2` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_php-composer2
cat > /var/db/ports/devel_php-composer2/options << "EOF"
_OPTIONS_READ=php81-composer2-2.5.5
_FILE_COMPLETE_OPTIONS_LIST=CURL
OPTIONS_FILE_SET+=CURL
"EOF"


cd /usr/ports/devel/php-composer2
make all install clean-depends clean
```

## PHP-PEAR installieren

Wir installieren `devel/pear` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_pear
cat > /var/db/ports/devel_pear/options << "EOF"
_OPTIONS_READ=php81-pear-1.10.13
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"


cd /usr/ports/devel/pear
make all install clean-depends clean
```

## Abschluss

PHP-FPM kann nun gestartet werden.

``` bash
service php-fpm start
```
