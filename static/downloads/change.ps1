<#
    ==========================================================================
    Copyright (c) 2026 Syncheo SAS (www.syncheo.tech)

    Logiciel open source distribue sous licence MIT.

    Permission est accordee, gracieusement, a toute personne obtenant une copie
    de ce logiciel et des fichiers associes, d'utiliser, copier, modifier,
    fusionner, publier, distribuer et/ou vendre des copies du logiciel, sous
    reserve de CONSERVER DANS TOUTES LES COPIES la presente notice de propriete
    et la presente clause de non-responsabilite.

    LE LOGICIEL EST FOURNI "EN L'ETAT", SANS GARANTIE D'AUCUNE SORTE, EXPRESSE
    OU IMPLICITE. EN AUCUN CAS SYNCHEO SAS NE POURRA ETRE TENUE RESPONSABLE DE
    TOUT DOMMAGE OU AUTRE RESPONSABILITE LIE A L'UTILISATION DU LOGICIEL.
    ==========================================================================

    change.ps1 - Transforme un export ReqIF (.reqifz).

    Pour chaque piece jointe de l'archive, detecte le vrai type de fichier via
    sa signature ("magic bytes") et lui applique la bonne extension, a la fois
    sur le fichier ET dans les references de Requirements.reqif. Reconstruit
    ensuite un <nom>.changed.reqifz pret a etre reimporte.

    Concu pour traiter efficacement des centaines de fichiers (une seule passe).

    Usage :
      powershell -NoProfile -ExecutionPolicy Bypass -File change.ps1 "MonFichier.reqifz"

    Types detectes : png, jpg, gif, bmp, tif, pdf, emf, wmf, rtf,
                     docx/xlsx/pptx (OOXML) et doc/xls/ppt (OLE legacy).
#>
param([Parameter(Mandatory = $true)][string]$ReqifzFile)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

# ============================ Detection de type =============================

# Office "legacy" (OLE compound) : distingue doc / xls / ppt.
# Heuristique : les noms de flux internes sont en UTF-16LE ; on les cherche
# dans le debut du fichier (max 64 Ko).
function Get-OleKind {
    param([string]$Path)
    $size = (Get-Item -LiteralPath $Path).Length
    $len  = [Math]::Min(65536, $size)
    $buf  = New-Object byte[] $len
    $fs   = [IO.File]::OpenRead($Path)
    try { [void]$fs.Read($buf, 0, $len) } finally { $fs.Close() }
    $u = [Text.Encoding]::Unicode.GetString($buf)
    if ($u -like '*WordDocument*')        { return 'doc' }
    if ($u -like '*PowerPoint Document*') { return 'ppt' }
    if ($u -like '*Workbook*' -or $u -like '*Book*') { return 'xls' }
    return ''   # OLE inconnu -> on n'y touche pas
}

function Get-FileKind {
    param([string]$Path)
    $fs = [IO.File]::OpenRead($Path)
    try { $b = New-Object byte[] 44; $n = $fs.Read($b, 0, 44) } finally { $fs.Close() }

    if ($n -ge 4  -and $b[0] -eq 137 -and $b[1] -eq 80  -and $b[2] -eq 78  -and $b[3] -eq 71) { return 'png' }
    if ($n -ge 3  -and $b[0] -eq 255 -and $b[1] -eq 216 -and $b[2] -eq 255) { return 'jpg' }
    if ($n -ge 4  -and $b[0] -eq 71  -and $b[1] -eq 73  -and $b[2] -eq 70  -and $b[3] -eq 56) { return 'gif' }
    if ($n -ge 2  -and $b[0] -eq 66  -and $b[1] -eq 77) { return 'bmp' }
    if ($n -ge 4  -and (($b[0] -eq 73 -and $b[1] -eq 73 -and $b[2] -eq 42 -and $b[3] -eq 0) -or ($b[0] -eq 77 -and $b[1] -eq 77 -and $b[2] -eq 0 -and $b[3] -eq 42))) { return 'tif' }
    if ($n -ge 4  -and $b[0] -eq 37  -and $b[1] -eq 80  -and $b[2] -eq 68  -and $b[3] -eq 70) { return 'pdf' }
    if ($n -ge 5  -and $b[0] -eq 123 -and $b[1] -eq 92  -and $b[2] -eq 114 -and $b[3] -eq 116 -and $b[4] -eq 102) { return 'rtf' }  # {\rtf
    if ($n -ge 44 -and $b[0] -eq 1 -and $b[1] -eq 0 -and $b[2] -eq 0 -and $b[3] -eq 0 -and $b[40] -eq 32 -and $b[41] -eq 69 -and $b[42] -eq 77 -and $b[43] -eq 70) { return 'emf' }
    if ($n -ge 4  -and (($b[0] -eq 215 -and $b[1] -eq 205 -and $b[2] -eq 198 -and $b[3] -eq 154) -or ($b[0] -eq 1 -and $b[1] -eq 0 -and $b[2] -eq 9 -and $b[3] -eq 0))) { return 'wmf' }

    # OOXML / ZIP : PK\x03\x04 -> on ouvre l'archive pour distinguer les formats Office
    if ($n -ge 4 -and $b[0] -eq 80 -and $b[1] -eq 75 -and $b[2] -eq 3 -and $b[3] -eq 4) {
        try {
            $zip = [IO.Compression.ZipFile]::OpenRead($Path)
            try {
                $names = @($zip.Entries.FullName)
                if     ($names -match '^word/') { return 'docx' }
                elseif ($names -match '^xl/')   { return 'xlsx' }
                elseif ($names -match '^ppt/')  { return 'pptx' }
                else                            { return 'zip'  }
            } finally { $zip.Dispose() }
        } catch { return 'zip' }
    }

    # OLE compound (Office legacy) : D0 CF 11 E0 A1 B1 1A E1
    if ($n -ge 8 -and $b[0] -eq 208 -and $b[1] -eq 207 -and $b[2] -eq 17 -and $b[3] -eq 224 -and $b[4] -eq 161 -and $b[5] -eq 177 -and $b[6] -eq 26 -and $b[7] -eq 225) {
        return (Get-OleKind -Path $Path)
    }

    return ''   # type non reconnu
}

