---
title: 'CertBot'
description: 'In diesem HowTo wird step-by-step die Installation von CertBot für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
tags:
    - FreeBSD
    - CertBot
---

# CertBot

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird folgende Dienste umfassen.

-   CertBot 1.11.0 (LetsEncrypt ACME API 2.0)
-   CertBot Wrapper 0.3.0 (LetsEncrypt API 2.0)


## Installation

Wir installieren `security/py-certbot` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_py-certbot
cat > /var/db/ports/security_py-certbot/options << "EOF"
_OPTIONS_READ=py37-certbot-1.11.0
_FILE_COMPLETE_OPTIONS_LIST=MANPAGES
OPTIONS_FILE_SET+=MANPAGES
"EOF"


cd /usr/ports/security/py-certbot
make all install clean-depends clean
```


## Konfiguration

Die Konfiguration des CertBot erfolgt mittels des CertBot Wrapper welchen wir nun installieren.


## CertBot Wrapper

Es müssen zuerst noch zwei DNS-Records angelegt werden, sofern sie noch nicht existieren, oder entsprechend geändert werden, sofern sie bereits existieren.

``` dns-zone
example.com.            IN  CAA     ( 0 issue "letsencrypt.org" )
example.com.            IN  CAA     ( 0 issuewild "letsencrypt.org" )
```

Wir installieren den [RootService CertBot Wrapper](https://github.com/RootService/certbot-wrapper){: target="_blank" rel="noopener"}.

``` bash
fetch -q -4 -o '/data/ssl/certbot-wrapper.sh' https://raw.githubusercontent.com/RootService/certbot-wrapper/master/certbot-wrapper.sh

chmod 0755 /data/ssl/certbot-wrapper.sh
```

???+ note

    Der CertBot Wrapper ist noch im Staging-Modus, das heisst er nutzt nur die LetsEncrypt Sandbox statt des regulären API. In diesem Modus kann man LetsEncrypt in Ruhe testen, ohne die Limits bei LetsEncrypt zu erreichen.

Wir deaktivieren den Staging-Modus.

``` baah
sed -e 's|^\(STAGING\)=1$|\1=0|g' \
    -i '' /data/ssl/certbot-wrapper.sh
```

Wir erstellen unseren LetsEncrypt-Account und unsere Zertifikate und lassen diese auch gleich automatisch vom CertBot Wrapper in Apache, Dovecot und Postfix aktivieren.

``` bash
/data/ssl/certbot-wrapper.sh --create
```

Die Ausgabe und Eingaben sollten in etwa so aussehen:

``` bash
Enter Domain: example.com
Enter Mailadress: admin@example.com

Enter Subdomain: devnull
Automatically reconfigure apache24 for this subdomain? [y/n] y
Activate HSTS for this subdomain? [y/n] n
Automatically reconfigure postfix for this subdomain? [y/n] n
Automatically reconfigure dovecot for this subdomain? [y/n] n

Another Subdomain? [y/n] y

Enter Subdomain: www
Automatically reconfigure apache24 for this subdomain? [y/n] y
Activate HSTS for this subdomain? [y/n] n
Automatically reconfigure postfix for this subdomain? [y/n] n
Automatically reconfigure dovecot for this subdomain? [y/n] n

Another Subdomain? [y/n] y

Enter Subdomain: mail
Automatically reconfigure apache24 for this subdomain? [y/n] n
Automatically reconfigure postfix for this subdomain? [y/n] y
Automatically reconfigure dovecot for this subdomain? [y/n] y

Another Subdomain? [y/n] n

Another Domain? [y/n] n
```

Wir richten einen Cronjob ein, um die Zertifikate regelmässig automatisch vor dem Ablaufen zu erneuern.

``` bash
cat >> /etc/crontab << "EOF"
30      7       *       *       2,5     root    /data/ssl/certbot-wrapper.sh --cron
"EOF"
```

Ein manuelles Erneuern der Zertifikate ist bei Bedarf ebenfalls möglich.

``` bash
/data/ssl/certbot-wrapper.sh --renew
```

Um weitere Zertifikate hinzuzufügen genügt ein erneutes Aufrufen.

``` bash
/data/ssl/certbot-wrapper.sh --create
```

Abschliessend müssen wir noch den Cronjob aus [Certificate Authority](/howtos/freebsd/certificate_authority) löschen, da dieser mit dem CertBot Wrapper nicht kompatibel ist.

``` bash
sed '/update-crls-chains/d' -i '' /etc/crontab
```


## Abschluss

Der CertBot Wrapper sollte bei Bedarf manuell auf den aktuellen Stand gebracht werden.
