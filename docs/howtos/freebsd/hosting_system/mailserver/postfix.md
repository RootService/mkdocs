---
title: 'Postfix'
description: 'In diesem HowTo wird step-by-step die Installation des Postfix Mailservers für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
tags:
    - FreeBSD
    - Postfix
---

# Postfix

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird um folgende Dienste erweitert.

- Postfix 3.5.9 (Dovecot-SASL, postscreen)
- Python-SPF-Engine 2.9.2 (SPF2)

## Installation

Wir installieren `mail/postfix` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_cyrus-sasl2
cat > /var/db/ports/security_cyrus-sasl2/options << "EOF"
_OPTIONS_READ=cyrus-sasl-2.1.27
_FILE_COMPLETE_OPTIONS_LIST=ALWAYSTRUE AUTHDAEMOND DOCS KEEP_DB_OPEN  OBSOLETE_CRAM_ATTR OBSOLETE_DIGEST_ATTR BDB1 BDB GDBM LMDB ANONYMOUS CRAM DIGEST LOGIN NTLM OTP PLAIN SCRAM
OPTIONS_FILE_UNSET+=ALWAYSTRUE
OPTIONS_FILE_UNSET+=AUTHDAEMOND
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_UNSET+=KEEP_DB_OPEN
OPTIONS_FILE_UNSET+=OBSOLETE_CRAM_ATTR
OPTIONS_FILE_UNSET+=OBSOLETE_DIGEST_ATTR
OPTIONS_FILE_UNSET+=BDB1
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_UNSET+=GDBM
OPTIONS_FILE_SET+=LMDB
OPTIONS_FILE_SET+=ANONYMOUS
OPTIONS_FILE_SET+=CRAM
OPTIONS_FILE_SET+=DIGEST
OPTIONS_FILE_SET+=LOGIN
OPTIONS_FILE_SET+=NTLM
OPTIONS_FILE_SET+=OTP
OPTIONS_FILE_SET+=PLAIN
OPTIONS_FILE_SET+=SCRAM
"EOF"

mkdir -p /var/db/ports/mail_postfix
cat > /var/db/ports/mail_postfix/options << "EOF"
_OPTIONS_READ=postfix-3.5.9
_FILE_COMPLETE_OPTIONS_LIST=BDB BLACKLISTD CDB DOCS EAI INST_BASE LDAP LDAP_SASL LMDB MYSQL NIS PCRE PGSQL SASL SQLITE TEST TLS SASLKRB5 SASLKMIT
OPTIONS_FILE_UNSET+=BDB
OPTIONS_FILE_UNSET+=BLACKLISTD
OPTIONS_FILE_SET+=CDB
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EAI
OPTIONS_FILE_UNSET+=INST_BASE
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=LDAP_SASL
OPTIONS_FILE_SET+=LMDB
OPTIONS_FILE_SET+=MYSQL
OPTIONS_FILE_UNSET+=NIS
OPTIONS_FILE_SET+=PCRE
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=SASL
OPTIONS_FILE_SET+=SQLITE
OPTIONS_FILE_UNSET+=TEST
OPTIONS_FILE_SET+=TLS
OPTIONS_FILE_UNSET+=SASLKRB5
OPTIONS_FILE_UNSET+=SASLKMIT
"EOF"


cd /usr/ports/mail/postfix
make all install clean-depends clean


echo 'postfix_enable="YES"' >> /etc/rc.conf
```

Wir wollen Postfix in der `/etc/mail/mailer.conf` aktivieren.

## Konfiguration

`main.cf` einrichten.

``` bash
cat > /usr/local/etc/postfix/main.cf << "EOF"
allow_percent_hack = no
always_add_missing_headers = yes
biff = no
compatibility_level = 2
disable_vrfy_command = yes
dovecot_destination_recipient_limit = 1
enable_long_queue_ids = yes
home_mailbox = .maildir/
inet_interfaces = all
inet_protocols = all
lmtp_tls_fingerprint_digest = sha1
local_header_rewrite_clients = permit_mynetworks permit_sasl_authenticated
mail_spool_directory = /data/vmail
mailbox_size_limit = 0
masquerade_domains = $mydomain
masquerade_exceptions = root mailer-daemon
message_size_limit = 0
milter_default_action = accept
mydestination = $myhostname localhost.$mydomain localhost
mydomain = example.com
myhostname = mail.$mydomain
mynetworks_style = host
myorigin = $mydomain
non_smtpd_milters = $smtpd_milters
notify_classes = data protocol resource software
openssl_path = /usr/local/bin/openssl
postscreen_access_list =
  permit_mynetworks
  cidr:${config_directory}/postscreen_whitelist.cidr
