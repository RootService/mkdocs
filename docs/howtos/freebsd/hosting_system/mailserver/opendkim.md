---
title: 'OpenDKIM'
description: 'In diesem HowTo wird step-by-step die Installation von OpenDKIM für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# OpenDKIM

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- OpenDKIM 2.10.3 (VBR, 2048 Bit RSA)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/opendkim` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_opendbx
cat <<'EOF' > /var/db/ports/databases_opendbx/options
--8<-- "ports/databases_opendbx/options"
EOF

mkdir -p /var/db/ports/dns_ldns
cat <<'EOF' > /var/db/ports/dns_ldns/options
--8<-- "ports/dns_ldns/options"
EOF

mkdir -p /var/db/ports/textproc_libtre
cat <<'EOF' > /var/db/ports/textproc_libtre/options
--8<-- "ports/textproc_libtre/options"
EOF

mkdir -p /var/db/ports/mail_opendkim
cat <<'EOF' > /var/db/ports/mail_opendkim/options
--8<-- "ports/mail_opendkim/options"
EOF


portmaster -w -B -g --force-config mail/opendkim  -n


sysrc milteropendkim_enable=YES
sysrc milteropendkim_socket="inet:8891@localhost"
```

Bitte example.com ersetzen:

``` bash
mkdir -p /data/db/opendkim/keys/example.com

chown -R mailnull:mailnull /data/db/opendkim
```

## Konfiguration

`opendkim.conf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/mail/opendkim.conf
--8<-- "configs/usr/local/etc/mail/opendkim.conf"
EOF
```

Singning-Key erzeugen.

``` bash
opendkim-genkey --append-domain --bits=2048 --directory=/data/db/opendkim/keys/example.com --domain=example.com --hash-algorithms=sha256 --note=example.com --selector=20250426 --subdomains --verbose

chmod 0600 /data/db/opendkim/keys/*/*.private
```

KeyTable anlegen.

``` bash
cat <<'EOF' > /data/db/opendkim/keytable
20250426._domainkey.example.com    example.com:20250426:/data/db/opendkim/keys/example.com/20250426.private
EOF
```

SingingTable anlegen.

``` bash
cat <<'EOF' > /data/db/opendkim/signingtable
*@example.com      20250426._domainkey.example.com
*@*.example.com    20250426._domainkey.example.com
EOF
```

TrustedHosts anlegen.

``` bash
cat <<'EOF' > /data/db/opendkim/trustedhosts
::1
127.0.0.1
fe80::/10
ff02::/16
10.0.0.0/8
__IPV4ADDR__
__IPV6ADDR__
localhost
example.com
*.example.com
EOF
```

``` bash
chown -R mailnull:mailnull /data/db/opendkim
```

Es muss noch ein DNS-Record angelegt werden, sofern er noch nicht existiert, oder entsprechend geändert werden, sofern er bereits existiert.

``` bash
/usr/local/bin/openssl pkey -pubout -outform pem -in /data/db/opendkim/keys/example.com/20250426.private | \
    awk '\!/^-----/ {printf $0}' | awk 'BEGIN{n=1}\
        {printf "\n20250426._domainkey.example.com.    IN  TXT    ( \"v=DKIM1; h=shs256; k=rsa; s=*; t=*; p=\"";\
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
20250426._domainkey.example.com.    IN  TXT    ( "v=DKIM1; h=shs256; k=rsa; s=*; t=*; p="
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
