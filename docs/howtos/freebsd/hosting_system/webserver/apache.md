---
title: 'Apache'
description: 'In diesem HowTo wird step-by-step die Installation des Apache Webservers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-02-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Apache

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- Apache 2.4.58 (MPM-Event, HTTP/2, mod_brotli)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `www/apache24` und dessen Abhängigkeiten.

``` bash
cat << "EOF" >> /etc/make.conf
#DEFAULT_VERSIONS+=apache=2.4
"EOF"


mkdir -p /var/db/ports/www_apache24
cat << "EOF" > /var/db/ports/www_apache24/options
_OPTIONS_READ=apache24-2.4.58
_FILE_COMPLETE_OPTIONS_LIST=ACCESS_COMPAT ACTIONS ALIAS ALLOWMETHODS ASIS AUTHNZ_FCGI AUTHNZ_LDAP AUTHN_ANON AUTHN_CORE AUTHN_DBD AUTHN_DBM AUTHN_FILE AUTHN_SOCACHE AUTHZ_CORE AUTHZ_DBD AUTHZ_DBM AUTHZ_GROUPFILE AUTHZ_HOST AUTHZ_OWNER AUTHZ_USER AUTH_BASIC AUTH_DIGEST AUTH_FORM AUTOINDEX BROTLI BUFFER CACHE CACHE_DISK CACHE_SOCACHE CERN_META CGI CGID CHARSET_LITE DATA DAV DAV_FS DAV_LOCK DBD DEFLATE DIALUP DIR DOCS DUMPIO ENV EXPIRES EXT_FILTER FILE_CACHE FILTER HEADERS HEARTBEAT HEARTMONITOR HTTP2 IDENT IMAGEMAP INCLUDE INFO IPV4_MAPPED LBMETHOD_BYBUSYNESS LBMETHOD_BYREQUESTS LBMETHOD_BYTRAFFIC LBMETHOD_HEARTBEAT LDAP LOGIO LOG_DEBUG LOG_FORENSIC LUA LUAJIT MACRO MD MIME MIME_MAGIC NEGOTIATION PROXY RATELIMIT REFLECTOR REMOTEIP REQTIMEOUT REQUEST REWRITE SED SESSION SETENVIF SLOTMEM_PLAIN SLOTMEM_SHM SOCACHE_DBM SOCACHE_DC SOCACHE_MEMCACHE SOCACHE_REDIS SOCACHE_SHMCB SPELING SSL STATUS SUBSTITUTE SUEXEC SUEXEC_SYSLOG UNIQUE_ID USERDIR USERTRACK VERSION VHOST_ALIAS WATCHDOG XML2ENC MPM_PREFORK MPM_WORKER MPM_EVENT MPM_SHARED PROXY_AJP PROXY_BALANCER PROXY_CONNECT PROXY_EXPRESS PROXY_FCGI  PROXY_HTTP2 PROXY_FDPASS PROXY_FTP PROXY_HCHECK PROXY_HTML PROXY_HTTP  PROXY_SCGI PROXY_UWSGI PROXY_WSTUNNEL  SESSION_COOKIE SESSION_CRYPTO SESSION_DBD  BUCKETEER CASE_FILTER CASE_FILTER_IN ECHO EXAMPLE_HOOKS EXAMPLE_IPC  OPTIONAL_FN_EXPORT OPTIONAL_FN_IMPORT OPTIONAL_HOOK_EXPORT  OPTIONAL_HOOK_IMPORT
OPTIONS_FILE_SET+=ACCESS_COMPAT
OPTIONS_FILE_SET+=ACTIONS
OPTIONS_FILE_SET+=ALIAS
OPTIONS_FILE_SET+=ALLOWMETHODS
OPTIONS_FILE_SET+=ASIS
OPTIONS_FILE_SET+=AUTHNZ_FCGI
OPTIONS_FILE_UNSET+=AUTHNZ_LDAP
OPTIONS_FILE_SET+=AUTHN_ANON
OPTIONS_FILE_SET+=AUTHN_CORE
OPTIONS_FILE_SET+=AUTHN_DBD
OPTIONS_FILE_SET+=AUTHN_DBM
OPTIONS_FILE_SET+=AUTHN_FILE
OPTIONS_FILE_SET+=AUTHN_SOCACHE
OPTIONS_FILE_SET+=AUTHZ_CORE
OPTIONS_FILE_SET+=AUTHZ_DBD
OPTIONS_FILE_SET+=AUTHZ_DBM
OPTIONS_FILE_SET+=AUTHZ_GROUPFILE
OPTIONS_FILE_SET+=AUTHZ_HOST
OPTIONS_FILE_SET+=AUTHZ_OWNER
OPTIONS_FILE_SET+=AUTHZ_USER
OPTIONS_FILE_SET+=AUTH_BASIC
OPTIONS_FILE_SET+=AUTH_DIGEST
OPTIONS_FILE_SET+=AUTH_FORM
OPTIONS_FILE_SET+=AUTOINDEX
OPTIONS_FILE_SET+=BROTLI
OPTIONS_FILE_SET+=BUFFER
OPTIONS_FILE_SET+=CACHE
OPTIONS_FILE_SET+=CACHE_DISK
OPTIONS_FILE_SET+=CACHE_SOCACHE
OPTIONS_FILE_SET+=CERN_META
OPTIONS_FILE_SET+=CGI
OPTIONS_FILE_SET+=CGID
OPTIONS_FILE_SET+=CHARSET_LITE
OPTIONS_FILE_SET+=DATA
OPTIONS_FILE_SET+=DAV
OPTIONS_FILE_SET+=DAV_FS
OPTIONS_FILE_SET+=DAV_LOCK
OPTIONS_FILE_SET+=DBD
OPTIONS_FILE_SET+=DEFLATE
OPTIONS_FILE_SET+=DIALUP
OPTIONS_FILE_SET+=DIR
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=DUMPIO
OPTIONS_FILE_SET+=ENV
OPTIONS_FILE_SET+=EXPIRES
OPTIONS_FILE_SET+=EXT_FILTER
OPTIONS_FILE_SET+=FILE_CACHE
OPTIONS_FILE_SET+=FILTER
OPTIONS_FILE_SET+=HEADERS
OPTIONS_FILE_SET+=HEARTBEAT
OPTIONS_FILE_SET+=HEARTMONITOR
OPTIONS_FILE_SET+=HTTP2
OPTIONS_FILE_UNSET+=IDENT
OPTIONS_FILE_SET+=IMAGEMAP
OPTIONS_FILE_SET+=INCLUDE
OPTIONS_FILE_SET+=INFO
OPTIONS_FILE_UNSET+=IPV4_MAPPED
OPTIONS_FILE_SET+=LBMETHOD_BYBUSYNESS
OPTIONS_FILE_SET+=LBMETHOD_BYREQUESTS
OPTIONS_FILE_SET+=LBMETHOD_BYTRAFFIC
OPTIONS_FILE_SET+=LBMETHOD_HEARTBEAT
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=LOGIO
OPTIONS_FILE_SET+=LOG_DEBUG
OPTIONS_FILE_SET+=LOG_FORENSIC
OPTIONS_FILE_UNSET+=LUA
OPTIONS_FILE_UNSET+=LUAJIT
OPTIONS_FILE_SET+=MACRO
OPTIONS_FILE_SET+=MD
OPTIONS_FILE_SET+=MIME
OPTIONS_FILE_SET+=MIME_MAGIC
OPTIONS_FILE_SET+=NEGOTIATION
OPTIONS_FILE_SET+=PROXY
OPTIONS_FILE_SET+=RATELIMIT
OPTIONS_FILE_SET+=REFLECTOR
OPTIONS_FILE_SET+=REMOTEIP
OPTIONS_FILE_SET+=REQTIMEOUT
OPTIONS_FILE_SET+=REQUEST
OPTIONS_FILE_SET+=REWRITE
OPTIONS_FILE_SET+=SED
OPTIONS_FILE_SET+=SESSION
OPTIONS_FILE_SET+=SETENVIF
OPTIONS_FILE_SET+=SLOTMEM_PLAIN
OPTIONS_FILE_SET+=SLOTMEM_SHM
OPTIONS_FILE_SET+=SOCACHE_DBM
OPTIONS_FILE_UNSET+=SOCACHE_DC
OPTIONS_FILE_SET+=SOCACHE_MEMCACHE
OPTIONS_FILE_UNSET+=SOCACHE_REDIS
OPTIONS_FILE_SET+=SOCACHE_SHMCB
OPTIONS_FILE_SET+=SPELING
OPTIONS_FILE_SET+=SSL
OPTIONS_FILE_SET+=STATUS
OPTIONS_FILE_SET+=SUBSTITUTE
OPTIONS_FILE_UNSET+=SUEXEC
OPTIONS_FILE_UNSET+=SUEXEC_SYSLOG
OPTIONS_FILE_SET+=UNIQUE_ID
OPTIONS_FILE_SET+=USERDIR
OPTIONS_FILE_SET+=USERTRACK
OPTIONS_FILE_SET+=VERSION
OPTIONS_FILE_SET+=VHOST_ALIAS
OPTIONS_FILE_SET+=WATCHDOG
OPTIONS_FILE_SET+=XML2ENC
OPTIONS_FILE_UNSET+=MPM_PREFORK
OPTIONS_FILE_UNSET+=MPM_WORKER
OPTIONS_FILE_SET+=MPM_EVENT
OPTIONS_FILE_SET+=MPM_SHARED
OPTIONS_FILE_SET+=PROXY_AJP
OPTIONS_FILE_SET+=PROXY_BALANCER
OPTIONS_FILE_SET+=PROXY_CONNECT
OPTIONS_FILE_SET+=PROXY_EXPRESS
OPTIONS_FILE_SET+=PROXY_FCGI
OPTIONS_FILE_SET+=PROXY_HTTP2
OPTIONS_FILE_SET+=PROXY_FDPASS
OPTIONS_FILE_SET+=PROXY_FTP
OPTIONS_FILE_SET+=PROXY_HCHECK
OPTIONS_FILE_SET+=PROXY_HTML
OPTIONS_FILE_SET+=PROXY_HTTP
OPTIONS_FILE_SET+=PROXY_SCGI
OPTIONS_FILE_SET+=PROXY_UWSGI
OPTIONS_FILE_SET+=PROXY_WSTUNNEL
OPTIONS_FILE_SET+=SESSION_COOKIE
OPTIONS_FILE_SET+=SESSION_CRYPTO
OPTIONS_FILE_SET+=SESSION_DBD
OPTIONS_FILE_UNSET+=BUCKETEER
OPTIONS_FILE_UNSET+=CASE_FILTER
OPTIONS_FILE_UNSET+=CASE_FILTER_IN
OPTIONS_FILE_UNSET+=ECHO
OPTIONS_FILE_UNSET+=EXAMPLE_HOOKS
OPTIONS_FILE_UNSET+=EXAMPLE_IPC
OPTIONS_FILE_UNSET+=OPTIONAL_FN_EXPORT
OPTIONS_FILE_UNSET+=OPTIONAL_FN_IMPORT
OPTIONS_FILE_UNSET+=OPTIONAL_HOOK_EXPORT
OPTIONS_FILE_UNSET+=OPTIONAL_HOOK_IMPORT
"EOF"


cd /usr/ports/www/apache24
make all install clean-depends clean


sysrc apache24_enable=YES
sysrc apache24limits_enable=YES
sysrc apache24_http_accept_enable=YES


mkdir -p /usr/local/etc/newsyslog.conf.d
cat << "EOF" >> /usr/local/etc/newsyslog.conf.d/apache24
/var/log/httpd-*.log                    644  13    *    $W6D0 JCG   /var/run/httpd.pid
/data/www/vhosts/*/logs/apache_*_log    644  24    *    $M1D0 JCG   /var/run/httpd.pid
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

`httpd.conf` einrichten.

``` bash
cat << "EOF" > /usr/local/etc/apache24/httpd.conf
ServerRoot "/usr/local"
PidFile "/var/run/httpd.pid"
LoadModule mpm_event_module libexec/apache24/mod_mpm_event.so
#LoadModule mpm_prefork_module libexec/apache24/mod_mpm_prefork.so
#LoadModule mpm_worker_module libexec/apache24/mod_mpm_worker.so
LoadModule authn_file_module libexec/apache24/mod_authn_file.so
#LoadModule authn_dbm_module libexec/apache24/mod_authn_dbm.so
#LoadModule authn_anon_module libexec/apache24/mod_authn_anon.so
#LoadModule authn_dbd_module libexec/apache24/mod_authn_dbd.so
#LoadModule authn_socache_module libexec/apache24/mod_authn_socache.so
LoadModule authn_core_module libexec/apache24/mod_authn_core.so
LoadModule authz_host_module libexec/apache24/mod_authz_host.so
LoadModule authz_groupfile_module libexec/apache24/mod_authz_groupfile.so
LoadModule authz_user_module libexec/apache24/mod_authz_user.so
#LoadModule authz_dbm_module libexec/apache24/mod_authz_dbm.so
#LoadModule authz_owner_module libexec/apache24/mod_authz_owner.so
#LoadModule authz_dbd_module libexec/apache24/mod_authz_dbd.so
LoadModule authz_core_module libexec/apache24/mod_authz_core.so
#LoadModule authnz_fcgi_module libexec/apache24/mod_authnz_fcgi.so
#LoadModule access_compat_module libexec/apache24/mod_access_compat.so
LoadModule auth_basic_module libexec/apache24/mod_auth_basic.so
#LoadModule auth_form_module libexec/apache24/mod_auth_form.so
LoadModule auth_digest_module libexec/apache24/mod_auth_digest.so
LoadModule allowmethods_module libexec/apache24/mod_allowmethods.so
#LoadModule file_cache_module libexec/apache24/mod_file_cache.so
LoadModule cache_module libexec/apache24/mod_cache.so
LoadModule cache_disk_module libexec/apache24/mod_cache_disk.so
LoadModule cache_socache_module libexec/apache24/mod_cache_socache.so
LoadModule socache_shmcb_module libexec/apache24/mod_socache_shmcb.so
LoadModule socache_dbm_module libexec/apache24/mod_socache_dbm.so
#LoadModule socache_memcache_module libexec/apache24/mod_socache_memcache.so
#LoadModule watchdog_module libexec/apache24/mod_watchdog.so
#LoadModule macro_module libexec/apache24/mod_macro.so
#LoadModule dbd_module libexec/apache24/mod_dbd.so
#LoadModule dumpio_module libexec/apache24/mod_dumpio.so
LoadModule buffer_module libexec/apache24/mod_buffer.so
#LoadModule data_module libexec/apache24/mod_data.so
#LoadModule ratelimit_module libexec/apache24/mod_ratelimit.so
LoadModule reqtimeout_module libexec/apache24/mod_reqtimeout.so
#LoadModule ext_filter_module libexec/apache24/mod_ext_filter.so
#LoadModule request_module libexec/apache24/mod_request.so
#LoadModule include_module libexec/apache24/mod_include.so
LoadModule filter_module libexec/apache24/mod_filter.so
#LoadModule reflector_module libexec/apache24/mod_reflector.so
LoadModule substitute_module libexec/apache24/mod_substitute.so
#LoadModule sed_module libexec/apache24/mod_sed.so
#LoadModule charset_lite_module libexec/apache24/mod_charset_lite.so
LoadModule deflate_module libexec/apache24/mod_deflate.so
LoadModule xml2enc_module libexec/apache24/mod_xml2enc.so
LoadModule proxy_html_module libexec/apache24/mod_proxy_html.so
LoadModule brotli_module libexec/apache24/mod_brotli.so
LoadModule mime_module libexec/apache24/mod_mime.so
LoadModule log_config_module libexec/apache24/mod_log_config.so
#LoadModule log_debug_module libexec/apache24/mod_log_debug.so
#LoadModule log_forensic_module libexec/apache24/mod_log_forensic.so
#LoadModule logio_module libexec/apache24/mod_logio.so
LoadModule env_module libexec/apache24/mod_env.so
#LoadModule mime_magic_module libexec/apache24/mod_mime_magic.so
#LoadModule cern_meta_module libexec/apache24/mod_cern_meta.so
LoadModule expires_module libexec/apache24/mod_expires.so
LoadModule headers_module libexec/apache24/mod_headers.so
#LoadModule usertrack_module libexec/apache24/mod_usertrack.so
LoadModule unique_id_module libexec/apache24/mod_unique_id.so
LoadModule setenvif_module libexec/apache24/mod_setenvif.so
LoadModule version_module libexec/apache24/mod_version.so
#LoadModule remoteip_module libexec/apache24/mod_remoteip.so
LoadModule proxy_module libexec/apache24/mod_proxy.so
#LoadModule proxy_connect_module libexec/apache24/mod_proxy_connect.so
#LoadModule proxy_ftp_module libexec/apache24/mod_proxy_ftp.so
LoadModule proxy_http_module libexec/apache24/mod_proxy_http.so
LoadModule proxy_fcgi_module libexec/apache24/mod_proxy_fcgi.so
#LoadModule proxy_scgi_module libexec/apache24/mod_proxy_scgi.so
#LoadModule proxy_uwsgi_module libexec/apache24/mod_proxy_uwsgi.so
#LoadModule proxy_fdpass_module libexec/apache24/mod_proxy_fdpass.so
#LoadModule proxy_wstunnel_module libexec/apache24/mod_proxy_wstunnel.so
#LoadModule proxy_ajp_module libexec/apache24/mod_proxy_ajp.so
#LoadModule proxy_balancer_module libexec/apache24/mod_proxy_balancer.so
#LoadModule proxy_express_module libexec/apache24/mod_proxy_express.so
#LoadModule proxy_hcheck_module libexec/apache24/mod_proxy_hcheck.so
#LoadModule session_module libexec/apache24/mod_session.so
#LoadModule session_cookie_module libexec/apache24/mod_session_cookie.so
#LoadModule session_crypto_module libexec/apache24/mod_session_crypto.so
#LoadModule session_dbd_module libexec/apache24/mod_session_dbd.so
#LoadModule slotmem_shm_module libexec/apache24/mod_slotmem_shm.so
#LoadModule slotmem_plain_module libexec/apache24/mod_slotmem_plain.so
LoadModule ssl_module libexec/apache24/mod_ssl.so
#LoadModule dialup_module libexec/apache24/mod_dialup.so
LoadModule http2_module libexec/apache24/mod_http2.so
LoadModule proxy_http2_module libexec/apache24/mod_proxy_http2.so
#LoadModule md_module libexec/apache24/mod_md.so
#LoadModule lbmethod_byrequests_module libexec/apache24/mod_lbmethod_byrequests.so
#LoadModule lbmethod_bytraffic_module libexec/apache24/mod_lbmethod_bytraffic.so
#LoadModule lbmethod_bybusyness_module libexec/apache24/mod_lbmethod_bybusyness.so
#LoadModule lbmethod_heartbeat_module libexec/apache24/mod_lbmethod_heartbeat.so
LoadModule unixd_module libexec/apache24/mod_unixd.so
#LoadModule heartbeat_module libexec/apache24/mod_heartbeat.so
#LoadModule heartmonitor_module libexec/apache24/mod_heartmonitor.so
#LoadModule dav_module libexec/apache24/mod_dav.so
LoadModule status_module libexec/apache24/mod_status.so
#LoadModule autoindex_module libexec/apache24/mod_autoindex.so
#LoadModule asis_module libexec/apache24/mod_asis.so
LoadModule info_module libexec/apache24/mod_info.so
<IfModule !mpm_prefork_module>
    LoadModule cgid_module libexec/apache24/mod_cgid.so
