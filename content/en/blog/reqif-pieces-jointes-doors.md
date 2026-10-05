---
title: "ReqIF: When DOORS Attachments Vanish After Import"
date: 2026-07-30T10:00:00+02:00
draft: false
tags: ["ReqIF", "IBM DOORS", "DOORS Next", "Requirements Engineering", "ALM", "PowerShell", "Syncheo"]
categories: ["Technical Expertise"]
author: "Syncheo Engineering"
description: "After a ReqIF export from IBM DOORS, embedded images and OLE objects no longer display in the target tool. Root-cause analysis and a PowerShell utility that restores the correct extension to each attachment based on its binary signature."
banner: "img/blog/reqif-attachments-banner.png"
translationKey: "reqif-pieces-jointes-doors"
---

You export a module from **IBM DOORS** or **DOORS Next Generation** as **ReqIF** (`.reqifz`), import it into another requirements management tool, and the text comes through fine — but the **embedded images and objects stay blank**. This is a classic ReqIF interchange issue, and the cause is subtler than mere tool incompatibility. This article explains the cause of the problem and offers a ready-to-use utility to fix it.

<!--more-->

## In short

A `.reqifz` file is a ZIP archive containing `Requirements.reqif` plus all the attachments. DOORS stores those attachments **without a file extension** (their names are GUIDs such as `_3dcc85d5-...`). The target tool relies on the extension to know how to render a file: with none, it displays nothing. The utility presented here — `change.bat` + `change.ps1` — detects the **real type of each attachment from its binary signature**, restores the correct extension, updates every reference inside `Requirements.reqif`, and rebuilds a re-importable `.changed.reqifz` archive.

---

## The problem

ReqIF (*Requirements Interchange Format*) is an OMG standard designed precisely to exchange requirements between heterogeneous tools. In practice, exchanging the text works well; it is the **embedded attachments** — screenshots, diagrams, OLE objects from Word or Excel — that break during a DOORS ↔ other-tool round trip.

The flow is as follows: DOORS produces a `.reqifz` archive containing the `Requirements.reqif` XML document alongside the binary attachment files. Those files are named after a unique identifier (a GUID) **and carry no extension whatsoever**. The importing tool determines how to render a file from its extension; without one, it has no way to know the file is a PNG or a PDF, and shows nothing.

## Why it breaks

Three mechanisms combine to produce this outcome.

**Storage without an extension.** This is the immediate cause. DOORS exports attachments under their internal name (a GUID), with no type suffix. A strict target tool will not guess the type from the content and relies solely on the extension — which does not exist.

**OLE object previews.** In line with the ReqIF standard, an object that is not an image (an Excel table, a Word document) is wrapped in a **preview image**. You therefore find pairs of files: a base file declared `type="text/rtf"` and its `_<guid>_alternative_image.png` declared `type="image/png"`. References are made in the XML through `<object data="name" type="mime/type">` tags. A DOORS export option also converts some OLE objects to `.rtf`, which adds further variety to the types present.

**The MIME type is not trustworthy.** One might be tempted to rely on the `type` MIME declared in the XML to rename the files. That is a trap. On a real export of **461 files**, **55 (12%) were actually PNGs but labelled `text/rtf`** by DOORS — confirmed with the `file` tool. Renaming those files by their MIME would have turned them into `.rtf` and broken their display. The **binary signature (the magic bytes) is the only source of truth**; MIME serves only as a fallback for exotic types the signature does not cover.

## The solution

The utility comes down to two files that must sit in the same folder: `change.bat`, the launcher, and `change.ps1`, which holds all the logic. It works as follows: it extracts the archive, detects the real type of each attachment from its binary signature (falling back to MIME where needed), renames each file with the correct extension **and** updates all its references inside `Requirements.reqif` in a single pass, then rebuilds a `<name>.changed.reqifz` archive ready for re-import. The original file is never modified.

Two implementation details are worth highlighting. Name replacement in the XML is **safe against nested names**: a base file's name is never altered inside the longer name of its `_alternative_image.png` preview, and the `.reqif` encoding is preserved through byte-for-byte read/write. Furthermore, the `.bat` launcher loads the PowerShell code **in memory**, which bypasses an `ExecutionPolicy` set to *Restricted* — so the utility runs even on a workstation locked down by group policy.

### Usage

From a command prompt, in the folder containing the `.reqifz`:

