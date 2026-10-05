---
title: "ReqIF: Wenn DOORS-Anhänge nach dem Import verschwinden"
date: 2026-07-30T10:00:00+02:00
draft: false
tags: ["ReqIF", "IBM DOORS", "DOORS Next", "Requirements Engineering", "ALM", "PowerShell", "Syncheo"]
categories: ["Technische Expertise"]
author: "Syncheo Engineering"
description: "Nach einem ReqIF-Export aus IBM DOORS werden eingebettete Bilder und OLE-Objekte im Zielwerkzeug nicht mehr angezeigt. Ursachenanalyse und ein PowerShell-Werkzeug, das jedem Anhang anhand seiner Binärsignatur die richtige Erweiterung zurückgibt."
banner: "img/blog/reqif-attachments-banner.png"
translationKey: "reqif-pieces-jointes-doors"
---

Sie exportieren ein Modul aus **IBM DOORS** oder **DOORS Next Generation** als **ReqIF** (`.reqifz`), importieren es in ein anderes Anforderungsmanagement-Werkzeug, und der Text kommt sauber an — doch die **eingebetteten Bilder und Objekte bleiben leer**. Das ist ein klassisches Problem des ReqIF-Austauschs, und die Ursache ist subtiler als bloße Werkzeug-Inkompatibilität. Dieser Artikel erklärt die Ursache des Problems und stellt ein einsatzbereites Werkzeug zu seiner Behebung bereit.

<!--more-->

## Kurz gefasst

Eine `.reqifz`-Datei ist ein ZIP-Archiv, das `Requirements.reqif` sowie sämtliche Anhänge enthält. DOORS speichert diese Anhänge **ohne Dateierweiterung** (ihre Namen sind GUIDs wie `_3dcc85d5-...`). Das Zielwerkzeug stützt sich auf die Erweiterung, um zu wissen, wie eine Datei dargestellt wird: Fehlt sie, zeigt es nichts an. Das hier vorgestellte Werkzeug — `change.bat` + `change.ps1` — erkennt den **echten Typ jedes Anhangs anhand seiner Binärsignatur**, stellt die korrekte Erweiterung wieder her, aktualisiert jede Referenz in `Requirements.reqif` und baut ein reimportierbares `.changed.reqifz`-Archiv neu auf.

---

## Das Problem

ReqIF (*Requirements Interchange Format*) ist ein OMG-Standard, der genau dafür konzipiert wurde, Anforderungen zwischen heterogenen Werkzeugen auszutauschen. In der Praxis funktioniert der Austausch des Textes gut; es sind die **eingebetteten Anhänge** — Screenshots, Diagramme, OLE-Objekte aus Word oder Excel — die beim Hin- und Rückweg DOORS ↔ anderes Werkzeug brechen.

Der Ablauf ist folgender: DOORS erzeugt ein `.reqifz`-Archiv, das das XML-Dokument `Requirements.reqif` samt der binären Anhangsdateien enthält. Diese Dateien sind nach einer eindeutigen Kennung (einer GUID) benannt **und tragen überhaupt keine Erweiterung**. Das importierende Werkzeug ermittelt die Darstellung einer Datei aus ihrer Erweiterung; ohne diese kann es nicht wissen, dass es sich um ein PNG oder ein PDF handelt, und zeigt nichts an.

## Warum es bricht

Drei Mechanismen wirken zusammen und führen zu diesem Ergebnis.

**Speicherung ohne Erweiterung.** Das ist die unmittelbare Ursache. DOORS exportiert Anhänge unter ihrem internen Namen (einer GUID), ohne Typ-Suffix. Ein striktes Zielwerkzeug rät den Typ nicht aus dem Inhalt und verlässt sich allein auf die Erweiterung — die nicht existiert.

**Vorschaubilder von OLE-Objekten.** Gemäß dem ReqIF-Standard wird ein Objekt, das kein Bild ist (eine Excel-Tabelle, ein Word-Dokument), in ein **Vorschaubild** eingehüllt. Man findet daher Dateipaare: eine Basisdatei mit der Deklaration `type="text/rtf"` und ihr `_<guid>_alternative_image.png` mit der Deklaration `type="image/png"`. Die Referenzen erfolgen im XML über `<object data="name" type="mime/type">`-Tags. Eine Exportoption von DOORS wandelt zudem manche OLE-Objekte in `.rtf` um, was die Vielfalt der vorhandenen Typen weiter erhöht.

