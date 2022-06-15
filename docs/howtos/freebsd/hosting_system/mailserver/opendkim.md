---
title: 'OpenDKIM'
description: 'In diesem HowTo wird step-by-step die Installation von OpenDKIM für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
tags:
    - FreeBSD
    - OpenDKIM
---

# OpenDKIM

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird um folgende Dienste erweitert.

-   OpenDKIM 2.10.3 (VBR, 2048 Bit RSA)


## Installation

Wir installieren `mail/opendkim` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/dns_ldns
cat > /var/db/ports/dns_ldns/options << "EOF"
_OPTIONS_READ=ldns-1.7.1
_FILE_COMPLETE_OPTIONS_LIST=DANETAUSAGE DOXYGEN DRILL EXAMPLES GOST RRTYPEAMTRELAY RRTYPEAVC RRTYPENINFO RRTYPERKEY RRTYPETA
OPTIONS_FILE_UNSET+=DANETAUSAGE
OPTIONS_FILE_UNSET+=DOXYGEN
OPTIONS_FILE_SET+=DRILL
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=GOST
OPTIONS_FILE_SET+=RRTYPEAMTRELAY
OPTIONS_FILE_SET+=RRTYPEAVC
OPTIONS_FILE_SET+=RRTYPENINFO
OPTIONS_FILE_SET+=RRTYPERKEY
OPTIONS_FILE_SET+=RRTYPETA
"EOF"

mkdir -p /var/db/ports/textproc_libtre
cat > /var/db/ports/textproc_libtre/options << "EOF"
_OPTIONS_READ=libtre-0.8.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS NLS OPTIMIZED_CFLAGS PGO
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=NLS
OPTIONS_FILE_UNSET+=OPTIMIZED_CFLAGS
OPTIONS_FILE_UNSET+=PGO
"EOF"

mkdir -p /var/db/ports/mail_opendkim
cat > /var/db/ports/mail_opendkim/options << "EOF"
_OPTIONS_READ=opendkim-2.10.3
_FILE_COMPLETE_OPTIONS_LIST=FILTER CURL GNUTLS JANSSON LDNS LMDB LUA MEMCACHED  BDB_BASE OPENDBX OPENLDAP POPAUTH QUERY_CACHE SASL DOCS STOCK_RESOLVER UNBOUND ALLSYMBOLS CODECOVERAGE DEBUG ADSP_LISTS ATPS DB_HANDLE_POOLS  DEFAULT_SENDER DIFFHEADERS IDENTITY_HEADER  LDAP_CACHING POSTGRES_RECONNECT_HACK  RATE_LIMIT RBL REPLACE_RULES REPRRD  REPUTATION RESIGN SENDER_MACRO  SOCKETDB STATS STATSEXT VBR
OPTIONS_FILE_SET+=FILTER
OPTIONS_FILE_SET+=CURL
OPTIONS_FILE_UNSET+=GNUTLS
OPTIONS_FILE_UNSET+=JANSSON
OPTIONS_FILE_SET+=LDNS
OPTIONS_FILE_SET+=LMDB
OPTIONS_FILE_SET+=LUA
OPTIONS_FILE_UNSET+=MEMCACHED
OPTIONS_FILE_UNSET+=BDB_BASE
OPTIONS_FILE_UNSET+=OPENDBX
OPTIONS_FILE_UNSET+=OPENLDAP
OPTIONS_FILE_UNSET+=POPAUTH
OPTIONS_FILE_SET+=QUERY_CACHE
OPTIONS_FILE_UNSET+=SASL
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=STOCK_RESOLVER
OPTIONS_FILE_UNSET+=UNBOUND
OPTIONS_FILE_UNSET+=ALLSYMBOLS
OPTIONS_FILE_UNSET+=CODECOVERAGE
OPTIONS_FILE_UNSET+=DEBUG
OPTIONS_FILE_UNSET+=ADSP_LISTS
OPTIONS_FILE_SET+=ATPS
OPTIONS_FILE_UNSET+=DB_HANDLE_POOLS
OPTIONS_FILE_SET+=DEFAULT_SENDER
OPTIONS_FILE_SET+=DIFFHEADERS
OPTIONS_FILE_SET+=IDENTITY_HEADER
OPTIONS_FILE_UNSET+=LDAP_CACHING
OPTIONS_FILE_UNSET+=POSTGRES_RECONNECT_HACK
OPTIONS_FILE_UNSET+=RATE_LIMIT
OPTIONS_FILE_UNSET+=RBL
OPTIONS_FILE_SET+=REPLACE_RULES
OPTIONS_FILE_UNSET+=REPRRD
OPTIONS_FILE_UNSET+=REPUTATION
OPTIONS_FILE_SET+=RESIGN
OPTIONS_FILE_SET+=SENDER_MACRO
OPTIONS_FILE_UNSET+=SOCKETDB
OPTIONS_FILE_UNSET+=STATS
OPTIONS_FILE_UNSET+=STATSEXT
OPTIONS_FILE_SET+=VBR
"EOF"


