---
title: 'mfsBSD Image'
description: 'In diesem HowTo wird step-by-step die Erstellung eines mfsBSD Images zur Remote Installation von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-06'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
---

# mfsBSD Image

## Einleitung

In diesem HowTo beschreibe ich step-by-step das Erstellen eines [mfsBSD](https://mfsbsd.vx.sk/){: target="_blank" rel="noopener"} Images mit dem die [Remote Installation](/howtos/freebsd/remote_install/) von [FreeBSD](https://www.freebsd.org/){: target="_blank" rel="noopener"} 64Bit auf einem dedizierten Server durchgeführt werden kann.

## Das Referenzsystem

Als Referenzsystem habe ich mich für eine virtuelle Maschine auf Basis von [Oracle VM VirtualBox](https://www.virtualbox.org/){: target="_blank" rel="noopener"} unter [Microsoft Windows 11 Professional (64 Bit)](https://support.microsoft.com/products/windows){: target="_blank" rel="noopener"} entschieden. Leider bringt Microsoft Windows keinen eigenen SSH-Client mit, so dass ich auf das sehr empfehlenswerte [PuTTY (64 Bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/){: target="_blank" rel="noopener"} zurückgreife.

VirtualBox (inklusive dem Extensionpack) und PuTTY werden mit den jeweiligen Standardoptionen installiert.

``` powershell
winget install PuTTY.PuTTY
winget install Oracle.VirtualBox

$Env:vbox_ver=((winget show Oracle.VirtualBox) -match '^Version' -split '\s+')[1]
curl -o "Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack" -L "https://download.virtualbox.org/virtualbox/${Env:vbox_ver}/Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack
rm Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack
$Env:vbox_ver=''
```

## Die Virtuelle Maschine

Als Erstes öffnen wir eine neue PowerShell und legen manuell eine neue virtuelle Maschine an. Diese virtuelle Maschine bekommt den Namen `mfsBSD` und wird mit einer UEFI-Firmware, einem Quad-Core Prozessor, Intels ICH9-Chipsatz, 4096MB RAM, 64MB VideoRAM, einer 64GB SSD-Festplatte, einem DVD-Player, einer Netzwerkkarte, einem NVMe-Controller sowie einem AHCI-Controller und einem TPM 2.0 ausgestattet. Zudem setzen wir die RTC (Real-Time Clock) der virtuellen Maschine auf UTC (Coordinated Universal Time), aktivieren den HPET (High Precision Event Timer) und legen die Bootreihenfolge fest.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createvm --name "mfsBSD" --ostype FreeBSD_64 --register

cd "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD"

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --filename "mfsBSD1.vdi" --format VDI --size 64536

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "mfsBSD" --firmware efi --memory 4096 --vram 64 --cpus 4 --hpet on --hwvirtex on --chipset ICH9 --iommu automatic --tpm-type 2.0 --rtc-use-utc on
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "mfsBSD" --cpu-profile host --apic on --ioapic on --x2apic on --pae on --long-mode on --nested-paging on --large-pages on --vtx-vpid on --vtx-ux on
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "mfsBSD" --nic1 nat --nic-type1 virtio --nat-pf1 "VBoxSSH,tcp,,2222,,22" --nat-pf1 "VBoxHTTP,tcp,,8080,,80" --nat-pf1 "VBoxHTTPS,tcp,,8443,,443"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "mfsBSD" --graphicscontroller vmsvga --audio-enabled off --usb-ehci off --usb-ohci off --usb-xhci off --boot1 dvd --boot2 disk --boot3 none --boot4 none

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "mfsBSD" --name "NVMe Controller" --add pcie --controller NVMe --portcount 4 --bootable on --hostiocache off
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "mfsBSD" --name "AHCI Controller" --add sata --controller IntelAHCI --portcount 4 --bootable on --hostiocache off

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "mfsBSD" --storagectl "NVMe Controller" --port 0 --device 0 --type hdd --nonrotational on --medium "mfsBSD1.vdi"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

Als nächstes benötigen wir die FreeBSD 64Bit Installations-CD, welche wir mittels des mit Windows mitgelieferten cURL-Client herunterladen und unserer virtuellen Maschine als Bootmedium zuweisen.

``` powershell
cd "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD"

curl -o "FreeBSD-13.2-RELEASE-amd64-disc1.iso" -L "https://download.freebsd.org/releases/ISO-IMAGES/13.2/FreeBSD-13.2-RELEASE-amd64-disc1.iso"

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium "FreeBSD-13.2-RELEASE-amd64-disc1.iso"
```

Nachdem die virtuelle Maschine nun fertig konfiguriert ist, wird es Zeit diese zu booten.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "mfsBSD"
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

# Set root shell to /bin/tcsh
chsh -s /bin/tcsh root
```

Das Home-Verzeichnis des Users root ist standardmässig leider nicht ausreichend restriktiv in seinen Zugriffsrechten, was wir mit einem entsprechenden Aufruf von `chmod` schnell ändern. Bevor wir es vergessen, setzen wir bei dieser Gelegenheit gleich ein sicheres Passwort für root.

``` bash
passwd root
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
ifconfig_vtnet0="DHCP"

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

Da dies lediglich ein lokales temporäres System zum Erzeugen unseres mfsBSD-Images wird, können wir den SSH-Dienst bedenkenlos etwas komfortabler aber dadurch zwangsläufig auch etwas unsicherer konfigurieren, indem wir den Login per Passwort zulassen.

``` bash
sed -e 's|^#\(PermitRootLogin\).*$|\1 yes|' \
    -e 's|^#\(PasswordAuthentication\).*$|\1 yes|' \
    -e 's|^#\(KbdInteractiveAuthentication\).*$|\1 no|' \
    -e 's|^#\(UsePAM\).*$|\1 no|' \
    -e 's|^#\(UseBlacklist\).*$|\1 no|' \
    -i '' /etc/ssh/sshd_config

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
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" controlvm "mfsBSD" acpipowerbutton
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" controlvm "mfsBSD" poweroff

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

## Einloggen ins virtuelle System

Nachdem wir unser frisch installiertes System gebootet haben, sollten wir uns mittels PuTTY als `root` einloggen können.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" startvm "mfsBSD"

putty -ssh -P 2222 root@127.0.0.1
```

## ports-mgmt/pkg installieren

Wir installieren pkg via pkg.

``` bash
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

fetch -4 -q -o "mfsbsd-master.tar.gz" --no-verify-peer "https://github.com/mmatuska/mfsbsd/archive/master.tar.gz"

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
make BASE=/usr/freebsd-dist RELEASE=13.2-RELEASE ARCH=amd64 PKG_STATIC=/usr/local/sbin/pkg-static MFSROOT_MAXSIZE=120m
```

Anschliessend liegt unter `/usr/local/mfsbsd/mfsbsd-master/mfsbsd-13.2-RELEASE-amd64.img` unser fertiges mfsBSD-Image. Dieses kopieren wir nun per PuTTY auf den Windows Host.

``` powershell
pscp -P 2222 root@127.0.0.1:/usr/local/mfsbsd/mfsbsd-master/mfsbsd-13.2-RELEASE-amd64.img "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD\mfsbsd-13.2-RELEASE-amd64.img"
```

Die virtuelle Maschine können wir an dieser Stelle nun beenden.

``` bash
exit
```

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" controlvm "mfsBSD" acpipowerbutton
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" controlvm "mfsBSD" poweroff
```

Fertig.

Viel Spass mit dem neuen mfsBSD Image