**Der MIME-Typ ist nicht verlässlich.** Man könnte versucht sein, sich auf den im XML deklarierten `type` (MIME) zu stützen, um die Dateien umzubenennen. Das ist eine Falle. Bei einem realen Export von **461 Dateien** waren **55 (12 %) tatsächlich PNGs, aber von DOORS als `text/rtf` etikettiert** — bestätigt mit dem Werkzeug `file`. Diese Dateien nach ihrem MIME-Typ umzubenennen hätte sie in `.rtf` verwandelt und ihre Darstellung zerstört. Die **Binärsignatur (die Magic Bytes) ist die einzige Quelle der Wahrheit**; MIME dient nur als Rückfalloption für exotische Typen, die die Signatur nicht abdeckt.

## Die Lösung

Das Werkzeug besteht aus zwei Dateien, die im selben Ordner liegen müssen: `change.bat`, der Starter, und `change.ps1`, das die gesamte Logik enthält. Es arbeitet so: Es entpackt das Archiv, erkennt den echten Typ jedes Anhangs anhand seiner Binärsignatur (mit Rückfall auf MIME, wo nötig), benennt jede Datei mit der korrekten Erweiterung um **und** aktualisiert all ihre Referenzen in `Requirements.reqif` in einem einzigen Durchlauf, und baut dann ein `<name>.changed.reqifz`-Archiv neu auf, das zum Reimport bereit ist. Die Originaldatei wird nie verändert.

Zwei Implementierungsdetails verdienen Beachtung. Die Namensersetzung im XML ist **sicher gegenüber verschachtelten Namen**: Der Name einer Basisdatei wird nie innerhalb des längeren Namens ihres `_alternative_image.png`-Vorschaubilds verändert, und die Kodierung der `.reqif` bleibt durch byteweises Lesen/Schreiben erhalten. Zudem lädt der `.bat`-Starter den PowerShell-Code **in den Speicher**, was eine auf *Restricted* gesetzte `ExecutionPolicy` umgeht — das Werkzeug läuft also auch auf einer per Gruppenrichtlinie gesperrten Arbeitsstation.

### Verwendung

Aus einer Eingabeaufforderung, im Ordner mit der `.reqifz`:

```bat
change.bat "MeineDatei.reqifz"
```

Das Ergebnis ist eine Datei `MeineDatei.changed.reqifz`, die neben dem Original erstellt wird. Behalten Sie die Anführungszeichen, wenn der Pfad Leerzeichen enthält.

### Unterstützte Dateitypen

Die Erkennung umfasst Bilder (`png`, `jpg`, `gif`, `bmp`, `tif`, `emf`, `wmf`), Dokumente (`pdf`, `rtf`), neueres Office im OOXML-Format (`docx`, `xlsx`, `pptx`) und älteres Office im OLE-Format (`doc`, `xls`, `ppt`). Eine Datei, deren Typ nicht erkannt wird, bleibt unangetastet, statt blind eine Erweiterung zu erhalten. Beim realen Validierungsexport verarbeitete das Werkzeug den gesamten Satz ohne einen unerkannten Typ und ohne eingeführte Inkonsistenz; die Aktualisierung einer 15 MB großen `.reqif` dauerte etwa 0,3 Sekunden.

## Weitere Ansätze

Das Skript ist ein wirksamer Workaround, aber nicht der einzige Weg. Je nach Spielraum kann es besser sein, das Problem weiter stromaufwärts zu beheben.

