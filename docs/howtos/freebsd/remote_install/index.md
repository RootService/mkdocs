---
title: 'Remote Installation'
description: 'In diesem HowTo werden step-by-step die Voraussetzungen für die Remote Installation des FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2023-04-06'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Remote Installation

## Einleitung

Unser BaseSystem wird am Ende folgende Dienste umfassen.

- FreeBSD 13.2-RELEASE 64Bit
- OpenSSL 1.1.1
- OpenSSH 9.3
- Unbound 1.17.1

Unsere BasePorts werden am Ende folgende Dienste umfassen.

- Perl 5.32.1
- OpenSSL 1.1.1
- LUA 5.4.4
- TCL 8.6.13
- Python 3.9.16
- Ruby 3.1.3

Unsere BaseTools werden am Ende folgende Dienste umfassen.

- Sudo 1.9.13
- cURL 8.0.1
- Bash 5.2.15
- GIT 2.40.0
- Portmaster 3.22
- SMARTmontools 7.3
- SQLite 3.41.0
- Nano 7.2
- GnuPG 2.3.8
- Subversion 1.14.2

Folgende Punkte sind in allen folgenden HowTos zu beachten.

- Alle Dienste werden mit einem möglichst minimalen und bewährten Funktionsumfang installiert.
- Alle Dienste werden mit einer möglichst sicheren und dennoch flexiblen Konfiguration versehen.
- Alle Konfigurationen sind selbstständig auf notwendige individuelle Anpassungen zu kontrollieren.
- Alle Benutzernamen werden als `__USERNAME__` dargestellt und sind selbstständig passend zu ersetzen.
- Alle Passworte werden als `__PASSWORD__` dargestellt und sind selbstständig durch sichere Passworte zu ersetzen.
- Die Domain des Servers lautet `example.com` und ist selbstständig durch die eigene Domain zu ersetzen.
- Der Hostname des Servers lautet `devnull` und ist selbstständig durch den eigenen Hostnamen zu ersetzen (FQDN=devnull.example.com).
- Es wird der FQDN `devnull.example.com` verwendet und ist selbstständig im DNS zu registrieren.
- Die primäre IPv4 Adresse des Systems wird als `__IPV4ADDR__` dargestellt und ist selbsttändig zu ersetzen.
- Die primäre IPv6 Adresse des Systems wird als `__IPV6ADDR__` dargestellt und ist selbsttändig zu ersetzen.

## Voraussetzungen

Die Installation des FreeBSD BaseSystem setzt ein wie in [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) beschriebenes, bereits fertig erstelltes mfsBSD Image voraus.

## DNS Records

Für diese HowTos müssen zuvor folgende DNS-Records angelegt werden, sofern sie noch nicht existieren, oder entsprechend geändert werden, sofern sie bereits existieren.

``` dns-zone
example.com.            IN  A       __IPV4ADDR__
example.com.            IN  AAAA    __IPV6ADDR__

devnull.example.com.    IN  A       __IPV4ADDR__
devnull.example.com.    IN  AAAA    __IPV6ADDR__
```

## Das Referenzsystem