# ============================ Validation ===================================
if (-not (Test-Path -LiteralPath $ReqifzFile -PathType Leaf)) {
    Write-Error "Fichier introuvable : '$ReqifzFile'"
    exit 1
}
$src = (Resolve-Path -LiteralPath $ReqifzFile).Path
if ([IO.Path]::GetExtension($src).ToLower() -ne '.reqifz') {
    Write-Warning "Extension attendue : .reqifz (recu : '$src'). On continue quand meme."
}

$dir           = Split-Path -Parent $src
$base          = [IO.Path]::GetFileNameWithoutExtension($src)
$folder        = Join-Path $dir $base
$zip           = Join-Path $dir "$base.zip"
$changedZip    = Join-Path $dir "$base.changed.zip"
$changedReqifz = Join-Path $dir "$base.changed.reqifz"

# ============================ 1. Extraction ================================
Write-Host "Extraction : $src"
Copy-Item -LiteralPath $src -Destination $zip -Force
if (Test-Path -LiteralPath $folder) { Remove-Item -LiteralPath $folder -Recurse -Force }
Expand-Archive -LiteralPath $zip -DestinationPath $folder -Force
Remove-Item -LiteralPath $zip -Force

# ============ 2. Detection + renommage + mise a jour du reqif ==============
# Recherche dynamique du fichier .reqif dans l'archive extraite
$reqifFileItem = Get-ChildItem -LiteralPath $folder -Filter "*.reqif" -File | Select-Object -First 1

if (-not $reqifFileItem) {
    Write-Error "Aucun fichier .reqif n'a été trouvé dans le dossier '$folder'."
    exit 1
}

$reqifPath = $reqifFileItem.FullName
Write-Host ("Fichier ReqIF identifié : {0}" -f $reqifFileItem.Name)

# Lecture octet-par-octet (Latin1 = mapping 1:1) pour ne pas alterer l'encodage.
$latin1 = [Text.Encoding]::GetEncoding(28591)
$text   = $latin1.GetString([IO.File]::ReadAllBytes($reqifPath))

# Table MIME -> extension. Utilisee UNIQUEMENT en repli quand la signature du
# fichier ne permet pas de trancher. NB : le type MIME declare par DOORS n'est
# PAS fiable (on a observe des PNG etiquetes "text/rtf") -- la signature binaire
# reste donc la source de verite ; le MIME ne sert qu'a rattraper les types
# exotiques que la signature ne reconnait pas.
$mimeExt = @{
    'image/png' = 'png'; 'image/jpeg' = 'jpg'; 'image/jpg' = 'jpg'; 'image/gif' = 'gif'
    'image/bmp' = 'bmp'; 'image/tiff' = 'tif'; 'image/tif' = 'tif'; 'application/pdf' = 'pdf'
    'text/rtf'  = 'rtf'; 'application/rtf' = 'rtf'; 'application/msword' = 'doc'
    'application/vnd.ms-excel' = 'xls'; 'application/vnd.ms-powerpoint' = 'ppt'
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'   = 'docx'
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'         = 'xlsx'
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' = 'pptx'
    'image/x-emf' = 'emf'; 'image/emf' = 'emf'; 'image/x-wmf' = 'wmf'; 'image/wmf' = 'wmf'
}
# MIME declare par le reqif pour chaque piece jointe (premiere occurrence).
$mimeOf = @{}
foreach ($m in [regex]::Matches($text, 'data="([^"]+)"\s+type="([^"]+)"')) {
    $nm = $m.Groups[1].Value
    if (-not $mimeOf.ContainsKey($nm)) { $mimeOf[$nm] = $m.Groups[2].Value }
}