</IfModule>
<IfModule mpm_prefork_module>
    LoadModule cgi_module libexec/apache24/mod_cgi.so
</IfModule>
#LoadModule dav_fs_module libexec/apache24/mod_dav_fs.so
#LoadModule dav_lock_module libexec/apache24/mod_dav_lock.so
#LoadModule vhost_alias_module libexec/apache24/mod_vhost_alias.so
LoadModule negotiation_module libexec/apache24/mod_negotiation.so
LoadModule dir_module libexec/apache24/mod_dir.so
#LoadModule imagemap_module libexec/apache24/mod_imagemap.so
#LoadModule actions_module libexec/apache24/mod_actions.so
#LoadModule speling_module libexec/apache24/mod_speling.so
#LoadModule userdir_module libexec/apache24/mod_userdir.so
LoadModule alias_module libexec/apache24/mod_alias.so
LoadModule rewrite_module libexec/apache24/mod_rewrite.so
<IfModule mpm_prefork_module>
    StartServers             16
    MinSpareServers          32
    MaxSpareServers          64
    MaxRequestWorkers       256
    MaxConnectionsPerChild 5000
</IfModule>
<IfModule mpm_worker_module>
    StartServers             16
    ServerLimit              64
    ThreadsPerChild          64
    ThreadLimit             128
    MinSpareThreads         128
    MaxSpareThreads         256
    MaxRequestWorkers      1024
    MaxConnectionsPerChild 5000
