---
title: 'Certificate Authority'
description: 'In diesem HowTo wird step-by Schritt die Installation einer Certificate Authority mit OpenSSL (PKI) auf Basis von Gentoo Linusx 64Bit beschrieben.'
date: '2013-11-15'
updated: '2014-09-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Stefan H. Holek'
---

# Certificate Authority mit OpenSSL auf Gentoo Linux

In diesem HowTo wird Schritt für Schritt die Installation einer Certificate Authority (PKI) mit OpenSSL auf Basis von Gentoo Linux 64Bit beschrieben.

## Einleitung

???+ warning

    Dieses HowTo wird seit **2014-09-01** nicht mehr aktiv gepflegt und entspricht daher nicht mehr dem aktuellen Stand.

    Die Verwendung dieses HowTo geschieht somit auf eigene Gefahr!

Dieses HowTo setzt ein wie in [Remote Installation](/howtos/gentoo/remote_install/) beschriebenes, installiertes und konfiguriertes Gentoo Linux Basissystem und OpenSSL >= 1.0.1 voraus.

## Inhaltsverzeichnis
- [Vorbereitungen](#vorbereitungen)
- [OpenSSL](#openssl)
  - [OpenSSL konfigurieren](#openssl-konfigurieren)
  - [OpenSSL CA](#openssl-ca)
    - [Root CA erstellen](#root-ca-erstellen)
    - [Network / Intermediate CA erstellen](#network--intermediate-ca-erstellen)
    - [Identity Signing CA erstellen](#identity-signing-ca-erstellen)
    - [Component Signing CA erstellen](#component-signing-ca-erstellen)
    - [CRLs und Chains erneuern](#crls-und-chains-erneuern)
  - [OpenSSL Zertifikate](#openssl-zertifikate)
    - [Identity Certificate erstellen](#identity-certificate-erstellen)
    - [TLS Client Certificate erstellen](#tls-client-certificate-erstellen)
    - [TLS Server Certificate erstellen](#tls-server-certificate-erstellen)
    - [Time-stamping Certificate erstellen](#time-stamping-certificate-erstellen)
    - [OCSP-Signing Certificate erstellen](#ocsp-signing-certificate-erstellen)
- [Wie geht es weiter?](#wie-geht-es-weiter)

## Vorbereitungen

Verzeichnisstruktur anlegen und RANDFILE sowie EC-Params und DH-Params erzeugen.

``` bash
mkdir -p /data/pki/{ca,certs,crl,etc,newcerts,private,revoked}
chmod 0700 /data/pki/private
openssl rand -out /data/pki/private/.rand 65536

openssl genpkey -genparam -algorithm DH -pkeyopt dh_paramgen_prime_len:4096 -out /data/pki/certs/dh_params.pem
openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out /data/pki/certs/ec_params.pem
```

## OpenSSL

### OpenSSL konfigurieren

Sofern noch nicht während der [Remote Installation](/howtos/gentoo/remote_install/) erledigt, müssen folgende Optionen in der `/etc/ssl/openssl.cnf` im Abschnitt `[ req_distinguished_name ]` angepasst beziehungsweise ergänzt werden.

``` text
countryName_default             = DE
stateOrProvinceName_default     = Bundesland
localityName_default            = Ort
0.organizationName_default      = Example Corporation
organizationalUnitName_default  = Certification Authority
emailAddress_default            = admin@example.com
```

Folgende Optionen müssen im Abschnitt `[ CA_default ]` angepasst werden.

``` text
default_days            = 730
default_md              = sha256
```

Folgende Optionen müssen im Abschnitt `[ req ]` angepasst werden.

``` text
default_bits            = 4096
string_mask             = utf8only
```

DH Param Files erzeugen

``` bash
openssl genpkey -genparam -algorithm DH -pkeyopt dh_paramgen_prime_len:4096 -out /etc/ssl/dh_params.pem
openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out /etc/ssl/ec_params.pem
```

### OpenSSL CA

#### Root CA erstellen

In der `etc/root-ca.conf` müssen noch ein paar Anpassungen vorgenommen werden:

1. Im Abschnitt `[ default ]` muss die Option `base_url` auf den URL gesetzt werden, unter dem später die Certs, CRLs und Chains veröffentlicht werden sollen.
1. Im Abschnitt `[ ca_dn ]` muss die Option `countryName` auf das internationale zweibuchstabige Länderkürzel des Betreibers der Root CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationName` auf den Firmennamen des Betreibers der Root CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationalUnitName` auf den zuständigen Abteilungsnamen des Betreibers der Root CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `commonName` auf den Namen der Root CA (im Regelfall "Firmenname Root CA") gesetzt werden.
1. Im Abschnitt `[ additional_oids ]` müssen die OIDs entsprechend der eigenen registrierten OIDs ersetzt werden.

``` bash
cd /data/pki

cat > etc/root-ca.conf << "EOF"
#
# Example Corporation Root CA
#

[ default ]
ca                      = root-ca
base_url                = https://pki.example.com
aia_url                 = $base_url/$ca.cer
crl_url                 = $base_url/$ca.crl
name_opt                = multiline,-esc_msb,utf8
openssl_conf            = openssl_init

[ ca ]
default_ca              = root_ca

[ root_ca ]
dir                     = .
certs                   = $dir/ca/$ca/certs
crl_dir                 = $dir/ca/$ca/crl
database                = $dir/ca/$ca/index.txt
new_certs_dir           = $dir/ca/$ca/newcerts
certificate             = $dir/ca/$ca/cacert.pem
serial                  = $dir/ca/$ca/serial
crlnumber               = $dir/ca/$ca/crlnumber
crl                     = $dir/ca/$ca/crl.pem
private_key             = $dir/ca/$ca/private/cakey.pem
RANDFILE                = $dir/ca/$ca/private/.rand
unique_subject          = no
default_days            = 1826
default_md              = sha256
digests                 = sha1
policy                  = match_pol
email_in_dn             = no
preserve                = no
name_opt                = $name_opt
cert_opt                = ca_default
copy_extensions         = none
x509_extensions         = intermediate_ca_ext
default_crl_days        = 30
crl_extensions          = crl_ext

[ match_pol ]
countryName             = match
stateOrProvinceName     = optional
localityName            = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied

[ any_pol ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = ca_dn
req_extensions          = ca_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = no
SET-ex3                 = SET extension number 3

[ ca_dn ]
countryName             = "DE"
organizationName        = "Example Corporation"
organizationalUnitName  = "Certification Authority"
commonName              = "Example Corporation Root CA"

[ ca_reqext ]
basicConstraints        = critical, CA:TRUE
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash

[ root_ca_ext ]
basicConstraints        = critical, CA:TRUE
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

[ intermediate_ca_ext ]
basicConstraints        = critical, CA:TRUE
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssurance, mediumAssuranceDevice

[ crl_ext ]
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info

[ issuer_info ]
caIssuers;URI.0         = $aia_url

[ crl_info ]
URI.0                   = $crl_url

[ openssl_init ]
oid_section             = additional_oids

[ additional_oids ]
mediumAssurance         = Medium Assurance, 1.3.6.1.4.1.0.1.7.8
mediumAssuranceDevice   = Medium Device Assurance, 1.3.6.1.4.1.0.1.7.9
"EOF"
```

Verzeichnisstruktur anlegen, RANDFILE erzeugen, zufälligen Startwert für die späteren Serialnummern festlegen und Indexfile anlegen.

``` bash
mkdir -p ca/root-ca/{certs,crl,newcerts,private,revoked}
chmod 0700 ca/root-ca/private
openssl rand -out ca/root-ca/private/.rand 65536
echo `openssl rand -hex 64 | tr '[[:lower:]]' '[[:upper:]]'` > ca/root-ca/serial
cp ca/root-ca/serial ca/root-ca/crlnumber
touch ca/root-ca/index.txt ca/root-ca/index.txt.attr
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > ca/root-ca/private/root-ca.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out ca/root-ca/private/cakey.pem \
    -pass file:ca/root-ca/private/root-ca.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/root-ca.conf \
    -new \
    -sha256 \
    -out ca/root-ca/careq.pem \
    -key ca/root-ca/private/cakey.pem \
    -passin file:ca/root-ca/private/root-ca.pwd
```

Durch die Root CA selbstsigniertes Zertifikat für die Root CA erzeugen. Die Gültigkeitsdauer wird auf 5 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/root-ca.conf \
    -batch \
    -selfsign \
    -md sha256 \
    -in ca/root-ca/careq.pem \
    -out ca/root-ca/cacert.pem \
    -extensions root_ca_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+5y '+%Y%m01000000Z'` \
    -passin file:ca/root-ca/private/root-ca.pwd
```

Initiale CRL der Root CA erzeugen.

``` bash
openssl ca \
    -config etc/root-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/root-ca/crl.pem \
    -passin file:ca/root-ca/private/root-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl x509 \
    -in ca/root-ca/cacert.pem \
    -out ca/root-ca.cer \
    -outform DER
```

CRL in ein veröffentlichbares Format exportieren.

``` bash
openssl crl \
    -in ca/root-ca/crl.pem \
    -out ca/root-ca.crl \
    -outform DER
```

#### Network / Intermediate CA erstellen

In der `etc/network-ca.conf` müssen noch ein paar Anpassungen vorgenommen werden:

1. Im Abschnitt `[ default ]` muss die Option `base_url` auf den URL gesetzt werden, unter dem später die Certs, CRLs und Chains veröffentlicht werden sollen.
1. Im Abschnitt `[ ca_dn ]` muss die Option `countryName` auf das internationale zweibuchstabige Länderkürzel des Betreibers der Network CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationName` auf den Firmennamen des Betreibers der Network CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationalUnitName` auf den zuständigen Abteilungsnamen des Betreibers der Network CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `commonName` auf den Namen der Network CA (im Regelfall "Firmenname Network CA") gesetzt werden.
1. Im Abschnitt `[ additional_oids ]` müssen die OIDs entsprechend der eigenen registrierten OIDs ersetzt werden.

``` bash
cd /data/pki

cat > etc/network-ca.conf << "EOF"
#
# Example Corporation Network CA
#

[ default ]
ca                      = network-ca
base_url                = https://pki.example.com
aia_url                 = $base_url/$ca.cer
crl_url                 = $base_url/$ca.crl
name_opt                = multiline,-esc_msb,utf8
openssl_conf            = openssl_init

[ ca ]
default_ca              = network_ca

[ network_ca ]
dir                     = .
certs                   = $dir/ca/$ca/certs
crl_dir                 = $dir/ca/$ca/crl
database                = $dir/ca/$ca/index.txt
new_certs_dir           = $dir/ca/$ca/newcerts
certificate             = $dir/ca/$ca/cacert.pem
serial                  = $dir/ca/$ca/serial
crlnumber               = $dir/ca/$ca/crlnumber
crl                     = $dir/ca/$ca/crl.pem
private_key             = $dir/ca/$ca/private/cakey.pem
RANDFILE                = $dir/ca/$ca/private/.rand
unique_subject          = no
default_days            = 1826
default_md              = sha256
digests                 = sha1
policy                  = match_pol
email_in_dn             = no
preserve                = no
name_opt                = $name_opt
cert_opt                = ca_default
copy_extensions         = none
x509_extensions         = signing_ca_ext
default_crl_days        = 30
crl_extensions          = crl_ext

[ match_pol ]
countryName             = match
stateOrProvinceName     = optional
localityName            = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied

[ any_pol ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = ca_dn
req_extensions          = ca_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = no
SET-ex3                 = SET extension number 3

[ ca_dn ]
countryName             = "DE"
organizationName        = "Example Corporation"
organizationalUnitName  = "Certification Authority"
commonName              = "Example Corporation Network CA"

[ ca_reqext ]
basicConstraints        = critical, CA:TRUE
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash

[ intermediate_ca_ext ]
basicConstraints        = critical, CA:TRUE
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssurance, mediumAssuranceDevice

[ signing_ca_ext ]
basicConstraints        = critical, CA:TRUE, pathLen:0
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssurance, mediumAssuranceDevice

[ crl_ext ]
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info

[ issuer_info ]
caIssuers;URI.0         = $aia_url

[ crl_info ]
URI.0                   = $crl_url

[ openssl_init ]
oid_section             = additional_oids

[ additional_oids ]
mediumAssurance         = Medium Assurance, 1.3.6.1.4.1.0.1.7.8
mediumAssuranceDevice   = Medium Device Assurance, 1.3.6.1.4.1.0.1.7.9
"EOF"
```

Verzeichnisstruktur anlegen, RANDFILE erzeugen, zufälligen Startwert für die späteren Serialnummern festlegen und Indexfile anlegen.

``` bash
mkdir -p ca/network-ca/{certs,crl,newcerts,private,revoked}
chmod 0700 ca/network-ca/private
openssl rand -out ca/network-ca/private/.rand 65536
echo `openssl rand -hex 64 | tr '[[:lower:]]' '[[:upper:]]'` > ca/network-ca/serial
cp ca/network-ca/serial ca/network-ca/crlnumber
touch ca/network-ca/index.txt ca/network-ca/index.txt.attr
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > ca/network-ca/private/network-ca.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out ca/network-ca/private/cakey.pem \
    -pass file:ca/network-ca/private/network-ca.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/network-ca.conf \
    -new \
    -sha256 \
    -out ca/network-ca/careq.pem \
    -key ca/network-ca/private/cakey.pem \
    -passin file:ca/network-ca/private/network-ca.pwd
```

Durch die Root CA signiertes Zertifikat für die Network CA erzeugen. Die Gültigkeitsdauer wird auf 5 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/root-ca.conf \
    -batch \
    -md sha256 \
    -in ca/network-ca/careq.pem \
    -out ca/network-ca/cacert.pem \
    -extensions intermediate_ca_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+5y '+%Y%m01000000Z'` \
    -passin file:ca/root-ca/private/root-ca.pwd
```

Initiale CRL der Network CA erzeugen.

``` bash
openssl ca \
    -config etc/network-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/network-ca/crl.pem \
    -passin file:ca/network-ca/private/network-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl x509 \
    -in ca/network-ca/cacert.pem \
    -out ca/network-ca.cer \
    -outform DER
```

CRL in ein veröffentlichbares Format exportieren.

``` bash
openssl crl \
    -in ca/network-ca/crl.pem \
    -out ca/network-ca.crl \
    -outform DER
```

Chain der Network CA erzeugen.

``` bash
cat ca/network-ca/crl.pem ca/root-ca/crl.pem > ca/network-ca-crl-chain.pem
cat ca/network-ca/cacert.pem ca/root-ca/cacert.pem > ca/network-ca-chain.pem
```

Chain der Network CA in ein veröffentlichbares Format exportieren.

``` bash
openssl crl2pkcs7 \
    -nocrl \
    -certfile ca/network-ca-chain.pem \
    -out ca/network-ca-chain.p7c \
    -outform DER
```

#### Identity Signing CA erstellen

In der `etc/identity-ca.conf` müssen noch ein paar Anpassungen vorgenommen werden:

1. Im Abschnitt `[ default ]` muss die Option `base_url` auf den URL gesetzt werden, unter dem später die Certs, CRLs und Chains veröffentlicht werden sollen.
1. Im Abschnitt `[ ca_dn ]` muss die Option `countryName` auf das internationale zweibuchstabige Länderkürzel des Betreibers der Identity CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationName` auf den Firmennamen des Betreibers der Identity CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationalUnitName` auf den zuständigen Abteilungsnamen des Betreibers der Identity CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `commonName` auf den Namen der Identity CA (im Regelfall "Firmenname Identity CA") gesetzt werden.
1. Im Abschnitt `[ additional_oids ]` müssen die OIDs entsprechend der eigenen registrierten OIDs ersetzt werden.

``` bash
cd /data/pki

cat > etc/identity-ca.conf << "EOF"
#
# Example Corporation Identity CA
#

[ default ]
ca                      = identity-ca
base_url                = https://pki.example.com
aia_url                 = $base_url/$ca.cer
crl_url                 = $base_url/$ca.crl
name_opt                = multiline,-esc_msb,utf8
openssl_conf            = openssl_init

[ ca ]
default_ca              = identity_ca

[ identity_ca ]
dir                     = .
certs                   = $dir/ca/$ca/certs
crl_dir                 = $dir/ca/$ca/crl
database                = $dir/ca/$ca/index.txt
new_certs_dir           = $dir/ca/$ca/newcerts
certificate             = $dir/ca/$ca/cacert.pem
serial                  = $dir/ca/$ca/serial
crlnumber               = $dir/ca/$ca/crlnumber
crl                     = $dir/ca/$ca/crl.pem
private_key             = $dir/ca/$ca/private/cakey.pem
RANDFILE                = $dir/ca/$ca/private/.rand
unique_subject          = no
default_days            = 730
default_md              = sha256
digests                 = sha1
policy                  = match_pol
email_in_dn             = no
preserve                = no
name_opt                = $name_opt
cert_opt                = ca_default
copy_extensions         = copy
x509_extensions         = identity_ca_ext
default_crl_days        = 30
crl_extensions          = crl_ext

[ match_pol ]
countryName             = match
stateOrProvinceName     = optional
localityName            = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied

[ any_pol ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = ca_dn
req_extensions          = ca_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = no
SET-ex3                 = SET extension number 3

[ ca_dn ]
countryName             = "DE"
organizationName        = "Example Corporation"
organizationalUnitName  = "Certification Authority"
commonName              = "Example Corporation Identity CA"

[ ca_reqext ]
basicConstraints        = critical, CA:TRUE, pathLen:0
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash

[ identity_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, emailProtection, clientAuth, msSmartcardLogin
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssurance

[ encryption_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, keyEncipherment
extendedKeyUsage        = critical, emailProtection, msEFS
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssurance

[ crl_ext ]
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info

[ issuer_info ]
caIssuers;URI.0         = $aia_url

[ crl_info ]
URI.0                   = $crl_url

[ openssl_init ]
oid_section             = additional_oids

[ additional_oids ]
mediumAssurance         = Medium Assurance, 1.3.6.1.4.1.0.1.7.8
mediumAssuranceDevice   = Medium Device Assurance, 1.3.6.1.4.1.0.1.7.9
"EOF"
```

Verzeichnisstruktur anlegen, RANDFILE erzeugen, zufälligen Startwert für die späteren Serialnummern festlegen und Indexfile anlegen.

``` bash
mkdir -p ca/identity-ca/{certs,crl,newcerts,private,revoked}
chmod 0700 ca/identity-ca/private
openssl rand -out ca/identity-ca/private/.rand 65536
echo `openssl rand -hex 64 | tr '[[:lower:]]' '[[:upper:]]'` > ca/identity-ca/serial
cp ca/identity-ca/serial ca/identity-ca/crlnumber
touch ca/identity-ca/index.txt ca/identity-ca/index.txt.attr
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > ca/identity-ca/private/identity-ca.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out ca/identity-ca/private/cakey.pem \
    -pass file:ca/identity-ca/private/identity-ca.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/identity-ca.conf \
    -new \
    -sha256 \
    -out ca/identity-ca/careq.pem \
    -key ca/identity-ca/private/cakey.pem \
    -passin file:ca/identity-ca/private/identity-ca.pwd
```

Durch die Network CA signiertes Zertifikat für die Identity CA erzeugen. Die Gültigkeitsdauer wird auf 5 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/network-ca.conf \
    -batch \
    -md sha256 \
    -in ca/identity-ca/careq.pem \
    -out ca/identity-ca/cacert.pem \
    -extensions signing_ca_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+5y '+%Y%m01000000Z'` \
    -passin file:ca/network-ca/private/network-ca.pwd
```

Initiale CRL der Identity CA erzeugen.

``` bash
openssl ca \
    -config etc/identity-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/identity-ca/crl.pem \
    -passin file:ca/identity-ca/private/identity-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl x509 \
    -in ca/identity-ca/cacert.pem \
    -out ca/identity-ca.cer \
    -outform DER
```

CRL in ein veröffentlichbares Format exportieren.

``` bash
openssl crl \
    -in ca/identity-ca/crl.pem \
    -out ca/identity-ca.crl \
    -outform DER
```

Chain der Identity CA erzeugen.

``` bash
cat ca/identity-ca/crl.pem ca/network-ca/crl.pem > ca/identity-ca-crl-chain.pem
cat ca/identity-ca/cacert.pem ca/network-ca/cacert.pem > ca/identity-ca-chain.pem
```

Chain der Identity CA in ein veröffentlichbares Format exportieren.

``` bash
openssl crl2pkcs7 \
    -nocrl \
    -certfile ca/identity-ca-chain.pem \
    -out ca/identity-ca-chain.p7c \
    -outform DER
```

#### Component Signing CA erstellen

In der `etc/component-ca.conf` müssen noch ein paar Anpassungen vorgenommen werden:

1. Im Abschnitt `[ default ]` muss die Option `base_url` auf den URL gesetzt werden, unter dem später die Certs, CRLs und Chains veröffentlicht werden sollen.
1. **Wird derzeit nicht verwendet** Im Abschnitt `[ default ]` muss die Option `ocsp_url` auf den URL gesetzt werden, unter dem später der OCSP-Responder erreichbar sein wird.
1. Im Abschnitt `[ ca_dn ]` muss die Option `countryName` auf das internationale zweibuchstabige Länderkürzel des Betreibers der Component CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationName` auf den Firmennamen des Betreibers der Component CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `organizationalUnitName` auf den zuständigen Abteilungsnamen des Betreibers der Component CA gesetzt werden.
1. Im Abschnitt `[ ca_dn ]` muss die Option `commonName` auf den Namen der Component CA (im Regelfall "Firmenname Component CA") gesetzt werden.
1. Im Abschnitt `[ additional_oids ]` müssen die OIDs entsprechend der eigenen registrierten OIDs ersetzt werden.

``` bash
cd /data/pki

cat > etc/component-ca.conf << "EOF"
#
# Example Corporation Component CA
#

[ default ]
ca                      = component-ca
base_url                = https://pki.example.com
ocsp_url                = https://pki.example.com/ocsp
aia_url                 = $base_url/$ca.cer
crl_url                 = $base_url/$ca.crl
name_opt                = multiline,-esc_msb,utf8
openssl_conf            = openssl_init

[ ca ]
default_ca              = component_ca

[ component_ca ]
dir                     = .
certs                   = $dir/ca/$ca/certs
crl_dir                 = $dir/ca/$ca/crl
database                = $dir/ca/$ca/index.txt
new_certs_dir           = $dir/ca/$ca/newcerts
certificate             = $dir/ca/$ca/cacert.pem
serial                  = $dir/ca/$ca/serial
crlnumber               = $dir/ca/$ca/crlnumber
crl                     = $dir/ca/$ca/crl.pem
private_key             = $dir/ca/$ca/private/cakey.pem
RANDFILE                = $dir/ca/$ca/private/.rand
unique_subject          = no
default_days            = 730
default_md              = sha256
digests                 = sha1
policy                  = match_pol
email_in_dn             = no
preserve                = no
name_opt                = $name_opt
cert_opt                = ca_default
copy_extensions         = copy
x509_extensions         = server_ext
default_crl_days        = 30
crl_extensions          = crl_ext

[ match_pol ]
countryName             = match
stateOrProvinceName     = optional
localityName            = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied

[ any_pol ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = ca_dn
req_extensions          = ca_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = no
SET-ex3                 = SET extension number 3

[ ca_dn ]
countryName             = "DE"
organizationName        = "Example Corporation"
organizationalUnitName  = "Certification Authority"
commonName              = "Example Corporation Component CA"

[ ca_reqext ]
basicConstraints        = critical, CA:TRUE, pathLen:0
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash

[ server_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, digitalSignature, keyEncipherment
extendedKeyUsage        = critical, serverAuth, clientAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
#authorityInfoAccess     = @ocsp_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssuranceDevice

[ client_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, clientAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
#authorityInfoAccess     = @ocsp_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssuranceDevice

[ timestamp_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, timeStamping
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
crlDistributionPoints   = @crl_info
certificatePolicies     = mediumAssuranceDevice

[ ocspsign_ext ]
basicConstraints        = CA:FALSE
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, OCSPSigning
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info
noCheck                 = null
certificatePolicies     = mediumAssuranceDevice

[ crl_ext ]
authorityKeyIdentifier  = keyid:always
authorityInfoAccess     = @issuer_info

[ ocsp_info ]
caIssuers;URI.0         = $aia_url
OCSP;URI.0              = $ocsp_url

[ issuer_info ]
caIssuers;URI.0         = $aia_url

[ crl_info ]
URI.0                   = $crl_url

[ openssl_init ]
oid_section             = additional_oids

[ additional_oids ]
mediumAssurance         = Medium Assurance, 1.3.6.1.4.1.0.1.7.8
mediumAssuranceDevice   = Medium Device Assurance, 1.3.6.1.4.1.0.1.7.9
"EOF"
```

Verzeichnisstruktur anlegen, RANDFILE erzeugen, zufälligen Startwert für die späteren Serialnummern festlegen und Indexfile anlegen.

``` bash
mkdir -p ca/component-ca/{certs,crl,newcerts,private,revoked}
chmod 0700 ca/component-ca/private
openssl rand -out ca/component-ca/private/.rand 65536
echo `openssl rand -hex 64 | tr '[[:lower:]]' '[[:upper:]]'` > ca/component-ca/serial
cp ca/component-ca/serial ca/component-ca/crlnumber
touch ca/component-ca/index.txt ca/component-ca/index.txt.attr
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > ca/component-ca/private/component-ca.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out ca/component-ca/private/cakey.pem \
    -pass file:ca/component-ca/private/component-ca.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/component-ca.conf \
    -new \
    -sha256 \
    -out ca/component-ca/careq.pem \
    -key ca/component-ca/private/cakey.pem \
    -passin file:ca/component-ca/private/component-ca.pwd
```

Durch die Network CA signiertes Zertifikat für die Component CA erzeugen. Die Gültigkeitsdauer wird auf 5 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/network-ca.conf \
    -batch \
    -md sha256 \
    -in ca/component-ca/careq.pem \
    -out ca/component-ca/cacert.pem \
    -extensions signing_ca_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+5y '+%Y%m01000000Z'` \
    -passin file:ca/network-ca/private/network-ca.pwd
```

Initiale CRL der Component CA erzeugen.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/component-ca/crl.pem \
    -passin file:ca/component-ca/private/component-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl x509 \
    -in ca/component-ca/cacert.pem \
    -out ca/component-ca.cer \
    -outform DER
```

CRL in ein veröffentlichbares Format exportieren.

``` bash
openssl crl \
    -in ca/component-ca/crl.pem \
    -out ca/component-ca.crl \
    -outform DER
```

Chain der Component CA erzeugen.

``` bash
cat ca/component-ca/crl.pem ca/network-ca/crl.pem > ca/component-ca-crl-chain.pem
cat ca/component-ca/cacert.pem ca/network-ca/cacert.pem > ca/component-ca-chain.pem
```

Chain der Component CA in ein veröffentlichbares Format exportieren.

``` bash
openssl crl2pkcs7 \
    -nocrl -certfile ca/component-ca-chain.pem \
    -out ca/component-ca-chain.p7c \
    -outform DER
```

#### CRLs und Chains erneuern

Die CRLs und Chains sollten regelmässig (spätestens alle 30 Tage) aktualisiert und veröffentlicht werden, da sie ansonsten ungültig werden und manche Clients deshalb auch die Zertifikate als ungültig einstufen.

Um diesen Zustand gar nicht erst entstehen zu lassen, legen wir uns ein passendes Script an und automatisieren dessen Ausführung (täglich 06:00 Uhr) per `cron`.

``` bash
cd /data/pki

cat > update-crls-chains.sh << "EOF"
#!/bin/sh

cd /data/pki

openssl ca \
    -config etc/root-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/root-ca/crl.pem \
    -passin file:ca/root-ca/private/root-ca.pwd
openssl ca \
    -config etc/network-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/network-ca/crl.pem \
    -passin file:ca/network-ca/private/network-ca.pwd
openssl ca \
    -config etc/identity-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/identity-ca/crl.pem \
    -passin file:ca/identity-ca/private/identity-ca.pwd
openssl ca \
    -config etc/component-ca.conf \
    -gencrl \
    -md sha256 \
    -out ca/component-ca/crl.pem \
    -passin file:ca/component-ca/private/component-ca.pwd

openssl crl \
    -in ca/root-ca/crl.pem \
    -out ca/root-ca.crl \
    -outform DER
openssl crl \
    -in ca/network-ca/crl.pem \
    -out ca/network-ca.crl \
    -outform DER
openssl crl \
    -in ca/identity-ca/crl.pem \
    -out ca/identity-ca.crl \
    -outform DER
openssl crl \
    -in ca/component-ca/crl.pem \
    -out ca/component-ca.crl \
    -outform DER

cat ca/network-ca/crl.pem ca/root-ca/crl.pem > ca/network-ca-crl-chain.pem
cat ca/identity-ca/crl.pem ca/network-ca-crl-chain.pem > ca/identity-ca-crl-chain.pem
cat ca/component-ca/crl.pem ca/network-ca-crl-chain.pem > ca/component-ca-crl-chain.pem

cat ca/network-ca/cacert.pem ca/root-ca/cacert.pem > ca/network-ca-chain.pem
cat ca/identity-ca/cacert.pem ca/network-ca/cacert.pem > ca/identity-ca-chain.pem
cat ca/component-ca/cacert.pem ca/network-ca/cacert.pem > ca/component-ca-chain.pem

openssl crl2pkcs7 \
    -nocrl \
    -certfile ca/network-ca-chain.pem \
    -out ca/network-ca-chain.p7c \
    -outform DER
openssl crl2pkcs7 \
    -nocrl \
    -certfile ca/identity-ca-chain.pem \
    -out ca/identity-ca-chain.p7c \
    -outform DER
openssl crl2pkcs7 \
    -nocrl \
    -certfile ca/component-ca-chain.pem \
    -out ca/component-ca-chain.p7c \
    -outform DER

cp ca/root-ca.cer /data/www/vhosts/pki.example.com/data/root-ca.cer
cp ca/network-ca.cer /data/www/vhosts/pki.example.com/data/network-ca.cer
cp ca/identity-ca.cer /data/www/vhosts/pki.example.com/data/identity-ca.cer
cp ca/component-ca.cer /data/www/vhosts/pki.example.com/data/component-ca.cer

cp ca/root-ca.crl /data/www/vhosts/pki.example.com/data/root-ca.crl
cp ca/network-ca.crl /data/www/vhosts/pki.example.com/data/network-ca.crl
cp ca/identity-ca.crl /data/www/vhosts/pki.example.com/data/identity-ca.crl
cp ca/component-ca.crl /data/www/vhosts/pki.example.com/data/component-ca.crl

cp ca/network-ca-chain.p7c /data/www/vhosts/pki.example.com/data/network-ca-chain.p7c
cp ca/identity-ca-chain.p7c /data/www/vhosts/pki.example.com/data/identity-ca-chain.p7c
cp ca/component-ca-chain.p7c /data/www/vhosts/pki.example.com/data/component-ca-chain.p7c

chmod 0440 /data/www/vhosts/pki.example.com/data/*.cer
chmod 0440 /data/www/vhosts/pki.example.com/data/*.crl
chmod 0440 /data/www/vhosts/pki.example.com/data/*.p7c

chown www:www /data/www/vhosts/pki.example.com/data/*.cer
chown www:www /data/www/vhosts/pki.example.com/data/*.crl
chown www:www /data/www/vhosts/pki.example.com/data/*.p7c

service dovecot restart
service postfix restart
service apache24 restart
"EOF"

chmod 0755 update-crls-chains.sh
```

Cronjob für `update-crls-chains.sh` anlegen.

``` bash
cat >> /etc/crontab << "EOF"
0       6       *       *       *       root    /data/pki/update-crls-chains.sh
"EOF"
```

### OpenSSL Zertifikate

#### Identity Certificate erstellen

``` bash
cd /data/pki

cat > etc/identity.conf << "EOF"
# Identity certificate request

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = identity_dn
req_extensions          = identity_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ identity_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. YOUR name)
commonName_max          = 64
emailAddress            = Email Address
emailAddress_max        = 64

[ identity_reqext ]
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, emailProtection, clientAuth
subjectKeyIdentifier    = hash
subjectAltName          = email:move
"EOF"

cat > etc/encryption.conf << "EOF"
# Encryption certificate request

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = encryption_dn
req_extensions          = encryption_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ encryption_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. YOUR name)
commonName_max          = 64
emailAddress            = Email Address
emailAddress_max        = 64

[ encryption_reqext ]
keyUsage                = critical, keyEncipherment
extendedKeyUsage        = critical, emailProtection
subjectKeyIdentifier    = hash
subjectAltName          = email:move
"EOF"
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/admin-id.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/admin-id.key \
    -pass file:private/admin-id.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/identity.conf \
    -new \
    -sha256 \
    -out certs/admin-id.csr \
    -key private/admin-id.key \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=Administrator/emailAddress=admin@example.com \
    -passin file:private/admin-id.pwd
```

Durch die Identity CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/identity-ca.conf \
    -batch \
    -md sha256 \
    -in certs/admin-id.csr \
    -out certs/admin-id.crt \
    -extensions identity_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/identity-ca/private/identity-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl pkcs12 \
    -export \
    -aes256 \
    -inkey private/admin-id.key \
    -certfile ca/identity-ca-chain.pem \
    -name "Administrator (System Administration)" \
    -caname "Example Corporation Identity CA" \
    -caname "Example Corporation Network CA" \
    -caname "Example Corporation Root CA" \
    -in certs/admin-id.crt \
    -out certs/admin-id.p12 \
    -passin file:private/admin-id.pwd
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/admin-enc.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/admin-enc.key \
    -pass file:private/admin-enc.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/encryption.conf \
    -new \
    -sha256 \
    -out certs/admin-enc.csr \
    -key private/admin-enc.key \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=Administrator/emailAddress=admin@example.com \
    -passin file:private/admin-enc.pwd
```

Durch die Identity CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/identity-ca.conf \
    -batch \
    -md sha256 \
    -in certs/admin-enc.csr \
    -out certs/admin-enc.crt \
    -extensions encryption_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/identity-ca/private/identity-ca.pwd
```

Zertifikat in ein veröffentlichbares Format exportieren.

``` bash
openssl pkcs12 \
    -export \
    -aes256 \
    -inkey private/admin-enc.key \
    -certfile ca/identity-ca-chain.pem \
    -name "Administrator (System Administration)" \
    -caname "Example Corporation Identity CA" \
    -caname "Example Corporation Network CA" \
    -caname "Example Corporation Root CA" \
    -in certs/admin-enc.crt \
    -out certs/admin-enc.p12 \
    -passin file:private/admin-enc.pwd
```

#### TLS Client Certificate erstellen

``` bash
cd /data/pki

cat > etc/tls-client.conf << "EOF"
# TLS client certificate request

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = no
distinguished_name      = client_dn
req_extensions          = client_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ client_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. server FQDN)
commonName_max          = 64

[ client_reqext ]
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, clientAuth
subjectKeyIdentifier    = hash
"EOF"
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/workstation.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/workstation.key \
    -pass file:private/workstation.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/tls-client.conf \
    -new \
    -sha256 \
    -out certs/workstation.csr \
    -key private/workstation.key \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=Workstation \
    -passin file:private/workstation.pwd
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/workstation.csr \
    -out certs/workstation.crt \
    -extensions client_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

#### TLS Server Certificate erstellen

In der `etc/tls-server.conf` müssen noch ein paar Anpassungen vorgenommen werden:

1. Im Abschnitt `[ default ]` muss die Option `SAN` auf den Domainnamen (ohne Subdomain) des Serverbetreibers gesetzt werden.

``` bash
cd /data/pki

cat > etc/tls-server.conf << "EOF"
# TLS server certificate request

[ default ]
SAN                     = DNS:example.com

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = yes
distinguished_name      = server_dn
req_extensions          = server_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ server_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. server FQDN)
commonName_max          = 64
emailAddress            = Email Address
emailAddress_max        = 64

[ server_reqext ]
keyUsage                = critical, digitalSignature, keyEncipherment
extendedKeyUsage        = critical, serverAuth, clientAuth
subjectKeyIdentifier    = hash
subjectAltName          = $ENV::SAN
"EOF"
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/devnull.example.com.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/devnull.example.com.key.enc \
    -pass file:private/devnull.example.com.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
setenv SAN "DNS:devnull.example.com"
openssl req \
    -config etc/tls-server.conf \
    -new \
    -sha256 \
    -out certs/devnull.example.com.csr \
    -key private/devnull.example.com.key.enc \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=devnull.example.com \
    -passin file:private/devnull.example.com.pwd
unsetenv SAN
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/devnull.example.com.csr \
    -out certs/devnull.example.com.crt \
    -extensions server_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

Eine passwortlose Kopie des privaten Schlüssels anlegen, wie sie zum problemlosen Starten von Diensten wie Webserver, Mailserver, etc benötigt wird.

``` bash
openssl pkey \
    -in private/devnull.example.com.key.enc \
    -out private/devnull.example.com.key \
    -passin file:private/devnull.example.com.pwd
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/mail.example.com.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/mail.example.com.key.enc \
    -pass file:private/mail.example.com.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
setenv SAN "DNS:mail.example.com"
openssl req \
    -config etc/tls-server.conf \
    -new \
    -sha256 \
    -out certs/mail.example.com.csr \
    -key private/mail.example.com.key.enc \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=mail.example.com \
    -passin file:private/mail.example.com.pwd
unsetenv SAN
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/mail.example.com.csr \
    -out certs/mail.example.com.crt \
    -extensions server_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

Eine passwortlose Kopie des privaten Schlüssels anlegen, wie sie zum problemlosen Starten von Diensten wie Webserver, Mailserver, etc benötigt wird.

``` bash
openssl pkey \
    -in private/mail.example.com.key.enc \
    -out private/mail.example.com.key \
    -passin file:private/mail.example.com.pwd
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/www.example.com.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/www.example.com.key.enc \
    -pass file:private/www.example.com.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
setenv SAN "DNS:www.example.com,DNS:example.com"
openssl req \
    -config etc/tls-server.conf \
    -new \
    -sha256 \
    -out certs/www.example.com.csr \
    -key private/www.example.com.key.enc \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=www.example.com \
    -passin file:private/www.example.com.pwd
unsetenv SAN
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/www.example.com.csr \
    -out certs/www.example.com.crt \
    -extensions server_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

Eine passwortlose Kopie des privaten Schlüssels anlegen, wie sie zum problemlosen Starten von Diensten wie Webserver, Mailserver, etc benötigt wird.

``` bash
openssl pkey \
    -in private/www.example.com.key.enc \
    -out private/www.example.com.key \
    -passin file:private/www.example.com.pwd
```

#### Time-stamping Certificate erstellen

``` bash
cd /data/pki

cat > etc/timestamping.conf << "EOF"
# Time-stamping certificate request

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = no
distinguished_name      = timestamp_dn
req_extensions          = timestamp_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ timestamp_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. server FQDN)
commonName_max          = 64

[ timestamp_reqext ]
keyUsage                = critical, digitalSignature
extendedKeyUsage        = critical, timeStamping
subjectKeyIdentifier    = hash
"EOF"
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/timestamping.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/timestamping.key \
    -pass file:private/timestamping.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/timestamping.conf \
    -new \
    -sha256 \
    -out certs/timestamping.csr \
    -key private/timestamping.key \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=Example\ Corporation\ Timestamping\ Service \
    -passin file:private/timestamping.pwd
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/timestamping.csr \
    -out certs/timestamping.crt \
    -extensions timestamp_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

#### OCSP-Signing Certificate erstellen

``` bash
cd /data/pki

cat > etc/ocspsigning.conf << "EOF"
# OCSP-signing certificate request

[ req ]
default_bits            = 4096
default_md              = sha256
encrypt_key             = no
distinguished_name      = ocspsign_dn
req_extensions          = ocspsign_reqext
string_mask             = utf8only
utf8                    = yes
prompt                  = yes
SET-ex3                 = SET extension number 3

[ ocspsign_dn ]
countryName             = Country Name (2 letter code)
countryName_min         = 2
countryName_max         = 2
stateOrProvinceName     = State or Province Name (full name)
localityName            = Locality Name (eg, city)
organizationName        = Organization Name (eg, company)
organizationalUnitName  = Organizational Unit Name (eg, section)
commonName              = Common Name (e.g. server FQDN)
commonName_max          = 64

[ ocspsign_reqext ]
keyUsage                = critical, digitalSignature, keyEncipherment
extendedKeyUsage        = critical, serverAuth, clientAuth
subjectKeyIdentifier    = hash
"EOF"
```

Zufälliges, sicheres Passwort für das Zertifikat erzeugen und zur späteren (automatisierten) Verwendung in der .pwd speichern.

``` bash
openssl rand -hex 64 | openssl passwd -5 -stdin | tr -cd '[[:print:]]' | cut -c 2-17 \
    > private/ocspresponder.pwd
```

Privaten Schlüssel (RSA mit 4096 Bit Länge und AES256 verschlüsselt) zum Signieren des Zertifikats erzeugen.

``` bash
openssl genpkey \
    -aes-256-cbc \
    -algorithm RSA \
    -pkeyopt 'rsa_keygen_bits:4096' \
    -out private/ocspresponder.key \
    -pass file:private/ocspresponder.pwd
```

Zertifikatsanforderung erzeugen und mit dem privaten Schlüssel signieren.

``` bash
openssl req \
    -config etc/ocspsigning.conf \
    -new \
    -sha256 \
    -out certs/ocspresponder.csr \
    -key private/ocspresponder.key \
    -subj /C=DE/ST=State/L=Locality/O=Example\ Corporation/OU=System\ Administration/CN=Example\ Corporation\ OCSP\ Responder \
    -passin file:private/ocspresponder.pwd
```

Durch die Component CA signiertes Zertifikat erzeugen. Die Gültigkeitsdauer wird auf 2 Jahre ab dem 1. des aktuellen Monats festgelegt.

``` bash
openssl ca \
    -config etc/component-ca.conf \
    -batch \
    -md sha256 \
    -in certs/ocspresponder.csr \
    -out certs/ocspresponder.crt \
    -extensions ocspsign_ext \
    -startdate `date -j -u '+%Y%m01000000Z'` \
    -enddate `date -j -u -v+2y '+%Y%m01000000Z'` \
    -passin file:ca/component-ca/private/component-ca.pwd
```

???+ note

    Work in progress basierend auf dem [OpenSSL PKI Tutorial v1.0 (Stand: 31.10.2013)](https://pki-tutorial.readthedocs.io/){: target="_blank" rel="noopener"} (für Erläuterungen bitte auch dort nachsehen).

## Wie geht es weiter?

Natürlich mit dem [Hosting System](/howtos/gentoo/hosting_system/).