postscreen_bare_newline_action = enforce
postscreen_bare_newline_enable = yes
postscreen_blacklist_action = enforce
postscreen_dnsbl_action = enforce
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
  safe.dnsbl.sorbs.net*1
postscreen_dnsbl_threshold = 5
postscreen_dnsbl_whitelist_threshold = 0
postscreen_greet_action = enforce
postscreen_non_smtp_command_enable = yes
postscreen_pipelining_enable = yes
recipient_delimiter = +
remote_header_rewrite_domain = domain.invalid
show_user_unknown_table_name = no
smtp_dns_support_level = enabled
smtp_tls_CAfile = /usr/local/share/certs/ca-root-nss.crt
smtp_tls_ciphers = medium
smtp_tls_connection_reuse = yes
smtp_tls_fingerprint_digest = sha1
smtp_tls_loglevel = 1
smtp_tls_mandatory_ciphers = medium
smtp_tls_mandatory_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
smtp_tls_note_starttls_offer = yes
smtp_tls_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
smtp_tls_security_level = may
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtpd_client_port_logging = yes
smtpd_client_restrictions =
  sleep 1
  permit
smtpd_data_restrictions =
  reject_unauth_pipelining
  reject_multi_recipient_bounce
  permit
smtpd_end_of_data_restrictions =
  permit
smtpd_etrn_restrictions =
  reject
smtpd_helo_required = yes
smtpd_helo_restrictions =
  permit_mynetworks
  permit_sasl_authenticated
  reject_invalid_helo_hostname
  reject_non_fqdn_helo_hostname
  permit
smtpd_milters = inet:127.0.0.1:8891 inet:127.0.0.1:8893
smtpd_recipient_restrictions =
  permit_mynetworks
  permit_sasl_authenticated
  reject_non_fqdn_recipient
  reject_unknown_recipient_domain
  check_recipient_access pcre:${config_directory}/recipient_checks.pcre
  check_policy_service unix:private/policyd-spf
#  check_policy_service inet:127.0.0.1:8890
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
  /data/pki/private/mail.example.com.key
  /data/pki/certs/mail.example.com.crt
smtpd_tls_ciphers = medium
smtpd_tls_fingerprint_digest = sha1
smtpd_tls_loglevel = 1
smtpd_tls_mandatory_ciphers = medium
smtpd_tls_mandatory_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
smtpd_tls_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
smtpd_tls_received_header = yes
smtpd_tls_security_level = may
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
strict_rfc821_envelopes = yes
swap_bangpath = no
tls_daemon_random_bytes = 64
tls_eecdh_auto_curves = X448 X25519 secp384r1 prime256v1 secp521r1
tls_high_cipherlist = TLSv1.2 +CHACHA20 +AES +SHA !DH !AESCCM !CAMELLIA !PSK !RSA !SHA1 !SHA256 !SHA384 !kDHd !kDHr !kECDH !aDSS !aNULL
tls_medium_cipherlist = TLSv1.2 +CHACHA20 +AES +SHA !DH !AESCCM !CAMELLIA !PSK !RSA !SHA1 !kDHd !kDHr !kECDH !aDSS !aNULL
tls_preempt_cipherlist = yes
tls_random_bytes = 64
tls_ssl_options = NO_COMPRESSION
virtual_alias_domains = hash:${config_directory}/virtual_alias_domains
virtual_alias_maps = hash:${config_directory}/virtual_alias_maps
virtual_gid_maps = static:5000
virtual_mailbox_base = /data/vmail
virtual_mailbox_domains = hash:${config_directory}/virtual_mailbox_domains
virtual_mailbox_limit = 0
virtual_mailbox_maps = hash:${config_directory}/virtual_mailbox_maps
virtual_minimum_uid = 5000
virtual_transport = dovecot
virtual_uid_maps = static:5000
"EOF"
```

`master.cf` einrichten.

``` bash
cat > /usr/local/etc/postfix/master.cf << "EOF"
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
#  -o milter_macro_daemon_name=VERIFYING
smtpd     pass  -       -       n       -       -       smtpd
dnsblog   unix  -       -       n       -       0       dnsblog
tlsproxy  unix  -       -       n       -       0       tlsproxy
submission inet n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_tls_auth_only=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
#smtps     inet  n       -       n       -       -       smtpd
#  -o syslog_name=postfix/smtps
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
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
policyd-spf  unix  -    n       n       -       0       spawn
  user=nobody argv=/usr/local/bin/policyd-spf