</IfModule>
<IfModule mpm_event_module>
    StartServers             16
    ServerLimit              64
    ThreadsPerChild          64
    ThreadLimit             128
    MinSpareThreads         128
    MaxSpareThreads         256
    MaxRequestWorkers      1024
    MaxConnectionsPerChild 5000
</IfModule>
<IfModule unixd_module>
    User www
    Group www
</IfModule>
TraceEnable off
HttpProtocolOptions Strict LenientMethods Require1.0
<IfModule http2_module>
    Protocols h2 http/1.1
    ProtocolsHonorOrder On
    H2Padding 2
    H2EarlyHints On
    H2PushPriority * After 16
    H2PushPriority text/javascript Interleaved
    H2PushPriority text/css Interleaved
</IfModule>
<IfModule log_config_module>
    <IfModule logio_module>
        LogFormat "%v %a %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    LogFormat "%v %a %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%v %a %h %l %u %t \"%r\" %>s %b" common
    <IfModule ssl_module>
        <IfModule logio_module>
            LogFormat "%v %a %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O %{SSL_PROTOCOL}x %{SSL_CIPHER}x" combinediossl
        </IfModule>
        LogFormat "%v %a %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %{SSL_PROTOCOL}x %{SSL_CIPHER}x" combinedssl
        LogFormat "%v %a %h %l %u %t \"%r\" %>s %b %{SSL_PROTOCOL}x %{SSL_CIPHER}x" commonssl
    </IfModule>
