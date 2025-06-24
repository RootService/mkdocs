---
title: 'Postfix'
description: 'In diesem HowTo wird step-by-step die Installation des Postfix Mailservers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Postfix

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- Postfix 3.10.2 (Dovecot-SASL, postscreen)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/postfix` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/mail_postfix
cat <<'EOF' > /var/db/ports/mail_postfix/options
_OPTIONS_READ=postfix-3.9.0
_FILE_COMPLETE_OPTIONS_LIST=BDB BLACKLISTD CDB DOCS EAI INST_BASE LDAP LMDB MONGO MYSQL NIS PCRE2 PGSQL SASL SQLITE TEST TLS SASLKMIT SASLKRB5
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_UNSET+=BLACKLISTD
OPTIONS_FILE_SET+=CDB
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=EAI
OPTIONS_FILE_UNSET+=INST_BASE
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_SET+=LMDB
OPTIONS_FILE_UNSET+=MONGO
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=NIS
OPTIONS_FILE_SET+=PCRE2
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_UNSET+=SASL
OPTIONS_FILE_SET+=SQLITE
OPTIONS_FILE_UNSET+=TEST
OPTIONS_FILE_SET+=TLS
OPTIONS_FILE_UNSET+=SASLKMIT
OPTIONS_FILE_UNSET+=SASLKRB5
EOF


cd /usr/ports/mail/postfix
make all install clean-depends clean


sysrc postfix_enable=YES


install -d /usr/local/etc/mail
install -m 0644 /usr/local/share/postfix/mailer.conf.postfix /usr/local/etc/mail/mailer.conf
```

## Konfiguration

