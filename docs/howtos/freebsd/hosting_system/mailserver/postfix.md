---
title: 'Postfix'
description: 'In diesem HowTo wird step-by-step die Installation des Postfix Mailservers für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2025-06-24'
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
--8<-- "ports/mail_postfix/options"
EOF


portmaster -w -B -g --force-config mail/postfix@default  -n


sysrc postfix_enable=YES


install -d /usr/local/etc/mail
install -m 0644 /usr/local/share/postfix/mailer.conf.postfix /usr/local/etc/mail/mailer.conf
```

## Konfiguration

`main.cf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/main.cf
--8<-- "configs/usr/local/etc/postfix/main.cf"
EOF
```

`master.cf` einrichten.

``` bash
cat <<'EOF' > /usr/local/etc/postfix/master.cf
--8<-- "configs/usr/local/etc/postfix/master.cf"
EOF
```

`pgsql/*.cf` einrichten.

``` bash
mkdir -p /usr/local/etc/postfix/pgsql

cat <<'EOF' > /usr/local/etc/postfix/pgsql/recipient_bcc_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/recipient_bcc_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/relay_domains.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/relay_domains.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/sender_bcc_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/sender_bcc_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/sender_dependent_relayhost_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/sender_dependent_relayhost_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/sender_login_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/sender_login_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/transport_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/transport_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_alias_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_alias_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_alias_domains_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_alias_domains_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_alias_domains_catchall_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_alias_domains_catchall_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_alias_domains_mailbox_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_alias_domains_mailbox_maps.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_mailbox_domains.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_mailbox_domains.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_mailbox_limits.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_mailbox_limits.cf"
EOF

cat <<'EOF' > /usr/local/etc/postfix/pgsql/virtual_mailbox_maps.cf
--8<-- "configs/usr/local/etc/postfix/pgsql/virtual_mailbox_maps.cf"
EOF


chmod 0640 /usr/local/etc/postfix/pgsql/*.cf
chown root:postfix /usr/local/etc/postfix/pgsql/*.cf
```

Restriktionen einrichten.

``` bash
cp -a /etc/mail/aliases /usr/local/etc/postfix/aliases

cat <<'EOF' > /usr/local/etc/postfix/postscreen_access.cidr
--8<-- "configs/usr/local/etc/postfix/postscreen_access.cidr"
EOF

cat <<'EOF' > /usr/local/etc/postfix/postscreen_whitelist.cidr
--8<-- "configs/usr/local/etc/postfix/postscreen_whitelist.cidr"
EOF

cat <<'EOF' > /usr/local/etc/postfix/body_checks.pcre
--8<-- "configs/usr/local/etc/postfix/body_checks.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/header_checks.pcre
--8<-- "configs/usr/local/etc/postfix/header_checks.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/command_filter.pcre
--8<-- "configs/usr/local/etc/postfix/command_filter.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/helo_access.pcre
--8<-- "configs/usr/local/etc/postfix/helo_access.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/recipient_checks.pcre
--8<-- "configs/usr/local/etc/postfix/recipient_checks.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/sender_access.pcre
--8<-- "configs/usr/local/etc/postfix/sender_access.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/submission_header_checks.pcre
--8<-- "configs/usr/local/etc/postfix/submission_header_checks.pcre"
EOF

cat <<'EOF' > /usr/local/etc/postfix/postscreen_dnsbl_reply
--8<-- "configs/usr/local/etc/postfix/postscreen_dnsbl_reply"
EOF

cat <<'EOF' > /usr/local/etc/postfix/dnsbl_reply_map
--8<-- "configs/usr/local/etc/postfix/dnsbl_reply_map"
EOF

cat <<'EOF' > /usr/local/etc/postfix/mx_access
--8<-- "configs/usr/local/etc/postfix/mx_access"
EOF


chmod 0640 /usr/local/etc/postfix/*.pcre
chown root:postfix /usr/local/etc/postfix/*.pcre


postmap /usr/local/etc/postfix/postscreen_dnsbl_reply
postmap /usr/local/etc/postfix/dnsbl_reply_map
postmap /usr/local/etc/postfix/mx_access

/usr/local/bin/newaliases
```

Abschliessende Arbeiten.

``` bash
portmaster -w -B -g --force-config dns/rubygem-dnsruby  -n
portmaster -w -B -g --force-config net/rubygem-ipaddress  -n
portmaster -w -B -g --force-config devel/rubygem-optparse  -n
portmaster -w -B -g --force-config devel/rubygem-pp  -n


cat <<'EOF' > /usr/local/etc/postfix/postscreen_whitelist.rb
--8<-- "configs/usr/local/etc/postfix/postscreen_whitelist.rb"
EOF
chmod 0755 /usr/local/etc/postfix/postscreen_whitelist.rb

/usr/local/etc/postfix/postscreen_whitelist.rb -f
```

Wir installieren `mail/libmilter` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/mail_libmilter
cat <<'EOF' > /var/db/ports/mail_libmilter/options
--8<-- "ports/mail_libmilter/options"
EOF


portmaster -w -B -g --force-config mail/libmilter  -n
```

Wir installieren `mail/py-spf-engine` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/devel_py-anyio
cat <<'EOF' > /var/db/ports/devel_py-anyio/options
--8<-- "ports/devel_py-anyio/options"
EOF

mkdir -p /var/db/ports/devel_py-pyasn1-modules
cat <<'EOF' > /var/db/ports/devel_py-pyasn1-modules/options
--8<-- "ports/devel_py-pyasn1-modules/options"
EOF

mkdir -p /var/db/ports/dns_py-dnspython
cat <<'EOF' > /var/db/ports/dns_py-dnspython/options
--8<-- "ports/dns_py-dnspython/options"
EOF

mkdir -p /var/db/ports/mail_py-pymilter
cat <<'EOF' > /var/db/ports/mail_py-pymilter/options
--8<-- "ports/mail_py-pymilter/options"
EOF

mkdir -p /var/db/ports/www_py-httpcore
cat <<'EOF' > /var/db/ports/www_py-httpcore/options
--8<-- "ports/www_py-httpcore/options"
EOF

mkdir -p /var/db/ports/www_py-httpx
cat <<'EOF' > /var/db/ports/www_py-httpx/options
--8<-- "ports/www_py-httpx/options"
EOF

mkdir -p /var/db/ports/www_py-requests
cat <<'EOF' > /var/db/ports/www_py-requests/options
--8<-- "ports/www_py-requests/options"
EOF

mkdir -p /var/db/ports/mail_py-spf-engine
cat <<'EOF' > /var/db/ports/mail_py-spf-engine/options
--8<-- "ports/mail_py-spf-engine/options"
EOF


portmaster -w -B -g --force-config mail/py-spf-engine  -n


sysrc pyspf_milter_enable="YES"


cat <<'EOF' > /usr/local/etc/pyspf-milter/pyspf-milter.conf
--8<-- "configs/usr/local/etc/pyspf-milter/pyspf-milter.conf"
EOF

cat <<'EOF' > /usr/local/etc/python-policyd-spf/policyd-spf.conf
--8<-- "configs/usr/local/etc/python-policyd-spf/policyd-spf.conf"
EOF


service pyspf-milter start
```

## Abschluss

Postfix kann nun gestartet werden.

``` bash
service postfix start
```