</IfModule>
LogLevel info
#LogLevel info rewrite:trace8
<IfModule ssl_module>
    Listen 443
</IfModule>
Listen 80
Timeout 60
KeepAlive Off
KeepAliveTimeout 2
MaxKeepAliveRequests 100
UseCanonicalName On
HostnameLookups Double
ServerTokens OS
ServerSignature Off
ServerName devnull.example.com
ServerAdmin webmaster@example.com
AccessFileName .htaccess
AllowEncodedSlashes NoDecode
AddDefaultCharset UTF-8
<Directory "/">
    <IfModule allowmethods_module>
        AllowMethods GET POST OPTIONS
    </IfModule>
    Options None +FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>
<LocationMatch "^/?(.+/)*[\._]">
    Require all denied
</LocationMatch>
<LocationMatch "^/?(?:\.well-known)">
    Require all granted
</LocationMatch>
AliasMatch "^/?\.well-known/acme-challenge(.*)" "/data/www/acme/.well-known/acme-challenge$1"
<Directory "/data/www/acme">
    <IfModule allowmethods_module>
        AllowMethods GET
    </IfModule>
    Options None +FollowSymlinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule reqtimeout_module>
    RequestReadTimeout handshake=0 header=20-40,MinRate=500 body=20,MinRate=500