`main.cf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/main.cf
address_verify_map = lmdb:${data_directory}/verify_cache
alias_database = lmdb:/etc/aliases
alias_maps = lmdb:/etc/aliases
allow_percent_hack = no
always_add_missing_headers = yes
biff = no
compatibility_level = 3.6
default_database_type = lmdb
disable_vrfy_command = yes
dovecot_destination_recipient_limit = 1
enable_long_queue_ids = yes
home_mailbox = .maildir/
inet_interfaces = all
inet_protocols = all
internal_mail_filter_classes = bounce
local_header_rewrite_clients = permit_mynetworks permit_sasl_authenticated
mail_spool_directory = /data/vmail
mailbox_size_limit = 0
mailbox_transport = lmtp:unix:private/dovecot-lmtp
masquerade_domains = $mydomain
masquerade_exceptions = root mailer-daemon
message_size_limit = 0
milter_default_action = accept
mydestination = $myhostname localhost.$mydomain localhost
mydomain = example.com
myhostname = mail.$mydomain
mynetworks_style = host
myorigin = $mydomain
non_smtpd_milters =
  inet:127.0.0.1:8891
notify_classes = data protocol resource software
openssl_path = /usr/local/bin/openssl
postscreen_access_list =
  permit_mynetworks
  cidr:${config_directory}/postscreen_whitelist.cidr
postscreen_bare_newline_action = enforce
postscreen_bare_newline_enable = yes
postscreen_cache_map = lmdb:${data_directory}/postscreen_cache
postscreen_denylist_action = enforce
postscreen_dnsbl_action = enforce
postscreen_dnsbl_allowlist_threshold = 0
postscreen_dnsbl_sites =
  list.dnswl.org=127.0.[0..255].0*-2
  list.dnswl.org=127.0.[0..255].1*-4
  list.dnswl.org=127.0.[0..255].2*-6
  list.dnswl.org=127.0.[0..255].3*-8
  zen.spamhaus.org=127.0.0.9*25
  zen.spamhaus.org=127.0.0.3*10
  zen.spamhaus.org=127.0.0.2*5
  zen.spamhaus.org=127.0.0.[4..7]*3
  zen.spamhaus.org=127.0.0.[10..11]*3
  swl.spamhaus.org*-10
  bl.mailspike.net=127.0.0.2*10
  bl.mailspike.net=127.0.0.10*5
  bl.mailspike.net=127.0.0.11*4
  bl.mailspike.net=127.0.0.12*3
  bl.mailspike.net=127.0.0.13*2
  bl.mailspike.net=127.0.0.14*1
  wl.mailspike.net=127.0.0.16*-2
  wl.mailspike.net=127.0.0.17*-4
  wl.mailspike.net=127.0.0.18*-6
  wl.mailspike.net=127.0.0.19*-8
  wl.mailspike.net=127.0.0.20*-10
  backscatter.spameatingmonkey.net*2
  bl.ipv6.spameatingmonkey.net*2
  bl.spameatingmonkey.net*2
  ix.dnsbl.manitu.net*2
  bl.spamcop.net*2
  db.wpbl.info*2
  psbl.surriel.com*2
  torexit.dan.me.uk*2
  tor.dan.me.uk*1
#  safe.dnsbl.sorbs.net*1
postscreen_dnsbl_threshold = 5
postscreen_greet_action = enforce
postscreen_non_smtp_command_enable = yes
postscreen_pipelining_enable = yes
recipient_delimiter = +
remote_header_rewrite_domain = domain.invalid
show_user_unknown_table_name = no
smtp_dns_support_level = enabled
smtp_tls_CAfile = /usr/local/share/certs/ca-root-nss.crt
smtp_tls_connection_reuse = yes
smtp_tls_loglevel = 1
smtp_tls_mandatory_protocols = >=TLSv1.2
smtp_tls_note_starttls_offer = yes
smtp_tls_protocols = >=TLSv1.2
smtp_tls_security_level = may
smtp_tls_session_cache_database = lmdb:${data_directory}/smtp_scache
smtpd_client_port_logging = yes
smtpd_client_restrictions =
  sleep 1
  permit
smtpd_data_restrictions =
  reject_unauth_pipelining
  reject_multi_recipient_bounce
  permit
smtpd_discard_ehlo_keywords = chunking, silent-discard
smtpd_end_of_data_restrictions =
  permit
smtpd_etrn_restrictions =
  reject
smtpd_forbid_bare_newline = normalize
smtpd_forbid_bare_newline_exclusions = $mynetworks
smtpd_forbid_unauth_pipelining = yes
smtpd_helo_required = yes
smtpd_helo_restrictions =
  permit_mynetworks
  permit_sasl_authenticated
  reject_invalid_helo_hostname
  reject_non_fqdn_helo_hostname
  permit
smtpd_milters =
  inet:127.0.0.1:8891
  inet:127.0.0.1:8895
  unix:/var/run/spamass-milter/spamass-milter.sock
smtpd_recipient_restrictions =
  permit_mynetworks
  permit_sasl_authenticated
  reject_non_fqdn_recipient
  reject_unknown_recipient_domain
  check_recipient_access pcre:${config_directory}/recipient_checks.pcre
  permit
smtpd_relay_restrictions =
  permit_mynetworks
  permit_sasl_authenticated
  reject_unauth_destination
  permit
smtpd_sasl_auth_enable = yes
smtpd_sasl_authenticated_header = yes
smtpd_sasl_path = private/auth
smtpd_sasl_type = dovecot
smtpd_sender_restrictions =
  reject_non_fqdn_sender
  reject_unknown_sender_domain
  permit
smtpd_tls_auth_only = yes
smtpd_tls_chain_files =
  /usr/local/etc/letsencrypt/live/mail.example.com/privkey.pem
  /usr/local/etc/letsencrypt/live/mail.example.com/fullchain.pem
smtpd_tls_loglevel = 1
smtpd_tls_mandatory_protocols = >=TLSv1.2
smtpd_tls_protocols = >=TLSv1.2
smtpd_tls_received_header = yes
smtpd_tls_security_level = may
smtpd_tls_session_cache_database = lmdb:${data_directory}/smtpd_scache
strict_rfc821_envelopes = yes
swap_bangpath = no
tls_eecdh_auto_curves = X448 X25519 secp384r1 prime256v1 secp521r1
tls_high_cipherlist = "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
tls_medium_cipherlist = "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
tls_preempt_cipherlist = yes
tls_ssl_options = NO_RENEGOTIATION NO_SESSION_RESUMPTION_ON_RENEGOTIATION
virtual_alias_domains = lmdb:${config_directory}/virtual_alias_domains
virtual_alias_maps = lmdb:${config_directory}/virtual_alias_maps
virtual_gid_maps = static:5000
virtual_mailbox_base = /data/vmail
virtual_mailbox_domains = lmdb:${config_directory}/virtual_mailbox_domains
virtual_mailbox_limit = 0
virtual_mailbox_maps = lmdb:${config_directory}/virtual_mailbox_maps
virtual_minimum_uid = 5000
virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_uid_maps = static:5000
EOF
```