```bat
change.bat "MyFile.reqifz"
```

The result is a `MyFile.changed.reqifz` file created next to the original. Keep the quotes if the path contains spaces.

### Supported file types

Detection covers images (`png`, `jpg`, `gif`, `bmp`, `tif`, `emf`, `wmf`), documents (`pdf`, `rtf`), recent Office in OOXML format (`docx`, `xlsx`, `pptx`) and legacy Office in OLE format (`doc`, `xls`, `ppt`). A file whose type is not recognised is left untouched rather than being given an extension blindly. On the real validation export, the utility processed the whole set with no unrecognised type and no inconsistency introduced, updating a 15 MB `.reqif` in roughly 0.3 seconds.

## Other approaches

The script is an effective workaround, but it is not the only path. Depending on your leeway, fixing the problem further upstream may be preferable.

| Approach | Principle | When to prefer it |
|----------|-----------|-------------------|
| **At the source** | Adjust the DOORS ReqIF export settings (notably the OLE → RTF conversion option) to match what the target tool can read. | You control the DOORS export configuration and the exchange is recurring. |
| **Standards-compliant target tool** | Use an importer that honours the standard (reading the MIME type and object references), such as ReqView, Polarion or Jama (DX). | The choice of target tool is still open, or its importer is configurable. |
| **Post-processing script** | Restore the extensions after export, relying on the binary signature (the utility presented here). | The export and target tool are fixed and an immediate file-side fix is needed. |

One important caveat: **Jama's documentation explicitly advises against renaming** attachment extensions. The script therefore owns its status as a workaround, specific to a given DOORS export / target-tool pairing. If you can act at the source or choose a compliant importer, those options are more durable.

## Downloads

The two files of the utility, together with its documentation:

<a href="/downloads/change.bat" download><code>change.bat</code></a> — the launcher (the one to run)<br>
<a href="/downloads/change.ps1" download><code>change.ps1</code></a> — the detection and rebuild logic<br>
<a href="/downloads/README.md" download><code>README.md</code></a> — full documentation (prerequisites, troubleshooting, technical notes)

Keep `change.bat` and `change.ps1` **in the same folder**. Prerequisite: Windows with PowerShell 5.0 or later (present by default on Windows 10/11).

### Verify file integrity

The **SHA-256** checksums of the two executable files are:

| File | SHA-256 |
|------|---------|
| `change.bat` | `ef05de15b35328d2acd35fca3fb93c8f1f2ab36b31cd3430ff3914523880530e` |
| `change.ps1` | `f46a785778785131d1fa8e006da2ced1c07ee7b61526e46532dd15df6e323706` |

To verify a downloaded file, in PowerShell: `Get-FileHash .\change.ps1 -Algorithm SHA256`, then compare the result (case-insensitive). A checksums file (<a href="/downloads/CHECKSUMS.txt" download><code>CHECKSUMS.txt</code></a>) is also available.

**To rule out any risk of compromise**: checksums published on the same site as the files offer no protection if that site were itself compromised. You can therefore obtain the reference checksums, kept offline on our own computer, by clicking [Contact us](/en/contact): we will send them to you through a separate channel.

## Sources

- [Why OLE object is not visible after importing ReqIF file into DOORS — jazz.net](https://jazz.net/forum/questions/241237/why-ole-object-is-not-visible-after-importing-reqif-file-in-to-doors)
- [ReqIF roundtrip to DOORS NG — problem with images — reqif.academy](https://www.reqif.academy/forums/topic/reqif-roundtrip-to-doors-ng-problem-with-images/)
- [ReqIF export without images — jazz.net](https://jazz.net/forum/questions/266492/reqif-export-without-images)
- [Handling OLEs and RTF Files in DX Imports from DOORS to Jama — Jama Software](https://support.jamasoftware.com/hc/en-us/articles/34970364995213-Handling-OLEs-and-RTF-Files-in-DX-Imports-from-DOORS-to-Jama)
- [ReqIF Import/Export — Polarion](https://qademo.polarion.com/polarion/help/topic/com.polarion.xray.doc.user/ugDocsReqIfImportExport.html)
- [Import ReqIF — ReqView](https://www.reqview.com/doc/import-reqif/)
- [Requirements Interchange Format — Wikipedia](https://en.wikipedia.org/wiki/Requirements_Interchange_Format)