</IfModule>
FileETag None
<IfModule headers_module>
    RequestHeader unset Proxy early
</IfModule>
<IfModule dir_module>
    DirectoryIndex index.html index.htm index.php
</IfModule>
<IfModule cgi_module>
    <FilesMatch "\.(?:cgi|pl|py|rb)$">
        SetHandler cgi-script
    </FilesMatch>
</IfModule>
<IfModule cgid_module>
    <FilesMatch "\.(?:cgi|pl|py|rb)$">
        SetHandler cgi-script
    </FilesMatch>
    Scriptsock "/var/run/cgisock"
</IfModule>
<IfModule include_module>
    AddOutputFilter INCLUDES .shtml
</IfModule>
<IfModule mime_module>
    TypesConfig "etc/apache24/mime.types"
    AddType application/gzip                            gz tgz
    AddType application/ld+json                         jsonld
    AddType application/manifest+json                   manifest
    AddType text/html                                   shtml
    AddType text/javascript                             js
    AddType text/ecmascript                             ecma
    AddType text/markdown                               md
    <FilesMatch "favicon\.ico$">
        AddType image/vnd.microsoft.icon                ico
    </FilesMatch>
    AddEncoding gzip                                    svgz
    AddHandler type-map                                 var
    <IfModule negotiation_module>
        AddLanguage de             .de
        AddLanguage en             .en
        DefaultLanguage en
        LanguagePriority en de
        ForceLanguagePriority Prefer Fallback
        AddCharset us-ascii.ascii  .us-ascii
        AddCharset ISO-8859-1      .iso8859-1   .latin1
        AddCharset ISO-8859-15     .iso8859-15  .latin9
        AddCharset UTF-8           .utf8
        AddCharset UTF-8 .atom \
                         .css \
                         .js \
                         .json \
                         .jsonld \
                         .md \
                         .manifest \
                         .rdf \
                         .rss \
                         .xml \
                         .xsl
    </IfModule>
</IfModule>
<IfModule mime_magic_module>
    MIMEMagicFile "etc/apache24/magic"
</IfModule>
<IfModule expires_module>
    ExpiresActive on
    ExpiresDefault                                      "access plus 1 month"
    ExpiresByType text/html                             "access plus 0 seconds"
    ExpiresByType application/xhtml+xml                 "access plus 0 seconds"
    ExpiresByType text/css                              "access plus 1 week"
    ExpiresByType text/javascript                       "access plus 1 week"
    ExpiresByType text/ecmascript                       "access plus 1 week"
    ExpiresByType application/javascript                "access plus 1 week"
    ExpiresByType application/ecmascript                "access plus 1 week"
    ExpiresByType text/markdown                         "access plus 0 seconds"
    ExpiresByType application/xml                       "access plus 0 seconds"
    ExpiresByType text/xml                              "access plus 0 seconds"
    ExpiresByType text/xsl                              "access plus 0 seconds"
    ExpiresByType application/atom+xml                  "access plus 1 hour"
    ExpiresByType application/rss+xml                   "access plus 1 hour"
    ExpiresByType application/rdf+xml                   "access plus 1 hour"
    ExpiresByType application/json                      "access plus 0 seconds"
    ExpiresByType application/ld+json                   "access plus 0 seconds"
    ExpiresByType application/schema+json               "access plus 0 seconds"
    ExpiresByType application/manifest+json             "access plus 1 week"
    ExpiresByType image/vnd.microsoft.icon              "access plus 1 week"
