---
title: 'OpenSSH'
description: 'In diesem HowTo wird step-by-step die Installation von OpenSSH für ein Hosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# OpenSSH

## Einleitung

Unser Hosting System wird folgende Dienste umfassen.

- OpenSSH 9.7p1 (Public-Key-Auth)

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Hosting System](/howtos/freebsd/hosting_system/)

## Installation

Wir installieren `security/openssh-portable` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/security_libfido2
cat <<'EOF' > /var/db/ports/security_libfido2/options
_OPTIONS_READ=libfido2-1.14.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_UNSET+=DOCS
EOF

mkdir -p /var/db/ports/dns_ldns
cat <<'EOF' > /var/db/ports/dns_ldns/options
_OPTIONS_READ=ldns-1.8.3
_FILE_COMPLETE_OPTIONS_LIST=DANETAUSAGE DOXYGEN DRILL EXAMPLES GOST RRTYPEAMTRELAY RRTYPEAVC RRTYPENINFO RRTYPERKEY RRTYPETA
OPTIONS_FILE_SET+=DANETAUSAGE
OPTIONS_FILE_UNSET+=DOXYGEN
OPTIONS_FILE_SET+=DRILL
OPTIONS_FILE_UNSET+=EXAMPLES
OPTIONS_FILE_SET+=GOST
OPTIONS_FILE_UNSET+=RRTYPEAMTRELAY
OPTIONS_FILE_UNSET+=RRTYPEAVC
OPTIONS_FILE_UNSET+=RRTYPENINFO
OPTIONS_FILE_UNSET+=RRTYPERKEY
OPTIONS_FILE_SET+=RRTYPETA
EOF

mkdir -p /var/db/ports/security_openssh-portable
cat <<'EOF' > /var/db/ports/security_openssh-portable/options
_OPTIONS_READ=openssh-portable-9.7.p1
_FILE_COMPLETE_OPTIONS_LIST=BLACKLISTD BSM DOCS FIDO_U2F HPN KERB_GSSAPI LDNS LIBEDIT NONECIPHER PAM TCP_WRAPPERS XMSS MIT HEIMDAL HEIMDAL_BASE
OPTIONS_FILE_UNSET+=BLACKLISTD
OPTIONS_FILE_UNSET+=BSM
OPTIONS_FILE_UNSET+=DOCS
OPTIONS_FILE_SET+=FIDO_U2F
OPTIONS_FILE_UNSET+=HPN
OPTIONS_FILE_UNSET+=KERB_GSSAPI
OPTIONS_FILE_SET+=LDNS
OPTIONS_FILE_SET+=LIBEDIT
OPTIONS_FILE_UNSET+=NONECIPHER
OPTIONS_FILE_SET+=PAM
OPTIONS_FILE_SET+=TCP_WRAPPERS
OPTIONS_FILE_UNSET+=XMSS
OPTIONS_FILE_UNSET+=MIT
OPTIONS_FILE_UNSET+=HEIMDAL
OPTIONS_FILE_UNSET+=HEIMDAL_BASE
EOF


cd /usr/ports/security/openssh-portable
make all install clean-depends clean


sysrc openssh_enable=YES
```

## Konfiguration

Wir konfigurieren Unbound:

``` bash
sed -e 's|^#\(Port\).*$|\1 2222|' \
    -e 's|^#\(PermitRootLogin\).*$|\1 prohibit-password|' \
    -e 's|^#\(PubkeyAuthentication\).*$|\1 yes|' \
    -e 's|^#\(PasswordAuthentication\).*$|\1 no|' \
    -e 's|^#\(PermitEmptyPasswords\).*$|\1 no|' \
    -e 's|^#\(KbdInteractiveAuthentication\).*$|\1 no|' \
    -e 's|^#\(UsePAM\).*$|\1 no|' \
    -e 's|^#\(AllowAgentForwarding\).*$|\1 no|' \
    -e 's|^#\(AllowTcpForwarding\).*$|\1 no|' \
    -e 's|^#\(GatewayPorts\).*$|\1 no|' \
    -e 's|^#\(X11Forwarding\).*$|\1 no|' \
    -e 's|^#\(PermitUserEnvironment\).*$|\1 no|' \
    -e 's|^#\(ClientAliveInterval\).*$|\1 10|' \
    -e 's|^#\(ClientAliveCountMax\).*$|\1 6|' \
    -e 's|^#\(PidFile\).*$|\1 /var/run/opensshd.pid|' \
    -e 's|^#\(MaxStartups\).*$|\1 10:30:100|' \
    -e 's|^#\(PermitTunnel\).*$|\1 no|' \
    -e 's|^#\(ChrootDirectory\).*$|\1 %h|' \
    -e 's|^#\(UseBlacklist\).*$|\1 no|' \
    -e 's|^#\(VersionAddendum\).*$|\1 none|' \
    -e 's|^\(Subsystem.*\)$|#\1|' \
    -i '' /usr/local/etc/ssh/sshd_config

cat <<'EOF' >> /usr/local/etc/ssh/sshd_config

Subsystem sftp internal-sftp -u 0027

AllowGroups wheel admin sshusers sftponly

Match User root
    ChrootDirectory none
    PasswordAuthentication no

Match Group admin
    ChrootDirectory none
    PasswordAuthentication no

Match Group sshusers
    ChrootDirectory none
    PasswordAuthentication no

Match Group sftponly
    ChrootDirectory /home
    PasswordAuthentication yes
    ForceCommand internal-sftp -d %u

EOF

# Ciphers: ssh -Q cipher
# MACs: ssh -Q mac
# KexAlgorithms: ssh -Q kex
# PubkeyAcceptedKeyTypes: ssh -Q key

sed -e '/^# Ciphers and keying/ a\
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com\
Macs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com\
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256\
' -i '' /usr/local/etc/ssh/sshd_config

ssh-keygen -q -t rsa -b 4096 -f "/usr/local/etc/ssh/ssh_host_rsa_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_rsa_key.pub"
ssh-keygen -q -t ecdsa -b 384 -f "/usr/local/etc/ssh/ssh_host_ecdsa_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_ecdsa_key.pub"
ssh-keygen -q -t ed25519 -f "/usr/local/etc/ssh/ssh_host_ed25519_key" -N ""
ssh-keygen -l -f "/usr/local/etc/ssh/ssh_host_ed25519_key.pub"


sysrc openssh_dsa_enable=NO
sysrc openssh_pidfile="/var/run/opensshd.pid"
```

## Abschluss

OpenSSH kann nun gestartet werden.

``` bash
service openssh start
```
