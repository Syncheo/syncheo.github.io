---
title: "Status History Presentation — IBM EWM / Jazz Widget"
subtitle: "Die Statushistorie eines Work Items als Zeitleiste visualisieren"
description: "Open-Source-Widget (jazz-community), das Syncheo auf GitHub aufgegriffen und für eine einfache Installation auf den neuesten Jazz-Versionen neu verpackt hat: die Statusentwicklung eines Work Items grafisch dargestellt, direkt im Editor."
date: 2026-09-07T10:00:00+02:00
draft: false
slug: "status-history-presentation"
tags: ["IBM EWM", "ELM", "Jazz", "Work Items", "Open Source", "Historie"]
author: "Syncheo Engineering"
summary: "Ein Open-Source-Widget aus der Jazz-Community, von Syncheo auf GitHub aufgegriffen und neu verpackt, damit es sich einfach auf den neuesten IBM-Jazz-Versionen installieren lässt. Es zeigt die Statushistorie eines Work Items als Zeitleiste, direkt im Editor."
banner: "img/banners/status-history-banner.png"
translationKey: "status-history-presentation"
aliases: ["/de/portfolio/status-history-presentation/"]
---

IBM Engineering Workflow Management (EWM / RTC) speichert die vollständige Historie eines Work Items, aber bei Tickets mit vielen Änderungen wird es sehr schwierig, den **Statusverlauf über die Zeit nachzuvollziehen**. **Status History Presentation** ist ein Open-Source-Widget aus der Jazz-Community, das genau diesen Bedarf abdeckt: Syncheo hat es **auf GitHub aufgegriffen und neu verpackt**, damit es sich einfach auf den neuesten IBM-Jazz-Versionen installieren lässt. Es zeigt direkt im Work-Item-Editor eine **Zeitleiste** der Statuswechsel an.

## Das Problem

Die native Historie eines Work Items vermischt alle geänderten Attribute — Zusammenfassung, Owner, Schätzung, Kommentare — über sämtliche Speichervorgänge hinweg. Um eine so einfache Frage zu beantworten wie „Wann ist dieses Ticket auf *In Bearbeitung* gewechselt, und wie lange blieb es *In Prüfung*?", muss man Dutzende von Zeilen durchgehen und die Chronologie im Kopf rekonstruieren. Bei einem Work Item, das über mehrere Monate lebt, ist das mühsam und fehleranfällig.

## Eine Zeitleiste, zwei Lesarten

Das Widget berücksichtigt nur die Statuswechsel: Jede Phase im Leben des Tickets wird zu einem Punkt auf einer Zeitachse, von der Erstellung bis zum aktuellen Zustand. Auf einen Blick ist erkennbar, welche Zustände das Work Item durchlaufen hat, in welcher Reihenfolge und wann. Alles wird als SVG gerendert und bleibt bei jedem Zoomniveau gestochen scharf. Je nach Schwerpunkt stehen zwei Anzeigemodi zur Verfügung.

### USER-Modus — die Mitwirkenden im Fokus

<figure class="post-figure post-figure--right post-figure--narrow">
  <img src="/img/portfolio/status-history-user.png" alt="Status History im USER-Modus: Avatare der Mitwirkenden auf der Zeitleiste">
  <figcaption>Modus <code>timeline=USER</code>: der Avatar jedes Mitwirkenden auf der Zeitleiste.</figcaption>
</figure>

Im USER-Modus (`timeline=USER`), der Standardeinstellung, zeigt jeder Punkt der Zeitleiste das Profilbild der Person, die die Änderung vorgenommen hat. Die zugehörige Karte nennt Datum und erreichten Status — *In Bearbeitung*, *Neu* und so weiter. Die ideale Lesart, um auf einen Blick zu sehen, **wer** das Ticket vorangebracht hat und **wann**, ohne die vollständige Historie zu öffnen.

### STATUS-Modus — die Übergänge im Fokus