</IfModule>
<IfModule filter_module>
    <IfModule brotli_module>
        FilterDeclare  COMPRESS_BR CONTENT_SET
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/html\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/plain\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/css\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/javascript\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^text/ecmascript\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/json\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/ld+json\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/schema+json\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/manifest+json\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/javascript\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/ecmascript\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/xhtml\+xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/rss\+xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^application/atom\+xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^image/svg\+xml\b#"
        FilterProvider COMPRESS_BR BROTLI_COMPRESS "%{Content_Type} =~ m#^image/vnd\.microsoft\.icon\b#"
        FilterProtocol COMPRESS_BR BROTLI_COMPRESS change=yes;byteranges=no
    </IfModule>
    <IfModule deflate_module>
        FilterDeclare  COMPRESS_GZ CONTENT_SET
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/html\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/plain\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/css\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/javascript\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^text/ecmascript\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/json\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/ld+json\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/schema+json\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/manifest+json\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/jvascript\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/ecmascript\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/xhtml\+xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/rss\+xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^application/atom\+xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^image/svg\+xml\b#"
        FilterProvider COMPRESS_GZ DEFLATE "%{Content_Type} =~ m#^image/vnd\.microsoft\.icon\b#"
        FilterProtocol COMPRESS_GZ DEFLATE change=yes;byteranges=no
    </IfModule>
    <If "%{HTTP:Accept-Encoding} =~ /\bbr\b/i">
        <IfModule brotli_module>
            FilterChain COMPRESS_BR
        </IfModule>
        <IfModule !brotli_module>
            <If "%{HTTP:Accept-Encoding} =~ /\bdeflate\b/i">
                <IfModule deflate_module>
                    FilterChain COMPRESS_GZ
                </IfModule>
            </If>
        </IfModule>
    </If>
    <ElseIf "%{HTTP:Accept-Encoding} =~ /\bdeflate\b/i">
        <IfModule deflate_module>
            FilterChain COMPRESS_GZ
        </IfModule>
    </ElseIf>
</IfModule>
<IfModule proxy_html_module>
    ProxyHTMLLinks  a               href
    ProxyHTMLLinks  area            href
    ProxyHTMLLinks  link            href
    ProxyHTMLLinks  img             src longdesc usemap
    ProxyHTMLLinks  object          classid codebase data usemap
    ProxyHTMLLinks  q               cite
    ProxyHTMLLinks  blockquote      cite
    ProxyHTMLLinks  ins             cite
    ProxyHTMLLinks  del             cite
    ProxyHTMLLinks  form            action
    ProxyHTMLLinks  input           src usemap
    ProxyHTMLLinks  head            profile
    ProxyHTMLLinks  base            href
    ProxyHTMLLinks  script          src for
    ProxyHTMLEvents onclick ondblclick onmousedown onmouseup \
                    onmouseover onmousemove onmouseout onkeypress \
                    onkeydown onkeyup onfocus onblur onload \
                    onunload onsubmit onreset onselect onchange
</IfModule>
<IfModule cache_module>
    CacheQuickHandler Off
    CacheStorePrivate On
    CacheIgnoreNoLastMod On
    CacheIgnoreCacheControl On
    CacheIgnoreURLSessionIdentifiers sid SID
    CacheHeader On
    <IfModule cache_disk_module>
        CacheRoot "/data/www/cache/"
    </IfModule>
    <IfModule cache_socache_module>
        CacheSocache shmcb
    </IfModule>
</IfModule>
<IfModule userdir_module>
    UserDir disabled
    UserDir public_html
    <Directory "/home/*/public_html">
        Options None +SymLinksIfOwnerMatch
        AllowOverride None
        Require method GET POST OPTIONS
        Require all granted
    </Directory>
</IfModule>
<IfModule info_module>
    <Location "/server-info">
        SetHandler server-info
        <RequireAny>
            Require host localhost
        </RequireAny>
    </Location>
</IfModule>
<IfModule status_module>
    <Location "/server-status">
        SetHandler server-status
        <RequireAny>
            Require host localhost
        </RequireAny>
    </Location>
    <IfModule http2_module>
        <Location "/server-status2">
            SetHandler http2-status
            <RequireAny>
                Require host localhost
            </RequireAny>
        </Location>
    </IfModule>
