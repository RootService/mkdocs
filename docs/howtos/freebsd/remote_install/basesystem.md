---
title: 'BaseSystem'
description: 'In diesem HowTo wird step-by-step die Remote Installation des FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# BaseSystem

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Remote Installation des [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem mittels [mfsBSD](https://mfsbsd.vx.sk/){: target="_blank" rel="noopener"} auf einem dedizierten Server. Um eine weitere Republikation der offiziellen [FreeBSD Dokumentation](https://docs.freebsd.org/en/books/handbook/){: target="_blank" rel="noopener"} zu vermeiden, werde ich in diesem HowTo nicht alle Punkte bis ins Detail erläutern.

Unser BaseSystem wird folgende Dienste umfassen.

- FreeBSD 14.1-RELEASE 64Bit
- OpenSSL 3.0.13
- OpenSSH 9.7p1
- Unbound 1.20.0

## Voraussetzungen

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Remote Installation](/howtos/freebsd/remote_install/)

## RescueSystem booten

Um unser [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) installieren zu können, müssen wir unsere virtuelle Maschine mit einem RescueSystem booten. Hierfür eignet sich die auf [Arch Linux](https://www.archlinux.org/){: target="_blank" rel="noopener"} basierende [SystemRescueCD](https://www.system-rescue.org/){: target="_blank" rel="noopener"} am Besten, welche wir mittels des mit Windows mitgelieferten cURL-Client herunterladen und unserer virtuellen Maschine als Bootmedium zuweisen.

``` powershell
cd "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD"

curl -o "systemrescue-11.01-amd64.iso" -L "https://fastly-cdn.system-rescue.org/releases/11.00/systemrescue-11.01-amd64.iso"

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "FreeBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium "systemrescue-11.01-amd64.iso"
```

Wir können das RescueSystem jetzt booten.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "FreeBSD"
```

Im Bootmenü wählen wir die erste Option "Boot with default options" aus.

Ist der Bootvorgang abgeschlossen, wird als Erstes das root-Passwort für das RescueSystem gesetzt und die Firewall deaktiviert.

``` bash
setkmap de

passwd root

systemctl stop iptables
systemctl stop ip6tables
```

Jetzt sollten wir uns mittels PuTTY als `root` in das RescueSystem einloggen und mit der Installation unseres mfsBSD Image fortfahren können.

``` powershell
putty -ssh -P 2222 root@127.0.0.1
```

## mfsBSD installieren

Um unsere umfangreichen Vorbereitungen nun abzuschliessen, müssen wir nur noch unser [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) installieren und booten.

Als Erstes kopieren wir mittels PuTTYs SCP-Client (`pscp`) das mfsBSD Image in das RescueSystem.

``` powershell
pscp -P 2222 "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD\mfsbsd-14.1-RELEASE-amd64.img" root@127.0.0.1:/tmp/mfsbsd-14.1-RELEASE-amd64.img
```

Jetzt können wir das mfsBSD Image mittels `dd` auf der ersten Festplatte (`/dev/nvme0n1`) unserer virtuellen Maschine installieren und uns anschliessend wieder aus dem RescueSystem ausloggen.

``` bash
dd if=/dev/zero of=/dev/nvme0n1 count=512 bs=1M

dd if=/tmp/mfsbsd-14.1-RELEASE-amd64.img of=/dev/nvme0n1 bs=1M

exit
```

Abschliessend stoppen wir die virtuelle Maschine vorübergehend und entfernen die SystemRescueCD aus dem virtuellen DVD-Laufwerk.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" controlvm "FreeBSD" poweroff

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "FreeBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

## FreeBSD installieren

Nachdem nun alle Vorbereitungen abgeschlossen sind, können wir endlich mit der eigentlichen FreeBSD Remote Installation beginnen, indem wir die virtuelle Maschine wieder booten.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "FreeBSD"
```

Jetzt sollten wir uns mittels PuTTY als `root` mit dem Passwort `mfsroot` in das mfsBSD Image einloggen und mit der Installation von FreeBSD beginnen können.

``` powershell
putty -ssh -P 2222 root@127.0.0.1
```

## Partitionieren der Festplatte

Bevor wir anfangen, bereinigen wir die Festplatten von jeglichen Datenrückständen, indem wir sie mit Nullen überschreiben. Je nach Festplattengrösse kann dies einige Stunden bis Tage in Anspruch nehmen. Aus diesem Grund verlegen wir diese Jobs mittels `nohup` in den Hintergrund, so dass wir uns zwischenzeitlich ausloggen können ohne dass dabei die Jobs automatisch von der Shell abgebrochen werden. Ob die Jobs fertig sind, lässt dann mittels `ps -auxfwww` und `top -atCP` ermitteln.

``` bash
nohup dd if=/dev/zero of=/dev/nvd0 bs=1M  &
nohup dd if=/dev/zero of=/dev/nvd1 bs=1M  &
```

Da jeder Administrator andere Präferenzen an sein Partitionslayout stellt und wir andernfalls mit diesem HowTo nicht weiterkommen, verwenden wir im Folgenden ein Standard-Partitionslayout. Fortgeschrittenere FreeBSD-Administratoren können dieses Partitionslayout selbstverständlich an ihre eigenen Bedürfnisse anpassen.

| Partition | Mountpunkt | Filesystem | Grösse |
| :-------: | :--------- | :--------: | -----: |
| /dev/mirror/root | /     | UFS2 | 60 GB |
| /dev/mirror/swap | none  | SWAP |  4 GB |

Als Erstes müssen wir die Festplatte partitionieren, was wir mittels `gpart` erledigen werden. Zuvor müssen wir dies aber dem Kernel mittels `sysctl` mitteilen, da er uns andernfalls dazwischenfunken würde.

Wir werden auf beiden Festplatten jeweils vier Partitionen anlegen, die Erste für den GPT-Bootcode, die Zweite für den EFI-Bootcode, die Dritte als Swap und die Vierte als Systempartition. Dabei werden wir die Partitionen auch gleich für modernere Festplatten mit 4K-Sektoren optimieren und statt den veralteten "MBR Partition Tables" die aktuelleren "GUID Partition Tables (GPT)" verwenden.

``` bash
sysctl kern.geom.debugflags=0x10

gpart destroy -F nvd0
gpart destroy -F nvd1

gpart create -s gpt nvd0
gpart create -s gpt nvd1

gpart add -t freebsd-boot  -b      40 -s     216 -l bootfs0 nvd0
gpart add -t efi           -b     256 -s    3840 -l efiesp0 nvd0
gpart add -t freebsd-swap  -b    4096 -s 8388608 -l swapfs0 nvd0
gpart add -t freebsd-ufs   -b 8392704            -l rootfs0 nvd0

gpart add -t freebsd-boot  -b      40 -s     216 -l bootfs1 nvd1
gpart add -t efi           -b     256 -s    3840 -l efiesp1 nvd1
gpart add -t freebsd-swap  -b    4096 -s 8388608 -l swapfs1 nvd1
gpart add -t freebsd-ufs   -b 8392704            -l rootfs1 nvd1

gpart set -a bootme -i 4 nvd0
gpart set -a bootme -i 4 nvd1
```

Für eine leicht erhöhte Datensicherheit legen wir mittels `gmirror` ein Software-RAID1 an.

``` bash
kldload geom_mirror
kldload zfs

sysctl vfs.zfs.min_auto_ashift=12

gmirror label -b load rootfs nvd0p4 nvd1p4
gmirror label -b prefer -F swapfs nvd0p3 nvd1p3
```

## Formatieren der Partitionen

Nun müssen wir noch die Systempartition und die Partition für die Nutzdaten mit "UFS2" und einer 4K-Blockgrösse formatieren und aktivieren auch gleich die "soft-updates".

``` bash
newfs -U -l -t /dev/mirror/rootfs
tunefs -a enable /dev/mirror/rootfs
```

## Mounten der Partitionen

Die Partitionen mounten wir unterhalb von `/mnt`.

``` bash
mount -t ufs /dev/mirror/rootfs /mnt
mkdir -p /mnt/data
```

## Installation der Chroot-Umgebung

Auf die gemounteten Partitionen entpacken wir ein FreeBSD Basesystem mit dem wir problemlos weiterarbeiten können. Je nach Auslastung des FreeBSD FTP-Servers kann dies ein wenig dauern, bitte nicht ungeduldig werden.

``` bash
fetch -4 -q -o - --no-verify-peer "https://download.freebsd.org/releases/amd64/14.1-RELEASE/base.txz"   | tar Jxpvf - -C /mnt/
fetch -4 -q -o - --no-verify-peer "https://download.freebsd.org/releases/amd64/14.1-RELEASE/kernel.txz" | tar Jxpvf - -C /mnt/

cp -a /mnt/boot/kernel /mnt/boot/GENERIC
```

Unser System soll natürlich auch von den Festplatten booten können, weshalb wir jetzt den Bootcode und Bootloader in den Bootpartitionen installieren.

Festplatte 1:

``` bash
newfs_msdos /dev/gpt/efiesp0

mount -t msdosfs /dev/gpt/efiesp0 /mnt/boot/efi

mkdir -p /mnt/boot/efi/EFI/BOOT
cp /mnt/boot/loader.efi /mnt/boot/efi/EFI/BOOT/BOOTX64.efi
efibootmgr -a -c -l vtbd0p2:/EFI/BOOT/BOOTX64.efi -L FreeBSD

umount /mnt/boot/efi

gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptboot -i 1 nvd0
```

Festplatte 2:

``` bash
newfs_msdos /dev/gpt/efiesp1

mount -t msdosfs /dev/gpt/efiesp1 /mnt/boot/efi

mkdir -p /mnt/boot/efi/EFI/BOOT
cp /mnt/boot/loader.efi /mnt/boot/efi/EFI/BOOT/BOOTX64.efi
efibootmgr -a -c -l vtbd0p2:/EFI/BOOT/BOOTX64.efi -L FreeBSD

umount /mnt/boot/efi

gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptboot -i 1 nvd1
```

## Vorbereiten der Chroot-Umgebung

Vor dem Wechsel in die Chroot-Umgebung müssen wir noch die `resolv.conf` in die Chroot-Umgebung kopieren und das Device-Filesysteme dorthin mounten.

``` bash
cp /etc/resolv.conf /mnt/etc/resolv.conf

mount -t devfs devfs /mnt/dev
```

## Betreten der Chroot-Umgebung

Das neu installierte System selbstverständlich noch konfiguriert werden, bevor wir es nutzen können. Dazu werden wir jetzt in das neue System chrooten und eine minimale Grundkonfiguration vornehmen.

Beim Betreten der Chroot-Umgebung setzen wir mittels `/usr/bin/env -i` erstmal alle Environment-Variablen zurück. Andererseits benötigen wir aber die Environment-Variablen `HOME` und `TERM`, welche wir manuell auf sinnvolle Defaults setzen.

``` bash
chroot /mnt /usr/bin/env -i HOME=/root TERM=$TERM /bin/tcsh
```

## Zeitzone einrichten

Zunächst setzen wir die Systemzeit (CMOS clock) mittels `tzsetup` auf "UTC" (Universal Time Code).

``` bash
/usr/sbin/tzsetup UTC
```

Cronjob zur regelmässigen Syncronisation mit einem Zeitserver einrichten.

``` bash
cat <<'EOF' >> /etc/crontab
59      */4     *       *       *       root    /usr/sbin/sntp -S ptbtime3.ptb.de >/dev/null 2>&1
EOF
```

## Shell einrichten

This version of sh was rewritten in 1989 under the BSD license after the Bourne shell from AT&T System V Release 4 UNIX.

``` bash
# Colorize console output
cat <<'EOF' >> /etc/csh.cshrc
setenv LSCOLORS "Dxfxcxdxbxegedabagacad"
EOF

sed -e '/export PAGER/ a\
CLICOLORS="YES";                             export CLICOLOR\
LSCOLORS="Dxfxcxdxbxegedabagacad";           export LSCOLORS\
COLORFGBG="15;0";                            export COLORFGBG\
COLORTERM=truecolor;                         export COLORTERM\
TERM=${TERM:-xterm-256color};                export TERM\
MANCOLOR="1";                                export MANCOLOR\
MANWIDTH=tty;                                export MANWIDTH\
' -i '' /usr/share/skel/dot.profile

sed -e '/export PAGER/ a\
CLICOLORS="YES";                             export CLICOLOR\
LSCOLORS="Dxfxcxdxbxegedabagacad";           export LSCOLORS\
COLORFGBG="15;0";                            export COLORFGBG\
COLORTERM=truecolor;                         export COLORTERM\
TERM=${TERM:-xterm-256color};                export TERM\
MANCOLOR="1";                                export MANCOLOR\
MANWIDTH=tty;                                export MANWIDTH\
' -i '' /root/.profile


# Some useful aliases
cat <<'EOF' >> /etc/csh.cshrc
alias ls        ls -FGIPTW
alias l         ls -FGIPTWahl
EOF

sed -e '/some useful aliases/ a\
alias ls="ls -FGIPTW"\
alias l="ls -FGIPTWahl"\
' -i '' /usr/share/skel/dot.shrc

sed -e '/some useful aliases/ a\
alias ls="ls -FGIPTW"\
alias l="ls -FGIPTWahl"\
' -i '' /root/.shrc


# Use ee instead of vi as standard editor
sed -e 's/\(EDITOR[[:space:]]*\)vi[[:space:]]*$/\1ee/' -i '' /usr/share/skel/dot.cshrc
sed -e 's/\(set EDITOR=\)vi[[:space:]]*$/\1ee/' -i '' /usr/share/skel/dot.mailrc
sed -e 's/\(set VISUAL=\)vi[[:space:]]*$/\1ee/' -i '' /usr/share/skel/dot.mailrc
sed -e 's/\(EDITOR=\)vi;\([[:space:]].*\)$/\1ee;\2/' -i '' /usr/share/skel/dot.profile

sed -e 's/\(EDITOR[[:space:]]*\)vi[[:space:]]*$/\1ee/' -i '' /root/.cshrc
sed -e 's/\(EDITOR=\)vi;\([[:space:]].*\)$/\1ee;\2/' -i '' /root/.profile


# Use meaningfuller prompt
sed -e 's/\(set prompt =\).*$/\1 "[%B%n%b@%B%m%b:%B%~%b] %# "/' -i '' /root/.cshrc
sed -e 's/\(PS1=\).*$/\1"\\[\\e[1;36m\\][\\[\\e[1;33m\\]\\u@\\h:\\[\\e[1;36m\\]\\w] \\\\$ \\[\\e[0m\\]"/' -i '' /root/.shrc

sed -e 's/\(set prompt =\).*$/\1 "[%B%n%b@%B%m%b:%B%~%b] %# "/' -i '' /usr/share/skel/dot.cshrc
sed -e 's/\(PS1=\).*$/\1"\\[\\e[1;36m\\][\\[\\e[1;33m\\]\\u@\\h:\\[\\e[1;36m\\]\\w] \\\\$ \\[\\e[0m\\]"/' -i '' /usr/share/skel/dot.shrc


# Set missing ENV
sed -e 's#\(setenv=BLOCKSIZE=K\)#\1,OPENSSL_CONF=/usr/local/openssl/openssl.cnf,CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1#' -i '' /etc/login.conf
cap_mkdb /etc/login.conf


# Set root shell to /bin/sh
pw useradd -D -g '' -M 0700 -s sh -w no
pw usermod -n root -s sh -w none
```

## Systemsicherheit verstärken

Die hier vorgestellten Massnahmen sind äusserst simple Basics, die aus Hygienegründen auf jedem FreeBSD System selbstverständlich sein sollten. Um ein FreeBSD System richtig zu härten (Hardened), kommt man jedoch nicht an komplexeren Methoden wie Security Event Auditing und Mandatory Access Control vorbei. Diese Themen werden im FreeBSD Handbuch recht ausführlich besprochen; für den Einstieg empfehle ich hier die Lektüre von [Chapter 14. Security](https://docs.freebsd.org/en/books/handbook/security/){: target="_blank" rel="noopener"}, für die weiterführenden Themen die [Chapter 16. Mandatory Access Control](https://docs.freebsd.org/en/books/handbook/mac/){: target="_blank" rel="noopener"} und [Chapter 17. Security Event Auditing](https://docs.freebsd.org/en/books/handbook/audit/){: target="_blank" rel="noopener"}.

### OpenSSH konfigurieren

Da wir gerade ein Produktiv-System aufsetzen, werden wir den SSH-Dienst recht restriktiv konfigurieren, unter Anderem werden wir den Login per Passwort verbieten und nur per PublicKey zulassen.

``` bash
sed -e 's|^#\(Port\).*$|\1 22|' \
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
    -e 's|^#\(PidFile\).*$|\1 /var/run/sshd.pid|' \
    -e 's|^#\(MaxStartups\).*$|\1 10:30:100|' \
    -e 's|^#\(PermitTunnel\).*$|\1 no|' \
    -e 's|^#\(ChrootDirectory\).*$|\1 %h|' \
    -e 's|^#\(UseBlacklist\).*$|\1 no|' \
    -e 's|^#\(VersionAddendum\).*$|\1 none|' \
    -e 's|^\(Subsystem.*\)$|#\1|' \
    -i '' /etc/ssh/sshd_config

cat <<'EOF' >> /etc/ssh/sshd_config

Subsystem sftp internal-sftp -u 0027

AllowGroups wheel admin sshusers sftponly

Match User root
    ChrootDirectory none
    PasswordAuthentication no

Match Group admin
    ChrootDirectory none
    PasswordAuthentication yes

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
' -i '' /etc/ssh/sshd_config

ssh-keygen -q -t rsa -b 4096 -f "/etc/ssh/ssh_host_rsa_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_rsa_key.pub"
ssh-keygen -q -t ecdsa -b 384 -f "/etc/ssh/ssh_host_ecdsa_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_ecdsa_key.pub"
ssh-keygen -q -t ed25519 -f "/etc/ssh/ssh_host_ed25519_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_ed25519_key.pub"


mkdir -p /root/.ssh
chmod 0700 /root/.ssh
ssh-keygen -t ed25519 -O clear -O permit-pty -f "/root/.ssh/id_ed25519" -N ""
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
ssh-keygen -t ecdsa -b 384 -O clear -O permit-pty -f "/root/.ssh/id_ecdsa" -N ""
cat /root/.ssh/id_ecdsa.pub >> /root/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -O clear -O permit-pty -f "/root/.ssh/id_rsa" -N ""
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
```

### /etc/sysctl.conf anpassen

In der `sysctl.conf` können die meisten Kernel-Parameter verändert werden. Wir wollen dies nutzen, um unser System etwas robuster und sicherer zu machen.

``` bash
cat <<'EOF' >> /etc/sysctl.conf
kern.ipc.maxsockbuf=16777216
kern.ipc.shm_use_phys=1
kern.ipc.soacceptqueue=1024
kern.ipc.somaxconn=1024
kern.maxfiles=65536
kern.maxprocperuid=65535
kern.msgbuf_show_timestamp=1
kern.ps_arg_cache_limit=4096
kern.randompid=1369
kern.sched.slice=1
kern.threads.max_threads_per_proc=4096
net.inet.icmp.drop_redirect=1
net.inet.icmp.icmplim=1
net.inet.icmp.icmplim_output=0
net.inet.ip.check_interface=1
net.inet.ip.forwarding=1
net.inet.ip.intr_queue_maxlen=2048
net.inet.ip.maxfragpackets=0
net.inet.ip.maxfragsperpacket=0
net.inet.ip.process_options=0
net.inet.ip.random_id=1
net.inet.ip.redirect=0
net.inet.ip.stealth=1
net.inet.ip.ttl=128
net.inet.raw.maxdgram=16384
net.inet.raw.recvspace=16384
net.inet.sctp.blackhole=2
net.inet.tcp.abc_l_var=44
net.inet.tcp.blackhole=2
net.inet.tcp.cc.abe=1
net.inet.tcp.cc.algorithm=htcp
net.inet.tcp.cc.htcp.adaptive_backoff=1
net.inet.tcp.cc.htcp.rtt_scaling=1
net.inet.tcp.delacktime=20
#net.inet.tcp.delayed_ack=0
net.inet.tcp.drop_synfin=1
net.inet.tcp.ecn.enable=1
net.inet.tcp.fast_finwait2_recycle=1
net.inet.tcp.fastopen.client_enable=0
net.inet.tcp.fastopen.server_enable=0
net.inet.tcp.finwait2_timeout=5000
net.inet.tcp.icmp_may_rst=0
net.inet.tcp.initcwnd_segments=44
net.inet.tcp.isn_reseed_interval=4500
net.inet.tcp.keepcnt=2
net.inet.tcp.keepidle=62000
net.inet.tcp.keepintvl=5000
net.inet.tcp.minmss=536
net.inet.tcp.msl=2500
net.inet.tcp.mssdflt=1460
net.inet.tcp.nolocaltimewait=1
net.inet.tcp.path_mtu_discovery=0
net.inet.tcp.recvbuf_inc=65536
net.inet.tcp.recvbuf_max=4194304
net.inet.tcp.recvspace=655536
net.inet.tcp.rfc6675_pipe=1
net.inet.tcp.sendbuf_inc=65536
net.inet.tcp.sendbuf_max=4194304
net.inet.tcp.sendspace=655536
net.inet.tcp.syncache.rexmtlimit=0
net.inet.tcp.syncookies=0
net.inet.tcp.syncookies_only=1
net.inet.tcp.tso=0
net.inet.udp.blackhole=1
net.inet.udp.maxdgram=16384
net.inet.udp.recvspace=1048576
net.inet6.icmp6.nodeinfo=0
net.inet6.icmp6.rediraccept=0
net.inet6.ip6.forwarding=1
net.inet6.ip6.maxfragpackets=0
net.inet6.ip6.maxfrags=0
net.inet6.ip6.redirect=0
net.inet6.ip6.stealth=1
net.local.stream.recvspace=16384
net.local.stream.sendspace=16384
net.route.netisr_maxqlen=2048
security.bsd.hardlink_check_gid=1
security.bsd.hardlink_check_uid=1
security.bsd.see_other_gids=0
security.bsd.see_other_uids=0
security.bsd.see_jail_proc=0
security.bsd.stack_guard_page=1
security.bsd.unprivileged_proc_debug=0
security.bsd.unprivileged_read_msgbuf=0
vfs.read_max=128
vfs.ufs.dirhash_maxmem=67108864
vfs.zfs.min_auto_ashift=12
EOF
```

### Stärkere Passwort-Hashes verwenden

Um Bruteforce-Attacken erheblich auszubremsen setzen wir für die Passworte der Systemuser eine Mindestlänge (minpasswordlen) von 12 Zeichen in einem Mix aus Gross- und Kleinschreibung (mixpasswordcase) fest. Desweiteren lassen wir User nach 30 Minuten Inaktivität automatisch ausloggen (idletime). Wir bearbeiten hierzu mit dem Editor `ee` (`ee /etc/login.conf`) in der Datei `/etc/login.conf` die Login-Klasse `default`, indem wir vor der vorletzten Zeile folgende Zeilen hinzufügen.

``` text
        :mixpasswordcase=true:\
        :minpasswordlen=12:\
        :idletime=30:\
```

Anschliessend muss die Datei in eine Systemdatenbank umgewandelt werden.

``` bash
cap_mkdb /etc/login.conf
```

Die neuen Einstellungen werden erst wirksam, wenn das Passwort eines Benutzers geändert wird. Deshalb müssen wir jetzt die Passwörter für `root` und alle anderen bisher von uns angelegten User ändern.

``` bash
passwd root
```

### Terminals absichern

Um zu verhindern, dass das System im Single User Mode ohne jeglichen Schutz benutzbar ist, ändern wir in der Datei `/etc/ttys` die Zeile `console none...` wie folgt ab.

``` text
console none                            unknown off insecure
```

Dadurch wird die Eingabe des root-Kennworts erforderlich, um das System im Single User Mode booten zu können. Den Rest sollten wir hingegen unverändert lassen.

Zusätzlich können wir veranlassen, dass die Konsole bei jedem Logout gelöscht wird, so dass nicht versehentlich vertrauliche Informationen auf dem Bildschirm sichtbar bleiben. Dazu ändern wir in der Datei `/etc/gettytab` den Eintrag `P|Pc|Pc console` (circa Zeile 170) wie folgt ab.

``` text
P|Pc|Pc console:\
        :ht:np:sp#115200:\
        :cl=\E[H\E[2J:
```

Wir passen auch unsere Login-Begrüssung (motd) an.

``` bash
cat <<'EOF' > /etc/motd.template



      ______                                 ,        ,
     |  ____| __ ___  ___                   /(        )`
     | |__ | '__/ _ \/ _ \                  \ \___   / |
     |  __|| | |  __/  __/                  /- _  `-/  '
     | |   | | |    |    |                 (/\/ \ \   /\
     |_|   |_|  \___|\___|                 / /   | `    \
      ____   _____ _____                   O O   ) /    |
     |  _ \ / ____|  __ \                  `-^--'`<     '
     | |_) | (___ | |  | |                (_.)  _  )   /
     |  _ < \___ \| |  | |                 `.___/`    /
     | |_) |____) | |__| |                   `-----' /
     |     |      |      |      <----.     __ / __   \
     |____/|_____/|_____/       <----|====O)))==) \) /====
                                <----'    `--' `.__,' \
                                             |        |
     Welcome to our Server                    \       /       /\
                                         ______( (_  / \______/
                                       ,'  ,-----'   |
                                       `--{__________)


EOF
```

## System konfigurieren

Die aliases-Datenbank für FreeBSDs DMA müssen wir mittels `newaliases` anlegen, auch wenn wir später DMA gar nicht verwenden möchten.

``` bash
sed -e 's/^#[[:space:]]*\(root:[[:space:]]*\).*$/\1 admin@example.com/' \
    -e 's/^#[[:space:]]*\(hostmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(webmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(www:[[:space:]]*.*\)$/\1/' \
    -i '' /etc/mail/aliases

newaliases
```

``` bash
cat <<'EOF' >> /etc/nscd.conf
keep-hot-count hosts 16384
EOF
```

``` bash
sed -e '/[a-z]*_compat/d' \
    -e 's/compat/files/g' \
    -i '' /etc/nsswitch.conf
```

``` bash
sed -e 's/^[[:space:]]*\(pool[[:space:]]*0\.freebsd\.pool.*\)$/#\1/' \
    -e 's/^#[[:space:]]*\(pool[[:space:]]*0\.CC\.pool\)/pool 0.de.pool/' \
    -i '' /etc/ntp.conf

sed -e '/^#server time.my-internal.org iburst/ a\
Server ptbtime3.ptb.de iburst\
Server ptbtime2.ptb.de iburst\
Server ptbtime1.ptb.de iburst\
' -i '' /etc/ntp.conf

cat <<'EOF' >> /etc/ntp.conf
#
interface ignore wildcard
interface listen 127.0.0.1
interface listen ::1
EOF
```

``` bash
cat <<'EOF' > /etc/resolvconf.conf
resolvconf=NO
EOF

resolvconf -u
```

Die `/etc/periodic.conf` legen wir mit folgendem Inhalt an.

``` bash
cat <<'EOF' >> /etc/periodic.conf
daily_clean_hoststat_enable="NO"
daily_clean_tmps_enable="YES"
daily_status_gmirror_enable="YES"
daily_status_include_submit_mailq="NO"
daily_status_mail_rejects_enable="NO"
daily_status_ntpd_enable="YES"
daily_submit_queuerun="NO"
weekly_noid_enable="YES"
daily_backup_pkg_enable="YES"
daily_status_pkg_changes_enable="YES"
weekly_status_pkg_enable="YES"
security_status_pkgaudit_enable="YES"
security_status_pkgchecksum_enable="YES"
EOF
```

Die `/etc/fstab` legen wir entsprechend unserem Partitionslayout an.

``` bash
cat <<'EOF' > /etc/fstab
# Device           Mountpoint    FStype     Options      Dump    Pass
# Custom /etc/fstab for FreeBSD VM images
/dev/gpt/rootfs    /             ufs        rw           1       1
/dev/gpt/swapfs    none          swap       sw           0       0
/dev/gpt/efiesp    /boot/efi     msdosfs    rw           2       2
EOF
```

In der `/etc/rc.conf` werden diverse Grundeinstellungen für das System und die installierten Dienste vorgenommen.

``` bash
cat > /etc/rc.conf
##############################################################
###  Important initial Boot-time options  ####################
##############################################################
#kern_securelevel_enable="YES"
#kern_securelevel="1"
kld_list="accf_data accf_http accf_dns cc_htcp"
fsck_y_enable="YES"
growfs_enable="YES"
dmesg_enable="YES"
zfs_enable="YES"
zpool_reguid="zroot"
zpool_upgrade="zroot"
dumpdev="AUTO"

##############################################################
###  Network configuration sub-section  ######################
##############################################################
hostname="devnull.example.com"

##### IPv4
defaultrouter="GATEWAY4"
ifconfig_IFACE="inet IPADDR4 netmask NETMASK4"

##### IPv6
ipv6_activate_all_interfaces="YES"
ipv6_defaultrouter="GATEWAY6"
ifconfig_IFACE_ipv6="inet6 IPADDR6 prefixlen PREFLEN6 accept_rtadv"

##### Additional IP Addresses
### specify additional IPv4 and IPv6 addresses one per line
#ifconfig_IFACE_aliases="\\
#        inet IPV4 netmask NETMASK \\
#        inet IPV4 netmask NETMASK \\
#        inet6 IPV6 prefixlen PREFLEN \\
#        inet6 IPV6 prefixlen PREFLEN"

##############################################################
###  Paketfilter (PF) options  ###############################
##############################################################
pf_enable="YES"
pf_rules="/etc/pf.conf"
pflog_enable="YES"
pflog_logfile="/var/log/pflog"
pflog_flags="$pflog_flags -d 600 -s 1600"

##############################################################
###  System console options  #################################
##############################################################
keymap="de.acc.kbd"

##############################################################
###  Mail Transfer Agent (MTA) options  ######################
##############################################################
sendmail_enable="NONE"
sendmail_cert_create="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
sendmail_rebuild_aliases="NO"
dma_flushq_enable="YES"

##############################################################
###  Miscellaneous administrative options  ###################
##############################################################
syslogd_flags="-ss"
clear_tmp_enable="YES"
cron_flags="$cron_flags -j 0 -J 0 -m root"
update_motd="YES"
nscd_enable="YES"
ntpd_enable="YES"
ntpd_sync_on_start="YES"
resolv_enable="NO"

##############################################################
### Jail Configuration #######################################
##############################################################

##############################################################
###  System services options  ################################
##############################################################
local_unbound_enable="YES"
local_unbound_tls="NO"
blacklistd_enable="NO"
sshd_enable="YES"
EOF
```

Es folgt ein wenig Voodoo, um die Netzwerkkonfiguration in der `/etc/rc.conf` zu vervollständigen.

``` bash
# Default Interface
route -n get -inet default | awk '/interface/ {print $2}' | \
    xargs -I % sed -e 's/IFACE/%/g' -i '' /etc/rc.conf

# IPv4
route -n get -inet default | awk '/gateway/ {print $2}' | \
    xargs -I % sed -e 's/GATEWAY4/%/g' -i '' /etc/rc.conf
ifconfig `route -n get -inet default | awk '/interface/ {print $2}'` inet | \
    awk '/inet / {if(substr($2,1,3)!=127) print $2}' | head -n 1 | \
    xargs -I % sed -e 's/IPADDR4/%/g' -i '' /etc/rc.conf
ifconfig `route -n get -inet default | awk '/interface/ {print $2}'` inet | \
    awk '/inet / {if(substr($2,1,3)!=127) print $4}' | head -n 1 | \
    xargs -I % sed -e 's/NETMASK4/%/g' -i '' /etc/rc.conf

# IPv6
route -n get -inet6 default | awk '/gateway/ {print $2}' | \
    xargs -I % sed -e 's/GATEWAY6/%/g' -i '' /etc/rc.conf
ifconfig `route -n get -inet6 default | awk '/interface/ {print $2}'` inet6 | \
    awk '/inet6 / {if(substr($2,1,1)!="f") print $2}' | head -n 1 | \
    xargs -I % sed -e 's/IPADDR6/%/g' -i '' /etc/rc.conf
ifconfig `route -n get -inet6 default | awk '/interface/ {print $2}'` inet6 | \
    awk '/inet6 / {if(substr($2,1,1)!="f") print $4}' | head -n 1 | \
    xargs -I % sed -e 's/PREFLEN6/%/g' -i '' /etc/rc.conf
```

Wir richten die `/etc/hosts` ein.

``` bash
# localhost
sed -e 's/my.domain/example.com/g' -i '' /etc/hosts

# IPv4
echo 'IPADDR4   devnull.example.com   devnull' >> /etc/hosts

ifconfig `route -n get -inet default | awk '/interface/ {print $2}'` inet | \
    awk '/inet / {if(substr($2,1,3)!=127) print $2}' | head -n 1 | \
    xargs -I % sed -e 's/IPADDR4/%/g' -i '' /etc/hosts

# IPv6
echo 'IPADDR6   devnull.example.com   devnull' >> /etc/hosts

ifconfig `route -n get -inet6 default | awk '/interface/ {print $2}'` inet6 | \
    awk '/inet6 / {if(substr($2,1,1)!="f") print $2}' | head -n 1 | \
    xargs -I % sed -e 's/IPADDR6/%/g' -i '' /etc/hosts
```

### Systemgruppen anlegen

Zur besseren Trennung beziehungsweise Gruppierung unterschiedlicher Nutzungszwecke legen wir ein paar Gruppen an (admin für rein administrative Nutzer, users für normale Nutzer, sshusers für Nutzer mit SSH-Zugang und sftponly für reine SFTP-Nutzer).

``` bash
pw groupadd -n admin -g 1000
pw groupadd -n users -g 2000
pw groupadd -n sshusers -g 3000
pw groupadd -n sftponly -g 4000
```

### Systembenutzer anlegen

Um nicht ständig mit dem root-User arbeiten zu müssen, legen wir uns einen Administrations-User an, den wir praktischerweise "admin" nennen. Diesem User verpassen wir die Standard-Systemgruppe "admin" und nehmen ihn zusätzlich in die Systemgruppe "wheel" auf, damit dieser User später per `su` zum root-User wechseln kann. Das Home-Verzeichnis des admin-Users lassen wir automatisch anlegen und setzen seine Standard-Shell auf `/bin/tcsh`. Ein sicheres Passwort bekommt er selbstverständlich auch noch.

``` bash
pw useradd -n admin -u 1000 -g admin -G wheel -c 'Administrator' -m -w random

passwd admin
```

Wir richten unserem `admin` noch die Shell und die zum zukünftigen Einloggen zwingend nötigten SSH-Keys ein.

``` bash
su - admin

mkdir -p .ssh
chmod 0700 .ssh

ssh-keygen -t ed25519 -O clear -O permit-pty -f ".ssh/id_ed25519" -N ""
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
ssh-keygen -t ecdsa -b 384 -O clear -O permit-pty -f ".ssh/id_ecdsa" -N ""
cat .ssh/id_ecdsa.pub >> .ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -O clear -O permit-pty -f ".ssh/id_rsa" -N ""
cat .ssh/id_rsa.pub >> .ssh/authorized_keys

exit
```

Einen normalen User mit SSH-Zugang legen wir ebenfalls an, ihn nennen wir "joeuser". Diesem User verpassen wir die Standard-Systemgruppe "users" und nehmen ihn zusätzlich in die Systemgruppe "sshusers" auf, damit sich dieser User später per `SSH` einloggen kann. Das Home-Verzeichnis des Users lassen wir automatisch anlegen und setzen seine Standard-Shell auf `/bin/tcsh`. Ein sicheres Passwort bekommt er selbstverständlich auch noch.

``` bash
pw useradd -n joeuser -u 2000 -g users -G sshusers -c 'Joe User' -m -w random

passwd joeuser
```

Wir richten unserem `joeuser` noch die Shell und die zum zukünftigen Einloggen zwingend nötigten SSH-Keys ein.

``` bash
su - joeuser

mkdir -p .ssh
chmod 0700 .ssh

ssh-keygen -t ed25519 -O clear -O permit-pty -f ".ssh/id_ed25519" -N ""
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
ssh-keygen -t ecdsa -b 384 -O clear -O permit-pty -f ".ssh/id_ecdsa" -N ""
cat .ssh/id_ecdsa.pub >> .ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -O clear -O permit-pty -f ".ssh/id_rsa" -N ""
cat .ssh/id_rsa.pub >> .ssh/authorized_keys

exit
```

## Buildsystem konfigurieren

``` bash
cat <<'EOF' > /etc/make.conf
KERNCONF?=GENERIC MYKERNEL
PRINTERDEVICE=ascii
LICENSES_ACCEPTED+=EULA
DISABLE_VULNERABILITIES=yes
EOF
```

``` bash
cat <<'EOF' > /etc/src.conf
WITHOUT_APM=YES
WITHOUT_BHYVE=YES
WITH_BIND_NOW=YES
WITHOUT_BLUETOOTH=YES
WITHOUT_BOOTPARAMD=YES
WITHOUT_BOOTPD=YES
WITHOUT_BSDINSTALL=YES
WITHOUT_BSNMP=YES
WITHOUT_CALENDAR=YES
WITHOUT_CCD=YES
WITH_CLANG_EXTRAS=YES
WITH_CLANG_FORMAT=YES
WITHOUT_CUSE=YES
WITHOUT_DEBUG_FILES=YES
WITH_DETECT_TZ_CHANGES=YES
WITHOUT_DOCCOMPRESS=YES
WITHOUT_FINGER=YES
WITHOUT_FLOPPY=YES
WITHOUT_FREEBSD_UPDATE=YES
WITHOUT_FTP=YES
WITHOUT_GAMES=YES
WITHOUT_GPIO=YES
WITHOUT_HTML=YES
WITHOUT_HYPERV=YES
WITHOUT_INETD=YES
WITHOUT_KERBEROS=YES
WITH_KERNEL_RETPOLINE=YES
WITHOUT_LIB32=YES
WITHOUT_LLVM_TARGET_ALL=YES
WITH_LLVM_TARGET_AARCH64=YES
WITH_LLVM_TARGET_ARM=YES
WITH_LLVM_TARGET_X86=YES
WITHOUT_LPR=YES
WITHOUT_MANCOMPRESS=YES
WITHOUT_NIS=YES
WITHOUT_PMC=YES
WITHOUT_PPP=YES
WITHOUT_RADIUS_SUPPORT=YES
WITHOUT_RBOOTD=YES
WITH_REPRODUCIBLE_BUILD=YES
WITH_RETPOLINE=YES
WITHOUT_SENDMAIL=YES
WITHOUT_SHAREDOCS=YES
WITH_SORT_THREAD=YES
WITHOUT_TALK=YES
WITHOUT_TESTS=YES
WITHOUT_TFTP=YES
WITHOUT_WIRELESS=YES
WITH_ZONEINFO_LEAPSECONDS_SUPPORT=YES
EOF
```

## Kernel konfigurieren

Kernel Parameter in `/boot/loader.conf` setzen.

``` bash
cat <<'EOF' >> /boot/loader.conf
# Loader options
boot_verbose="YES"
verbose_loading="YES"

# Microcode updates
#cpu_microcode_load="YES"
#cpu_microcode_name="/boot/firmware/intel-ucode.bin"
#cpu_microcode_name="/usr/local/share/cpucontrol/microcode_amd.bin"

# Kernel selection
#kernel="GENERIC"
#kernels="GENERIC ROOTSERVICE"
#kernel_options="ds=nocloud s=file://data/cloud-init/"

# Kernel modules
#coretemp_load="YES"
geom_mirror_load="YES"
zfs_load="YES"

# Kernel parameters
#debug.acpi.disabled="thermal"
security.bsd.stack_guard_page="1"
security.bsd.allow_destructive_dtrace="0"
kern.geom.label.disk_ident.enable="0"
kern.geom.label.gptid.enable="0"
kern.geom.label.gpt.enable="1"
kern.maxproc="65536"
kern.maxusers="512"
kern.ipc.nmbclusters=32768
kern.ipc.semmni="256"
kern.ipc.semmns="512"
kern.ipc.semmnu="256"
kern.ipc.shmmax="2147483648"
kern.msgbufsize="2097152"
kern.random.fortuna.minpoolsize="256"
kern.sync_on_panic="0"
#machdep.hyperthreading_allowed="0"
net.inet.tcp.hostcache.enable="0"
net.inet.tcp.hostcache.cachelimit="0"
net.inet.tcp.soreceive_stream="1"
net.inet.tcp.syncache.hashsize="1024"
net.inet.tcp.syncache.bucketlimit="100"
net.inet.tcp.tcbhashsize="524288"
net.isr.bindthreads="1"
net.isr.maxthreads="-1"
net.isr.defaultqlimit="2048"
net.link.ifqmaxlen="2048"
net.pf.source_nodes_hashsize="1048576"
EOF
```

## Abschluss der Installation

Um uns künftig mit unserem Arbeitsuser einloggen zu können, müssen wir uns dessen SSH-Key (id_ed25519) auf unser lokales System kopieren und ihn dann mit Hilfe der [PuTTYgen Dokumentation](https://the.earth.li/~sgtatham/putty/latest/htmldoc/Chapter8.html){: target="_blank" rel="noopener"} in einen für PuTTY lesbaren Private Key umwandeln (id_ed25519.ppk).

``` powershell
pscp -P 2222 -r root@127.0.0.1:/mnt/home/admin/.ssh "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh"

puttygen "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_ed25519"
```

Nun ist es endlich soweit: Wir verlassen das Chroot, unmounten die Partitionen und rebooten zum ersten Mal in unser neues FreeBSD Basis-System.

``` bash
exit

rm /mnt/root/.sh_history
rm /mnt/home/*/.sh_history
chmod 0700 /mnt/root

umount /mnt/dev
umount /mnt

shutdown -r now
```

### Einloggen und zu *root* werden

Einloggen ab hier nur noch mit Public-Key

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_ed25519.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## System aktualisieren

Nach dem Reboot aktualisieren und entschlacken wir das System.

### ports-mgmt/pkg installieren

Wir installieren als Erstes `pkg`.

``` bash
pkg bootstrap -y
```

### Git installieren

Wir installieren als Nächstes `git` und seine Abhängigkeiten.

``` bash
pkg install -y devel/git
```

### Source Tree auschecken

Am Besten funktioniert bei FreeBSD immer noch die Aktualisierung über die System-Sourcen. Auf diesem Wege kann man ein System über viele Release-Generationen hinweg aktuell halten, ohne eine Neuinstallation durchzuführen. Das Verfahren ist zwar etwas zeitaufwändig, aber erprobt und führt bei richtiger Anwendung zu einem sauberen, aktuellen System.

Zunächst wird hierzu das aktuelle Quellenverzeichnis von FreeBSD benötigt, weshalb wir es mittels [git](https://www.freebsd.org/cgi/man.cgi?query=git&sektion=1&format=html){: target="_blank" rel="noopener"} auschecken.

``` bash
# Neues Quellenverzeichnis anlegen (clone)
rm -r /usr/src
git clone -o freebsd -b releng/`/bin/freebsd-version -u | cut -d- -f1` https://git.FreeBSD.org/src.git /usr/src
etcupdate extract


# Vorhandenes Quellenverzeichnis aktualisieren (pull)
git -C /usr/src pull --rebase


# Vorhandenes Quellenverzeichnis zu FreeBSD 13-STABLE wechseln (checkout)
git -C /usr/src checkout stable/13
etcupdate extract
```

### Portstree auschecken

Um unser Basissystem später um sinnvolle Programme erweitern zu können, fehlt uns noch der sogenannte Portstree. Diesen checken wir nun ebenfalls mittels `git` aus (kann durchaus eine Stunde oder länger dauern).

``` bash
rm -r /usr/ports
git clone https://git.FreeBSD.org/ports.git /usr/ports
make -C /usr/ports fetchindex
```

Damit ist der Portstree einsatzbereit. Um den Tree künftig zu aktualisieren genügt der folgende Befehl.

``` bash
git -C /usr/ports pull --rebase
make -C /usr/ports fetchindex
```

Wichtige Informationen zu neuen Paketversionen finden sich in `/usr/ports/UPDATING` und sollten dringend beachtet werden.

``` bash
less /usr/ports/UPDATING
```

### Git deinstallieren

Wir deinstallieren `git` und seine Abhängigkeiten nun vorerst wieder.

``` bash
pkg delete -y -a
```

### Konfiguration anpassen

In den Abschnitten [Buildsystem konfigurieren](#buildsystem-konfigurieren) und [Kernel konfigurieren](#kernel-konfigurieren) haben wir uns bereits eine geeignete `make.conf` und gegebenenfalls auch eine individuelle Kernel-Konfiguration erstellt. Dennoch sei an dieser Stelle nochmals auf das FreeBSD Handbuch verwiesen. Insbesondere [Chapter 8. Configuring the FreeBSD Kernel](https://docs.freebsd.org/en/books/handbook/kernelconfig/){: target="_blank" rel="noopener"} und [24.6. Updating FreeBSD from Source](https://docs.freebsd.org/en/books/handbook/cutting-edge/#makeworld){: target="_blank" rel="noopener"} seien Jedem FreeBSD Administratoren ans Herz gelegt.

Ausserdem empfiehlt es sich vor einem Update des Basissystems die Datei `/usr/src/UPDATING` zu lesen. Alle Angaben und Hinweise in dieser Datei sind aktueller und zutreffender als das Handbuch und sollten unbedingt befolgt werden.

### Vorbereitende Arbeiten

???+ hint

    Für die spätere Installation des neu kompilierten Basissystems darf `/tmp` nicht mit der Option `noexec` gemounted sein. Da zwischendrin noch mal ein Reboot erfolgt, können wir bei Bedarf bereits jetzt die entsprechende Zeile in der `fstab` anpassen, sofern vorhanden.

Zunächst müssen eventuell vorhandene Object-Dateien im Verzeichnis `/usr/obj` gelöscht werden, damit `make` später wirklich das gesamte System neu erstellt.

``` bash
cd /usr/src

make cleanworld

git -C /usr/src pull --rebase
```

### Basissystem rekompilieren

Das Kompilieren des Basissystems kann durchaus eine Stunde oder länger dauern.

``` bash
make -j4 buildworld
```

### Kernel rekompilieren und installieren

Wenn die eigene Kernel-Konfiguration wie bei uns bereits in der `/etc/make.conf` eingetragen ist, wird sie automatisch verwendet, andernfalls wird die Konfiguration des generischen FreeBSD-Kernels verwendet. Das Kompilieren des Kernels kann durchaus eine Stunde oder länger dauern.

``` bash
mkdir -p /root/kernels

cat <<'EOF' > /root/kernels/MYKERNEL
include         GENERIC
ident           MYKERNEL
EOF

ln -s /root/kernels/MYKERNEL /usr/src/sys/amd64/conf/

make -j4 KERNCONF=GENERIC INSTALLKERNEL=GENERIC INSTKERNNAME=GENERIC kernel

make -j4 KERNCONF=MYKERNEL INSTALLKERNEL=MYKERNEL INSTKERNNAME=MYKERNEL kernel

sed -e 's/^#*\(kernels=\).*$/\1"MYKERNEL GENERIC"/' -i '' /boot/loader.conf
sed -e 's/^#*\(kernel=\).*$/\1"MYKERNEL"/' -i '' /boot/loader.conf

rm -r /boot/kernel /boot/kernel.old
```

Normalerweise wäre nun ein Reboot in den Single User Mode an der Reihe. Da sich ein Remote-System in diesem Modus ohne KVM-Lösung aber nicht bedienen lässt, begnügen wir uns damit, das System regulär neu zu starten.

``` bash
shutdown -r now
```

Wenn wir unser System zu einem späteren Zeitpunkt nochmals aktualisieren, sollten wir zuden zuvor alle Dienste ausser OpenSSH, sowie sämtliche Jails in der Datei `/etc/rc.conf` deaktivieren.

Einloggen und zu `root` werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_ed25519.ppk" admin@127.0.0.1
```

``` bash
su - root
```

### Basissystem installieren

Wir installieren das neue Basissystem.

Ausserdem sollte [etcupdate](https://www.freebsd.org/cgi/man.cgi?query=etcupdate&sektion=8&format=html){: target="_blank" rel="noopener"} im Pre-Build-Mode angeworfen werden, damit es während der Aktualisierung nicht zu Fehlern kommt, weil z. B. bestimmte User oder Gruppen noch nicht vorhanden sind.

``` bash
cd /usr/src

etcupdate -p

make installworld
```

Als letzten Schritt müssen nun noch die Neuerungen in den Konfigurationsdateien gemerged werden. Dabei unterstützt uns das Tool `etcupdate`. Wir müssen selbstverständlich darauf achten, dass wir hierbei nicht versehentlich unsere zuvor gemachten Anpassungen an den diversen Konfigurationsdateien wieder rückgängig machen.

``` bash
etcupdate -B
```

Wir entsorgen nun noch eventuell vorhandene veraltete und überflüssige Dateien.

``` bash
make BATCH_DELETE_OLD_FILES=yes delete-old
make BATCH_DELETE_OLD_FILES=yes delete-old-libs
```

Anschliessend müssen wir noch die für die Installation gegebenenfalls vorgenommenen Änderungen in der `fstab` sowie `rc.conf` rückgängig machen und das System nochmals durchstarten.

``` bash
shutdown -r now
```

Viel Spass mit dem neuen FreeBSD BaseSystem.