cd /usr/ports/mail/opendkim
make all install clean-depends clean


echo 'milteropendkim_socket="inet:8891@localhost"' >> /etc/rc.conf
echo 'milteropendkim_enable="YES"' >> /etc/rc.conf
```

``` bash
mkdir -p /data/db/opendkim/keys/example.com

chown -R mailnull:mailnull /data/db/opendkim
```


## Konfiguration

`opendkim.conf` einrichten.

``` bash
sed -e 's|^#[[:space:]]\(AuthservID\)[[:space:]].*$|\1 mail.example.com|g' \
    -e 's|^#[[:space:]]\(AutoRestart\)[[:space:]].*$|\1 Yes|g' \
    -e 's|^#[[:space:]]\(AutoRestartRate\)[[:space:]].*$|\1 10/1h|g' \
    -e 's|^#[[:space:]]\(Canonicalization\)[[:space:]].*$|\1 relaxed/relaxed|g' \
    -e 's|^\(Domain\)[[:space:]].*$|# \1 example.com|g' \
    -e 's|^#[[:space:]]\(ExternalIgnoreList\)[[:space:]].*$|\1 refile:/data/db/opendkim/trustedhosts|g' \
    -e 's|^#[[:space:]]\(InternalHosts\)[[:space:]].*$|\1 refile:/data/db/opendkim/trustedhosts|g' \
    -e 's|^\(KeyFile\)[[:space:]].*$|# \1 /data/db/opendkim/keys/example.com/20210211.private|g' \
    -e 's|^#[[:space:]]\(KeyTable\)[[:space:]].*$|\1 refile:/data/db/opendkim/keytable|g' \
    -e 's|^#[[:space:]]\(LogWhy\)[[:space:]].*$|\1 Yes|g' \
    -e 's|^#[[:space:]]\(Mode\)[[:space:]].*$|\1 sv|g' \
    -e 's|^#[[:space:]]\(PeerList\)[[:space:]].*$|# \1 /data/db/opendkim/peerlist|g' \
    -e 's|^#[[:space:]]\(PidFile\)[[:space:]].*$|# \1 /var/run/milteropendkim/pid|g' \
    -e 's|^#[[:space:]]\(RedirectFailuresTo\)[[:space:]].*$|# \1 postmaster@example.com|g' \
    -e 's|^#[[:space:]]\(ReportAddress\)[[:space:]].*$|\1 "DKIM Error Postmaster" <postmaster@example.com>|g' \
    -e 's|^#[[:space:]]\(ReportBccAddress\)[[:space:]].*$|# \1 admin@example.com|g' \
    -e 's|^\(Selector\)[[:space:]].*$|# \1 20210211|g' \
    -e 's|^#[[:space:]]\(SenderHeaders\)[[:space:]].*$|# \1 From,Reply-To|g' \
    -e 's|^#[[:space:]]\(SendReports\)[[:space:]].*$|\1 Yes|g' \
    -e 's|^#[[:space:]]\(SignatureAlgorithm\)[[:space:]].*$|\1 rsa-sha256|g' \
    -e 's|^#[[:space:]]\(SignHeaders\)[[:space:]].*$|\1 From,Reply-To,To,Cc,In-Reply-To,References,Date,Subject,Content-Type,Content-Transfer-Encoding,MIME-Version|g' \
    -e 's|^#[[:space:]]\(SigningTable\)[[:space:]].*$|\1 refile:/data/db/opendkim/signingtable|g' \
    -e 's|^#[[:space:]]\(Socket\)[[:space:]]*smtp.*$|SMTPURI smtp://localhost|g' \
    -e 's|^\(Socket\)[[:space:]]*inet.*$|\1 inet:8891@localhost|g' \
    -e 's|^#[[:space:]]\(SubDomains\)[[:space:]].*$|\1 Yes|g' \
    -e 's|^\(Syslog\)[[:space:]].*$|\1 Yes|g' \
    -e 's|^#[[:space:]]\(SyslogSuccess\)[[:space:]].*$|# \1 Yes|g' \
    -e 's|^#[[:space:]]\(TrustAnchorFile\)[[:space:]].*$|\1 /var/unbound/root.key|g' \
    -e 's|^#[[:space:]]\(UMask\)[[:space:]].*$|\1 022|g' \
    -e 's|^#[[:space:]]\(UnboundConfigFile\)[[:space:]].*$|# \1 /var/unbound/unbound.conf|g' \
    -e 's|^#[[:space:]]\(UserID\)[[:space:]].*$|\1 mailnull:mailnull|g' \
    /usr/local/etc/mail/opendkim.conf.sample > /usr/local/etc/mail/opendkim.conf