$files = @(Get-ChildItem -LiteralPath $folder -Recurse -File |
           Where-Object { $_.Name -ne 'Requirements.reqif' -and @('.reqif', '.reqifz') -notcontains $_.Extension.ToLower() })

# 2a. Detection : table "nom actuel" -> "nom avec la bonne extension".
$map = @{}
$skipped  = 0
$byMime   = 0
foreach ($f in $files) {
    # 1) Signature binaire (source de verite).
    $ext = Get-FileKind -Path $f.FullName
    # 2) Repli MIME uniquement si la signature n'a rien donne.
    if ([string]::IsNullOrEmpty($ext) -and $mimeOf.ContainsKey($f.Name)) {
        $mt = $mimeOf[$f.Name]
        if ($mimeExt.ContainsKey($mt)) { $ext = $mimeExt[$mt]; $byMime++ }
    }
    if ([string]::IsNullOrEmpty($ext)) {
        Write-Host ("  ignore (type non reconnu) : {0}" -f $f.Name)
        $skipped++
        continue
    }
    # Deja la bonne extension -> rien a faire.
    if ($f.Extension.TrimStart('.').ToLower() -eq $ext) { continue }
    $map[$f.Name] = "$($f.Name).$ext"
}

# 2b. Mise a jour des references dans Requirements.reqif, en UNE SEULE passe.
#   * Une regex alternee de tous les noms -> O(taille du fichier), rapide meme
#     sur un reqif de plusieurs Mo avec des centaines de pieces jointes.
#   * Les frontieres (?<!...) / (?!...) couvrent TOUTE la classe des caracteres
#     de nom (lettres, chiffres, _ . -). Un nom n'est donc jamais remplace a
#     l'interieur d'un nom plus long -- ex. le prefixe RTF ne doit PAS etre
#     modifie dans "<guid>_alternative_image.png".
if ($map.Count -gt 0) {
    $fn  = 'A-Za-z0-9_.\-'
    $alt = ($map.Keys | Sort-Object { $_.Length } -Descending | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $rx  = [regex]"(?<![$fn])(?:$alt)(?![$fn])"
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
        param($m)
        if ($map.ContainsKey($m.Value)) { $map[$m.Value] } else { $m.Value }
    }
    $text = $rx.Replace($text, $evaluator)
    [IO.File]::WriteAllBytes($reqifPath, $latin1.GetBytes($text))
}

# ================= 2b-bis. Correction schéma XHTML (blockquote) ==============
# Dans le schéma XHTML ReqIF, <blockquote> ne peut contenir que des éléments
# de type bloc (<p>, <div>, etc.). Tout contenu direct non-bloc doit être encapsulé dans un <p>.

$patternBlockquote = '(?is)<(?<ns>[a-z0-9_-]+:)?blockquote(?<attr>[^>]*)>(?!\s*<\k<ns>?(?:p|div|h[1-6]|ul|ol)\b)(?<content>.*?)</\k<ns>?blockquote>'

$evalBlockquote = [System.Text.RegularExpressions.MatchEvaluator]{
    param($m)
    $ns = $m.Groups['ns'].Value
    $attr = $m.Groups['attr'].Value
    $inner = $m.Groups['content'].Value

    # Encapsule le contenu direct dans un paragraphe <p>
    "<$($ns)blockquote$attr><$($ns)p>$inner</$($ns)p></$($ns)blockquote>"
}

$text = [regex]::Replace($text, $patternBlockquote, $evalBlockquote)

# Sauvegarde systématique dans le fichier .reqif détecté
[IO.File]::WriteAllBytes($reqifPath, $latin1.GetBytes($text))


# 2c. Renommage physique des fichiers concernes.
foreach ($f in $files) {
    if ($map.ContainsKey($f.Name)) {
        Rename-Item -LiteralPath $f.FullName -NewName $map[$f.Name] -Force
        Write-Host ("  {0} -> {1}" -f $f.Name, $map[$f.Name])
    }
}

Write-Host ("Detection : {0} fichier(s) renomme(s), {1} ignore(s), {2} via repli MIME." -f $map.Count, $skipped, $byMime)

# ======================= 3. Reconstruction de l'archive ====================
if (Test-Path -LiteralPath $changedReqifz) { Remove-Item -LiteralPath $changedReqifz -Force }
if (Test-Path -LiteralPath $changedZip)    { Remove-Item -LiteralPath $changedZip -Force }
Compress-Archive -Path (Join-Path $folder '*') -DestinationPath $changedZip -Force
Move-Item -LiteralPath $changedZip -Destination $changedReqifz -Force

Write-Host "Termine. Archive generee : $changedReqifz"