"EOF"
```

`/usr/local/etc/postfix/virtual_*` einrichten.

``` bash
cat > /usr/local/etc/postfix/virtual_alias_domains << "EOF"
"EOF"

cat > /usr/local/etc/postfix/virtual_alias_maps << "EOF"
root@example.com          admin@example.com
postmaster@example.com    admin@example.com
hostmaster@example.com    admin@example.com
abuse@example.com         admin@example.com
security@example.com      admin@example.com
webmaster@example.com     admin@example.com
"EOF"

cat > /usr/local/etc/postfix/virtual_mailbox_domains << "EOF"
example.com               OK
"EOF"

cat > /usr/local/etc/postfix/virtual_mailbox_maps << "EOF"
admin@example.com         example.com/admin/
"EOF"

postmap /usr/local/etc/postfix/virtual_alias_domains
postmap /usr/local/etc/postfix/virtual_alias_maps
postmap /usr/local/etc/postfix/virtual_mailbox_domains
postmap /usr/local/etc/postfix/virtual_mailbox_maps
```

Transport map einrichten.

``` bash
cat >> /usr/local/etc/postfix/transport << "EOF"
"EOF"

postmap /usr/local/etc/postfix/transport
```

Restriktionen einrichten.

``` bash
cat > /usr/local/etc/postfix/recipient_checks.pcre << "EOF"
/^\@/                 550 Invalid address format.
/[!%\@].*\@/          550 This server disallows weird address syntax.
/^postmaster\@/       OK
/^hostmaster\@/       OK
/^security\@/         OK
/^abuse\@/            OK
/^admin\@/            OK
"EOF"
```

Abschliessende Arbeiten.

``` bash
pw groupadd -n vmail -g 5000
pw useradd -n vmail -u 5000 -g vmail -c 'Virtual Mailuser' -d /nonexistent -s /usr/sbin/nologin

mkdir -p /data/vmail
chmod 0750 /data/vmail
chown vmail:vmail /data/vmail
```

## Python-SPF-Engine

Wir installieren `mail/py-spf-engine` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/dns_py-dnspython
cat > /var/db/ports/dns_py-dnspython/options << "EOF"
_OPTIONS_READ=py37-dnspython-1.16.0
_FILE_COMPLETE_OPTIONS_LIST=EXAMPLES PYCRYPTODOME
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_UNSET+=PYCRYPTODOME
"EOF"

mkdir -p /var/db/ports/mail_libmilter
cat > /var/db/ports/mail_libmilter/options << "EOF"
_OPTIONS_READ=libmilter-8.16.1
_FILE_COMPLETE_OPTIONS_LIST=IPV6 MILTER_SHARED MILTER_POOL DOCS
OPTIONS_FILE_SET+=IPV6
OPTIONS_FILE_SET+=MILTER_SHARED
OPTIONS_FILE_SET+=MILTER_POOL
OPTIONS_FILE_SET+=DOCS
"EOF"


cd /usr/ports/mail/py-spf-engine
make all install clean-depends clean

echo 'pyspf_milter_enable="YES"' >> /etc/rc.conf
```

`py-spf-engine` konfigurieren.

``` bash
sed -e 's|^\(TestOnly[[:space:]]=\)[[:space:]].*$|\1 0|g' \
    -e 's|^\(Authserv_Id[[:space:]]=\)[[:space:]].*$|\1 mail.example.com|g' \
    /usr/local/share/doc/spf-engine/policyd-spf.conf.commented \
    > /usr/local/etc/python-policyd-spf/policyd-spf.conf
```

Es muss noch ein DNS-Record angelegt werden, sofern er noch nicht existieren, oder entsprechend geändert werden, sofern er bereits existieren.

``` dns-zone
example.com.            IN  TXT     ( "v=spf1 a mx -all" )
```

## Abschluss

Postfix kann nun gestartet werden.

``` bash
service pyspf_milter start
service postfix start
```
