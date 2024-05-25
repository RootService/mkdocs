---
title: 'mfsBSD Image'
description: 'In diesem HowTo wird step-by-step die Erstellung eines mfsBSD Images zur Remote Installation von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2024-05-24'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
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

$Env:vbox_ver=((winget show Oracle.VirtualBox) -match '^Version:' -split '\s+')[1]
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

curl -o "FreeBSD-14.1-RELEASE-amd64-disc1.iso" -L "https://download.freebsd.org/releases/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-amd64-disc1.iso"

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "mfsBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium "FreeBSD-14.1-RELEASE-amd64-disc1.iso"
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

Wir werden vier Partitionen anlegen, die Erste für den GPT-Bootcode, die Zweite für den EFI-Bootcode, die Dritte als Swap und die Vierte als Systempartition. Dabei werden wir die Partitionen auch gleich für modernere Festplatten mit 4K-Sektoren optimieren und statt den veralteten "MBR Partition Tables" die aktuelleren "GUID Partition Tables (GPT)" verwenden.

``` bash
sysctl kern.geom.debugflags=0x10

gpart create -s gpt nvd0

gpart add -t freebsd-boot  -b      40 -s     216 -l bootfs nvd0
gpart add -t efi           -b     256 -s    3840 -l uefifs nvd0
gpart add -t freebsd-swap  -b    4096 -s 8388608 -l swapfs nvd0
gpart add -t freebsd-ufs   -b 8392704            -l rootfs nvd0

gpart set -a bootme -i 4 nvd0
```

Nun müssen wir noch die Systempartition mit "UFS2" und einer 4K-Blockgrösse formatieren und aktivieren auch gleich die "soft-updates".

``` bash
newfs -U -l -t /dev/gpt/rootfs
```

Die Systempartition mounten wir nach `/mnt` und entpacken darauf ein FreeBSD-Minimalsystem mit dem wir problemlos weiterarbeiten können.

``` bash
mount -t ufs /dev/gpt/rootfs /mnt

tar Jxpvf /usr/freebsd-dist/base.txz   -C /mnt/
tar Jxpvf /usr/freebsd-dist/kernel.txz -C /mnt/
tar Jxpvf /usr/freebsd-dist/lib32.txz  -C /mnt/
tar Jxpvf /usr/freebsd-dist/src.txz    -C /mnt/

cp -a /usr/freebsd-dist /mnt/usr/
```

Unser System soll natürlich auch von der Festplatte booten können, weshalb wir jetzt den Bootcode und Bootloader in der Bootpartittion installieren.

``` bash
newfs_msdos /dev/gpt/uefifs

mount -t msdosfs /dev/gpt/uefifs /mnt/boot/efi

mkdir -p /mnt/boot/efi/EFI/BOOT
cp /mnt/boot/loader.efi /mnt/boot/efi/EFI/BOOT/BOOTX64.efi
efibootmgr -a -c -l vtbd0p2:/EFI/BOOT/BOOTX64.efi -L FreeBSD
umount /mnt/boot/efi

gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptboot -i 1 nvd0
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
chroot /mnt /usr/bin/env -i HOME=/root TERM=$TERM /bin/tcsh
```

Zunächst setzen wir die Systemzeit (CMOS clock) mittels `tzsetup` auf "UTC" (Universal Time Code).

``` bash
/usr/sbin/tzsetup UTC
```

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

Das Home-Verzeichnis des Users root ist standardmässig leider nicht ausreichend restriktiv in seinen Zugriffsrechten, was wir mit einem entsprechenden Aufruf von `chmod` schnell ändern. Bevor wir es vergessen, setzen wir bei dieser Gelegenheit gleich ein sicheres Passwort für root.

``` bash
passwd root
```

Die aliases-Datenbank für FreeBSDs DMA müssen wir mittels `newaliases` anlegen, auch wenn wir später DMA gar nicht verwenden möchten.

``` bash
sed -e 's/^#[[:space:]]*\(root:[[:space:]]*\).*$/\1 admin@example.com/' \
    -e 's/^#[[:space:]]*\(hostmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(webmaster:[[:space:]]*.*\)$/\1/' \
    -e 's/^#[[:space:]]*\(www:[[:space:]]*.*\)$/\1/' \
    -i '' /etc/mail/aliases

newaliases
```

Die `fstab` ist bei unserem minimalistischen Partitionslayout zwar nicht zwingend nötig, aber wir möchten später keine unerwarteten Überraschungen erleben, also legen wir sie vorsichtshalber an.

``` text
cat <<'EOF' > /etc/fstab
# Device           Mountpoint    FStype     Options      Dump    Pass
# Custom /etc/fstab for FreeBSD VM images
/dev/gpt/rootfs    /             ufs        rw           1       1
/dev/gpt/swapfs    none          swap       sw           0       0
/dev/gpt/efiesp    /boot/efi     msdosfs    rw           2       2
EOF
```

In der `rc.conf` werden diverse Grundeinstellungen für das System und die installierten Dienste vorgenommen. Wir legen sie daher mittela `ee /etc/rc.conf` mit folgendem Inhalt an.

``` bash
cat <<'EOF' >> /etc/rc.conf
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
hostname="vbox.example.com"
ifconfig_vtnet0="DHCP"

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

Da dies lediglich ein lokales temporäres System zum Erzeugen unseres mfsBSD-Images wird, können wir den SSH-Dienst bedenkenlos etwas komfortabler aber dadurch zwangsläufig auch etwas unsicherer konfigurieren, indem wir den Login per Passwort zulassen.

``` bash
sed -e 's|^#\(Port\).*$|\1 22|' \
    -e 's|^#\(PermitRootLogin\).*$|\1 prohibit-password|' \
    -e 's|^#\(PubkeyAuthentication\).*$|\1 yes|' \
    -e 's|^#\(PasswordAuthentication\).*$|\1 no|' \
    -e 's|^#\(PermitEmptyPasswords\).*$|\1 no|' \
    -e 's|^#\(KbdInteractiveAuthentication\).*$|\1 no|' \
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
pkg bootstrap -y
```

## mfsBSD erzeugen

Wir werden nun unser mfsBSD-Image erzeugen, um damit später unser eigentliches dediziertes System booten und installieren zu können. Hierzu legen uns zunächst ein Arbeitsverzeichnis an.

``` bash
mkdir -p /usr/local/mfsbsd
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
make BASE=/usr/freebsd-dist RELEASE=14.1-RELEASE ARCH=amd64 PKG_STATIC=/usr/local/sbin/pkg-static MFSROOT_MAXSIZE=120m
```

Anschliessend liegt unter `/usr/local/mfsbsd/mfsbsd-master/mfsbsd-14.1-RELEASE-amd64.img` unser fertiges mfsBSD-Image. Dieses kopieren wir nun per PuTTY auf den Windows Host.

``` powershell
pscp -P 2222 root@127.0.0.1:/usr/local/mfsbsd/mfsbsd-master/mfsbsd-14.1-RELEASE-amd64.img "${Env:USERPROFILE}\VirtualBox VMs\mfsBSD\mfsbsd-14.1-RELEASE-amd64.img"
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