</IfModule>
<IfModule headers_module>
    Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
    <IfModule setenvif_module>
        SetEnvIf Origin ":" IS_CORS
        Header set Access-Control-Allow-Origin "*" env=IS_CORS
    </IfModule>
    Header set Access-Control-Max-Age "600"
    Header set Content-Security-Policy "\
upgrade-insecure-requests; \
base-uri 'self'; \
default-src 'self'; \
child-src 'self'; \
connect-src 'self' https:; \
font-src 'self' https:; \
frame-src 'self'; \
img-src 'self' https: data:; \
manifest-src 'self'; \
media-src 'self' https:; \
object-src 'none'; \
script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval' https:; \
style-src 'self' 'unsafe-inline' 'unsafe-eval' https:; \
worker-src 'self'; \
form-action 'self' https:; \
frame-ancestors 'self'; \
sandbox allow-downloads allow-forms allow-modals allow-orientation-lock allow-pointer-lock allow-popups allow-popups-to-escape-sandbox allow-presentation allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation"
    Header set Cross-Origin-Opener-Policy "same-origin-allow-popups"
    Header set Cross-Origin-Embedder-Policy "credentialless"
    Header set Cross-Origin-Resource-Policy "cross-origin"
    Header set Referrer-Policy "strict-origin-when-cross-origin"
    Header set Timing-Allow-Origin "*"
    Header set X-Content-Type-Options "nosniff"
    Header set X-DNS-Prefetch-Control "on"
    Header set X-Download-Options "noopen"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-Permitted-Cross-Domain-Policies "none"
    Header set X-XSS-Protection "1; mode=block"
</IfModule>
IncludeOptional "etc/apache24/modules.d/[0-9][0-9][0-9]_*.conf"
Include "etc/apache24/vhosts.conf"
<IfModule ssl_module>
    SSLRandomSeed startup "file:/dev/urandom" 65536
    SSLRandomSeed connect "file:/dev/urandom" 65536
    SSLPassPhraseDialog builtin
    <IfModule socache_shmcb_module>
        SSLSessionCache "shmcb:/var/run/ssl_scache(512000)"
    </IfModule>
    <IfModule !socache_shmcb_module>
        <IfModule socache_dbm_module>
            SSLSessionCache "dbm:/var/run/ssl_scache"
        </IfModule>
        <IfModule !socache_dbm_module>
            SSLSessionCache "nonenotnull"
        </IfModule>
    </IfModule>
    SSLHonorCipherOrder On
    SSLStrictSNIVHostCheck On
    SSLProtocol -ALL +TLSv1.2 +TLSv1.3
    SSLProxyProtocol -ALL +TLSv1.2 +TLSv1.3
    SSLOptions +StrictRequire +StdEnvVars
    SSLCipherSuite "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
    SSLCipherSuite TLSv1.3 "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256"
    SSLProxyCipherSuite "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
    SSLProxyCipherSuite TLSv1.3 "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256"
    SSLOpenSSLConfCmd Curves "X448:X25519:secp384r1:prime256v1:secp521r1"
    SSLOCSPEnable On
    SSLStaplingFakeTryLater Off
    SSLStaplingResponderTimeout 2
    SSLStaplingReturnResponderErrors Off
    SSLStaplingStandardCacheTimeout 86400
    <IfModule socache_shmcb_module>
        SSLUseStapling On
        SSLStaplingCache "shmcb:/var/run/stapling_cache(128000000)"
    </IfModule>
    <IfModule !socache_shmcb_module>
        <IfModule socache_dbm_module>
            SSLUseStapling On
            SSLStaplingCache "dbm:/var/run/stapling_cache"
        </IfModule>
        <IfModule !socache_dbm_module>
            SSLUseStapling Off
        </IfModule>
    </IfModule>
    Include "etc/apache24/vhosts-ssl.conf"
    <IfModule headers_module>
        Header set Public-Key-Pins "max-age=0; includeSubdomains"
        Header set Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
        Header edit* Set-Cookie "^(.*)(?i:\s*;\s*Secure)(.*)$" "$1$2"
        Header edit Set-Cookie "^(.*)$" "$1; Secure"
    </IfModule>
</IfModule>
<IfModule headers_module>
    Header merge Cache-Control "private"
    Header merge Cache-Control "no-cache"
    Header merge Cache-Control "no-transform"
    Header merge Cache-Control "must-revalidate"
    Header merge Cache-Control "proxy-revalidate"
    Header edit* Set-Cookie "^(.*)(?i:\s*;\s*HttpOnly)(.*)$" "$1$2"
    Header edit Set-Cookie "^(.*)$" "$1; HttpOnly"
    Header edit* Set-Cookie "^(.*)(?i:\s*;\s*SameSite=[A-Za-z0-9]+)(.*)$" "$1$2"
    Header edit Set-Cookie "^(.*)$" "$1; SameSite=Lax"
    Header always unset Pragma
    Header always unset ETag
    Header unset Pragma
    Header unset ETag
</IfModule>
"EOF"
```

`vhosts.conf` einrichten.

``` bash
cat << "EOF" > /usr/local/etc/apache24/vhosts.conf
<VirtualHost 127.0.0.1:80>
    ServerName localhost
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/_localhost_/logs/apache_access_log" combined
    ErrorLog "/data/www/vhosts/_localhost_/logs/apache_error_log"
    DocumentRoot "/data/www/vhosts/_localhost_/data"
    <Directory "/data/www/vhosts/_localhost_/data">
        Options None +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName devnull.example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/_default_/logs/apache_access_log" combined
    ErrorLog "/data/www/vhosts/_default_/logs/apache_error_log"
    DocumentRoot "/data/www/vhosts/_default_/data"
    <Directory "/data/www/vhosts/_default_/data">
        Options None +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    <IfModule rewrite_module>
        RewriteEngine On
        RewriteCond "%{REQUEST_FILENAME}" "!^/?(?:\.well-known|robots\.txt)" [NC]
        RewriteRule "^/?(.*)" "https://%{HTTP_HOST}/$1" [L,QSA,R=308]
    </IfModule>
