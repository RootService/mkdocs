---
title: 'mfsBSD Image'
description: 'In diesem HowTo wird step-by-step die Erstellung eines mfsBSD Images zur Remote Installation von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-07-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
tags:
    - FreeBSD
    - mfsBSD
---

# mfsBSD Image

## Einleitung

In diesem HowTo beschreibe ich step-by-step das Erstellen eines [mfsBSD](https://mfsbsd.vx.sk/){: target="_blank" rel="noopener"} Images mit dem die [Remote Installation](/howtos/freebsd/remote_install/) von [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit auf einem dedizierten Server durchgeführt werden kann.

## Das Referenzsystem

Als Referenzsystem habe ich mich für eine virtuelle Maschine auf Basis von [Oracle VM VirtualBox](https://www.virtualbox.org/){: target="_blank" rel="noopener"} unter [Microsoft Windows 11 Professional (64 Bit)](https://support.microsoft.com/products/windows){: target="_blank" rel="noopener"} entschieden. Leider bringt Microsoft Windows keinen eigenen SSH-Client mit, so dass ich auf das sehr empfehlenswerte [PuTTY (64 Bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/){: target="_blank" rel="noopener"} zurückgreife.

VirtualBox (inklusive dem Extensionpack) und PuTTY werden mit den jeweiligen Standardoptionen installiert.

## Die Virtuelle Maschine

Als Erstes öffnen wir eine neue PowerShell und legen manuell eine neue virtuelle Maschine an. Diese virtuelle Maschine bekommt den Namen `mfsBSD` und wird mit einer UEFI-Firmware, einem Dual-Core Prozessor, Intels ICH9-Chipsatz, 4096MB RAM, 64MB VideoRAM, einer 64GB SSD-Festplatte, einem DVD-Player, einer Intel-Netzwerkkarte, einem NVMe-Controller sowie einem AHCI-Controller ausgestattet. Zudem setzen wir die RTC (Real-Time Clock) der virtuellen Maschine auf UTC (Coordinated Universal Time), aktivieren den HPET (High Precision Event Timer) und legen die Bootreihenfolge fest.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" createvm --name "mfsBSD" --ostype FreeBSD_64 --register

cd "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD"

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" createmedium disk --filename "mfsBSD1.vdi" --format VDI --size 64536

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --firmware efi --cpus 2 --cpuexecutioncap 100 --cpuhotplug off
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --chipset ICH9 --graphicscontroller vmsvga --audio none --usb off
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --hwvirtex on --ioapic on --hpet on --rtcuseutc on --memory 4096 --vram 64
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --nic1 nat --nictype1 82540EM --natnet1 "192.168/16" --cableconnected1 on
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --boot1 dvd --boot2 disk --boot3 none --boot4 none

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storagectl "mfsBSD" --name "NVMe Controller" --add pcie --controller NVMe --portcount 4 --bootable on
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storagectl "mfsBSD" --name "AHCI Controller" --add sata --controller IntelAHCI --portcount 4 --bootable on

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "mfsBSD" --storagectl "NVMe Controller" --port 0 --device 0 --type hdd --nonrotational on --medium "mfsBSD1.vdi"
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

Die virtuelle Maschine, genauer die virtuelle Netzwerkkarte, kann dank NAT zwar problemlos mit der Aussenwelt, aber leider nicht direkt mit dem Hostsystem kommunizieren. Aus diesem Grund richten wir nun für den SSH-Zugang noch ein Portforwarding ein, welches den Port 2222 des Hostsystems auf den Port 22 der virtuellen Maschine weiterleitet.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "mfsBSD" --natpf1 "VBoxSSH,tcp,,2222,,22"
```

Als nächstes wird die FreeBSD 64Bit Installations-DVD heruntergeladen und dieser virtuellen Maschine als Bootmedium zugewiesen.

``` powershell
cd "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD"

ftp -A ftp.de.freebsd.org
cd FreeBSD/releases/amd64/amd64/ISO-IMAGES/13.1
binary
get FreeBSD-13.1-RELEASE-amd64-dvd1.iso
quit

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium "FreeBSD-13.1-RELEASE-amd64-dvd1.iso"
```

Nachdem die virtuelle Maschine nun fertig konfiguriert ist, wird es Zeit diese zu booten.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" startvm "mfsBSD"
```

Im Bootmenü wird die erste Option durch Drücken der Taste "Enter" beziehungsweise "Return", oder automatisch nach 10 Sekunden gewählt.

Es würde für unsere Zwecke durchaus genügen, einfach stumpf dem Installationsprogramm BSDInstall zu folgen, aber wir werden die Installation manuell durchführen, um ein paar Optionen zu nutzen, welche mit BSDInstall derzeit nicht verfügbar sind.

Aus diesem Grund werden wir, wenn der Bootvorgang abgeschlossen ist und wir den ersten Auswahldialog präsentiert bekommmen, "Shell" auswählen und bestätigen.

???+ hint

    Diese Shell nutzt das amerikanische Tastaturlayout, welches einige Tasten anders belegt als das deutsche Tastaturlayout.

## Minimalsystem installieren

Als Erstes müssen wir die Festplatte partitionieren, was wir mittels `gpart` erledigen werden. Zuvor müssen wir dies aber dem Kernel mittels `sysctl` mitteilen, da er uns andernfalls dazwischenfunken würde.

Wir werden drei Partitionen anlegen, die Erste für den Bootcode, die Zweite als Systempartition und die Dritte als Swap. Dabei werden wir die Partitionen auch gleich für modernere Festplatten mit 4K-Sektoren optimieren und statt den veralteten "MBR Partition Tables" die aktuelleren "GUID Partition Tables (GPT)" verwenden.

``` bash
sysctl kern.geom.debugflags=0x10

gpart create -s gpt nvd0
gpart add -t efi          -b 4096 -s 62M -a 4096 nvd0
gpart add -t freebsd-ufs          -s 56G -a 4096 nvd0
gpart add -t freebsd-swap         -s  4G -a 4096 nvd0
```

Nun müssen wir noch die Systempartition mit "UFS2" und einer 4K-Blockgrösse formatieren und aktivieren auch gleich die "soft-updates".

``` bash
newfs -O2 -U -f 4096 /dev/nvd0p2
```

Die Systempartition mounten wir nach `/mnt` und entpacken darauf ein FreeBSD-Minimalsystem mit dem wir problemlos weiterarbeiten können.

``` bash
mount -t ufs /dev/nvd0p2 /mnt

tar Jxpvf /usr/freebsd-dist/base.txz   -C /mnt/
tar Jxpvf /usr/freebsd-dist/kernel.txz -C /mnt/
tar Jxpvf /usr/freebsd-dist/lib32.txz  -C /mnt/
tar Jxpvf /usr/freebsd-dist/src.txz    -C /mnt/

cp -a /usr/freebsd-dist /mnt/usr/
```

Unser System soll natürlich auch von der Festplatte booten können, weshalb wir jetzt den Bootcode und Bootloader in der Bootpartittion installieren.

``` bash
newfs_msdos -F 32 -c 1 /dev/nvd0p1

mount -t msdosfs -o longnames /dev/nvd0p1 /mnt/boot/efi

mkdir -p /mnt/boot/efi/EFI/BOOT
cp /mnt/boot/loader.efi /mnt/boot/efi/EFI/BOOT/BOOTX64.efi

umount /mnt/boot/efi

gpart set -a bootme -i 2 nvd0
```

Vor dem Wechsel in die Chroot-Umgebung müssen wir noch die `resolv.conf` in die Chroot-Umgebung kopieren und das Device-Filesysteme dorthin mounten.

``` bash
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
cp /etc/resolv.conf /mnt/etc/resolv.conf

mount -t devfs devfs /mnt/dev
```

Das neu installierte System selbstverständlich noch konfiguriert werden, bevor wir es nutzen können. Dazu werden wir jetzt in das neue System chrooten und eine minimale Grundkonfiguration vornehmen.

``` bash
chroot /mnt

cd /root
```

Zunächst setzen wir die Systemzeit (CMOS clock) mittels `tzsetup`, hierzu wählen wir zunächst "Europe", dann "Germany" und zum Schluss "CET" beziehungsweise "CEST" aus.

``` bash
tzsetup
```

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

Das Home-Verzeichnis des Users root ist standardmässig leider nicht ausreichend restriktiv in seinen Zugriffsrechten, was wir mit einem entsprechenden Aufruf von `chmod` schnell ändern. Bevor wir es vergessen, setzen wir bei dieser Gelegenheit gleich ein sicheres Passwort für root.

``` bash
passwd root
```

Zur besseren Trennung beziehungsweise Gruppierung unterschiedlicher Nutzungszwecke legen wir ein paar Gruppen an (admin für rein administrative Nutzer, users für normale Nutzer, sshusers für Nutzer mit SSH-Zugang und sftponly für reine SFTP-Nutzer).

``` bash
pw groupadd -n admin -g 1000
pw groupadd -n users -g 2000
pw groupadd -n sshusers -g 3000
pw groupadd -n sftponly -g 4000
```

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

Die aliases-Datenbank für FreeBSDs Sendmail müssen wir mittels `make` anlegen, auch wenn wir später Sendmail gar nicht verwenden möchten.

``` bash
cd /etc/mail ; make aliases ; cd /root
```

Die `fstab` ist bei unserem minimalistischen Partitionslayout zwar nicht zwingend nötig, aber wir möchten später keine unerwarteten Überraschungen erleben, also legen wir sie vorsichtshalber mittels `ee /etc/fstab` mit folgendem Inhalt an.

``` text
# Device                     Mountpoint              FStype  Options         Dump    Pass
/dev/nvd0p2                  /                       ufs     rw              1       1
dev                          /dev                    devfs   rw              0       0
proc                         /proc                   procfs  rw              0       0
/dev/nvd0p3                  none                    swap    sw              0       0
```

In der `rc.conf` werden diverse Grundeinstellungen für das System und die installierten Dienste vorgenommen. Wir legen sie daher mittela `ee /etc/rc.conf` mit folgendem Inhalt an.

``` bash
cat > /etc/rc.conf << "EOF"
##############################################################
###  Important initial Boot-time options  ####################
##############################################################
fsck_y_enable="YES"
dumpdev="AUTO"

##############################################################
###  Network configuration sub-section  ######################
##############################################################
hostname="vbox.example.com"
ifconfig_em0="DHCP"

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

Da dies lediglich ein lokales temporäres System zum Erzeugen unseres mfsBSD-Images wird, können wir den SSH-Dienst bedenkenlos etwas komfortabler aber dadurch zwangsläufig auch etwas unsicherer konfigurieren, indem wir für "admin" den Login per Passwort zulassen.

``` bash
sed -e 's|^#\(PermitRootLogin\).*$|\1 yes|' \
    -e 's|^#\(PasswordAuthentication\).*$|\1 yes|' \
    -e 's|^#\(KbdInteractiveAuthentication\).*$|\1 no|' \
    -e 's|^#\(ChallengeResponseAuthentication\).*$|\1 no|' \
    -e 's|^#\(UsePAM\).*$|\1 no|' \
    -e 's|^#\(AllowAgentForwarding\).*$|\1 no|' \
    -e 's|^#\(AllowTcpForwarding\).*$|\1 no|' \
    -e 's|^#\(GatewayPorts\).*$|\1 no|' \
    -e 's|^#\(X11Forwarding\).*$|\1 no|' \
    -e 's|^#\(PermitUserEnvironment\).*$|\1 no|' \
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

Das System ist nun für unsere Zwecke ausreichend konfiguriert, so dass wir das Chroot nun verlassen und die Systempartition unmounten können.

``` bash
exit

umount /mnt/dev
umount /mnt

exit
```

Abschliessend beenden wir die virtuelle Maschine und werfen die Installations-DVD aus.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" controlvm "mfsBSD" acpipowerbutton

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

## Einloggen ins virtuelle System

Nachdem wir unser frisch installiertes System gebootet haben, sollten wir uns mittels PuTTY als `admin` einloggen können.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" startvm "mfsBSD"

putty -ssh -P 2222 admin@127.0.0.1
```

## ports-mgmt/pkg installieren

Hierzu wechseln wir nun per `su` zu `root` und installieren pkg.

``` bash
su - root

pkg install pkg
```

## mfsBSD erzeugen

Wir werden nun unser mfsBSD-Image erzeugen, um damit später unser eigentliches dediziertes System booten und installieren zu können. Hierzu legen uns zunächst ein Arbeitsverzeichnis an.

``` bash
mkdir /usr/local/mfsbsd
```

Nun fehlt noch das mfsBSD-Buildscript, welches wir jetzt mittels `fetch` in unserem Arbeitsverzeichnis downloaden und dann entpacken.

``` bash
cd /usr/local/mfsbsd

fetch -4 -q -o 'mfsbsd-master.tar.gz' --no-verify-peer https://github.com/mmatuska/mfsbsd/archive/master.tar.gz

tar xf mfsbsd-master.tar.gz
chown -R root:wheel mfsbsd-master
cd mfsbsd-master
```

Um uns später per SSH in unserem mfsBSD-Image einloggen zu können, legen wir das Passwort `mfsroot` für root fest.

``` bash
sed -e 's/^#\(mfsbsd.rootpw=\).*$/\1"mfsroot"/' conf/loader.conf.sample > conf/loader.conf
```

Für unsere Zwecke reicht die Standardkonfiguration des mfsBSD-Buildscripts aus, so dass wir unser mfsBSD-Image direkt erzeugen können.

``` bash
make BASE=/usr/freebsd-dist RELEASE=13.1-RELEASE ARCH=amd64 PKG_STATIC=/usr/local/sbin/pkg-static MFSROOT_MAXSIZE=120m
```

Anschliessend liegt unter `/usr/local/mfsbsd/mfsbsd-master/mfsbsd-13.1-RELEASE-amd64.img` unser fertiges mfsBSD-Image. Dieses kopieren wir nun per PuTTY auf den Windows Host.

``` powershell
pscp -P 2222 admin@127.0.0.1:/usr/local/mfsbsd/mfsbsd-master/mfsbsd-13.1-RELEASE-amd64.img "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD\mfsbsd-13.1-RELEASE-amd64.img"
```

Die virtuelle Maschine können wir an dieser Stelle nun beenden.

``` bash
exit
```

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" controlvm "mfsBSD" acpipowerbutton
```

Fertig.

Viel Spass mit dem neuen mfsBSD Image
