#!/bin/sh

dovecot_user="${1}"
dovecot_pass="`openssl rand -hex 64 | openssl passwd -1 -stdin | tr -cd '[[:alnum:]]' | cut -c 2-13`"
dovecot_hash="`echo ${dovecot_pass} | xargs -I % doveadm pw -s ARGON2ID -p %`"

echo "Password for ${dovecot_user} is: ${dovecot_pass}"
echo "${dovecot_user}:${dovecot_hash}:5000:5000::/data/vmail/%d/%n::" >> /usr/local/etc/dovecot/passwd

exit 0