Als Referenzsystem für dieses HowTo habe ich mich für eine virtuelle Maschine auf Basis von [Oracle VM VirtualBox](https://www.virtualbox.org/){: target="_blank" rel="noopener"} unter [Microsoft Windows 11 Professional (64 Bit)](https://support.microsoft.com/products/windows){: target="_blank" rel="noopener"} entschieden. So lässt sich ohne grösseren Aufwand ein handelsüblicher dedizierter Server simulieren und anschliessend kann diese virtuelle Maschine als kostengünstiges lokales Testsystem weiter genutzt werden.

Trotzdem habe ich dieses HowTo so ausgelegt, dass es sich nahezu unverändert auf dedizierte Server übertragen lässt und dieses auch auf mehreren dedizierten Servern getestet.

Leider bringt Microsoft Windows keinen eigenen SSH-Client mit, so dass ich auf das sehr empfehlenswerte [PuTTY (64 Bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/){: target="_blank" rel="noopener"} zurückgreife. Zur Simulation des bei nahezu allen Anbietern dedizierter Server vorhandene Rettungssystem, nachfolgend RescueSystem genannt, wird in diesem HowTo die auf [Gentoo Linux](https://www.gentoo.org/){: target="_blank" rel="noopener"} basierende [SystemRescueCD](https://www.system-rescue.org/){: target="_blank" rel="noopener"} eingesetzt.

VirtualBox (inklusive dem Extensionpack) und PuTTY werden mit den jeweiligen Standardoptionen installiert.

``` powershell
winget install PuTTY.PuTTY
winget install Oracle.VirtualBox

$Env:vbox_ver=((winget show Oracle.VirtualBox) -match '^Version' -split '\s+')[1]
curl -o Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack -L https://download.virtualbox.org/virtualbox/${Env:vbox_ver}/Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack
rm Oracle_VM_VirtualBox_Extension_Pack-${Env:vbox_ver}.vbox-extpack
$Env:vbox_ver=''
```

## Die Virtuelle Maschine

Als Erstes öffnen wir eine neue PowerShell und legen manuell eine neue virtuelle Maschine an. Diese virtuelle Maschine bekommt den Namen `FreeBSD` und wird mit einer UEFI-Firmware, einem Quad-Core Prozessor, Intels ICH9-Chipsatz, 4096MB RAM, 64MB VideoRAM, zwei 64GB SSD-Festplatten, einem DVD-Player, einer Netzwerkkarte, einem NVMe-Controller sowie einem AHCI-Controller und einem TPM 2.0 ausgestattet. Zudem setzen wir die RTC (Real-Time Clock) der virtuellen Maschine auf UTC (Coordinated Universal Time), aktivieren den HPET (High Precision Event Timer) und legen die Bootreihenfolge fest.

``` powershell
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createvm --name "FreeBSD" --ostype FreeBSD_64 --register

cd "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD"

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --filename "FreeBSD1.vdi" --format VDI --size 64536
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --filename "FreeBSD2.vdi" --format VDI --size 64536

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "FreeBSD" --firmware efi --memory 4096 --vram 64 --cpus 4 --hpet on --hwvirtex on --chipset ICH9 --iommu automatic --tpm-type 2.0 --rtc-use-utc on
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "FreeBSD" --cpu-profile host --apic on --ioapic on --x2apic on --pae on --long-mode on --nested-paging on --large-pages on --vtx-vpid on --vtx-ux on
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "FreeBSD" --nic1 nat --nic-type1 virtio --nat-pf1 "VBoxSSH,tcp,,2222,,22" --nat-pf1 "VBoxHTTP,tcp,,8080,,80" --nat-pf1 "VBoxHTTPS,tcp,,8443,,443"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" modifyvm "FreeBSD" --graphicscontroller vmsvga --audio-enabled off --usb-ehci off --usb-ohci off --usb-xhci off --boot1 dvd --boot2 disk --boot3 none --boot4 none

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "FreeBSD" --name "NVMe Controller" --add pcie --controller NVMe --portcount 4 --bootable on --hostiocache off
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storagectl "FreeBSD" --name "AHCI Controller" --add sata --controller IntelAHCI --portcount 4 --bootable on --hostiocache off

& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "FreeBSD" --storagectl "NVMe Controller" --port 0 --device 0 --type hdd --nonrotational on --medium "FreeBSD1.vdi"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "FreeBSD" --storagectl "NVMe Controller" --port 1 --device 0 --type hdd --nonrotational on --medium "FreeBSD2.vdi"
& "${Env:ProgramFiles}\Oracle\VirtualBox\VBoxManage.exe" storageattach "FreeBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

Nachdem die virtuelle Maschine nun konfiguriert ist, wird es Zeit diese zu booten.

## Los geht es

Die einzelnen HowTos bauen aufeinander auf, daher sollten sie in der Reihenfolge von oben nach unten bis zum Ende abgearbeitet werden.

Viel Spass und Erfolg
