---
title: 'NGinx'
description: 'In diesem HowTo wird step-by-step die Installation des NGinx Webservers für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-07-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Olaf Uecker'
tags:
    - FreeBSD
    - NGinx
---

# NGinx

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird um folgende Dienste erweitert.

- NGinx 1.22.0 (HTTP/2, mod_brotli)

## Installation

???+ important

    Der Rest des HowTo ist derzeit nicht auf das Zusammenspiel mit NGinx abgestimmt, daher ist die Verwendung von Apache aktuell zu bevorzugen. NGinx bietet zudem auch keinen wirklichen Mehrwert gegenüber Apache, so dass Apache generell bevorzugt werden sollte. Die hier gezeigte Konfiguration ist nicht ausreichend getestet, enthält möglicherweise sicherheitsrelevante Fehler und ist daher vollkommen unsupportet. Die Verwendung von NGinx erfolgt daher ausschliesslich auf eigenes Risiko und ohne weitere Unterstützung durch dieses HowTo.

Wir installieren `www/nginx` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/www_nginx
cat > /var/db/ports/www_nginx/options << "EOF"
_OPTIONS_READ=nginx-1.22.0_5,2
_FILE_COMPLETE_OPTIONS_LIST=DEBUG DEBUGLOG DSO FILE_AIO IPV6 NJS THREADS WWW PCRE_ONE PCRE_TWO MAIL MAIL_IMAP MAIL_POP3 MAIL_SMTP MAIL_SSL GOOGLE_PERFTOOLS HTTP HTTP_ADDITION HTTP_AUTH_REQ  HTTP_CACHE HTTP_DAV HTTP_FLV HTTP_GUNZIP_FILTER HTTP_GZIP_STATIC  HTTP_IMAGE_FILTER HTTP_MP4 HTTP_PERL HTTP_RANDOM_INDEX HTTP_REALIP  HTTP_SECURE_LINK HTTP_SLICE HTTP_SLICE_AHEAD  HTTP_SSL HTTP_STATUS HTTP_SUB HTTP_XSLT HTTPV2 HTTPV2_AUTOTUNE  STREAM STREAM_SSL STREAM_SSL_PREREAD AJP AWS_AUTH BROTLI CACHE_PURGE CLOJURE CT DEVEL_KIT  ARRAYVAR DRIZZLE DYNAMIC_TLS DYNAMIC_HC DYNAMIC_UPSTREAM ECHO ENCRYPTSESSION  FORMINPUT GRIDFS HEADERS_MORE HTTP_ACCEPT_LANGUAGE  HTTP_AUTH_DIGEST HTTP_AUTH_JWT HTTP_AUTH_KRB5 HTTP_AUTH_LDAP  HTTP_AUTH_PAM HTTP_DAV_EXT HTTP_EVAL HTTP_FANCYINDEX HTTP_FOOTER  HTTP_GEOIP2 HTTP_IP2LOCATION HTTP_IP2PROXY HTTP_JSON_STATUS HTTP_MOGILEFS  HTTP_MP4_H264 HTTP_NOTICE HTTP_PUSH HTTP_PUSH_STREAM HTTP_REDIS  HTTP_RESPONSE HTTP_SUBS_FILTER HTTP_TARANTOOL HTTP_UPLOAD  HTTP_UPLOAD_PROGRESS HTTP_UPSTREAM_CHECK HTTP_UPSTREAM_FAIR  HTTP_UPSTREAM_STICKY HTTP_VIDEO_THUMBEXTRACTOR HTTP_ZIP ICONV LET LINK LUA  MEMC MODSECURITY3 NAXSI OPENTRACING PASSENGER POSTGRES RDS_CSV  RDS_JSON REDIS2 RTMP SET_MISC SFLOW SHIBBOLETH SLOWFS_CACHE  SMALL_LIGHT SRCACHE VOD VTS XSS WEBSOCKIFY
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=DEBUGLOG
OPTIONS_FILE_SET+=DSO
OPTIONS_FILE_SET+=FILE_AIO
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_UNSET+=NJS
OPTIONS_FILE_SET+=THREADS
OPTIONS_FILE_UNSET+=WWW
OPTIONS_FILE_UNSET+=PCRE_ONE
OPTIONS_FILE_SET+=PCRE_TWO
OPTIONS_FILE_UNSET+=MAIL
OPTIONS_FILE_UNSET+=MAIL_IMAP
OPTIONS_FILE_UNSET+=MAIL_POP3
OPTIONS_FILE_UNSET+=MAIL_SMTP
OPTIONS_FILE_UNSET+=MAIL_SSL
OPTIONS_FILE_UNSET+=GOOGLE_PERFTOOLS
OPTIONS_FILE_SET+=HTTP
OPTIONS_FILE_SET+=HTTP_ADDITION
OPTIONS_FILE_SET+=HTTP_AUTH_REQ
OPTIONS_FILE_SET+=HTTP_CACHE
OPTIONS_FILE_SET+=HTTP_DAV
OPTIONS_FILE_SET+=HTTP_FLV
OPTIONS_FILE_SET+=HTTP_GUNZIP_FILTER
OPTIONS_FILE_SET+=HTTP_GZIP_STATIC
OPTIONS_FILE_UNSET+=HTTP_IMAGE_FILTER
OPTIONS_FILE_SET+=HTTP_MP4
OPTIONS_FILE_UNSET+=HTTP_PERL
OPTIONS_FILE_SET+=HTTP_RANDOM_INDEX
OPTIONS_FILE_SET+=HTTP_REALIP
OPTIONS_FILE_SET+=HTTP_SECURE_LINK
OPTIONS_FILE_SET+=HTTP_SLICE
OPTIONS_FILE_UNSET+=HTTP_SLICE_AHEAD
OPTIONS_FILE_SET+=HTTP_SSL
OPTIONS_FILE_SET+=HTTP_STATUS
OPTIONS_FILE_SET+=HTTP_SUB
OPTIONS_FILE_UNSET+=HTTP_XSLT
OPTIONS_FILE_SET+=HTTPV2
OPTIONS_FILE_UNSET+=HTTPV2_AUTOTUNE
OPTIONS_FILE_SET+=STREAM
OPTIONS_FILE_SET+=STREAM_SSL
OPTIONS_FILE_SET+=STREAM_SSL_PREREAD
OPTIONS_FILE_UNSET+=AJP
OPTIONS_FILE_UNSET+=AWS_AUTH
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_UNSET+=CACHE_PURGE
OPTIONS_FILE_UNSET+=CLOJURE
OPTIONS_FILE_SET+=CT
OPTIONS_FILE_UNSET+=DEVEL_KIT
OPTIONS_FILE_UNSET+=ARRAYVAR
OPTIONS_FILE_UNSET+=DRIZZLE
OPTIONS_FILE_UNSET+=DYNAMIC_TLS
OPTIONS_FILE_UNSET+=DYNAMIC_HC
OPTIONS_FILE_UNSET+=DYNAMIC_UPSTREAM
OPTIONS_FILE_UNSET+=ECHO
OPTIONS_FILE_UNSET+=ENCRYPTSESSION
OPTIONS_FILE_UNSET+=FORMINPUT
OPTIONS_FILE_UNSET+=GRIDFS
OPTIONS_FILE_UNSET+=HEADERS_MORE
OPTIONS_FILE_UNSET+=HTTP_ACCEPT_LANGUAGE
OPTIONS_FILE_SET+=HTTP_AUTH_DIGEST
OPTIONS_FILE_UNSET+=HTTP_AUTH_JWT
OPTIONS_FILE_UNSET+=HTTP_AUTH_KRB5
OPTIONS_FILE_UNSET+=HTTP_AUTH_LDAP
OPTIONS_FILE_UNSET+=HTTP_AUTH_PAM
OPTIONS_FILE_UNSET+=HTTP_DAV_EXT
OPTIONS_FILE_UNSET+=HTTP_EVAL
OPTIONS_FILE_UNSET+=HTTP_FANCYINDEX
OPTIONS_FILE_UNSET+=HTTP_FOOTER
OPTIONS_FILE_UNSET+=HTTP_GEOIP2
OPTIONS_FILE_UNSET+=HTTP_IP2LOCATION
OPTIONS_FILE_UNSET+=HTTP_IP2PROXY
OPTIONS_FILE_UNSET+=HTTP_JSON_STATUS
OPTIONS_FILE_UNSET+=HTTP_MOGILEFS
OPTIONS_FILE_UNSET+=HTTP_MP4_H264
OPTIONS_FILE_UNSET+=HTTP_NOTICE
OPTIONS_FILE_UNSET+=HTTP_PUSH
OPTIONS_FILE_UNSET+=HTTP_PUSH_STREAM
OPTIONS_FILE_UNSET+=HTTP_REDIS
OPTIONS_FILE_UNSET+=HTTP_RESPONSE
OPTIONS_FILE_UNSET+=HTTP_SUBS_FILTER
OPTIONS_FILE_UNSET+=HTTP_TARANTOOL
OPTIONS_FILE_UNSET+=HTTP_UPLOAD
OPTIONS_FILE_UNSET+=HTTP_UPLOAD_PROGRESS
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_CHECK
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_FAIR
OPTIONS_FILE_UNSET+=HTTP_UPSTREAM_STICKY
OPTIONS_FILE_UNSET+=HTTP_VIDEO_THUMBEXTRACTOR
OPTIONS_FILE_UNSET+=HTTP_ZIP
OPTIONS_FILE_UNSET+=ICONV
OPTIONS_FILE_UNSET+=LET
OPTIONS_FILE_UNSET+=LINK
OPTIONS_FILE_UNSET+=LUA
OPTIONS_FILE_UNSET+=MEMC
OPTIONS_FILE_UNSET+=MODSECURITY3
OPTIONS_FILE_UNSET+=NAXSI
OPTIONS_FILE_UNSET+=OPENTRACING
OPTIONS_FILE_UNSET+=PASSENGER
OPTIONS_FILE_UNSET+=POSTGRES
OPTIONS_FILE_UNSET+=RDS_CSV
OPTIONS_FILE_UNSET+=RDS_JSON
OPTIONS_FILE_UNSET+=REDIS2
OPTIONS_FILE_UNSET+=RTMP
OPTIONS_FILE_UNSET+=SET_MISC
OPTIONS_FILE_UNSET+=SFLOW
OPTIONS_FILE_UNSET+=SHIBBOLETH
OPTIONS_FILE_UNSET+=SLOWFS_CACHE
OPTIONS_FILE_UNSET+=SMALL_LIGHT
OPTIONS_FILE_UNSET+=SRCACHE
OPTIONS_FILE_UNSET+=VOD
OPTIONS_FILE_UNSET+=VTS
OPTIONS_FILE_UNSET+=XSS
OPTIONS_FILE_UNSET+=WEBSOCKIFY
"EOF"