```

Singning-Key erzeugen.

``` bash
opendkim-genkey -v -r -b 2048 -h sha256 -s 20210211 -d example.com -D /data/db/opendkim/keys/example.com

chmod 0600 /data/db/opendkim/keys/*.private
```

KeyTable anlegen.

``` bash
cat > /data/db/opendkim/keytable << "EOF"
20210211._domainkey.example.com    example.com:20210211:/data/db/opendkim/keys/example.com/20210211.private
"EOF"
```

SingingTable anlegen.

``` bash
cat > /data/db/opendkim/signingtable << "EOF"
*@example.com      20210211._domainkey.example.com
*@*.example.com    20210211._domainkey.example.com
"EOF"
```

TrustedHosts anlegen.

``` bash
cat > /data/db/opendkim/trustedhosts << "EOF"
::1
127.0.0.1
localhost
"EOF"

ifconfig `route -n get -inet default | \
    awk '/interface/ {print $2}'` inet | \
    awk '/inet / {if(substr($2,1,3)!=127) print $2}' \
    >> /data/db/opendkim/trustedhosts
ifconfig `route -n get -inet6 default | \
    awk '/interface/ {print $2}'` inet6 | \
    awk '/inet6 / {if(substr($2,1,1)!="f") print $2}' \
    >> /data/db/opendkim/trustedhosts

cat >> /data/db/opendkim/trustedhosts << "EOF"
example.com
*.example.com
"EOF"
```

``` bash
chown -R mailnull:mailnull /data/db/opendkim
```

Es muss noch ein DNS-Record angelegt werden, sofern er noch nicht existiert, oder entsprechend geändert werden, sofern er bereits existiert.

``` bash
/usr/local/bin/openssl pkey -pubout -outform pem -in /data/db/opendkim/keys/example.com/20210211.private | \
    awk '\!/^-----/ {printf $0}' | awk 'BEGIN{n=1}\
        {printf "\n20210211._domainkey.example.com.    IN  TXT    ( \"v=DKIM1; h=sha256; k=rsa; s=email; p=\"";\
            while(substr($0,n,98)){printf "\n        \"" substr($0,n,98) "\"";n+=98};printf " )\n"}'
```

``` dns-zone
#
# The output should look similar to this one, which will be the DNS-Record to publish
#
# Note: The folding of the pubkey is necessary as most nameservers have a line-length limit
#       If you use a DNS-Provider to publish your records, then use their free-text fields
#       to insert the record into their form
#
20210211._domainkey.example.com.    IN  TXT    ( "v=DKIM1; h=sha256; k=rsa; s=email; p="
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1Up5Z0TkPpE0mNAc9lf7Uug7P/n28Kk6fXC1V8m93dE+NPgsTKp4k+"
        "t2S3EujANO7J8WyBppE+aTbyQjU5TtaIPC8TS3sBg/6JX/QAw73+Hv03lieutmZ0GO4uuvj+QbOuDqNwHR/DZih3BrV7Mtit4F"
        "bILcz+V1QbJ7YssRQRaZ/LTGZ0Q6QLGr6BG9h3Ro4g1bTirFIuvbaVUuzDK/KxHKRAuAhIB7mmrpPRDQlFjgva9vQYsQUcQtVh"
        "Y/z6YvcGNvEWhme3gaTWzdG20aLTxut4Il17OSWiCbF0wdnUn0bnKins14YeHjkDhOhMoEagd3lWWs0k2KNxnbYljPQwIDAQAB" )
```


## Abschluss

OpenDKIM kann nun gestartet werden.

``` bash
service milter-opendkim start
```