`master.cf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/master.cf
#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================
#smtp      inet  n       -       n       -       -       smtpd
smtp      inet  n       -       n       -       1       postscreen
  -o milter_macro_daemon_name=VERIFYING
smtpd     pass  -       -       n       -       -       smtpd
dnsblog   unix  -       -       n       -       0       dnsblog
tlsproxy  unix  -       -       n       -       0       tlsproxy
# Choose one: enable submission for loopback clients only, or for any client.
#127.0.0.1:submission inet n -   n       -       -       smtpd
submission inet n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_tls_auth_only=yes
#  -o smtpd_reject_unlisted_recipient=no
#     Instead of specifying complex smtpd_<xxx>_restrictions here,
#     specify "smtpd_<xxx>_restrictions=$mua_<xxx>_restrictions"
#     here, and specify mua_<xxx>_restrictions in main.cf (where
#     "<xxx>" is "client", "helo", "sender", "relay", or "recipient").
#  -o smtpd_client_restrictions=
#  -o smtpd_helo_restrictions=
#  -o smtpd_sender_restrictions=
#  -o smtpd_relay_restrictions=
#  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
  -o smtpd_milters=$non_smtpd_milters
# Choose one: enable submissions for loopback clients only, or for any client.
#127.0.0.1:submissions inet n  -       n       -       -       smtpd
submissions     inet  n       -       n       -       -       smtpd
  -o syslog_name=postfix/submissions
  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#     Instead of specifying complex smtpd_<xxx>_restrictions here,
#     specify "smtpd_<xxx>_restrictions=$mua_<xxx>_restrictions"
#     here, and specify mua_<xxx>_restrictions in main.cf (where
#     "<xxx>" is "client", "helo", "sender", "relay", or "recipient").
#  -o smtpd_client_restrictions=
#  -o smtpd_helo_restrictions=
#  -o smtpd_sender_restrictions=
#  -o smtpd_relay_restrictions=
#  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
  -o smtpd_milters=$non_smtpd_milters
#628       inet  n       -       n       -       -       qmqpd
pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about ${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
#maildrop  unix  -       n       n       -       -       pipe
#  flags=DRXhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  flags=DRX user=cyrus argv=/cyrus/bin/deliver -e -r ${sender} -m ${extension} ${user}
#
# ====================================================================
#
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m ${extension} ${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
#uucp      unix  -       n       n       -       -       pipe
#  flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)
#
# ====================================================================
#
# Other external delivery methods.
#
#ifmail    unix  -       n       n       -       -       pipe
#  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)
#
#bsmtp     unix  -       n       n       -       -       pipe
#  flags=Fq. user=bsmtp argv=/usr/local/sbin/bsmtp -f $sender $nexthop $recipient
#
#scalemail-backend unix -       n       n       -       2       pipe
#  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store
#  ${nexthop} ${user} ${extension}
#
#mailman   unix  -       n       n       -       -       pipe
#  flags=FRX user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
#  ${nexthop} ${user}
#
dovecot   unix  -       n       n       -       -       pipe
  flags=DRXhu user=vmail:vmail argv=/usr/local/libexec/dovecot/dovecot-lda
  -f ${sender} -a ${recipient} -d ${user}@${nexthop}
EOF
```

`/usr/local/etc/postfix/virtual_*` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/virtual_alias_domains
EOF

cat <<'EOF' > /usr/local/etc/postfix/virtual_alias_maps
root@example.com          admin@example.com
postmaster@example.com    admin@example.com
hostmaster@example.com    admin@example.com
abuse@example.com         admin@example.com
security@example.com      admin@example.com
webmaster@example.com     admin@example.com
EOF

cat <<'EOF' > /usr/local/etc/postfix/virtual_mailbox_domains
example.com               OK
EOF

cat <<'EOF' > /usr/local/etc/postfix/virtual_mailbox_maps
admin@example.com         example.com/admin/
EOF

postmap lmdb:/usr/local/etc/postfix/virtual_alias_domains
postmap lmdb:/usr/local/etc/postfix/virtual_alias_maps
postmap lmdb:/usr/local/etc/postfix/virtual_mailbox_domains
postmap lmdb:/usr/local/etc/postfix/virtual_mailbox_maps
```

Transport map einrichten.

``` bash
cat <<'EOF' >> /usr/local/etc/postfix/transport
EOF