cd /usr/ports/www/nginx
make all install clean-depends clean


sysrc nginx_enable=YES
sysrc nginxlimits_enable=YES


mkdir -p /usr/local/etc/newsyslog.conf.d
cat >> /usr/local/etc/newsyslog.conf.d/nginx << "EOF"
/var/log/nginx/*.log                    644  13    *    $W6D0 JCG   /var/run/nginx.pid
/data/www/vhosts/*/logs/nginx_*_log     644  24    *    $M1D0 JCG   /var/run/nginx.pid
"EOF"
```

## Konfiguration

Verzeichnisse für die ersten VirtualHosts erstellen.

``` bash
mkdir -p /data/www/{cache,tmp}
chmod 1777 /data/www/{cache,tmp}
chown www:www /data/www/{cache,tmp}


mkdir -p /data/www/acme/.well-known

mkdir -p /data/www/vhosts/_{default,localhost}_/logs
mkdir -p /data/www/vhosts/_{default,localhost}_/data/.well-known
chmod 0750 /data/www/vhosts/_{default,localhost}_/data
chown www:www /data/www/vhosts/_{default,localhost}_/data

mkdir -p /data/www/vhosts/mail.example.com/logs
mkdir -p /data/www/vhosts/mail.example.com/data/.well-known
chmod 0750 /data/www/vhosts/mail.example.com/data
chown www:www /data/www/vhosts/mail.example.com/data

