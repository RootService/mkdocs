---
title: 'Unbound'
description: 'In diesem HowTo wird step-by-step die Installation von Unbound für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Unbound

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- Unbound 1.20.0 (DNScrypt, DNS over TLS)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `dns/unbound` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_libsodium
cat <<'EOF' > /var/db/ports/security_libsodium/options
_OPTIONS_READ=libsodium-1.0.19
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/devel_libevent
cat <<'EOF' > /var/db/ports/devel_libevent/options
_OPTIONS_READ=libevent-2.1.12
_FILE_COMPLETE_OPTIONS_LIST=OPENSSL THREADS
OPTIONS_FILE_SET+=OPENSSL
OPTIONS_FILE_SET+=THREADS
EOF

mkdir -p /var/db/ports/dns_unbound
cat <<'EOF' > /var/db/ports/dns_unbound/options
_OPTIONS_READ=unbound-1.20.0
_FILE_COMPLETE_OPTIONS_LIST=DEP-RSA1024 DNSCRYPT DNSTAP DOCS DOH DYNLIB ECDSA EVAPI FILTER_AAAA GOST HIREDIS LIBEVENT MUNIN_PLUGIN PYTHON SUBNET TFOCL TFOSE THREADS
OPTIONS_FILE_UNSET+=DEP-RSA1024
OPTIONS_FILE_SET+=DNSCRYPT
OPTIONS_FILE_UNSET+=DNSTAP
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=DOH
OPTIONS_FILE_SET+=DYNLIB
OPTIONS_FILE_SET+=ECDSA
OPTIONS_FILE_UNSET+=EVAPI
OPTIONS_FILE_UNSET+=FILTER_AAAA
OPTIONS_FILE_SET+=GOST
OPTIONS_FILE_UNSET+=HIREDIS
OPTIONS_FILE_SET+=LIBEVENT
OPTIONS_FILE_UNSET+=MUNIN_PLUGIN
OPTIONS_FILE_UNSET+=PYTHON
OPTIONS_FILE_SET+=SUBNET
OPTIONS_FILE_SET+=TFOCL
OPTIONS_FILE_SET+=TFOSE
OPTIONS_FILE_SET+=THREADS
EOF


cd /usr/ports/dns/unbound
make all install clean-depends clean


sysrc local_unbound_enable=NO
sysrc unbound_enable=YES
```

## Konfiguration

Wir konfigurieren Unbound:

``` bash
cat <<'EOF' > /usr/local/etc/unbound/unbound.conf
server:
  verbosity: 1
  num-threads: 4
  interface: 127.0.0.1
  interface: ::1
  port: 53
  access-control: 0.0.0.0/0 refuse
  access-control: 127.0.0.0/8 allow
  access-control: ::0/0 refuse
  access-control: ::1 allow
  access-control: ::ffff:127.0.0.1 allow
  access-control: 10.0.0.0/8 allow
  access-control: 172.16.0.0/12 allow
  access-control: 192.168.0.0/16 allow
  access-control: 169.254.0.0/16 allow
  access-control: fd00::/8 allow
  access-control: fe80::/10 allow
  access-control: ::ffff:0:0/96 allow
  do-ip4: yes
  do-ip6: yes
  do-udp: yes
  do-tcp: yes
  logfile: "/usr/local/etc/unbound/unbound.log"
  root-hints: "/usr/local/etc/unbound/root.hints"
  auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"
  tls-cert-bundle: "/usr/local/share/certs/ca-root-nss.crt"
  aggressive-nsec: yes
  cache-max-ttl: 14400
  cache-min-ttl: 1200
  so-rcvbuf: 4m
  so-sndbuf: 4m
  msg-cache-size: 128m
  msg-cache-slabs: 8
  num-queries-per-thread: 4096
  outgoing-range: 8192
  rrset-cache-size: 256m
  rrset-cache-slabs: 8
  infra-cache-slabs: 8
  key-cache-slabs: 8
  hide-identity: yes
  hide-version: yes
  prefetch: yes
  serve-expired: yes
  serve-expired-ttl: 86400
  serve-expired-client-timeout: 1800
  rrset-roundrobin: yes
  so-reuseport: yes
  use-caps-for-id: yes
  harden-short-bufsize: yes
  harden-large-queries: yes
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-below-nxdomain: yes
  harden-referral-path: yes
  harden-algo-downgrade: yes
  qname-minimisation: yes
  private-address: 10.0.0.0/8
  private-address: 172.16.0.0/12
  private-address: 192.168.0.0/16
  private-address: 169.254.0.0/16
  private-address: fd00::/8
  private-address: fe80::/10
  private-address: ::ffff:0:0/96
  private-domain: "example.lan"
  unwanted-reply-threshold: 10000
  do-not-query-localhost: no
  minimal-responses: yes
  val-clean-additional: yes
  local-zone: "localhost." static
  local-data: "localhost. 10800 IN NS localhost."
  local-data: "localhost. 10800 IN SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
  local-data: "localhost. 10800 IN A 127.0.0.1"
  local-zone: "127.in-addr.arpa." static
  local-data: "127.in-addr.arpa. 10800 IN NS localhost."
  local-data: "127.in-addr.arpa. 10800 IN SOA localhost. nobody.invalid. 2 3600 1200 604800 10800"
  local-data: "1.0.0.127.in-addr.arpa. 10800 IN PTR localhost."

#forward-zone:
#  name: "."
#  forward-tls-upstream: yes
#  forward-addr: 1.0.0.1@853#one.one.one.one
#  forward-addr: 8.8.4.4@853#dns.google
#  forward-addr: 149.112.112.112@853#dns.quad9.net
#  forward-addr: 1.1.1.1@853#one.one.one.one
#  forward-addr: 8.8.8.8@853#dns.google
#  forward-addr: 9.9.9.9@853#dns.quad9.net

#forward-zone:
#  name: "."
#  forward-addr: 1.0.0.1@53#one.one.one.one
#  forward-addr: 8.8.4.4@53#dns.google
#  forward-addr: 149.112.112.112@53#dns.quad9.net
#  forward-addr: 1.1.1.1@53#one.one.one.one
#  forward-addr: 8.8.8.8@53#dns.google
#  forward-addr: 9.9.9.9@53#dns.quad9.net

remote-control:
  control-enable: yes
  control-interface: 127.0.0.1
  control-interface: ::1
  control-port: 8953
  server-key-file: "/usr/local/etc/unbound/unbound_server.key"
  server-cert-file: "/usr/local/etc/unbound/unbound_server.pem"
  control-key-file: "/usr/local/etc/unbound/unbound_control.key"
  control-cert-file: "/usr/local/etc/unbound/unbound_control.pem"
EOF


curl -o "/usr/local/etc/unbound/root.hints" -L "https://www.internic.net/domain/named.root"
chown unbound /usr/local/etc/unbound/root.hints


sudo -u unbound unbound-anchor -a "/usr/local/etc/unbound/root.key"


sudo -u unbound unbound-control-setup


cat <<'EOF' > /etc/resolv.conf
nameserver 127.0.0.1
options edns0 ndots:1 timeout:0.3 attempts:1 rotate
EOF

cat <<'EOF' > /etc/resolvconf.conf
resolvconf=NO
EOF

resolvconf -u
```

## Abschluss

Unbound kann nun gestartet werden.

``` bash
service local_unbound stop
sysrc -x local_unbound_enable

service unbound start
```
