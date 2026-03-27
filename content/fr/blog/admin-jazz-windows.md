---
title: "Modernisation de l'Administration Système : Gérer Jazz et Scaleway sous Windows"
date: 2026-03-23T14:30:00+01:00
draft: false
tags: ["Windows Terminal", "SSH", "Jazz", "DevOps", "Syncheo"]
categories: ["Expertise Technique"]
author: "Syncheo Engineering"
description: "Guide complet pour passer de mRemoteNG à une stack native Windows ultra-performante : Windows Terminal, OpenSSH et PowerShell."
banner: "img/blog/admin-jazz-windows-banner.png"
translationKey: "admin-jazz-windows"
---

L'administration de plateformes critiques comme **Jazz** (gestion du CORS, déploiement de widgets EWM, maintenance de bases **DB2**) exige une interface réactive et une gestion fluide des flux sécurisés. Chez **Syncheo**, nous avons migré de solutions tierces lourdes comme mRemoteNG vers une stack 100 % native Windows.

<!--more-->

Ce guide détaille comment transformer votre environnement Windows en une station de travail DevOps optimisée, gratuite et sécurisée.

---

## 1. Connectivité Standardisée : OpenSSH & Bastion

L'utilisation du client SSH natif de Windows permet de s'affranchir des formats propriétaires (comme le `.ppk` de PuTTY). Nous centralisons toute la configuration dans le fichier `%USERPROFILE%\.ssh\config`.

### Architecture avec Jump Server (Bastion)

Pour accéder à nos serveurs isolés, nous utilisons un bastion sur le port **2222**. La directive `ProxyJump` rend ce rebond totalement transparent pour l'utilisateur.

```text
# Définition du Bastion
Host bastion-scw
    HostName <IP_BASTION>
    User bastion
    Port 2222
    IdentityFile C:\Users\<VotreUser>\Keys\bastion.pem

# Serveur Jazz principal via le Bastion
Host jazz-prod
    HostName <IP_JAZZ>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<VotreUser>\Keys\jazz_prod.pem

# Instance DB2 via le Bastion
Host jazz-db2
    HostName <IP_DB2>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<VotreUser>\Keys\db2_key.pem
```

Avec cette configuration, la commande `ssh jazz-prod` traverse automatiquement le bastion sans aucune configuration supplémentaire. L'option `ProxyJump` gère le tunnel de manière native et sécurisée.

---

## 2. Windows Terminal : Organisation par Contextes

Pour remplacer l'arborescence de dossiers de mRemoteNG, nous utilisons la **Palette de Commandes** (`Ctrl+Shift+P`) du Windows Terminal. Cela permet une navigation "Search-first" beaucoup plus rapide.

### Emplacement du fichier de configuration

Le fichier `settings.json` est accessible directement depuis Windows Terminal via `Paramètres → Ouvrir le fichier JSON`, ou à l'emplacement suivant :

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### Configuration des profils (settings.json)

Ajoutez un profil dédié dans la section `"profiles" > "list"` pour bénéficier d'un profil PowerShell avec exécution de scripts activée :

```json
{
    "guid": "{votre-guid-unique}",
    "name": "PowerShell Jazz Admin",
    "commandline": "powershell.exe -ExecutionPolicy Bypass -NoLogo",
    "startingDirectory": "%USERPROFILE%",
    "hidden": false
}
```

### Configuration des Actions (settings.json)

Ajoutez ce bloc dans la section `"actions": [...]` pour créer des menus déroulants virtuels accessibles via la Palette de Commandes :

```json
{
    "name": "📂 PROJET JAZZ",
    "commands": [
        { "name": "Jazz Main", "command": { "action": "runCommandline", "commandline": "ssh jazz-prod" } },
        { "name": "Jazz DB2", "command": { "action": "runCommandline", "commandline": "ssh jazz-db2" } }
    ]
},
{
    "name": "📂 INFRA SCALEWAY",
    "commands": [
        { "name": "Bastion", "command": { "action": "runCommandline", "commandline": "ssh bastion-scw" } },
        { "name": "Server 1", "command": { "action": "runCommandline", "commandline": "ssh scw-1" } }
    ]
}
```

---

## 3. Productivité : Autocomplétion Intelligente

Pour obtenir le confort de Linux (touche `Tab` pour compléter les noms de serveurs), nous injectons un helper dans le profil PowerShell (`$PROFILE`).

### Script de complétion automatique

```powershell
# Helper pour lire les hôtes du fichier SSH Config
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

# Activation du mode Menu pour la touche Tab
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
try { Set-PSReadLineOption -PredictionSource History } catch { }
```

Pour activer ce script au démarrage, ajoutez-le dans votre fichier `$PROFILE` (généralement `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`).

---

## 4. Sécurité et Intégrité

### Gestion des Clés PEM

Windows exige des permissions strictes sur les fichiers `.pem`. Appliquez ces droits pour éviter l'erreur *"Unprotected Private Key"* :

```powershell
icacls "ma_cle.pem" /inheritance:r
icacls "ma_cle.pem" /grant:r "${env:UserName}:(R)"
```

### Politique d'exécution isolée

Pour autoriser le chargement de votre profil PowerShell sans abaisser la sécurité globale du système, configurez le profil dans `settings.json` avec `-ExecutionPolicy Bypass` (voir section 2). Cette approche est préférable à une modification globale de la politique via `Set-ExecutionPolicy`, car elle est limitée au terminal d'administration.

---

## Conclusion

Cette approche "Lean" garantit une infrastructure d'administration robuste, transportable et extrêmement rapide. En centralisant la logique dans `~/.ssh/config` et l'interface dans Windows Terminal, les ingénieurs de Syncheo disposent d'un outil de niveau professionnel parfaitement adapté aux exigences du Cloud moderne — sans dépendance tierce et sans coût de licence.
