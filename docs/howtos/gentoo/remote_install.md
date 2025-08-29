---
title: 'Remote Installation'
description: 'In diesem HowTo wird step-by-step die Remote Installation von Gentoo Linux 64Bit auf einem dedizierten Server beschrieben.'
date: '2003-03-02'
updated: '2014-09-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
---

# Remote Installation von Gentoo Linux – Schritt für Schritt in leichter Sprache

In diesem HowTo lernst du, wie du Gentoo Linux 64Bit auf einem dedizierten Server remote installierst. Jeder Schritt wird ausführlich erklärt, damit du die Hintergründe und die Bedeutung der Befehle verstehst. Zielgruppe sind technisch versierte Nutzer mit Grundkenntnissen in Linux.

## Einleitung

???+ warning
    Dieses HowTo wird seit **2014-09-01** nicht mehr aktiv gepflegt und entspricht daher nicht mehr dem aktuellen Stand. Die Verwendung erfolgt auf eigene Gefahr!

Hier zeige ich dir, wie du [Gentoo Linux Hardened](https://wiki.gentoo.org/wiki/Project:Hardened){: target="_blank" rel="noopener"} remote installierst. Viele Details findest du in der offiziellen [Gentoo Linux Dokumentation](https://www.gentoo.org/support/documentation/){: target="_blank" rel="noopener"}. Die wichtigsten Schritte werden hier praxisnah, ausführlich und verständlich zusammengefasst.

## Inhaltsverzeichnis
- [Das Referenzsystem](#das-referenzsystem)
- [Die Virtuelle Maschine](#die-virtuelle-maschine)
- [RescueSystem booten](#rescuesystem-booten)
- [Partitionieren der Festplatte](#partitionieren-der-festplatte)
- [Formatieren der Partitionen](#formatieren-der-partitionen)
- [Mounten der Partitionen](#mounten-der-partitionen)
- [Entpacken des Stage-Tarballs](#entpacken-des-stage-tarballs)
- [Vorbereiten der Chroot-Umgebung](#vorbereiten-der-chroot-umgebung)
- [Betreten der Chroot-Umgebung](#betreten-der-chroot-umgebung)
- [Setup der Chroot-Umgebung](#setup-der-chroot-umgebung)
- [Portage konfigurieren](#portage-konfigurieren)
- [Locales setzen](#locales-setzen)
- [Basissystem kompilieren](#basissystem-kompilieren)
- [Basissystem rekompilieren](#basissystem-rekompilieren)
- [fstab erstellen](#fstab-erstellen)
- [OpenSSL konfigurieren](#openssl-konfigurieren)
- [OpenSSH konfigurieren](#openssh-konfigurieren)
- [Systemprogramme installieren](#systemprogramme-installieren)
- [Netzwerk konfigurieren](#netzwerk-konfigurieren)
- [Kernelsourcen installieren](#kernelsourcen-installieren)
- [Kernelsourcen konfigurieren](#kernelsourcen-konfigurieren)
- [Kernelsourcen kompilieren](#kernelsourcen-kompilieren)
- [Bootloader installieren](#bootloader-installieren)
- [Bootloader konfigurieren](#bootloader-konfigurieren)
- [Systemtools installieren](#systemtools-installieren)
- [Systemtools konfigurieren](#systemtools-konfigurieren)
- [sysctl.conf einrichten](#sysctlconf-einrichten)
- [Root-Passwort setzen](#root-passwort-setzen)
- [Arbeitsuser anlegen](#arbeitsuser-anlegen)
- [SSH-Keys installieren](#ssh-keys-installieren)
- [Reboot ins neue System](#reboot-ins-neue-system)
- [Wie geht es weiter?](#wie-geht-es-weiter)

## Das Referenzsystem

Wir nutzen eine virtuelle Maschine (VM) mit VirtualBox unter Windows als Testumgebung. So kannst du gefahrlos üben, bevor du auf einem echten Server arbeitest. Die VM simuliert einen dedizierten Server.

**Installation der benötigten Programme:**

Vor dem Start installiere bitte PuTTY (für SSH) und VirtualBox (für die VM):

```powershell
winget install PuTTY.PuTTY
winget install Oracle.VirtualBox
```

## Die Virtuelle Maschine

Jetzt legst du eine neue VM an. Die folgenden Befehle erstellen die VM, richten die Hardware ein und verbinden die Festplatten. Achte darauf, dass du im richtigen Verzeichnis bist und die Pfade stimmen.

```powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createvm --name "Gentoo" --ostype Gentoo_64 --register
cd "${Env:USERPROFILE}\VirtualBox VMs\Gentoo"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "Gentoo1.vdi" --size 32768
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "Gentoo2.vdi" --size 32768
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --firmware bios --cpus 2 --cpuexecutioncap 100 --cpuhotplug off
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --chipset ICH9 --graphicscontroller vmsvga --audio none --usb off
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --hwvirtex on --ioapic on --hpet on --rtcuseutc on --memory 4096 --vram 64
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --nic1 nat --nictype1 82540EM --natnet1 "192.168/16" --cableconnected1 on
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --boot1 dvd --boot2 disk --boot3 none --boot4 none
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "Gentoo" --name "IDE Controller" --add ide --controller ICH6 --portcount 2
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "Gentoo" --name "AHCI Controller" --add sata --controller IntelAHCI --portcount 4
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "Gentoo" --storagectl "AHCI Controller" --port 0 --device 0 --type hdd --medium "Gentoo1.vdi"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "Gentoo" --storagectl "AHCI Controller" --port 1 --device 0 --type hdd --medium "Gentoo2.vdi"
```

Damit du später per SSH auf die VM zugreifen kannst, richte ein Portforwarding ein. So kannst du von deinem Windows-Host aus auf die VM zugreifen:

```powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Gentoo" --natpf1 SSH,tcp,,2222,,22
```

Nachdem die virtuelle Maschine nun konfiguriert ist, wird es Zeit diese zu booten.

## RescueSystem booten

Lade die SystemRescueCD herunter und binde sie als Bootmedium ein. Damit kannst du Gentoo installieren und die Festplatten vorbereiten. Die folgenden Befehle laden das ISO-Image und binden es ein:

```powershell
cd "${Env:USERPROFILE}\VirtualBox VMs\Gentoo"
ftp -A ftp.halifax.rwth-aachen.de
cd osdn/storage/g/s/sy/systemrescuecd/releases/7.01
binary
get systemrescue-7.01-amd64.iso
quit
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "Gentoo" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "systemrescue-7.01-amd64.iso"
```

Starte die VM und boote von der SystemRescueCD:

```powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "Gentoo"
```

Im Bootmenü wählst du die Standardoption. Setze dann das root-Passwort, damit du dich per SSH einloggen kannst:

```bash
passwd root
```

Jetzt kannst du dich mit PuTTY als root auf die VM verbinden:

```powershell
putty -ssh -P 2222 root@127.0.0.1
```

## Partitionieren der Festplatte

Bevor du Partitionen anlegst, solltest du die Festplatten bereinigen. Das folgende Kommando überschreibt die Festplatten mit Nullen. Das dauert je nach Größe mehrere Stunden. Die Jobs laufen im Hintergrund weiter:

```bash
nohup dd if=/dev/zero of=/dev/sda bs=512  &
nohup dd if=/dev/zero of=/dev/sdb bs=512  &
```

Jetzt legst du das Partitionslayout fest. Die Tabelle zeigt ein Beispiel für ein sicheres und flexibles Layout. Passe es bei Bedarf an deine Anforderungen an.

| Partition | Mountpunkt | Filesystem | Grösse |
| :-------- | :--------- | :--------: | -----: |
| /dev/sda1 /dev/sdb1 | none | [bootloader] | 2 MB |
| /dev/sda2 /dev/sdb2 | /boot| EXT2 | 512 MB |
| /dev/sda3 /dev/sdb3 | / | EXT3 | 16 GB |
| /dev/sda4 /dev/sdb4 | /data | EXT3 | 8 GB |
| /dev/sda5 /dev/sdb5 | none | [swap] | 4 GB |

Die Partitionen legst du nun mittels parted an.

```bash
parted -s -a optimal /dev/sda
parted -s -a optimal /dev/sdb

parted -s /dev/sda mklabel gpt
parted -s /dev/sdb mklabel gpt

parted -s /dev/sda mkpart primary 4096s 8191s
parted -s /dev/sdb mkpart primary 4096s 8191s

parted -s /dev/sda mkpart primary 8192s 1056767s
parted -s /dev/sdb mkpart primary 8192s 1056767s

parted -s /dev/sda mkpart primary 1056768s 34611199s
parted -s /dev/sdb mkpart primary 1056768s 34611199s

parted -s /dev/sda mkpart primary 34611200s 51388415s
parted -s /dev/sdb mkpart primary 34611200s 51388415s

parted -s /dev/sda mkpart primary 51388416s 59777023s
parted -s /dev/sdb mkpart primary 51388416s 59777923s

parted -s /dev/sda name 1 grub
parted -s /dev/sdb name 1 grub

parted -s /dev/sda name 2 boot
parted -s /dev/sdb name 2 boot

parted -s /dev/sda name 3 rootfs
parted -s /dev/sdb name 3 rootfs

parted -s /dev/sda name 4 data
parted -s /dev/sdb name 4 data

parted -s /dev/sda name 5 swap
parted -s /dev/sdb name 5 swap

parted -s /dev/sda set 1 bios_grub on
parted -s /dev/sdb set 1 bios_grub on
```

Für mehr Datensicherheit richtest du ein Software-RAID1 mit mdadm ein. Das spiegelt die Daten auf beide Festplatten:

```bash
mknod /dev/md2 b 9 2
mknod /dev/md3 b 9 3
mknod /dev/md4 b 9 4
mknod /dev/md5 b 9 5

cat >> /etc/mdadm.conf << "EOF"
MAILADDR root@localhost
MAILFROM root@localhost
CREATE metadata=1.2
HOMEHOST <none>
DEVICE /dev/sd*[0-9]
EOF

mdadm --create /dev/md2 --name=boot --bitmap=internal --level=raid1 --raid-devices=2 --metadata=1.2 /dev/sd[ab]2
mdadm --create /dev/md3 --name=root --bitmap=internal --level=raid1 --raid-devices=2 --metadata=1.2 /dev/sd[ab]3
mdadm --create /dev/md4 --name=data --bitmap=internal --level=raid1 --raid-devices=2 --metadata=1.2 /dev/sd[ab]4
mdadm --create /dev/md5 --name=swap --bitmap=internal --level=raid1 --raid-devices=2 --metadata=1.2 /dev/sd[ab]5
```

## Formatieren der Partitionen

Jetzt formatierst du die Partitionen. Die Bootpartition wird mit EXT2 formatiert, die anderen mit EXT3. Die Optionen sorgen für Performance und Zuverlässigkeit. Swap wird ebenfalls initialisiert:

```bash
mke2fs -c -b 4096 -t ext2 /dev/md2
tune2fs -c 0 -i 0 /dev/md2
tune2fs -e continue /dev/md2
tune2fs -O dir_index /dev/md2
tune2fs -o user_xattr,acl /dev/md2
e2fsck -D /dev/md2

mke2fs -c -b 4096 -t ext3 -j /dev/md3
tune2fs -c 0 -i 0 /dev/md3
tune2fs -e continue /dev/md3
tune2fs -O dir_index,large_file /dev/md3
tune2fs -o user_xattr,acl,journal_data /dev/md3
e2fsck -D /dev/md3

mke2fs -c -b 4096 -t ext3 -j /dev/md4
tune2fs -c 0 -i 0 /dev/md4
tune2fs -e continue /dev/md4
tune2fs -O dir_index,large_file /dev/md4
tune2fs -o user_xattr,acl,journal_data /dev/md4
e2fsck -D /dev/md4

mkswap -c /dev/md5
```

## Mounten der Partitionen

Jetzt aktivierst du den Swap und mountest die Root-Partition als Ziel für die Installation:

```bash
swapon /dev/md5
mkdir -p /mnt/gentoo
mount -t ext3 -o defaults,relatime,barrier=1 /dev/md3 /mnt/gentoo
```

## Entpacken des Stage-Tarballs

Lade das aktuelle Gentoo-Basissystem (Stage3) herunter und entpacke es direkt ins Zielverzeichnis. Das ist die Grundlage für dein neues System:

```bash
wget -q -O - "https://gentoo.osuosl.org/releases/amd64/autobuilds/latest-stage3-amd64-hardened+nomultilib.txt" | tail -n 1 | \
     xargs -I % wget -q -O - "https://gentoo.osuosl.org/releases/amd64/autobuilds/%" | tar xpjvf - -C /mnt/gentoo/
```

## Vorbereiten der Chroot-Umgebung

Kopiere wichtige Konfigurationsdateien und mounte die Systemverzeichnisse, damit die Chroot-Umgebung funktioniert:

```bash
cp /etc/resolv.conf /mnt/gentoo/etc/resolv.conf

mount -t proc none /mnt/gentoo/proc
mount -o bind /sys /mnt/gentoo/sys
mount -o bind /dev /mnt/gentoo/dev
mount -o bind /dev/pts /mnt/gentoo/dev/pts
mount -o bind /dev/shm /mnt/gentoo/dev/shm
```

## Betreten der Chroot-Umgebung

Jetzt wechselst du in das neue System. Die Umgebungsvariablen werden gesetzt, damit du eine funktionierende Shell hast. /boot wird gemountet, damit du später den Kernel installieren kannst:

```bash
chroot /mnt/gentoo /bin/env -i HOME=/root TERM=$TERM PS1='\u:\w\$ ' PATH=/sbin:/bin:/usr/sbin:/usr/bin /bin/bash +h

mkdir /data

mount -t ext2 -o defaults,relatime /dev/md2 /boot
```

## Setup der Chroot-Umgebung

Stelle die Zeitzone ein, aktualisiere die Umgebungsvariablen und sorge dafür, dass das System korrekt startet:

```bash
echo "Europe/Berlin" > /etc/timezone
emerge --config sys-libs/timezone-data

grep -v rootfs /proc/mounts > /etc/mtab

env-update
source /etc/profile
```

## Portage konfigurieren

Jetzt legst du Compiler-Optionen, Sprachunterstützung und USE-Flags fest. Diese Einstellungen beeinflussen, wie Pakete gebaut und welche Features aktiviert werden:

```bash
cat > /etc/portage/make.conf << "EOF"
CHOST="x86_64-pc-linux-gnu"
CFLAGS="-O2 -pipe -fomit-frame-pointer -march=native"
CXXFLAGS="${CFLAGS}"
FFLAGS="${CFLAGS}"
FCFLAGS="${FFLAGS}"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
ACCEPT_KEYWORDS="amd64"
MAKEOPTS="-j2"
LINGUAS="en de"
PAX_MARKINGS="XT"
USE="-* acl berkdb bzip2 caps crypt cxx ecdsa fam fdformat filecaps \
    firmware-loader gcrypt gd gdbm gmp hardened iconv icu idn ipc ipv6 \
    ithreads jpeg kmod ldns libedit libssp lzma magic mime mktemp mmx \
    mpfr mudflap multicall ncurses net netifrc newnet nls nptl nscd \
    openmp openssl pax_kernel pci pcre pcre16 pcre32 perl pic png posix \
    ptpax python python2 python3 recursion-limit right_timezone sha512 \
    sharedmem sockets sse sse2 ssh ssl threads tiff tools truetype \
    tty-helpers udev unicode urandom usb utils xattr xml xsl xtpax zlib"
PYTHON_TARGETS="python2_7 python3_3 python3_4"
PYTHON_SINGLE_TARGET="python2_7"
CURL_SSL="openssl"
EOF
```

Lege den Portage-Tree an, damit du Pakete installieren kannst:

```bash
emerge-webrsync
```

## Locales setzen

Stelle die gewünschten Sprachen ein und generiere die passenden Locale-Dateien:

```bash
cat > /etc/env.d/02locale << "EOF"
LC_ALL="en_US.UTF-8"
LANG="en_US.UTF-8"
EOF

cat >> /etc/locale.gen << "EOF"
en_US ISO-8859-1
en_US.UTF-8 UTF-8
de_DE ISO-8859-1
de_DE@euro ISO-8859-15
de_DE.UTF-8 UTF-8
EOF

locale-gen -c /etc/locale.gen

env-update
source /etc/profile
```

## Basissystem kompilieren

Jetzt werden alle wichtigen Systempakete neu gebaut. Das ist nötig, um ein stabiles und aktuelles System zu erhalten:

```bash
emerge portage portage-utils

emerge -C cracklib pam pambase virtual/pam tcp-wrappers
emerge @preserved-rebuild

emerge glibc

emerge binutils gcc

env-update
source /etc/profile

emerge hardened-sources

emerge -e -D @world

dispatch-conf
```

## Basissystem rekompilieren

Verlasse kurz die Chroot-Umgebung und betrete sie erneut, um sicherzugehen, dass keine alten Bibliotheken mehr verwendet werden. Kompiliere dann das System erneut:

```bash
exit

chroot /mnt/gentoo /bin/env -i HOME=/root TERM=$TERM PS1='\u:\w\$ ' PATH=/sbin:/bin:/usr/sbin:/usr/bin /bin/bash +h

env-update
source /etc/profile

emerge -e -D @world

emerge --depclean

dispatch-conf

env-update
source /etc/profile
```

## fstab erstellen

Lege die fstab an, damit das System beim Booten die Partitionen korrekt einhängt:

```bash
cat > /etc/fstab << "EOF"
/dev/disk/by-id/md-name-root   /          ext3    defaults,relatime,barrier=1    1 1
/dev/disk/by-id/md-name-boot   /boot      ext2    defaults,relatime              1 2
/dev/disk/by-id/md-name-data   /data      ext3    defaults,relatime,barrier=1    2 2
/dev/disk/by-id/md-name-swap   none       swap    sw                             0 0
EOF
```

## OpenSSL konfigurieren

Passe die OpenSSL-Konfiguration an und erzeuge starke DH- und EC-Parameter für sichere Verschlüsselung:

```bash
openssl genpkey -genparam -algorithm DH -pkeyopt dh_paramgen_prime_len:4096 -out /etc/ssl/dh_params.pem
openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out /etc/ssl/ec_params.pem
```

## OpenSSH konfigurieren

Jetzt konfigurierst du den SSH-Dienst sicher. Nur PublicKey-Login ist erlaubt, Passwörter sind deaktiviert. Das schützt vor Brute-Force-Angriffen. Kontrolliere die Einstellungen und passe sie ggf. an deine Umgebung an.

```bash
sed -e 's/^#\(Protocol\).*$/\1 2/' \
    -e 's/^#\(RekeyLimit\).*$/\1 500M 1h/' \
    -e 's/^#\(LoginGraceTime\).*$/\1 1m/' \
    -e 's/^#\(PermitRootLogin\).*$/\1 yes/' \
    -e 's/^#\(StrictModes\).*$/\1 yes/' \
    -e 's/^#\(MaxAuthTries\).*$/\1 3/' \
    -e 's/^#\(MaxSessions\).*$/\1 10/' \
    -e 's/^#\(RSAAuthentication\).*$/\1 no/' \
    -e 's/^#\(PubkeyAuthentication\).*$/\1 yes/' \
    -e 's/^#\(IgnoreRhosts\).*$/\1 yes/' \
    -e 's/^#\(PasswordAuthentication\).*$/\1 no/' \
    -e 's/^#\(PermitEmptyPasswords\).*$/\1 no/' \
    -e 's/^#\(ChallengeResponseAuthentication\).*$/\1 no/' \
    -e 's/^#\(UsePAM\).*$/\1 no/' \
    -e 's/^#\(AllowAgentForwarding\).*$/\1 no/' \
    -e 's/^#\(AllowTcpForwarding\).*$/\1 no/' \
    -e 's/^#\(GatewayPorts\).*$/\1 no/' \
    -e 's/^#\(X11Forwarding\).*$/\1 no/' \
    -e 's/^#\(PermitTTY\).*$/\1 yes/' \
    -e 's/^#\(UseLogin\).*$/\1 no/' \
    -e 's/^#\(UsePrivilegeSeparation\).*$/\1 sandbox/' \
    -e 's/^#\(PermitUserEnvironment\).*$/\1 no/' \
    -e 's/^#\(UseDNS\).*$/\1 yes/' \
    -e 's/^#\(MaxStartups\).*$/\1 10:30:100/' \
    -e 's/^#\(PermitTunnel\).*$/\1 no/' \
    -e 's/^#\(ChrootDirectory\).*$/\1 %h/' \
    -e 's/^\(Subsystem\).*$/\1 sftp internal-sftp -u 0027/' \
    -i /etc/ssh/sshd_config

cat >> /etc/ssh/sshd_config << "EOF"
AllowGroups wheel admin sftponly users

Match Group wheel
        ChrootDirectory none

Match Group admin
        PasswordAuthentication yes

Match Group sftponly
        ForceCommand internal-sftp
EOF

sed -e '/^# Ciphers and keying/ a\
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-cbc,aes256-ctr\
Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256\
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1' -i /etc/ssh/sshd_config

cat >> /etc/ssh/ssh_config << "EOF"
Host *
        Protocol 2
        RekeyLimit 500M 1h
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes256-cbc
        Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
        KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1
        HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
        VisualHostKey yes
EOF

rc-update add sshd default
```

## Systemprogramme installieren

Installiere Logging, Cron, Netzwerktools und RAID-Tools. Diese Dienste sind für den stabilen Betrieb eines Servers unerlässlich:

```bash
cat >> /etc/portage/package.use << "EOF"
sys-fs/lvm2  lvm1 lvm2create_initrd
EOF

emerge syslog-ng logrotate cronie iproute2 dhcpcd mdadm lvm2 mcelog

rc-update add mdraid boot
rc-update add cronie default
rc-update add syslog-ng default

cat >> /etc/mdadm.conf << "EOF"
MAILADDR root@localhost
MAILFROM root@localhost
CREATE metadata=1.2
HOMEHOST <none>
DEVICE /dev/sd*[0-9]
EOF
```

## Netzwerk konfigurieren

Trage IP-Adresse, Netmask und Gateway ein und sorge für die lokale Namensauflösung. Passe die Werte an deine Umgebung an.

```bash
sed -e 's/^\(hostname=\).*$/\1"devnull"/' -i /etc/conf.d/hostname

cat >> /etc/conf.d/net << "EOF"
#
# Setup eth0
config_eth0="__IPADDR4__ netmask NETMASK4"
routes_eth0="default via GATEWAY4"
EOF

ln -s net.lo /etc/init.d/net.eth0

rc-update add net.eth0 boot
```

Es folgt ein wenig Voodoo, um die Netzwerkkonfiguration in der `/etc/conf.d/network` zu vervollständigen.

```bash
# IPv4
ifconfig `ip -f inet route show scope global | awk '/default/ {print $5}'` | \
    awk '/inet/ {print $2}' | xargs -I % sed -e 's/__IPADDR4__/%/g' -i /etc/conf.d/net
ifconfig `ip -f inet route show scope global | awk '/default/ {print $5}'` | \
    awk '/inet/ {print $4}' | xargs -I % sed -e 's/NETMASK4/%/g' -i /etc/conf.d/net
ip -f inet route show scope global | awk '/default/ {print $3}' | \
    xargs -I % sed -e 's/GATEWAY4/%/g' -i /etc/conf.d/net
```

Wir richten die `/etc/hosts` ein.

```bash
# localhost
sed -e 's/my.domain/example.com/g' -i /etc/hosts

# IPv4
echo '__IPADDR4__   devnull.example.com' >> /etc/hosts

ifconfig `ip -f inet route show scope global | awk '/default/ {print $5}'` | \
    awk '/inet/ {print $2}' | xargs -I % sed -e 's/__IPADDR4__/%/g' -i /etc/hosts
```

## Kernelsourcen installieren und konfigurieren

Installiere die Kernelquellen und das Tool genkernel. Passe die Kernelkonfiguration an deine Hardware an. Die bereitgestellte Konfiguration ist eine gute Basis.

```bash
cat >> /etc/portage/package.keywords << "EOF"
sys-kernel/genkernel  ~amd64
EOF

cat >> /etc/portage/package.use << "EOF"
sys-kernel/genkernel  -crypt
EOF

emerge hardened-sources genkernel

sed -e 's/^#\(SYMLINK=\).*$/\1"no"/' \
    -e 's/^#\(CLEAR_CACHE_DIR=\).*$/\1"yes"/' \
    -e 's/^#\(POSTCLEAR=\).*$/\1"yes"/' \
    -e 's/^#\(LVM=\).*$/\1"no"/' \
    -e 's/^#\(LUKS=\).*$/\1"no"/' \
    -e 's/^#\(GPG=\).*$/\1"no"/' \
    -e 's/^#\(DMRAID=\).*$/\1"no"/' \
    -e 's/^#\(BUSYBOX=\).*$/\1"yes"/' \
    -e 's/^#\(MDADM=\).*$/\1"yes"/' \
    -e 's/^#\(MULTIPATH=\).*$/\1"no"/' \
    -e 's/^#\(ISCSI=\).*$/\1"no"/' \
    -e 's/^#\(E2FSPROGS=\).*$/\1"yes"/' \
    -e 's/^#\(UNIONFS=\).*$/\1"no"/' \
    -e 's/^#\(ZFS=\).*$/\1"no"/' \
    -e 's/^#\(FIRMWARE=\).*$/\1"no"/' \
    -e 's/^#\(BUILD_STATIC=\).*$/\1"yes"/' \
    -i /etc/genkernel.conf
```

## Kernelsourcen kompilieren

Die Kernelkonfiguration, insbesondere die Hardware-Optionen, muss Abseits der virtuellen Maschine an das eigene System angepasst werden. Dies ermöglicht uns die Angabe der Option `--menuconfig` beim genkernel-Aufruf. Für die Verwendung des Kernels in der virtuelle Maschine ist allerdings kein weiteres Anpassen der Kernelkonfiguration notwendig.

```bash
make
make firmware_install
make modules_install
make install
cp /usr/src/linux/.config /root/kernels/MYKERNEL
cd /root

genkernel --kernel-config=/root/kernels/MYKERNEL --no-ramdisk-modules --mdadm --install initramfs
```

## Bootloader installieren und konfigurieren

Installiere und konfiguriere GRUB als Bootloader. Passe die Einstellungen für dein System an.

```bash
cat >> /etc/portage/make.conf << "EOF"
GRUB_PLATFORMS="emu efi-32 efi-64 pc"
EOF

cat >> /etc/portage/package.use << "EOF"
sys-boot/grub  -truetype efiemu mount
EOF

emerge grub

mount -o remount,rw /boot

chmod -x /etc/grub.d/{20_linux_xen,30_os-prober,40_custom,41_custom}

sed -e 's/^#\(GRUB_CMDLINE_LINUX=\).*$/\1"pax_softmode=1 domdadm"/' \
    -e 's/^#\(GRUB_CMDLINE_LINUX_DEFAULT=\).*$/\1"quiet"/' \
    -e 's/^#\(GRUB_TERMINAL=\).*$/\1console/' \
    -i /etc/default/grub

grub-install --grub-setup=/bin/true /dev/sdb
grub-install --grub-setup=/bin/true /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg
```

## Systemtools installieren und konfigurieren

Installiere Tools wie GnuPG, Bind-Tools, NTP und Smartmontools. Die Zeit- und SMART-Überwachung sorgt für einen sicheren und stabilen Betrieb.

```bash
cat >> /etc/portage/package.use << "EOF"
app-crypt/gnupg  -usb
net-dns/bind-tools  -xml
sys-apps/smartmontools  minimal
EOF

emerge gradm app-crypt/gnupg bind-tools ntp smartmontools

cat > /etc/cron.hourly/ntpdate << "EOF"
#!/bin/sh
/usr/sbin/ntpdate -4 -b -s ptbtime2.ptb.de
EOF

chmod 0755 /etc/cron.hourly/ntpdate

echo '/dev/sda -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /etc/smartd.conf
echo '/dev/sdb -a -o on -S on -s (S/../.././02|L/../../6/03)' >> /etc/smartd.conf
```

## sysctl.conf einrichten

Aktiviere empfohlene Kernelparameter für mehr Netzwerksicherheit:

```bash
sed -e 's/^#net.ipv4/net.ipv4/g' -i /etc/sysctl.conf
```

## Root-Passwort setzen

Vergib ein starkes Passwort für root. Nutze Groß- und Kleinbuchstaben, Zahlen und Sonderzeichen:

```bash
passwd root
```

## Arbeitsuser anlegen

Lege einen Arbeitsuser für die tägliche Administration an. Das Passwort sollte sich vom root-Passwort unterscheiden:

```bash
groupadd -g 1000 admin
useradd -u 1000 -g admin -G users,wheel -c 'Administrator' -m -s /bin/bash admin

passwd admin
```

## SSH-Keys installieren

Erzeuge SSH-Schlüssel für den Arbeitsuser und kopiere sie in die authorized_keys. So kannst du dich sicher per SSH anmelden:

```bash
su - admin

ssh-keygen -t ed25519 -O clear -O permit-pty
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
ssh-keygen -t ecdsa -b 384 -O clear -O permit-pty
cat .ssh/id_ecdsa.pub >> .ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -O clear -O permit-pty
cat .ssh/id_rsa.pub >> .ssh/authorized_keys

exit
```

Kopiere den SSH-Key auf dein Windows-System und wandle ihn ggf. für PuTTY um:

```powershell
pscp -P 2222 -r root@127.0.0.1:/mnt/gentoo/home/admin/.ssh "${Env:USERPROFILE}\VirtualBox VMs\Gentoo\ssh"

puttygen "${Env:USERPROFILE}\VirtualBox VMs\Gentoo\ssh\id_rsa"
```

## Reboot ins neue System

Hänge alle Partitionen aus und starte das System neu. Entferne das Installationsmedium:

```bash
umount /boot

exit

umount /mnt/gentoo/dev/shm
umount /mnt/gentoo/dev/pts
umount /mnt/gentoo/dev
umount /mnt/gentoo/sys
umount /mnt/gentoo/proc
umount /mnt/gentoo

shutdown -P now
```

Starte die VM ohne Installationsmedium und melde dich mit deinem Arbeitsuser an:

```powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "Gentoo" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "Gentoo"

putty -ssh -P 2222 admin@127.0.0.1
```

Führe abschließende Updates und Konfigurationsanpassungen durch:

```bash
su - root

gradm -P

emerge -e -D @world

dispatch-conf
```

## Wie geht es weiter?

Jetzt kannst du mit der [Certificate Authority](/howtos/gentoo/certificate_authority/) weitermachen.

Viel Erfolg mit deinem neuen Gentoo Basissystem!
