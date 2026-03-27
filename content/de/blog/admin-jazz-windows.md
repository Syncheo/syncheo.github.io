---
title: "Modernisierung der Systemadministration: Jazz und Scaleway unter Windows verwalten"
date: 2026-03-23T14:30:00+01:00
draft: false
tags: ["Windows Terminal", "SSH", "Jazz", "DevOps", "Syncheo"]
categories: ["Technische Expertise"]
author: "Syncheo Engineering"
description: "Eine vollständige Anleitung zum Wechsel von mRemoteNG zu einem hochleistungsfähigen nativen Windows-Stack: Windows Terminal, OpenSSH und PowerShell."
banner: "img/blog/admin-jazz-windows-banner.png"
translationKey: "admin-jazz-windows"
---

Die Administration kritischer Plattformen wie **Jazz** (CORS-Verwaltung, EWM-Widget-Deployment, **DB2**-Datenbankwartung) erfordert eine reaktionsschnelle Oberfläche und eine reibungslose Handhabung sicherer Datenflüsse. Bei **Syncheo** sind wir von schwerfälligen Drittanbieter-Tools wie mRemoteNG auf einen 100 % nativen Windows-Stack migriert.

<!--more-->

Dieser Leitfaden beschreibt, wie Sie Ihre Windows-Umgebung in eine optimierte, kostenfreie und sichere DevOps-Workstation verwandeln.

---

## 1. Standardisierte Konnektivität: OpenSSH & Bastion

Der native Windows SSH-Client macht Sie unabhängig von proprietären Formaten (wie PuTTys `.ppk`). Wir zentralisieren die gesamte Konfiguration in `%USERPROFILE%\.ssh\config`.

### Architektur mit Jump Server (Bastion)

Für den Zugriff auf isolierte Server verwenden wir einen Bastion-Host auf Port **2222**. Die Direktive `ProxyJump` macht diesen Sprung für den Benutzer vollständig transparent.

```text
# Bastion-Definition
Host bastion-scw
    HostName <BASTION_IP>
    User bastion
    Port 2222
    IdentityFile C:\Users\<IhrUser>\Keys\bastion.pem

# Jazz-Hauptserver über den Bastion
Host jazz-prod
    HostName <JAZZ_IP>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<IhrUser>\Keys\jazz_prod.pem

# DB2-Instanz über den Bastion
Host jazz-db2
    HostName <DB2_IP>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<IhrUser>\Keys\db2_key.pem
```

Mit dieser Konfiguration tunnelt der Befehl `ssh jazz-prod` automatisch über den Bastion ohne zusätzliche Einrichtung. Die Option `ProxyJump` verwaltet den Tunnel nativ und sicher.

---

## 2. Windows Terminal: Kontextbasierte Organisation

Um die Ordnerstruktur von mRemoteNG zu ersetzen, nutzen wir die **Befehlspalette** (`Ctrl+Shift+P`) des Windows Terminals. Dies ermöglicht eine wesentlich schnellere „Search-first"-Navigation.

### Speicherort der Konfigurationsdatei

Die Datei `settings.json` ist direkt über Windows Terminal unter `Einstellungen → JSON-Datei öffnen` zugänglich oder unter folgendem Pfad:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### Profilkonfiguration (settings.json)

Fügen Sie unter `"profiles" > "list"` ein dediziertes Profil hinzu, um ein PowerShell-Profil mit aktivierter Skriptausführung zu erhalten:

```json
{
    "guid": "{ihre-eindeutige-guid}",
    "name": "PowerShell Jazz Admin",
    "commandline": "powershell.exe -ExecutionPolicy Bypass -NoLogo",
    "startingDirectory": "%USERPROFILE%",
    "hidden": false
}
```

### Aktionskonfiguration (settings.json)

Fügen Sie diesen Block in den Abschnitt `"actions": [...]` ein, um virtuelle Dropdown-Menüs zu erstellen, die über die Befehlspalette zugänglich sind:

```json
{
    "name": "📂 JAZZ PROJEKT",
    "commands": [
        { "name": "Jazz Main", "command": { "action": "runCommandline", "commandline": "ssh jazz-prod" } },
        { "name": "Jazz DB2", "command": { "action": "runCommandline", "commandline": "ssh jazz-db2" } }
    ]
},
{
    "name": "📂 SCALEWAY INFRA",
    "commands": [
        { "name": "Bastion", "command": { "action": "runCommandline", "commandline": "ssh bastion-scw" } },
        { "name": "Server 1", "command": { "action": "runCommandline", "commandline": "ssh scw-1" } }
    ]
}
```

---

## 3. Produktivität: Intelligente Autovervollständigung

Um den Linux-Komfort zu erhalten (`Tab`-Taste zur Vervollständigung von Servernamen), injizieren wir einen Helper in das PowerShell-Profil (`$PROFILE`).

### Autovervollständigungs-Skript

```powershell
# Helper zum Lesen der Hosts aus der SSH-Config-Datei
$sshHelper = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $configPath = "$env:USERPROFILE\.ssh\config"
    if (Test-Path $configPath) {
        $hosts = Get-Content $configPath | Select-String "^Host\s+(.*)" | ForEach-Object {
            $_.Matches.Groups[1].Value.Trim() -split "\s+"
        } | Where-Object { $_ -notmatch "\*" }
        $hosts | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName ssh,scp,sftp -ScriptBlock $sshHelper

# Tab-Taste im Menümodus aktivieren
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
try { Set-PSReadLineOption -PredictionSource History } catch { }
```

Um dieses Skript beim Start zu aktivieren, fügen Sie es in Ihre `$PROFILE`-Datei ein (normalerweise `Dokumente\PowerShell\Microsoft.PowerShell_profile.ps1`).

---

## 4. Sicherheit und Integrität

### PEM-Schlüsselverwaltung

Windows erzwingt strenge Berechtigungen für `.pem`-Dateien. Wenden Sie folgende Rechte an, um den Fehler *"Unprotected Private Key"* zu vermeiden:

```powershell
icacls "mein_schluessel.pem" /inheritance:r
icacls "mein_schluessel.pem" /grant:r "${env:UserName}:(R)"
```

### Isolierte Ausführungsrichtlinie

Um das Laden Ihres PowerShell-Profils zu ermöglichen, ohne die globale Systemsicherheit zu senken, konfigurieren Sie das Profil in `settings.json` mit `-ExecutionPolicy Bypass` (siehe Abschnitt 2). Dieser Ansatz ist einer globalen Richtlinienänderung über `Set-ExecutionPolicy` vorzuziehen, da er auf das Administrations-Terminal beschränkt bleibt.

---

## Fazit

Dieser „Lean"-Ansatz garantiert eine robuste, portable und extrem schnelle Administrationsinfrastruktur. Durch die Zentralisierung der Logik in `~/.ssh/config` und der Oberfläche im Windows Terminal verfügen Syncheo-Ingenieure über ein professionelles Werkzeug, das perfekt auf die Anforderungen der modernen Cloud ausgerichtet ist — ohne Drittanbieter-Abhängigkeiten und ohne Lizenzkosten.