postmap lmdb:/usr/local/etc/postfix/transport
```

Restriktionen einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/recipient_checks.pcre
/^\@/                 550 Invalid address format.
/[!%\@].*\@/          550 This server disallows weird address syntax.
/^postmaster\@/       OK
/^hostmaster\@/       OK
/^security\@/         OK
/^abuse\@/            OK
/^admin\@/            OK
EOF

cat <<'EOF' > /usr/local/etc/postfix/postscreen_whitelist.cidr
EOF

cat <<'EOF' > /usr/local/etc/postfix/mx_access
0.0.0.0/8                REJECT MX in RFC 1122 Broadcast Network
10.0.0.0/8               REJECT MX in RFC 1918 Private Network
100.64.0.0/10            REJECT MX in RFC 6598 Shared Address Space
127.0.0.0/8              REJECT MX in RFC 1122 Loopback Network
169.254.0.0/16           REJECT MX in RFC 3927 Link Local Network
172.16.0.0/12            REJECT MX in RFC 1918 Private Network
192.0.0.0/24             REJECT MX in RFC 6890 IETF Protocol Assignments Network
192.0.0.0/29             REJECT MX in RFC 6333 DS-Lite Network
192.0.2.0/24             REJECT MX in RFC 5737 Documentation (TEST-NET-1) Network
192.168.0.0/16           REJECT MX in RFC 1918 Private Network
198.18.0.0/15            REJECT MX in RFC 2544 Interconnect Device Benchmark Testing Network
198.51.100.0/24          REJECT MX in RFC 5737 Documentation (TEST-NET-2) Network
203.0.113.0/24           REJECT MX in RFC 5737 Documentation (TEST-NET-3) Network
224.0.0.0/4              REJECT MX in RFC 5771 Multicast Network
240.0.0.0/4              REJECT MX in RFC 1122 Reserved Network
255.255.255.255/32       REJECT MX in RFC 919  Limited Broadcast Destination Address
::/128                   REJECT MX in RFC 4291 Unspecified Address
::1/128                  REJECT MX in RFC 4291 Loopback Address
::ffff:0:0/96            REJECT MX in RFC 4291 IPv4-mapped Address
100::/64                 REJECT MX in RFC 6666 Discard-Only Network
2001::/23                REJECT MX in RFC 2928 IETF Protocol Assignements Network
2001::/32                REJECT MX in RFC 4380 TEREDO Network
2001:2::/48              REJECT MX in RFC 5180 Interconnect Device Benchmark Testing Network
2001:db8::/32            REJECT MX in RFC 3849 Documentation Network
fc00::/7                 REJECT MX in RFC 4193 Unique-Local Network
fe80::/10                REJECT MX in RFC 4291 Linked-Scoped Unicast Network
ff00::/8                 REJECT MX in RFC 4291 Multicast Network
EOF

postmap lmdb:/usr/local/etc/postfix/mx_access
```

Abschliessende Arbeiten.

``` bash
/usr/local/bin/newaliases

pw groupadd -n vmail -g 5000
pw useradd -n vmail -u 5000 -g vmail -c 'Virtual Mailuser' -d /nonexistent -s /usr/sbin/nologin

mkdir -p /data/vmail
chmod 0750 /data/vmail
chown vmail:vmail /data/vmail
```

Wir installieren `mail/libmilter` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/mail_libmilter
cat <<'EOF' > /var/db/ports/mail_libmilter/options
_OPTIONS_READ=libmilter-8.18.1
_FILE_COMPLETE_OPTIONS_LIST=IPV6 MILTER_SHARED MILTER_POOL DOCS
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=MILTER_SHARED
OPTIONS_FILE_SET+=MILTER_POOL
OPTIONS_FILE_UNSET+=DOCS
EOF


cd /usr/ports/mail/libmilter
make all install clean-depends clean
```

Es muss noch ein DNS-Record angelegt werden, sofern er noch nicht existieren, oder entsprechend geändert werden, sofern er bereits existieren.

``` dns-zone
example.com.            IN  TXT     ( "v=spf1 a mx ~all" )
```

## Abschluss

Postfix kann nun gestartet werden.

``` bash
service postfix start
```