mkdir -p /data/www/vhosts/www.example.com/logs
mkdir -p /data/www/vhosts/www.example.com/data/.well-known
chmod 0750 /data/www/vhosts/www.example.com/data
chown www:www /data/www/vhosts/www.example.com/data
```

Die folgende Konfiguration verwendet für den localhost den Pfad `/data/www/vhosts/_localhost_`, für den Default-Host den Pfad `/data/www/vhosts/_default_` und für die regulären Virtual-Hosts den Pfad `/data/www/vhosts/sub.domain.tld`.

`nginx.conf` einrichten.

``` bash
cat > /usr/local/etc/nginx/nginx.conf << "EOF"
user  www  www;
load_module  /usr/local/libexec/nginx/ngx_http_brotli_filter_module.so;
load_module  /usr/local/libexec/nginx/ngx_http_brotli_static_module.so;
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include  mime.types;
    default_type  application/octet-stream;
    resolver  127.0.0.1;
    sendfile  on;
    tcp_nopush  on;
    keepalive_timeout  65;
    aio  on;
    deny  all;
    etag  off;
    charset  utf-8;
    charset_types  application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/schema+json application/vnd.geo+json application/x-javascript application/x-web-app-manifest+json application/xhtml+xml application/xml image/svg+xml text/cache-manifest text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
    gzip  on;
    gzip_vary  on;
    gzip_comp_level  6;
    gzip_types  application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/schema+json application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-javascript application/x-web-app-manifest+json application/xhtml+xml application/xml font/eot font/opentype image/bmp image/svg+xml image/vnd.microsoft.icon image/x-icon text/cache-manifest text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
    brotli  on;
    brotli_comp_level  6;
    brotli_types  application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/schema+json application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-javascript application/x-web-app-manifest+json application/xhtml+xml application/xml font/eot font/opentype image/bmp image/svg+xml image/vnd.microsoft.icon image/x-icon text/cache-manifest text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
    map $sent_http_content_type $expires {
        default                               30d;
        text/css                              7d;
        application/atom+xml                  1h;
        application/rdf+xml                   1h;
        application/rss+xml                   1h;
        application/xhtml+xml                 0;
        application/json                      0;
        application/ld+json                   0;
        application/schema+json               0;
        application/vnd.geo+json              0;
        application/xml                       0;
        text/xml                              0;
        image/vnd.microsoft.icon              7d;
        image/x-icon                          7d;
        text/html                             0;
        text/markdown                         0;
        application/javascript                7d;
        application/x-javascript              7d;
        text/javascript                       7d;
        application/manifest+json             7d;
        application/x-web-app-manifest+json   0;
        text/cache-manifest                   0;
        audio/ogg                             30d;
        image/bmp                             30d;
        image/gif                             30d;
        image/jpeg                            30d;
        image/png                             30d;
        image/svg+xml                         30d;
        image/webp                            30d;
        video/mp4                             30d;
        video/ogg                             30d;
        video/webm                            30d;
        application/vnd.ms-fontobject         30d;
        font/eot                              30d;
        font/opentype                         30d;
        application/x-font-ttf                30d;
        application/font-woff                 30d;
        application/x-font-woff               30d;
        font/woff                             30d;
        application/font-woff2                30d;
        text/x-cross-domain-policy            7d;
    }
    expires  $expires;
    include  vhosts.conf;
    ssl_stapling  on;
    ssl_session_tickets  off;
    ssl_session_timeout  10m;
    ssl_session_cache  shared:SSL:10m;
    ssl_protocols  TLSv1.2;
    ssl_ciphers  "TLSv1.2 +CHACHA20 +AESGCM !DH !AESCCM !ARIA !CAMELLIA !IDEA !PSK !RSA !SHA1 !SHA256 !SHA384 !kDHd !kDHr !kECDH !aDSS !aNULL";
    ssl_prefer_server_ciphers  on;
    include  vhosts-ssl.conf;
}
"EOF"
```

`vhosts.conf` einrichten.

``` bash
cat > /usr/local/etc/nginx/vhosts.conf << "EOF"
    server {
        listen  8080 default_server;
        server_name  localhost "";
        error_log  /data/www/vhosts/_localhost_/logs/nginx_error_log;
        access_log  /data/www/vhosts/_localhost_/logs/nginx_access_log  combined;
        root  /data/www/vhosts/_localhost_/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/_localhost_/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8080;
        server_name  devnull.example.com;
        error_log  /data/www/vhosts/_default_/logs/nginx_error_log;
        access_log  /data/www/vhosts/_default_/logs/nginx_access_log  combined;
        root  /data/www/vhosts/_default_/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/_default_/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8080;
        server_name  mail.example.com;
        error_log  /data/www/vhosts/mail.example.com/logs/nginx_error_log;
        access_log  /data/www/vhosts/mail.example.com/logs/nginx_access_log  combined;
        root  /data/www/vhosts/mail.example.com/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/mail.example.com/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8080;
        server_name  www.example.com;
        error_log  /data/www/vhosts/www.example.com/logs/nginx_error_log;
        access_log  /data/www/vhosts/www.example.com/logs/nginx_access_log  combined;
        root  /data/www/vhosts/www.example.com/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/www.example.com/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
"EOF"
```

`vhosts-ssl.conf` einrichten.

``` bash
cat > /usr/local/etc/nginx/vhosts-ssl.conf << "EOF"
    server {
        listen  8443 default_server ssl http2;
        server_name  localhost "";
        error_log  /data/www/vhosts/_localhost_/logs/nginx_ssl_error_log;
        access_log  /data/www/vhosts/_localhost_/logs/nginx_ssl_access_log  combined;
        ssl_certificate  /usr/local/etc/letsencrypt/live/devnull.example.com/fullchain.pem;
        ssl_certificate_key  /usr/local/etc/letsencrypt/live/devnull.example.com/privkey.pem;
        root  /data/www/vhosts/_localhost_/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        add_header  Public-Key-Pins "max-age=0; includeSubdomains"
        add_header  Strict-Transport-Security "max-age=15768000; includeSubdomains; preload"
        add_header  Expect-CT "max-age=0"
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/_localhost_/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8443 ssl http2;
        server_name  devnull.example.com;
        error_log  /data/www/vhosts/_default_/logs/nginx_ssl_error_log;
        access_log  /data/www/vhosts/_default_/logs/nginx_ssl_access_log  combined;
        ssl_certificate  /usr/local/etc/letsencrypt/live/devnull.example.com/fullchain.pem;
        ssl_certificate_key  /usr/local/etc/letsencrypt/live/devnull.example.com/privkey.pem;
        root  /data/www/vhosts/_default_/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        add_header  Public-Key-Pins "max-age=0; includeSubdomains"
        add_header  Strict-Transport-Security "max-age=15768000; includeSubdomains; preload"
        add_header  Expect-CT "max-age=0"
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/_default_/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8443 ssl http2;
        server_name  mail.example.com;
        error_log  /data/www/vhosts/mail.example.com/logs/nginx_ssl_error_log;
        access_log  /data/www/vhosts/mail.example.com/logs/nginx_ssl_access_log  combined;
        ssl_certificate  /usr/local/etc/letsencrypt/live/mail.example.com/fullchain.pem;
        ssl_certificate_key  /usr/local/etc/letsencrypt/live/mail.example.com/privkey.pem;
        root  /data/www/vhosts/www.example.com/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        add_header  Public-Key-Pins "max-age=0; includeSubdomains"
        add_header  Strict-Transport-Security "max-age=15768000; includeSubdomains; preload"
        add_header  Expect-CT "max-age=0"
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/mail.example.com/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
    server {
        listen  8443 ssl http2;
        server_name  www.example.com;
        error_log  /data/www/vhosts/www.example.com/logs/nginx_ssl_error_log;
        access_log  /data/www/vhosts/www.example.com/logs/nginx_ssl_access_log  combined;
        ssl_certificate  /usr/local/etc/letsencrypt/live/www.example.com/fullchain.pem;
        ssl_certificate_key  /usr/local/etc/letsencrypt/live/www.example.com/privkey.pem;
        root  /data/www/vhosts/www.example.com/data;
        index  index.html index.htm index.php;
        include  headers.conf;
        add_header  Public-Key-Pins "max-age=0; includeSubdomains"
        add_header  Strict-Transport-Security "max-age=15768000; includeSubdomains; preload"
        add_header  Expect-CT "max-age=0"
        location / {
            allow  all;
        }
        include  defaults.conf;
        location ~ ^(.+\.phps?)(/.*)?$ {
            fastcgi_pass  unix:/var/run/fpm_www.sock;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^(.+\.phps?)(/.*)?$;
            fastcgi_param  SCRIPT_FILENAME  /data/www/vhosts/www.example.com/data$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            include  fastcgi_params;
            allow  all;
        }
    }
"EOF"
```

`defaults.conf` und `headers.conf` einrichten.

``` bash
cat > /usr/local/etc/nginx/defaults.conf << "EOF"
        location ~* /?(.+/)*[\._] { return 403; }
        location ~* /?\.well-known { allow all; }
"EOF"

cat > /usr/local/etc/nginx/headers.conf << "EOF"
        add_header  Access-Control-Allow-Methods  "GET, POST, OPTIONS";
#        add_header  Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Accept-Encoding"
        add_header  Access-Control-Allow-Origin  "*";
        add_header  Access-Control-Max-Age  "600";
        add_header  Content-Security-Policy "\
block-all-mixed-content; \
upgrade-insecure-requests; \
default-src 'self' 'unsafe-inline' https: data: blob: mediastream:; \
script-src 'self' 'unsafe-inline' 'unsafe-eval' https: blob: mediastream:; \
form-action 'self' https:; \
frame-ancestors 'self'; \
sandbox allow-forms allow-modals allow-pointer-lock allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-top-navigation"
        add_header  Referrer-Policy  "strict-origin-when-cross-origin";
        add_header  Timing-Allow-Origin  "*";
        add_header  Upgrade-Insecure-Requests  "1";
        add_header  X-Content-Type-Options  "nosniff";
        add_header  X-DNS-Prefetch-Control  "on";
        add_header  X-Download-Options  "noopen";
        add_header  X-Frame-Options  "SAMEORIGIN";
        add_header  X-Permitted-Cross-Domain-Policies  "none";
        add_header  X-XSS-Protection  "1; mode=block";
"EOF"
```

## Abschluss

NGinx kann nun gestartet werden.

``` bash
service nginx start
```
