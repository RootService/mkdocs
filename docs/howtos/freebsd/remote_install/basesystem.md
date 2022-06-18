---
title: 'BaseSystem'
description: 'In diesem HowTo wird step-by-step die Remote Installation des FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-04-28'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
    - 'Eckhard Doll'
    - 'Olaf Uecker'
tags:
    - FreeBSD
    - BaseSystem
---

# BaseSystem

## Einleitung

In diesem HowTo beschreibe ich step-by-step die Remote Installation des [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit BaseSystem mittels [mfsBSD](https://mfsbsd.vx.sk/){: target="_blank" rel="noopener"} auf einem dedizierten Server. Um eine weitere Republikation der offiziellen [FreeBSD Dokumentation](https://www.freebsd.org/doc/handbook/){: target="_blank" rel="noopener"} zu vermeiden, werde ich in diesem HowTo nicht alle Punkte bis ins Detail erläutern.

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/remote_install/)

Unser BaseSystem wird folgende Dienste umfassen.

- FreeBSD 12.2-RELEASE 64Bit
- OpenSSL 1.1.1
- OpenSSH 7.8
- Unbound 1.8.1

## RescueSystem booten

Um unser [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) installieren zu können, müssen wir unsere virtuelle Maschine mit einem RescueSystem booten. Hierfür eignet sich die auf [Gentoo Linux](https://www.gentoo.org/){: target="_blank" rel="noopener"} basierende [SystemRescueCD](https://www.system-rescue.org/){: target="_blank" rel="noopener"} am Besten, welche wir mittels des mit Windows mitgelieferten cURL-Client herunterladen und unserer virtuellen Maschine als Bootmedium zuweisen.

???+ hint

    Die Versionen nach 5.3.2 der SystemRescueCD basieren auf [Arch Linux](https://archlinux.org/){: target="_blank" rel="noopener"} und werden in diesem HowTo noch nicht supportet.

``` powershell
cd "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD"

curl.exe -o systemrescuecd-x86-5.3.2.iso https://netcologne.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.3.2/systemrescuecd-x86-5.3.2.iso
# curl -o systemrescue-7.01-amd64.iso https://ftp.halifax.rwth-aachen.de/osdn/storage/g/s/sy/systemrescuecd/releases/7.01/systemrescue-7.01-i686.iso

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium "systemrescuecd-x86-5.3.2.iso"
# & "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium "systemrescue-7.01-amd64.iso"
```

Wir können das RescueSystem jetzt booten.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" startvm "FreeBSD"
```

Im Bootmenü wählen wir die erste Option "boot with default options" aus.

Wer mit dem amerikanischen Tastaturlayout nicht zurechtkommt, sollte nach dem Booten die Keymap auf `de` umstellen.

Ist der Bootvorgang abgeschlossen, wird als Erstes das root-Passwort für das RescueSystem gesetzt und der SSH-Server gestartet.

``` bash
passwd root

/etc/init.d/sshd start
```

Jetzt sollten wir uns mittels PuTTY als `root` in das RescueSystem einloggen und mit der Installation unseres mfsBSD Image fortfahren können.

``` powershell
putty -ssh -P 2222 root@127.0.0.1
```

## mfsBSD installieren

Um unsere umfangreichen Vorbereitungen nun abzuschliessen, müssen wir nur noch unser [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) installieren und booten.

Als Erstes kopieren wir mittels PuTTYs SCP-Client (`pscp`) das mfsBSD Image in das RescueSystem.

``` powershell
pscp -P 2222 "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD\mfsbsd-12.2-RELEASE-amd64.img" root@127.0.0.1:/tmp/mfsbsd-12.2-RELEASE-amd64.img
```

Jetzt können wir das mfsBSD Image mittels `dd` auf der ersten Festplatte (`/dev/sda`) unserer virtuellen Maschine installieren und uns anschliessend wieder aus dem RescueSystem ausloggen.

``` bash
dd if=/dev/zero of=/dev/sda count=256 bs=1M

dd if=/tmp/mfsbsd-12.2-RELEASE-amd64.img of=/dev/sda bs=1M

exit
```

Abschliessend stoppen wir die virtuelle Maschine vorübergehend und entfernen die SystemRescueCD aus dem virtuellen DVD-Laufwerk.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" controlvm "FreeBSD" poweroff

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

## FreeBSD installieren

Nachdem nun alle Vorbereitungen abgeschlossen sind, können wir endlich mit der eigentlichen FreeBSD Remote Installation beginnen, indem wir die virtuelle Maschine wieder booten.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" startvm "FreeBSD"
```

Jetzt sollten wir uns mittels PuTTY als `root` mit dem Passwort `mfsroot` in das mfsBSD Image einloggen und mit der Installation von FreeBSD beginnen können.

``` powershell
putty -ssh -P 2222 root@127.0.0.1
```

## Partitionieren der Festplatte

Bevor wir anfangen, bereinigen wir die Festplatten von jeglichen Datenrückständen, indem wir sie mit Nullen überschreiben. Je nach Festplattengrösse kann dies einige Stunden bis Tage in Anspruch nehmen. Aus diesem Grund verlegen wir diese Jobs mittels `nohup` in den Hintergrund, so dass wir uns zwischenzeitlich ausloggen können ohne dass dabei die Jobs automatisch von der Shell abgebrochen werden. Ob die Jobs fertig sind, lässt dann mittels `ps -auxfwww` und `top -atCP` ermitteln.

``` bash
nohup dd if=/dev/zero of=/dev/ada0 bs=1M  &
nohup dd if=/dev/zero of=/dev/ada1 bs=1M  &
```

Da jeder Administrator andere Präferenzen an sein Partitionslayout stellt und wir andernfalls mit diesem HowTo nicht weiterkommen, verwenden wir im Folgenden ein Standard-Partitionslayout. Fortgeschrittenere FreeBSD-Administratoren können dieses Partitionslayout selbstverständlich an ihre eigenen Bedürfnisse anpassen.

| Partition | Mountpunkt | Filesystem | Grösse |
| :-------: | :--------- | :--------: | -----: |
| /dev/mirror/root | /     | UFS2 | 32 GB |
| /dev/mirror/data | /data | UFS2 | 24 GB |
| /dev/mirror/swap | none  | SWAP |  4 GB |

Als Erstes müssen wir die Festplatte partitionieren, was wir mittels `gpart` erledigen werden. Zuvor müssen wir dies aber dem Kernel mittels `sysctl` mitteilen, da er uns andernfalls dazwischenfunken würde.

Wir werden auf beiden Festplatten jeweils vier Partitionen anlegen, die Erste für den Bootcode, die Zweite als Systempartition, die Dritte für unsere Nutzdaten und die Vierte als SWAP. Dabei werden wir die Partitionen auch gleich für modernere Festplatten mit 4K-Sektoren optimieren und statt den veralteten "MBR Partition Tables" die aktuelleren "GUID Partition Tables (GPT)" verwenden.

``` bash
sysctl kern.geom.debugflags=0x10

gpart destroy -F ada0
gpart destroy -F ada1

gpart create -s gpt ada0
gpart create -s gpt ada1

gpart add -t freebsd-boot -b 4096 -s 512 -a 4096 ada0
gpart add -t freebsd-ufs  -b 8192 -s 32G -a 4096 ada0
gpart add -t freebsd-ufs          -s 24G -a 4096 ada0
gpart add -t freebsd-swap         -s  4G -a 4096 ada0

gpart add -t freebsd-boot -b 4096 -s 512 -a 4096 ada1
gpart add -t freebsd-ufs  -b 8192 -s 32G -a 4096 ada1
gpart add -t freebsd-ufs          -s 24G -a 4096 ada1
gpart add -t freebsd-swap         -s  4G -a 4096 ada1
```

Für eine leicht erhöhte Datensicherheit legen wir mittels `gmirror` ein Software-RAID1 an.

``` bash
kldload geom_mirror

gmirror label -b load root ada0p2 ada1p2
gmirror label -b load data ada0p3 ada1p3
gmirror label -b prefer -F swap ada0p4 ada1p4
```

## Formatieren der Partitionen

Nun müssen wir noch die Systempartition und die Partition für die Nutzdaten mit "UFS2" und einer 4K-Blockgrösse formatieren und aktivieren auch gleich die "soft-updates".

``` bash
newfs -O2 -U -f 4096 /dev/mirror/root
newfs -O2 -U -f 4096 /dev/mirror/data

tunefs -n enable /dev/mirror/root
tunefs -n enable /dev/mirror/data

tunefs -a enable /dev/mirror/root
tunefs -a enable /dev/mirror/data

tunefs -l enable /dev/mirror/root
tunefs -l enable /dev/mirror/data
```

## Mounten der Partitionen

Die Partitionen mounten wir unterhalb von `/mnt`.

``` bash
mount -t ufs /dev/mirror/root /mnt
mkdir -p /mnt/data
mount -t ufs /dev/mirror/data /mnt/data
```

## Installation der Chroot-Umgebung

Auf die gemounteten Partitionen entpacken wir ein FreeBSD Basesystem mit dem wir problemlos weiterarbeiten können. Je nach Auslastung des FreeBSD FTP-Servers kann dies ein wenig dauern, bitte nicht ungeduldig werden.

``` bash
fetch -4 -q -o - --no-verify-peer https://download.freebsd.org/ftp/releases/amd64/amd64/12.2-RELEASE/base.txz   | tar Jxpvf - -C /mnt/
fetch -4 -q -o - --no-verify-peer https://download.freebsd.org/ftp/releases/amd64/amd64/12.2-RELEASE/kernel.txz | tar Jxpvf - -C /mnt/

cp -a /mnt/boot/kernel /mnt/boot/GENERIC
```

Unser System soll natürlich auch von den Festplatten booten können, weshalb wir jetzt den Bootcode und Bootloader in den Bootpartitionen installieren.

``` bash
gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptboot -i 1 ada0
gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptboot -i 1 ada1

gpart set -a bootme -i 2 ada0
gpart set -a bootme -i 2 ada1
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

cd /root
```

## Zeitzone einrichten

Zunächst setzen wir die Systemzeit (CMOS clock) mittels `tzsetup` auf die "Region" Europe, das "Country" auf Germany und "CET" beziehungsweise "CEST" trifft ebenfalls zu.

``` bash
/usr/sbin/tzsetup
```

Cronjob zur regelmässigen Syncronisation mit einem Zeitserver einrichten.

``` bash
cat >> /etc/crontab << "EOF"
59      */4     *       *       *       root    /usr/sbin/sntp -S ptbtime3.ptb.de >/dev/null 2>&1
"EOF"
```

## Locale einrichten

Auf Servern sollte für Systemuser eine amerikanisch-englische Locale mit Unicode (UTF-8) verwendet werden. Wir bearbeiten hierzu mit dem Editor `ee` (`ee /etc/login.conf`) in der Datei `/etc/login.conf` die Login-Klasse `default`, indem wir vor der letzten Zeile folgende Zeilen hinzufügen.

``` text
        :charset=UTF-8:\
        :lang=en_US.UTF-8:\
```

Anschliessend muss die Datei in eine Systemdatenbank umgewandelt werden.

``` bash
cap_mkdb /etc/login.conf
```

Nach dem nächsten Login sollte der Befehl `locale` die folgende Ausgabe liefern.

``` text
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_ALL=
```

## Shell einrichten

Unter FreeBSD ist die Tenex C Shell (TCSH) die Standard-Shell. Für Bash-gewohnte Linux-User ist diese Shell etwas gewöhnungsbedürftig, und natürlich kann man sie später auch gegen eine andere Shell austauschen (im Basis-System ist neben der TCSH auch eine ASH enthalten). Skripte würde ich persönlich für die TCSH eher nicht schreiben, aber für die tägliche Administrationsarbeit ist die TCSH ein sehr brauchbares Werkzeug – wenn man sie erst mal etwas umkonfiguriert hat. Dies tun wir jetzt.

``` bash
# Colorize console output
cat >> /etc/csh.cshrc << "EOF"
setenv LSCOLORS "Dxfxcxdxbxegedabagacad"
alias ls        ls -FGIPTW
alias l         ls -FGIPTWahl
"EOF"

# Use ee instead of vi as standard editor
sed -e 's/\(EDITOR[[:space:]]*\)vi[[:space:]]*$/\1ee/' -i '' /root/.cshrc

# Use meaningfuller prompt
sed -e 's/\(set prompt =\).*$/\1 "[%B%n%b@%B%m%b:%B%~%b] %# "/' -i '' /root/.cshrc

cp /root/.cshrc /.cshrc

# Set root shell to /bin/tcsh
chsh -s /bin/tcsh root
```

## Systemsicherheit verstärken

Die hier vorgestellten Massnahmen sind äusserst simple Basics, die aus Hygienegründen auf jedem FreeBSD System selbstverständlich sein sollten. Um ein FreeBSD System richtig zu härten (Hardened), kommt man jedoch nicht an komplexeren Methoden wie Security Event Auditing und Mandatory Access Control vorbei. Diese Themen werden im FreeBSD Handbuch recht ausführlich besprochen; für den Einstieg empfehle ich hier die Lektüre von [Chapter 13. Security](https://www.freebsd.org/doc/handbook/security.html){: target="_blank" rel="noopener"}, für die weiterführenden Themen die [Chapter 15. Mandatory Access Control](https://www.freebsd.org/doc/handbook/mac.html){: target="_blank" rel="noopener"} und [Chapter 16. Security Event Auditing](https://www.freebsd.org/doc/handbook/audit.html){: target="_blank" rel="noopener"}.

### OpenSSH konfigurieren

Da wir gerade ein Produktiv-System aufsetzen, werden wir den SSH-Dienst recht restriktiv konfigurieren, unter Anderem werden wir den Login per Passwort verbieten und nur per PublicKey zulassen.

``` bash
sed -e 's|^#\(PermitRootLogin\).*$|\1 yes|' \
    -e 's|^#\(PubkeyAuthentication\).*$|\1 yes|' \
    -e 's|^#\(PasswordAuthentication\).*$|\1 yes|' \
    -e 's|^#\(PermitEmptyPasswords\).*$|\1 no|' \
    -e 's|^#\(ChallengeResponseAuthentication\).*$|\1 no|' \
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

cat >> /etc/ssh/sshd_config << "EOF"

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

"EOF"

sed -e '/^# Ciphers and keying/ a\\
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr\\
Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com\\
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256' -i '' /etc/ssh/sshd_config

ssh-keygen -q -t rsa -b 4096 -f "/etc/ssh/ssh_host_rsa_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_rsa_key.pub"
ssh-keygen -q -t ecdsa -b 384 -f "/etc/ssh/ssh_host_ecdsa_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_ecdsa_key.pub"
ssh-keygen -q -t ed25519 -f "/etc/ssh/ssh_host_ed25519_key" -N ""
ssh-keygen -l -f "/etc/ssh/ssh_host_ed25519_key.pub"

mkdir -p /root/.ssh
chmod 0700 /root/.ssh

ssh-keygen -t ed25519 -O clear -O permit-pty -f ".ssh/id_ed25519" -N ""
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys

ssh-keygen -t ecdsa -b 384 -O clear -O permit-pty -f ".ssh/id_ecdsa" -N ""
cat .ssh/id_ecdsa.pub >> .ssh/authorized_keys

ssh-keygen -t rsa -b 4096 -O clear -O permit-pty -f ".ssh/id_rsa" -N ""
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
```

### /etc/sysctl.conf anpassen

In der `sysctl.conf` können die meisten Kernel-Parameter verändert werden. Wir wollen dies nutzen, um unser System etwas robuster und sicherer zu machen.

``` bash
cat > /etc/sysctl.conf << "EOF"
kern.ipc.maxsockbuf=16777216
kern.ipc.soacceptqueue=1024
kern.ipc.somaxconn=2048
kern.maxfiles=65536
kern.maxprocperuid=65535
kern.ps_arg_cache_limit=4096
kern.randompid=1369
kern.sched.slice=1
kern.threads.max_threads_per_proc=4096
net.inet.icmp.drop_redirect=1
net.inet.ip.check_interface=1
net.inet.ip.forwarding=1
net.inet.ip.intr_queue_maxlen=4096
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
net.inet.tcp.cc.algorithm=htcp
net.inet.tcp.cc.htcp.adaptive_backoff=1
net.inet.tcp.cc.htcp.rtt_scaling=1
net.inet.tcp.delacktime=50
#net.inet.tcp.delayed_ack=0
net.inet.tcp.drop_synfin=1
net.inet.tcp.ecn.enable=0
net.inet.tcp.fast_finwait2_recycle=1
net.inet.tcp.finwait2_timeout=5000
net.inet.tcp.icmp_may_rst=0
net.inet.tcp.initcwnd_segments=44
net.inet.tcp.isn_reseed_interval=10800
net.inet.tcp.keepcnt=3
net.inet.tcp.keepidle=10000
net.inet.tcp.keepintvl=5000
net.inet.tcp.minmss=536
net.inet.tcp.msl=2500
net.inet.tcp.mssdflt=1460
net.inet.tcp.nolocaltimewait=1
net.inet.tcp.path_mtu_discovery=0
net.inet.tcp.recvbuf_inc=65536
net.inet.tcp.recvbuf_max=16777216
net.inet.tcp.recvspace=131072
net.inet.tcp.rfc6675_pipe=1
net.inet.tcp.sendbuf_inc=65536
net.inet.tcp.sendbuf_max=16777216
net.inet.tcp.sendspace=131072
net.inet.tcp.syncache.rexmtlimit=0
net.inet.tcp.syncookies_only=1
net.inet.tcp.tso=0
net.inet.udp.blackhole=1
net.inet.udp.recvspace=4194304
net.inet6.icmp6.nodeinfo=0
net.inet6.icmp6.rediraccept=0
net.inet6.ip6.forwarding=1
net.inet6.ip6.redirect=0
net.inet6.ip6.stealth=1
net.local.stream.recvspace=524288
net.local.stream.sendspace=524288
net.route.netisr_maxqlen=4096
security.bsd.see_other_gids=0
security.bsd.see_other_uids=0
security.bsd.unprivileged_proc_debug=0
security.bsd.unprivileged_read_msgbuf=0
security.bsd.hardlink_check_gid=1
security.bsd.hardlink_check_uid=1
vfs.read_max=128
vfs.ufs.dirhash_maxmem=67108864
vfs.zfs.min_auto_ashift=12
"EOF"
```

### Stärkere Passwort-Hashes verwenden

Um Bruteforce-Attacken erheblich auszubremsen setzen wir für die Passworte der Systemuser eine Mindestlänge (minpasswordlen) von 12 Zeichen in einem Mix aus Gross- und Kleinschreibung (mixpasswordcase) fest. Desweiteren lassen wir User nach 30 Minuten Inaktivität automatisch ausloggen (idletime). Wir bearbeiten hierzu mit dem Editor `ee` (`ee /etc/login.conf`) in der Datei `/etc/login.conf` die Login-Klasse `default`, indem wir vor der letzten Zeile folgende Zeilen hinzufügen.

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

## System konfigurieren

Mail alias für `root` einrichten.

``` bash
sed -e 's/^#[[:space:]]*\(root:[[:space:]]*\).*$/\1 admin@example.com/' \
    -e 's/^#[[:space:]]*\(hostmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(webmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(www:[[:space:]]*.*\)$/\1/' \
    -i '' /etc/mail/aliases
```

Die aliases Datenbank für FreeBSDs Sendmail müssen wir mittels `make` anlegen, auch wenn wir später Sendmail gar nicht verwenden möchten.

``` bash
cd /etc/mail
make aliases
cd /etc
ln -s mail/aliases.db
cd /root
```

``` bash
cat >> /etc/nscd.conf << "EOF"
keep-hot-count hosts 16384
"EOF"
```

``` bash
cat > /etc/resolvconf.conf << "EOF"
resolvconf=NO
"EOF"
```

Die `/etc/periodic.conf` legen wir mit folgendem Inhalt an.

``` bash
cat > /etc/periodic.conf << "EOF"
daily_clean_hoststat_enable="NO"
daily_clean_tmps_enable="YES"
daily_status_gmirror_enable="YES"
daily_status_include_submit_mailq="NO"
daily_status_mail_rejects_enable="NO"
daily_status_ntpd_enable="YES"
daily_submit_queuerun="NO"
weekly_noid_enable="YES"
"EOF"
```

Die `/etc/fstab` legen wir entsprechend unserem Partitionslayout an.

``` bash
cat > /etc/fstab << "EOF"
# Device                   Mountpoint              FStype  Options             Dump    Pass
/dev/mirror/root           /                       ufs     rw                  1       1
dev                        /dev                    devfs   rw                  0       0
#fdesc                      /dev/fd                 fdescfs rw,late             0       0
proc                       /proc                   procfs  rw                  0       0
/dev/mirror/swap           none                    swap    sw                  0       0
/dev/mirror/data           /data                   ufs     rw                  2       2
"EOF"
```

In der `/etc/rc.conf` werden diverse Grundeinstellungen für das System und die installierten Dienste vorgenommen.

``` bash
cat > /etc/rc.conf << "EOF"
##############################################################
###  Important initial Boot-time options  ####################
##############################################################
#kern_securelevel_enable="YES"
#kern_securelevel="1"
fsck_y_enable="YES"
dumpdev="AUTO"

##############################################################
###  Network configuration sub-section  ######################
##############################################################
hostname="devnull.example.com"

##### IPv4
### uncomment next 2 lines if you need the simple config
defaultrouter="GATEWAY4"
ifconfig_IFACE="inet IPADDR4 netmask NETMASK4"
### the next 4 options may be needed on some isp-networks
### uncomment next 4 lines if you need the complex config
#route_gateway4="-host -inet GATEWAY4 -interface IFACE"
#route_default4="default GATEWAY4"
#static_routes="gateway4 default4"
#ifconfig_IFACE="inet IPADDR4 netmask NETMASK4"

##### IPv6
### uncomment next 2 lines if you need the simple config
#ipv6_defaultrouter="GATEWAY6"
#ifconfig_IFACE_ipv6="inet6 IPADDR6 prefixlen PREFLEN6"
### the next 4 options may be needed on some isp-networks
### uncomment next 4 lines if you need the complex config
#ipv6_route_gateway6="-host -inet6 GATEWAY6 -interface IFACE"
#ipv6_route_default6="default GATEWAY6"
#ipv6_static_routes="gateway6 default6"
#ifconfig_IFACE_ipv6="inet6 IPADDR6 prefixlen PREFLEN6"

##### Additional IP Addresses
### specify additional IPv4 and IPv6 addresses one per line
#ifconfig_IFACE_aliases="\
#        inet IPV4 netmask NETMASK \
#        inet IPV4 netmask NETMASK \
#        inet6 IPV6 prefixlen PREFLEN \
#        inet6 IPV6 prefixlen PREFLEN"

##############################################################
###  System console options  #################################
##############################################################
keymap="de.kbd"
font8x16="vgarom-8x16.fnt"
font8x14="vgarom-8x14.fnt"
font8x8="vgarom-8x8.fnt"

##############################################################
###  Mail Transfer Agent (MTA) options  ######################
##############################################################
sendmail_enable="NO"
sendmail_cert_create="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

##############################################################
###  Miscellaneous administrative options  ###################
##############################################################
syslogd_flags="-ss"
clear_tmp_enable="YES"
cron_flags="$cron_flags -j 0 -J 0 -m root"
nscd_enable="YES"
ntpd_enable="YES"
ntpd_sync_on_start="YES"
ntp_leapfile_fetch_verbose="YES"
resolv_enable="NO"

##############################################################
### Jail Configuration #######################################
##############################################################

##############################################################
###  System services options  ################################
##############################################################
local_unbound_enable="YES"
sshd_enable="YES"
"EOF"
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
pw useradd -n admin -u 1000 -g admin -G wheel -c 'Administrator' -m -s /bin/tcsh

passwd admin
```

Wir richten unserem `admin` noch die Shell und die zum zukünftigen Einloggen zwingend nötigten SSH-Keys ein.

``` bash
su - admin

sed -e 's/\(EDITOR[[:space:]]*\)vi[[:space:]]*$/\1ee/' -i '' ~/.cshrc
sed -e 's/\(set prompt =\).*$/\1 "[%B%n%b@%B%m%b:%B%~%b] %# "/' -i '' ~/.cshrc

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
pw useradd -n joeuser -u 2000 -g users -G sshusers -c 'Joe User' -m -s /bin/tcsh

passwd joeuser
```

Wir richten unserem `joeuser` noch die Shell und die zum zukünftigen Einloggen zwingend nötigten SSH-Keys ein.

``` bash
su - joeuser

sed -e 's/\(EDITOR[[:space:]]*\)vi[[:space:]]*$/\1ee/' -i '' ~/.cshrc
sed -e 's/\(set prompt =\).*$/\1 "[%B%n%b@%B%m%b:%B%~%b] %# "/' -i '' ~/.cshrc

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
cat > /etc/make.conf << "EOF"
KERNCONF?=GENERIC MYKERNEL
SVN=/usr/bin/svnlite
SVN_UPDATE=yes
#MAKE_JOBS_NUMBER=4
PRINTERDEVICE=ascii
LICENSES_ACCEPTED+=EULA
DISABLE_VULNERABILITIES=yes
.if ${.CURDIR:M/usr/ports/*}
OPTIONS_SET=CRYPTO DOCS EXAMPLES GSSAPI_NONE NLS IPV6 LIBEDIT OPENSSL THREADS
OPTIONS_UNSET=DEBUG DTRACE GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT NIS READLINE TEST TESTS X11
.endif
"EOF"
```

``` bash
cat > /etc/src.conf << "EOF"
WITHOUT_AMD=YES
WITHOUT_APM=YES
WITHOUT_ATM=YES
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
WITHOUT_CTM=YES
WITHOUT_CUSE=YES
WITHOUT_DEBUG_FILES=YES
WITHOUT_DMAGENT=YES
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
WITHOUT_KVM=YES
WITHOUT_LIB32=YES
WITHOUT_LLVM_TARGET_ALL=YES
WITH_LLVM_TARGET_X86=YES
WITHOUT_LPR=YES
WITHOUT_MANCOMPRESS=YES
WITHOUT_MODULE_DRM=YES
WITHOUT_MODULE_DRM2=YES
WITH_NAND=YES
WITHOUT_NDIS=YES
WITHOUT_NIS=YES
WITHOUT_PC_SYSINSTALL=YES
WITH_PIE=YES
WITHOUT_PMC=YES
WITHOUT_PPP=YES
WITHOUT_PROFILE=YES
WITHOUT_RADIUS_SUPPORT=YES
WITHOUT_RBOOTD=YES
WITHOUT_RCMDS=YES
WITH_RETPOLINE=YES
WITHOUT_SENDMAIL=YES
WITHOUT_SHAREDOCS=YES
WITH_SORT_THREAD=YES
WITHOUT_SYSINSTALL=YES
WITHOUT_TALK=YES
WITHOUT_TCP_WRAPPERS=YES
WITHOUT_TESTS=YES
WITHOUT_TFTP=YES
WITHOUT_TIMED=YES
WITHOUT_WIRELESS=YES
"EOF"
```

## Kernel konfigurieren

``` bash
svnlite checkout svn://svn.freebsd.org/base/releng/`/bin/freebsd-version -u | cut -d- -f1` /usr/src

mkdir -p /root/kernels

cat > /root/kernels/MYKERNEL << "EOF"
include GENERIC
ident   MYKERNEL
options ALTQ
options ALTQ_CBQ
options ALTQ_RED
options ALTQ_RIO
options ALTQ_HFSC
options ALTQ_CDNR
options ALTQ_PRIQ
options ALTQ_NOPCC
"EOF"

ln -s /root/kernels/MYKERNEL /usr/src/sys/amd64/conf/
```

Kernel Parameter in `/boot/loader.conf` setzen.

``` bash
cat > /boot/loader.conf << "EOF"
# Loader options
boot_verbose="YES"
verbose_loading="YES"

# Microcode updates
#cpu_microcode_load="YES"
#cpu_microcode_name="/boot/firmware/intel-ucode.bin"

# Kernel selection
kernel="GENERIC"
kernels="GENERIC MYKERNEL"

# Kernel modules
ahci_load="YES"
geom_mirror_load="YES"
opensolaris_load="YES"
zfs_load="YES"
accf_data_load="YES"
accf_http_load="YES"
accf_dns_load="YES"
cc_htcp_load="YES"

# Kernel parameters
debug.acpi.disabled="thermal"
security.bsd.stack_guard_page=1
security.bsd.allow_destructive_dtrace=0
kern.geom.label.disk_ident.enable=0
kern.geom.label.gptid.enable=0
kern.geom.label.gpt.enable=1
kern.maxproc=65536
kern.maxusers=512
kern.ipc.nmbclusters=32768
kern.ipc.semmni=256
kern.ipc.semmns=512
kern.ipc.semmnu=256
kern.ipc.shm_use_phys=1
kern.ipc.shmmax=2147483648
kern.msgbuf_show_timestamp=1
kern.random.fortuna.minpoolsize=256
kern.sync_on_panic=0
net.inet.tcp.soreceive_stream=1
net.inet.tcp.tcbhashsize=524288
net.link.ifqmaxlen=1024
"EOF"
```

## Abschluss der Installation

Um uns künftig mit unserem Arbeitsuser einloggen zu können, müssen wir uns dessen SSH-Key (id_rsa) auf unser lokales System kopieren und ihn dann mit Hilfe der [PuTTYgen Dokumentation](https://the.earth.li/~sgtatham/putty/latest/htmldoc/Chapter8.html){: target="_blank" rel="noopener"} in einen für PuTTY lesbaren Private Key umwandeln (id_rsa.ppk).

``` powershell
pscp -P 2222 -r root@127.0.0.1:/mnt/usr/home/admin/.ssh "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh"

puttygen "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa"

# Einloggen ab hier nur noch mit Key
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

Nun ist es endlich soweit: Wir verlassen das Chroot, unmounten die Partitionen und rebooten zum ersten Mal in unser neues FreeBSD Basis-System.

``` bash
exit

umount /mnt/dev
umount /mnt/data
umount /mnt

shutdown -r now
```

### Einloggen und zu *root* werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

``` bash
su - root
```

## System aktualisieren

Nach dem Reboot aktualisieren und entschlacken wir das System.

### Source Tree auschecken

Am Besten funktioniert bei FreeBSD immer noch die Aktualisierung über die System-Sourcen. Auf diesem Wege kann man ein System über viele Release-Generationen hinweg aktuell halten, ohne eine Neuinstallation durchzuführen. Das Verfahren ist zwar etwas zeitaufwändig, aber erprobt und führt bei richtiger Anwendung zu einem sauberen, aktuellen System.

Zunächst wird hierzu das aktuelle Quellenverzeichnis von FreeBSD benötigt, weshalb wir es mittels [svnlite](https://www.freebsd.org/cgi/man.cgi?query=svnlite&sektion=1){: target="_blank" rel="noopener"}, einem im Funktionsumfang reduziertem SVN-Client von FreeBSD, auschecken.

``` bash
# Neues Quellenverzeichnis anlegen (checkout)
rm -r /usr/src && svnlite checkout svn://svn.freebsd.org/base/releng/`/bin/freebsd-version -u | cut -d- -f1` /usr/src
ln -s /root/kernels/MYKERNEL /usr/src/sys/amd64/conf/

# Vorhandenes Quellenverzeichnis aktualisieren (update)
cd /usr/src && svnlite update

# Vorhandenes Quellenverzeichnis zu FreeBSD 12-STABLE wechseln (switch)
#cd /usr/src && svnlite switch svn://svn.freebsd.org/base/stable/12
```

### Konfiguration anpassen

In den Abschnitten [Buildsystem konfigurieren](#buildsystem-konfigurieren) und [Kernel konfigurieren](#kernel-konfigurieren) haben wir uns bereits eine geeignete `make.conf` und gegebenenfalls auch eine individuelle Kernel-Konfiguration erstellt. Dennoch sei an dieser Stelle nochmals auf das FreeBSD Handbuch verwiesen. Insbesondere [Chapter 8. Configuring the FreeBSD Kernel](https://www.freebsd.org/doc/handbook/kernelconfig.html){: target="_blank" rel="noopener"} (Kernel selbst erstellen) und [23.5. Updating FreeBSD from Source](https://www.freebsd.org/doc/handbook/makeworld.html){: target="_blank" rel="noopener"} (Basissystem komplett aktualisieren) seien Jedem FreeBSD Administratoren ans Herz gelegt.

Ausserdem empfiehlt es sich vor einem Update des Basissystems die Datei `/usr/src/UPDATING` zu lesen. Alle Angaben und Hinweise in dieser Datei sind aktueller und zutreffender als das Handbuch und sollten unbedingt befolgt werden.

### Vorbereitende Arbeiten

???+ hint

    Für die spätere Installation des neu kompilierten Basissystems darf `/tmp` nicht mit der Option `noexec` gemounted sein. Da zwischendrin noch mal ein Reboot erfolgt, können wir bei Bedarf bereits jetzt die entsprechende Zeile in der `fstab` anpassen, sofern vorhanden.

Zunächst müssen eventuell vorhandene Object-Dateien im Verzeichnis `/usr/obj` gelöscht werden, damit `make` später wirklich das gesamte System neu erstellt.

``` bash
cd /usr/src

make clean

svnlite update

chflags -R noschg /usr/obj/*
rm -rf /usr/obj/*
```

Ausserdem sollte [mergemaster](https://www.freebsd.org/cgi/man.cgi?query=mergemaster&sektion=8){: target="_blank" rel="noopener"} im Pre-Build-Mode angeworfen werden, damit es während der Aktualisierung nicht zu Fehlern kommt, weil z. B. bestimmte User oder Gruppen noch nicht vorhanden sind.

``` bash
/usr/src/usr.sbin/mergemaster/mergemaster.sh -p
```

### Basissystem rekompilieren

Das Kompilieren des Basissystems kann durchaus eine Stunde oder länger dauern.

``` bash
make -j2 buildworld
```

### Kernel rekompilieren und installieren

Wenn die eigene Kernel-Konfiguration wie bei uns bereits in der `/etc/make.conf` eingetragen ist, wird sie automatisch verwendet, andernfalls wird die Konfiguration des generischen FreeBSD-Kernels verwendet. Das Kompilieren des Kernels kann durchaus eine Stunde oder länger dauern.

``` bash
make -j2 KERNCONF=GENERIC buildkernel
make KERNCONF=GENERIC INSTALLKERNEL=GENERIC INSTKERNNAME=GENERIC installkernel
sed -e 's/^#fdesc/fdesc/' -i '' /etc/fstab

make -j2 KERNCONF=MYKERNEL buildkernel
make KERNCONF=MYKERNEL INSTALLKERNEL=MYKERNEL INSTKERNNAME=MYKERNEL installkernel
sed -e 's/^\(kernel=\).*$/\1"MYKERNEL"/' -i '' /boot/loader.conf
```

Normalerweise wäre nun ein Reboot in den Single User Mode an der Reihe. Da sich ein Remote-System in diesem Modus ohne KVM-Lösung aber nicht bedienen lässt, begnügen wir uns damit, das System regulär neu zu starten.

``` bash
shutdown -r now
```

Wenn wir unser System zu einem späteren Zeitpunkt nochmals aktualisieren, sollten wir zuden zuvor alle Dienste ausser OpenSSH, sowie sämtliche Jails in der Datei `/etc/rc.conf` deaktivieren.

Einloggen und zu `root` werden

``` powershell
putty -ssh -P 2222 -i "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD\ssh\id_rsa.ppk" admin@127.0.0.1
```

``` bash
su - root
```

### Basissystem installieren

Wir installieren das neue Basissystem.

``` bash
cd /usr/src

make installworld
```

Da wir den NIS-Support entfernt haben, müssen wir die `/etc/nsswitch.conf` anpassen.

``` bash
sed -e '/[a-z]*_compat/d' \
    -e 's/compat/files/g' \
    -i '' /etc/nsswitch.conf
```

Als letzten Schritt müssen nun noch die Neuerungen in den Konfigurationsdateien gemerged werden. Dabei unterstützt uns das Tool `mergemaster`. Wir müssen selbstverständlich darauf achten, dass wir hierbei nicht versehentlich unsere zuvor gemachten Anpassungen an den diversen Konfigurationsdateien wieder rückgängig machen.

``` bash
/usr/sbin/mergemaster -iFU --run-updates=always
```

Wir entsorgen nun noch eventuell vorhandene veraltete und überflüssige Dateien.

``` bash
make delete-old -DBATCH_DELETE_OLD_FILES
make delete-old-libs -DBATCH_DELETE_OLD_FILES
```

Anschliessend müssen wir noch die für die Installation gegebenenfalls vorgenommenen Änderungen in der `fstab` sowie `rc.conf` rückgängig machen und das System nochmals durchstarten.

``` bash
shutdown -r now
```

Viel Spass mit dem neuen FreeBSD BaseSystem.
