---
title: 'Voraussetzungen'
description: 'In diesem HowTo werden step-by-step die Voraussetzungen für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
tags:
    - FreeBSD
    - Hosting System
---

# Voraussetzungen

## Einleitung

Diese HowTos setzen ein wie in [Remote Installation](/howtos/freebsd/remote_install/) beschriebenes, installiertes und konfiguriertes FreeBSD Basissystem voraus.

Unser WebHosting System wird am Ende folgende Dienste umfassen.

-   MySQL 8.0.23 (InnoDB, GTID)
-   Dovecot 2.3.13 (IMAP only, 1GB Quota)
-   Postfix 3.5.9 (Dovecot-SASL, postscreen)
-   Python-SPF-Engine 2.9.2 (SPF2)
-   OpenDKIM 2.10.3 (VBR, 2048 Bit RSA)
-   OpenDMARC 1.3.2 (SPF2, FailureReports)
-   Apache 2.4.46 (MPM-Event, HTTP/2, mod_brotli)
-   NGinx 1.14.0 (HTTP/2, mod_brotli)
-   PHP 8.0.2 (PHP-FPM, Composer, PEAR)
-   CertBot 1.11.0 (LetsEncrypt ACME API 2.0)
-   CertBot Wrapper 0.3.0 (LetsEncrypt API 2.0)

Folgende Punkte sind in allen folgenden HowTos zu beachten.

-   Alle Dienste werden mit einem möglichst minimalen und bewährten Funktionsumfang installiert.
-   Alle Dienste werden mit einer möglichst sicheren und dennoch flexiblen Konfiguration versehen.
-   Alle Konfigurationen sind selbstständig auf notwendige individuelle Anpassungen zu kontrollieren.
-   Alle Benutzernamen werden als `__USERNAME__` dargestellt und sind selbstständig passend zu ersetzen.
-   Alle Passworte werden als `__PASSWORD__` dargestellt und sind selbstständig durch sichere Passworte zu ersetzen.
-   Die Domain des Servers lautet `example.com` und ist selbstständig durch die eigene Domain zu ersetzen.
-   Der Hostname des Servers lautet `devnull` und ist selbstständig durch den eigenen Hostnamen zu ersetzen (FQDN=devnull.example.com).
-   Es werden die FQDNs `devnull.example.com`, `mail.example.com` und `www.example.com` verwendet und sind selbstständig im DNS zu registrieren.
-   Die primäre IPv4 Adresse des Systems wird als `__IPV4ADDR__` dargestellt und ist selbsttändig zu ersetzen.
-   Die primäre IPv6 Adresse des Systems wird als `__IPV6ADDR__` dargestellt und ist selbsttändig zu ersetzen.
-   Postfix und Dovecot teilen sich sowohl den FQDN `mail.example.com` als auch das SSL-Zertifikat.


## Vorbereitungen

???+ important

    An diesem Punkt müssen wir uns entscheiden, ob wir die Pakete/Ports in Zukunft bequem als vorkompiliertes Binary-Paket per `pkg install <category/portname>` mit den Default-Optionen installieren wollen oder ob wir die Optionen und somit auch den Funktionsumfang beziehungsweise die Features unserer Pakete/Ports selbst bestimmen wollen.

In diesem HowTo werden wir uns für die zweite Variante entscheiden, da uns dies viele Probleme durch unnötige oder fehlende Features und Abhängigkeiten ersparen wird. Andererseits verlieren wir dadurch den Komfort von `pkg` bei der Installation und den Updates der Pakete/Ports. Ebenso müssen wir zwangsweise für alle Pakete/Ports die gewünschten Optionen manuell setzen und die Pakete/Ports auch selbst kompilieren.

Dieses Vorgehen ist deutlich zeitaufwendiger und erfordert auch etwas mehr Wissen über die jeweiligen Pakete/Ports und deren Features, dafür entschädigt es uns aber mit einem schlankeren, schnelleren und stabileren System und bietet uns gegebenenfalls nützliche/erforderliche zusätzliche Funktionen und Sicherheitsfeatures. Auch die potentielle Gefahr für Sicherheitslücken sinkt dadurch, da wir unnütze Pakete/Ports gar nicht erst als Abhängigkeiten mitinstallieren müssen.

Sofern noch nicht geschehen, deaktivieren wir also zuerst das Default-Repository von `pkg`, um versehentlichen Installationen von Binary-Paketen durch `pkg` vorzubeugen.

``` bash
mkdir -p /usr/local/etc/pkg/repos
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
```

Die von uns jeweils gewünschten Build-Optionen der Ports legen wir dabei mittels der `options`-Files des neuen Portkonfigurationsframeworks `OptionsNG` fest.

Da wir unsere Nutzdaten weitestgehend unter `/data` ablegen werden, legen wir ein paar hierfür benötigte Verzeichnisse an, sofern nicht bereits geschehen.

``` bash
mkdir -p /data/db /data/ssl /data/www
```


## DNS Records

Für diese HowTos müssen zuvor folgende DNS-Records angelegt werden, sofern sie noch nicht existieren, oder entsprechend geändert werden, sofern sie bereits existieren.

``` dns-zone
example.com.            IN  A       __IPV4ADDR__
example.com.            IN  AAAA    __IPV6ADDR__

devnull.example.com.    IN  A       __IPV4ADDR__
devnull.example.com.    IN  AAAA    __IPV6ADDR__

mail.example.com.       IN  A       __IPV4ADDR__
mail.example.com.       IN  AAAA    __IPV6ADDR__

www.example.com.        IN  A       __IPV4ADDR__
www.example.com.        IN  AAAA    __IPV6ADDR__

example.com.            IN  MX  10  mail.example.com.
```


## OpenSSL

Diese HowTos setzen aktuell die (temporäre) Erstellung einer eigenen [Certificate Authority](/howtos/freebsd/certificate_authority/) voraus. Dieser Punkt wird hoffentlich in Zukunft nicht mehr nötig sein.


## Los geht es

Die einzelnen HowTos bauen aufeinander auf, daher sollten sie in der Reihenfolge von oben nach unten bis zum Ende abgearbeitet werden.