<figure class="post-figure post-figure--left post-figure--narrow">
  <img src="/img/portfolio/status-history-status.png" alt="Status History im STATUS-Modus: Status-Icons auf der Zeitleiste">
  <figcaption>Modus <code>timeline=STATUS</code>: das Icon jedes Status auf der Zeitleiste.</figcaption>
</figure>

Im STATUS-Modus (`timeline=STATUS`) übernehmen die Status-Icons die Zeitleiste, während die Karte hervorhebt, wer die Änderung vorgenommen hat. Der Fokus verlagert sich auf die **Übergänge selbst**: Man verfolgt den Weg des Tickets durch seine aufeinanderfolgenden Zustände, die Information über die Personen tritt in den Hintergrund.

## Detaillierte Historie beim Hover

Die Option `enableDetailedHistory` steuert, wie viele Details beim Überfahren eines Punktes der Zeitleiste erscheinen.

### Detailansicht (`enableDetailedHistory = true`)

<figure class="post-figure post-figure--right">
  <img src="/img/portfolio/status-history-detailed.png" alt="Detaillierter Tooltip mit aktiviertem enableDetailedHistory">
  <figcaption>Vollständiger Tooltip: alle Attribute des Work Items zu diesem Zeitpunkt seiner Historie.</figcaption>
</figure>

Aktiviert, öffnet sich beim Hover ein vollständiger Tooltip mit allen Attributen des Work Items, wie sie zu diesem genauen Zeitpunkt seiner Historie waren: Zusammenfassung, Beschreibung, Typ, Schweregrad, Priorität, Planung, ID, Abonnenten… Ein vollständiger Schnappschuss, ohne den Editor zu verlassen — nützlich, um den genauen Kontext eines Statuswechsels zu verstehen.

### Kompaktansicht (`enableDetailedHistory = false`)

<figure class="post-figure post-figure--left">
  <img src="/img/portfolio/status-history-not-detailed.png" alt="Kompakter Tooltip mit deaktiviertem enableDetailedHistory">
  <figcaption>Kompakter Tooltip: Autor, Datum und Status.</figcaption>
</figure>

Deaktiviert, beschränkt sich der Hover auf einen kompakten Tooltip: Autor, Datum und erreichter Status. Der richtige Kompromiss, wenn Lesbarkeit und Performance im Vordergrund stehen, besonders bei Work Items mit sehr umfangreicher Historie.

Weitere Komfortoptionen runden das Ganze ab, etwa größere Icons oder ein Fälligkeitsindikator (`soonDays`), der nahende Termine per Farbcode kennzeichnet. Technisch handelt es sich um eine *Non-Attribute-based Presentation*: einen Abschnitt, den man über die Administration des Projektbereichs zur Editor-Konfiguration hinzufügt (Work Items → Editor Presentations), ohne serverseitige Entwicklung.

## Vereinfachte Installation durch Syncheo

Das ursprüngliche Projekt war zunächst ab RTC 6.0.3 verifiziert. Syncheo hat es als sofort einsetzbare Update-Site neu verpackt, abgestimmt auf die **neuesten Versionen der IBM-Jazz-Plattform**: kein Neu-Build und keine Anpassung an aktuelle Versionen mehr nötig — die Installation erfolgt direkt.

## Herkunft und Lizenz

Status History Presentation ist ein Open-Source-Projekt der **[jazz-community](https://github.com/jazz-community/rtc-statushistory-presentation)**, veröffentlicht unter der **MIT-Lizenz** (© **Siemens AG**); es bindet das Kalender-Icon von Font Awesome ein (CC BY 4.0). Der Beitrag von Syncheo besteht im Repackaging und der Anpassung an die neuesten Jazz-Versionen, unter Einhaltung dieser Lizenz.

## Kompatibilität

Das Widget richtet sich an **IBM Engineering Workflow Management (EWM / RTC)** auf aktuellen Jazz-Plattformen. Es läuft in allen modernen von EWM unterstützten Browsern: Chrome, Edge, Firefox.

## Das Original-Repository

Das ursprüngliche Open-Source-Projekt ist auf GitHub verfügbar: [jazz-community/rtc-statushistory-presentation](https://github.com/jazz-community/rtc-statushistory-presentation).
