---
title: 'Voraussetzungen'
description: 'In diesem HowTo werden step-by-step die Voraussetzungen für die Remote Installation des FreeBSD 64Bit BaseSystem auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-07-01'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
tags:
    - FreeBSD
    - Remote Installation
---

# Voraussetzungen

## Einleitung

Die Installation des FreeBSD BaseSystem setzt ein wie in [mfsBSD Image](/howtos/freebsd/mfsbsd_image/) beschriebenes, bereits fertig erstelltes mfsBSD Image voraus.

Unser BaseSystem wird am Ende folgende Dienste umfassen.

- FreeBSD 13.1-RELEASE 64Bit
- OpenSSL 1.1.1
- OpenSSH 8.8
- Unbound 1.13.1

Unsere BasePorts werden am Ende folgende Dienste umfassen.

- Perl 5.36.0
- OpenSSL 1.1.1
- LUA 5.3.6
- TCL 8.6.12
- Python 3.9.13
- Ruby 3.0.4
- Berkeley DB 18.1.40

Unsere BaseTools werden am Ende folgende Dienste umfassen.

- Sudo 1.9.11
- cURL 7.84.0
- GIT 2.37.0
- Portmaster 3.22
- SMARTmontools 7.3
- Bash 5.1.16
- Nano 6.2
- w3m 0.5.3
- GnuPG 2.3.3
- GDBM 1.23
- SVN 1.14.2

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

## Vorbereitungen

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

## Die Virtuelle Maschine

Als Erstes öffnen wir eine neue PowerShell und legen manuell eine neue virtuelle Maschine an. Diese virtuelle Maschine bekommt den Namen `FreeBSD` und wird mit einer UEFI-Firmware, einem Dual-Core Prozessor, Intels ICH9-Chipsatz, 4096MB RAM, 64MB VideoRAM, zwei 64GB SSD-Festplatten, einem DVD-Player, einer Intel-Netzwerkkarte, einem NVMe-Controller sowie einem AHCI-Controller ausgestattet. Zudem setzen wir die RTC (Real-Time Clock) der virtuellen Maschine auf UTC (Coordinated Universal Time), aktivieren den HPET (High Precision Event Timer) und legen die Bootreihenfolge fest.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" createvm --name "FreeBSD" --ostype FreeBSD_64 --register

cd "${Env:USERPROFILE}\VirtualBox VMs\FreeBSD"

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" createmedium disk --filename "FreeBSD1.vdi" --format VDI --size 64536
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" createmedium disk --filename "FreeBSD2.vdi" --format VDI --size 64536

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --firmware efi --cpus 2 --cpuexecutioncap 100 --cpuhotplug off
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --chipset ICH9 --graphicscontroller vmsvga --audio none --usb off
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --hwvirtex on --ioapic on --hpet on --rtcuseutc on --memory 4096 --vram 64
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --nic1 nat --nictype1 82540EM --natnet1 "192.168/16" --cableconnected1 on
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --boot1 dvd --boot2 disk --boot3 none --boot4 none

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storagectl "FreeBSD" --name "NVMe Controller" --add pcie --controller NVMe --portcount 4 --bootable on
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storagectl "FreeBSD" --name "AHCI Controller" --add sata --controller IntelAHCI --portcount 4 --bootable on

& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "NVMe Controller" --port 0 --device 0 --type hdd --nonrotational on --medium "FreeBSD1.vdi"
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "NVMe Controller" --port 1 --device 0 --type hdd --nonrotational on --medium "FreeBSD2.vdi"
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" storageattach "FreeBSD" --storagectl "AHCI Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
```

Die virtuelle Maschine, genauer die virtuelle Netzwerkkarte, kann dank NAT zwar problemlos mit der Aussenwelt, aber leider nicht direkt mit dem Hostsystem kommunizieren. Aus diesem Grund richten wir nun für den SSH-Zugang noch ein Portforwarding ein, welches den Port 2222 des Hostsystems auf den Port 22 der virtuellen Maschine weiterleitet.

``` powershell
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --natpf1 "VBoxSSH,tcp,,2222,,22"
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --natpf1 "VBoxHTTP,tcp,,80,,80"
& "${Env:VBOX_MSI_INSTALL_PATH}\VBoxManage.exe" modifyvm "FreeBSD" --natpf1 "VBoxHTTPS,tcp,,443,,443"
```

Nachdem die virtuelle Maschine nun konfiguriert ist, wird es Zeit diese zu booten.

## Los geht es

Die einzelnen HowTos bauen aufeinander auf, daher sollten sie in der Reihenfolge von oben nach unten bis zum Ende abgearbeitet werden.

Viel Spass und Erfolg