| Ansatz | Prinzip | Wann bevorzugen |
|--------|---------|-----------------|
| **An der Quelle** | Die ReqIF-Exporteinstellungen von DOORS anpassen (insbesondere die Option zur OLE → RTF-Umwandlung), damit sie dem entsprechen, was das Zielwerkzeug lesen kann. | Sie beherrschen die DOORS-Exportkonfiguration und der Austausch ist wiederkehrend. |
| **Normkonformes Zielwerkzeug** | Einen Importeur verwenden, der den Standard einhält (Lesen des MIME-Typs und der Objektreferenzen), etwa ReqView, Polarion oder Jama (DX). | Die Wahl des Zielwerkzeugs ist noch offen oder sein Importeur ist konfigurierbar. |
| **Nachbearbeitungsskript** | Die Erweiterungen nach dem Export wiederherstellen, gestützt auf die Binärsignatur (das hier vorgestellte Werkzeug). | Export und Zielwerkzeug sind fixiert und es wird eine sofortige dateiseitige Lösung benötigt. |

Eine wichtige Einschränkung: Die **Dokumentation von Jama rät ausdrücklich davon ab**, die Erweiterungen von Anhängen umzubenennen. Das Skript bekennt sich daher zu seinem Status als Workaround, spezifisch für eine bestimmte Kombination aus DOORS-Export und Zielwerkzeug. Wenn Sie an der Quelle eingreifen oder einen konformen Importeur wählen können, sind diese Optionen nachhaltiger.

## Downloads

Die beiden Dateien des Werkzeugs samt seiner Dokumentation:

<a href="/downloads/change.bat" download><code>change.bat</code></a> — der Starter (auszuführen)<br>
<a href="/downloads/change.ps1" download><code>change.ps1</code></a> — die Erkennungs- und Wiederaufbaulogik<br>
<a href="/downloads/README.md" download><code>README.md</code></a> — vollständige Dokumentation (Voraussetzungen, Fehlerbehebung, technische Hinweise)

Bewahren Sie `change.bat` und `change.ps1` **im selben Ordner** auf. Voraussetzung: Windows mit PowerShell 5.0 oder höher (standardmäßig auf Windows 10/11 vorhanden).

### Dateiintegrität prüfen

Die **SHA-256**-Prüfsummen der beiden ausführbaren Dateien lauten:

| Datei | SHA-256 |
|-------|---------|
| `change.bat` | `ef05de15b35328d2acd35fca3fb93c8f1f2ab36b31cd3430ff3914523880530e` |
| `change.ps1` | `f46a785778785131d1fa8e006da2ced1c07ee7b61526e46532dd15df6e323706` |

Zur Prüfung einer heruntergeladenen Datei in PowerShell: `Get-FileHash .\change.ps1 -Algorithm SHA256`, anschließend den Wert vergleichen (Groß-/Kleinschreibung egal). Eine Prüfsummendatei (<a href="/downloads/CHECKSUMS.txt" download><code>CHECKSUMS.txt</code></a>) steht ebenfalls bereit.

**Um jedes Kompromittierungsrisiko auszuschließen**: Auf derselben Website wie die Dateien veröffentlichte Prüfsummen schützen nicht, falls die Website selbst kompromittiert wäre. Die Referenz-Prüfsummen, die offline auf unserem Rechner aufbewahrt werden, erhalten Sie daher über [Kontakt](/de/contact): Wir senden sie Ihnen über einen separaten Kanal zu.

## Quellen

- [Why OLE object is not visible after importing ReqIF file into DOORS — jazz.net](https://jazz.net/forum/questions/241237/why-ole-object-is-not-visible-after-importing-reqif-file-in-to-doors)
- [ReqIF roundtrip to DOORS NG — problem with images — reqif.academy](https://www.reqif.academy/forums/topic/reqif-roundtrip-to-doors-ng-problem-with-images/)
- [ReqIF export without images — jazz.net](https://jazz.net/forum/questions/266492/reqif-export-without-images)
- [Handling OLEs and RTF Files in DX Imports from DOORS to Jama — Jama Software](https://support.jamasoftware.com/hc/en-us/articles/34970364995213-Handling-OLEs-and-RTF-Files-in-DX-Imports-from-DOORS-to-Jama)
- [ReqIF Import/Export — Polarion](https://qademo.polarion.com/polarion/help/topic/com.polarion.xray.doc.user/ugDocsReqIfImportExport.html)
- [Import ReqIF — ReqView](https://www.reqview.com/doc/import-reqif/)
- [Requirements Interchange Format — Wikipedia](https://en.wikipedia.org/wiki/Requirements_Interchange_Format)
