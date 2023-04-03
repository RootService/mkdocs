---
title: 'Dovecot'
description: 'In diesem HowTo wird step-by-step die Installation des Dovecot Mailservers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-03'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
---

# Dovecot

## Einleitung

Unser Hosting System wird um folgende Dienste erweitert.

- Dovecot 2.3.20 (IMAP only, 1GB Quota)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `mail/dovecot` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_libsodium
cat > /var/db/ports/security_libsodium/options << "EOF"
_OPTIONS_READ=libsodium-1.0.18
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/textproc_libexttextcat
cat > /var/db/ports/textproc_libexttextcat/options << "EOF"
_OPTIONS_READ=libexttextcat-3.4.6
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/mail_dovecot
cat > /var/db/ports/mail_dovecot/options << "EOF"
_OPTIONS_READ=dovecot-2.3.20
_FILE_COMPLETE_OPTIONS_LIST=DOCS EXAMPLES LIBSODIUM LIBUNWIND LIBWRAP LUA LZ4 GSSAPI_NONE GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT CDB LDAP MYSQL PGSQL SQLITE ICU LUCENE SOLR TEXTCAT
OPTIONS_FILE_SET+=DOCS
OPTIONS_FILE_SET+=EXAMPLES
OPTIONS_FILE_SET+=LIBSODIUM
OPTIONS_FILE_UNSET+=LIBUNWIND
OPTIONS_FILE_SET+=LIBWRAP
OPTIONS_FILE_UNSET+=LUA
OPTIONS_FILE_SET+=LZ4
OPTIONS_FILE_SET+=GSSAPI_NONE
OPTIONS_FILE_UNSET+=GSSAPI_BASE
OPTIONS_FILE_UNSET+=GSSAPI_HEIMDAL
OPTIONS_FILE_UNSET+=GSSAPI_MIT
OPTIONS_FILE_SET+=CDB
OPTIONS_FILE_UNSET+=LDAP
OPTIONS_FILE_UNSET+=MYSQL
OPTIONS_FILE_UNSET+=PGSQL
OPTIONS_FILE_SET+=SQLITE
OPTIONS_FILE_SET+=ICU
OPTIONS_FILE_UNSET+=LUCENE
OPTIONS_FILE_UNSET+=SOLR
OPTIONS_FILE_SET+=TEXTCAT
"EOF"


cd /usr/ports/mail/dovecot
make all install clean-depends clean


sysrc dovecot_enable=YES
```

## Konfiguration

`dovecot.conf` einrichten.

``` bash
cat > /usr/local/etc/dovecot/dovecot.conf << "EOF"
#auth_mechanisms = plain login
auth_verbose = yes
first_valid_gid = 5000
first_valid_uid = 5000
hostname = mail.example.com
imap_client_workarounds = tb-extra-mailbox-sep tb-lsub-flags
last_valid_gid = 5000
last_valid_uid = 5000
lda_mailbox_autocreate = yes
lda_mailbox_autosubscribe = yes
lda_original_recipient_header = X-Original-To
listen = * [::]
lmtp_client_workarounds = whitespace-before-path mailbox-for-path
login_log_format_elements = user=<%u> method=%m rip=%r lip=%l mpid=%e %c %k session=<%{session}>
mail_attribute_dict = file:%h/dovecot-attributes
mail_home = /data/vmail/%d/%n
mail_location = maildir:~/Maildir
mail_plugins = quota
#maildir_very_dirty_syncs = yes
namespace inbox {
  inbox = yes
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
  mailbox Archives {
    auto = subscribe
    special_use = \Archive
  }
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
  }
}
passdb {
  args = scheme=ARGON2ID username_format=%u /usr/local/etc/dovecot/passwd
  default_fields = uid=5000 gid=5000 home=/data/vmail/%d/%n
  driver = passwd-file
  override_fields = uid=5000 gid=5000 home=/data/vmail/%d/%n
}
plugin {
  quota = count:User quota
  quota_grace = 10%%
  quota_rule = *:storage=1G
  quota_rule2 = Archive:storage=+4G
  quota_status_nouser = DUNNO
  quota_status_overquota = 552 5.2.2 Mailbox is full
  quota_status_success = DUNNO
  quota_vsizes = yes
}
pop3_client_workarounds = outlook-no-nuls
postmaster_address = postmaster@example.com
protocols = imap lmtp
protocol !indexer-worker {
  mail_vsize_bg_after_count = 100
}
protocol imap {
  imap_metadata = yes
  mail_plugins = quota imap_quota
}
quota_full_tempfail = yes
service auth {
  unix_listener /var/spool/postfix/private/auth {
    group = postfix
    mode = 0660
    user = postfix
  }
  vsz_limit = 2G
}
service imap-login {
  inet_listener imap {
    port = 0
  }
  inet_listener imaps {
    port = 993
  }
  process_min_avail = 2
}
service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
service pop3-login {
  inet_listener pop3 {
    port = 0
  }
  inet_listener pop3s {
    port = 0
  }
}
service quota-status {
  executable = quota-status -p postfix
  inet_listener {
    address = 127.0.0.1
    port = 8890
  }
  client_limit = 1
}
service stats {
  unix_listener stats-writer {
    user = vmail
  }
}
ssl = required
ssl_cert = </usr/local/etc/letsencrypt/live/mail.example.com/fullchain.pem
ssl_cipher_list = "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
ssl_cipher_suites = "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256"
ssl_dh = </usr/local/etc/dovecot/dh.pem
ssl_key = </usr/local/etc/letsencrypt/live/mail.example.com/privkey.pem
ssl_min_protocol = TLSv1.2
ssl_prefer_server_ciphers = yes
userdb {
  args = username_format=%u /usr/local/etc/dovecot/passwd
  default_fields = uid=5000 gid=5000 home=/data/vmail/%d/%n
  driver = passwd-file
  override_fields = uid=5000 gid=5000 home=/data/vmail/%d/%n
}
"EOF"
```

`/usr/local/etc/dovecot/dh.pem` erzeugen.

``` bash
/usr/local/bin/openssl dhparam 4096 > /usr/local/etc/dovecot/dh.pem
```

`/usr/local/etc/dovecot/passwd` einrichten.

Das Anlegen neuer Mailuser wird mittels Script automatisiert.

``` bash
cat > /usr/local/etc/dovecot/create_mailuser.sh << "EOF"
#!/bin/sh
dovecot_user="${1}"
dovecot_pass="`openssl rand -hex 64 | openssl passwd -1 -stdin | tr -cd '[[:alnum:]]' | cut -c 2-13`"
dovecot_hash="`echo ${dovecot_pass} | xargs -I % doveadm pw -s ARGON2ID -p %`"
echo "Password for ${dovecot_user} is: ${dovecot_pass}"
echo "${dovecot_user}:${dovecot_hash}:5000:5000::/data/vmail/%d/%n::" >> /usr/local/etc/dovecot/passwd
exit 0
"EOF"

chmod 0755 /usr/local/etc/dovecot/create_mailuser.sh

# admin@example.com anlegen
/usr/local/etc/dovecot/create_mailuser.sh admin@example.com
```

## Abschluss

Dovecot kann nun gestartet werden.

``` bash
service dovecot start
```
