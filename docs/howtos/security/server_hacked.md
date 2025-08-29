---
title: 'Vorgehensweise bei gehacktem Server – Moderne Incident-Response-Checkliste'
description: 'In diesem HowTo findest Du eine praxisnahe, aktualisierte Schritt-für-Schritt-Anleitung, wie Du nach einem Servereinbruch professionell und sicher vorgehst. Ziel ist es, Schäden zu minimieren, Beweise zu sichern und das System fachgerecht wiederherzustellen.'
date: '2003-02-18'
updated: '2023-10-18'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
---

# Vorgehensweise bei gehacktem Server – Moderne Incident-Response-Checkliste

In diesem HowTo findest Du eine praxisnahe, aktualisierte Schritt-für-Schritt-Anleitung, wie Du nach einem Servereinbruch professionell und sicher vorgehst. Ziel ist es, Schäden zu minimieren, Beweise zu sichern und das System fachgerecht wiederherzustellen.

## Einleitung

Ein Servereinbruch ist ein Notfall – aber kein Grund zur Panik. Mit einem strukturierten Vorgehen, modernen Tools und klaren Prozessen kannst Du den Schaden begrenzen und die Kontrolle zurückgewinnen. Die folgenden Schritte orientieren sich an aktuellen Best Practices aus IT-Security und Incident Response.

## Inhaltsverzeichnis
- [Ruhe bewahren](#ruhe-bewahren)
- [Beweise sichern (Forensik)](#beweise-sichern-forensik)
- [Nutzdaten sichern](#nutzdaten-sichern)
- [Server neu aufsetzen](#server-neu-aufsetzen)
- [Nutzdaten und Beweise analysieren](#nutzdaten-und-beweise-analysieren)
- [Sicherheitskonzept anpassen](#sicherheitskonzept-anpassen)
- [Software minimal installieren](#software-minimal-installieren)
- [Nutzdaten einspielen](#nutzdaten-einspielen)
- [Server wieder online nehmen](#server-wieder-online-nehmen)
- [Abschließende Hinweise](#abschließende-hinweise)

## Ruhe bewahren

Handele besonnen und strukturiert. Überstürztes Vorgehen kann Beweise vernichten und den Schaden vergrößern. Lies diese Anleitung einmal komplett durch, bevor Du startest. Dokumentiere alle Schritte (z. B. in einem Incident-Log).

## Beweise sichern (Forensik)

- Trenne den Server sofort vom Netz (Netzwerkkabel ziehen, Firewall-Regel setzen, Cloud-Interface nutzen).
- Starte den Server nicht neu! Jeder Reboot kann Spuren vernichten.
- Erstelle ein vollständiges Festplatten-Image (z. B. mit `dd`, `dc3dd`, `Clonezilla`, `FTK Imager`).
- Sichere RAM-Inhalte, falls möglich (`LiME`, `volatility`).
- Notiere Zeitpunkte, IP-Adressen, auffällige Prozesse und offene Verbindungen (`lsof`, `netstat`, `ps`, `ss`).
- Bewahre das Image für spätere Analyse oder rechtliche Schritte auf. Für forensische Beweissicherung: Hashwerte (SHA256) dokumentieren.

## Nutzdaten sichern

- Sichere alle Nutzdaten (Webdaten, Datenbanken, E-Mails, Konfigurationen), aber keine ausführbaren Programme/Skripte.
- Nutze Tools wie `rsync`, `tar`, `borgbackup` oder Snapshots.
- Prüfe, ob Backups kompromittiert wurden.

## Server neu aufsetzen

- Setze das System komplett neu auf (kein Restore von Systemdateien!).
- Lösche alle Festplatten sicher (z. B. `shred`, `blkdiscard`, Cloud-API).
- Installiere das Betriebssystem minimal und aktualisiere es sofort.
- Aktiviere SSH nur mit Key-Auth, keine unnötigen Dienste starten.

## Nutzdaten und Beweise analysieren

- Analysiere die gesicherten Nutzdaten auf Manipulationen (Vergleich mit Backups, Hash-Prüfung).
- Untersuche das Festplatten-Image in einer isolierten VM (kein Netzwerk!).
- Nutze Forensik-Tools wie `Autopsy`, `The Sleuth Kit`, `plaso`, `volatility`.
- Suche nach Einfallstoren (z. B. ungepatchte Webanwendungen, schwache Passwörter, Exploits).
- Ziehe bei Unsicherheit professionelle Hilfe (IT-Forensiker, CERT, BSI) hinzu.
- Prüfe Meldepflichten (z. B. DSGVO, KRITIS, BSI) und informiere ggf. Behörden.

## Sicherheitskonzept anpassen

- Überarbeite Dein Security-Konzept auf Basis der Analyse.
- Schließe gefundene Schwachstellen (z. B. Updates, Härtung, Firewall, 2FA).
- Setze auf Defense-in-Depth: Monitoring (z. B. Wazuh, OSSEC, Fail2ban), regelmäßige Backups, automatisierte Updates.
- Dokumentiere alle Änderungen und Lessons Learned.

## Software minimal installieren

- Installiere nur unbedingt benötigte Software (Minimalprinzip).
- Nutze aktuelle, gepflegte Pakete und sichere Konfigurationen (z. B. CIS Benchmarks).
- Automatisiere Updates und Monitoring.

## Nutzdaten einspielen

- Spiele nur geprüfte, saubere Nutzdaten zurück.
- Verzichte auf veraltete, unnötige Daten (Datensparsamkeit, DSGVO).
- Prüfe die Integrität der Daten (Hashwerte, Checksummen).

## Server wieder online nehmen

- Teste das System in einer isolierten Umgebung.
- Überwache Logfiles und Netzwerkverkehr nach dem Go-Live besonders intensiv.
- Informiere Nutzer/Stakeholder über den Vorfall und die ergriffenen Maßnahmen.

## Abschließende Hinweise

- Dokumentiere den gesamten Vorfall und die Wiederherstellung für spätere Audits.
- Nutze die Gelegenheit, Prozesse und Monitoring zu verbessern.
- Ziehe bei Unsicherheit professionelle Hilfe hinzu.
- Melde sicherheitsrelevante Vorfälle an Betreiber, Kunden und ggf. Behörden.

**Fazit:**

Ein kompromittierter Server ist immer ein Risiko. Nur ein vollständiges Neuaufsetzen und ein modernes, kontinuierlich gepflegtes Sicherheitskonzept bieten nachhaltigen Schutz. Prävention, Monitoring und regelmäßige Schulung sind die beste Verteidigung.

**Dein RootService Team**
