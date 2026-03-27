---
title: "Modernising System Administration: Managing Jazz and Scaleway on Windows"
date: 2026-03-23T14:30:00+01:00
draft: false
tags: ["Windows Terminal", "SSH", "Jazz", "DevOps", "Syncheo"]
categories: ["Technical Expertise"]
author: "Syncheo Engineering"
description: "A complete guide to moving from mRemoteNG to a high-performance native Windows stack: Windows Terminal, OpenSSH and PowerShell."
banner: "img/blog/admin-jazz-windows-banner.png"
translationKey: "admin-jazz-windows"
---

Administering critical platforms like **Jazz** (CORS management, EWM widget deployment, **DB2** database maintenance) demands a responsive interface and smooth handling of secure data flows. At **Syncheo**, we migrated from heavy third-party tools like mRemoteNG to a 100% native Windows stack.

<!--more-->

This guide details how to transform your Windows environment into an optimised, free and secure DevOps workstation.

---

## 1. Standardised Connectivity: OpenSSH & Bastion

Using the native Windows SSH client eliminates dependency on proprietary formats (such as PuTTY's `.ppk`). We centralise all configuration in `%USERPROFILE%\.ssh\config`.

### Architecture with Jump Server (Bastion)

To access isolated servers, we use a bastion on port **2222**. The `ProxyJump` directive makes this hop completely transparent for the user.

```text
# Bastion definition
Host bastion-scw
    HostName <BASTION_IP>
    User bastion
    Port 2222
    IdentityFile C:\Users\<YourUser>\Keys\bastion.pem

# Jazz main server via Bastion
Host jazz-prod
    HostName <JAZZ_IP>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<YourUser>\Keys\jazz_prod.pem

# DB2 instance via Bastion
Host jazz-db2
    HostName <DB2_IP>
    User root
    ProxyJump bastion-scw
    IdentityFile C:\Users\<YourUser>\Keys\db2_key.pem
```

With this configuration, the command `ssh jazz-prod` automatically tunnels through the bastion with no additional setup. The `ProxyJump` option handles the tunnel natively and securely.

---

## 2. Windows Terminal: Context-Based Organisation

To replace mRemoteNG's folder tree, we use the **Command Palette** (`Ctrl+Shift+P`) in Windows Terminal. This enables a much faster "Search-first" navigation experience.

### Configuration file location

The `settings.json` file is accessible directly from Windows Terminal via `Settings → Open JSON file`, or at the following path:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### Profile configuration (settings.json)

Add a dedicated profile under `"profiles" > "list"` to get a PowerShell profile with script execution enabled:

```json
{
    "guid": "{your-unique-guid}",
    "name": "PowerShell Jazz Admin",
    "commandline": "powershell.exe -ExecutionPolicy Bypass -NoLogo",
    "startingDirectory": "%USERPROFILE%",
    "hidden": false
}
```

### Action configuration (settings.json)

Add this block to the `"actions": [...]` section to create virtual dropdown menus accessible via the Command Palette:

```json
{
    "name": "📂 JAZZ PROJECT",
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

## 3. Productivity: Intelligent Autocomplete

To get Linux-like comfort (`Tab` key to complete server names), we inject a helper into the PowerShell profile (`$PROFILE`).

### Autocomplete script

```powershell
# Helper to read hosts from SSH Config file
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

# Enable Menu mode for the Tab key
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
try { Set-PSReadLineOption -PredictionSource History } catch { }
```

To activate this script at startup, add it to your `$PROFILE` file (typically `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`).

---

## 4. Security and Integrity

### PEM Key Management

Windows enforces strict permissions on `.pem` files. Apply the following rights to avoid the *"Unprotected Private Key"* error:

```powershell
icacls "my_key.pem" /inheritance:r
icacls "my_key.pem" /grant:r "${env:UserName}:(R)"
```

### Isolated execution policy

To allow loading your PowerShell profile without lowering the system's overall security, configure the profile in `settings.json` with `-ExecutionPolicy Bypass` (see section 2). This approach is preferable to a global policy change via `Set-ExecutionPolicy`, as it is scoped to the administration terminal only.

---

## Conclusion

This "Lean" approach guarantees a robust, portable and extremely fast administration infrastructure. By centralising logic in `~/.ssh/config` and the interface in Windows Terminal, Syncheo engineers have a professional-grade tool perfectly suited to modern Cloud requirements — with no third-party dependency and no licence cost.