</VirtualHost>

<VirtualHost *:80>
    ServerName mail.example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/mail.example.com/logs/apache_access_log" combined
    ErrorLog "/data/www/vhosts/mail.example.com/logs/apache_error_log"
    DocumentRoot "/data/www/vhosts/mail.example.com/data"
    <Directory "/data/www/vhosts/mail.example.com/data">
        Options None +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    <IfModule rewrite_module>
        RewriteEngine On
        RewriteCond "%{REQUEST_FILENAME}" "!^/?(?:\.well-known|robots\.txt)" [NC]
        RewriteRule "^/?(.*)" "https://%{HTTP_HOST}/$1" [L,QSA,R=308]
    </IfModule>
</VirtualHost>

<VirtualHost *:80>
    ServerName www.example.com
    ServerAlias example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/www.example.com/logs/apache_access_log" combined
    ErrorLog "/data/www/vhosts/www.example.com/logs/apache_error_log"
    DocumentRoot "/data/www/vhosts/www.example.com/data"
    <Directory "/data/www/vhosts/www.example.com/data">
        Options None +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    <IfModule rewrite_module>
        RewriteEngine On
        RewriteCond "%{HTTP_HOST}" "!^www\.example\.com$" [NC]
        RewriteCond "%{REQUEST_FILENAME}" "!^/?(?:\.well-known|robots\.txt)" [NC]
        RewriteRule "^/?(.*)" "https://www.example.com/$1" [L,QSA,R=308]
        RewriteCond "%{REQUEST_FILENAME}" "!^/?(?:\.well-known|robots\.txt)" [NC]
        RewriteRule "^/?(.*)" "https://%{HTTP_HOST}/$1" [L,QSA,R=308]
    </IfModule>
</VirtualHost>
"EOF"
```

`vhosts-ssl.conf` einrichten.

``` bash
cat << "EOF" > /usr/local/etc/apache24/vhosts-ssl.conf
<VirtualHost *:443>
    ServerName devnull.example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/_default_/logs/apache_ssl_access_log" combinedssl
    ErrorLog "/data/www/vhosts/_default_/logs/apache_ssl_error_log"
    DocumentRoot "/data/www/vhosts/_default_/data"
    <Directory "/data/www/vhosts/_default_/data">
        Options None +FollowSymLinks
        AllowOverride Options FileInfo AuthConfig Limit
        Require all granted
    </Directory>
    <FilesMatch "(.+\.php.?)(/.*)?$">
        SetHandler "proxy:unix:/var/run/fpm_www.sock|fcgi://localhost"
    </FilesMatch>
    SSLEngine on
    SSLCertificateFile "/usr/local/etc/letsencrypt/live/devnull.example.com/fullchain.pem"
    SSLCertificateKeyFile "/usr/local/etc/letsencrypt/live/devnull.example.com/privkey.pem"
</VirtualHost>

<VirtualHost *:443>
    ServerName mail.example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/mail.example.com/logs/apache_ssl_access_log" combinedssl
    ErrorLog "/data/www/vhosts/mail.example.com/logs/apache_ssl_error_log"
    DocumentRoot "/data/www/vhosts/mail.example.com/data"
    <Directory "/data/www/vhosts/mail.example.com/data">
        Options None +FollowSymLinks
        AllowOverride Options FileInfo AuthConfig Limit
        Require all granted
    </Directory>
    <FilesMatch "(.+\.php.?)(/.*)?$">
        SetHandler "proxy:unix:/var/run/fpm_www.sock|fcgi://localhost"
    </FilesMatch>
    SSLEngine on
    SSLCertificateFile "/usr/local/etc/letsencrypt/live/mail.example.com/fullchain.pem"
    SSLCertificateKeyFile "/usr/local/etc/letsencrypt/live/mail.example.com/privkey.pem"
</VirtualHost>

<VirtualHost *:443>
    ServerName www.example.com
    ServerAlias example.com
    ServerAdmin webmaster@example.com
    CustomLog "/data/www/vhosts/www.example.com/logs/apache_ssl_access_log" combinedssl
    ErrorLog "/data/www/vhosts/www.example.com/logs/apache_ssl_error_log"
    DocumentRoot "/data/www/vhosts/www.example.com/data"
    <Directory "/data/www/vhosts/www.example.com/data">
        Options None +FollowSymLinks
        AllowOverride Options FileInfo AuthConfig Limit
        Require all granted
    </Directory>
    <IfModule rewrite_module>
        RewriteEngine On
        RewriteCond "%{HTTP_HOST}" "!^www\.example\.com$" [NC]
        RewriteCond "%{REQUEST_FILENAME}" "!^/?(?:\.well-known|robots\.txt)" [NC]
        RewriteRule "^/?(.*)" "https://www.example.com/$1" [L,QSA,R=308]
    </IfModule>
    <FilesMatch "(.+\.php.?)(/.*)?$">
        SetHandler "proxy:unix:/var/run/fpm_www.sock|fcgi://localhost"
    </FilesMatch>
    SSLEngine on
    SSLCertificateFile "/usr/local/etc/letsencrypt/live/www.example.com/fullchain.pem"
    SSLCertificateKeyFile "/usr/local/etc/letsencrypt/live/www.example.com/privkey.pem"
</VirtualHost>
"EOF"
```

## Abschluss

Apache kann nun gestartet werden.

``` bash
service apache24 start
```
