---
title: "Syncheo Connect — XWiki ↔ IBM Jazz Konnektor (OSLC)"
subtitle: "Verbinden Sie Ihre XWiki-Seiten nativ mit den Engineering-Artefakten von IBM Jazz — über den OSLC-Standard"
date: 2026-08-26T10:00:00+01:00
draft: false
author: "Syncheo"
description: "Ein nativer OSLC-Konnektor zwischen XWiki und IBM Jazz (ELM): Erstellen Sie Traceability-Links zwischen Ihren Dokumentationsseiten und Ihren Anforderungen, Work Items oder Tests — mit Vorschau und Bearbeitung direkt aus Jazz."
summary: "Unser XWiki–OSLC-Konnektor bringt Ihr Dokumentations-Wiki und Ihre IBM-Jazz-Engineering-Plattform ins Gespräch. Bidirektionale Traceability-Links, native Vorschau von Jazz-Artefakten in XWiki, Bearbeitung einer XWiki-Seite aus der Jazz-Vorschau, ein OSLC-Delegated-Picker, Integration in das Jazz-Menü und geteilte Authentifizierung — alles, ohne die eigenen Tools zu verlassen."
tags: ["XWiki", "IBM Jazz", "OSLC", "ELM", "Traceability", "Syncheo"]
translationKey: "xwiki-oslc-connector"
banner: "img/banners/xwiki-oslc-banner.png"
---

In den meisten Engineering-Organisationen lebt die Dokumentation auf der einen und die Engineering-Artefakte auf der anderen Seite. Teams schreiben ihre Spezifikationen, Architekturleitfäden und Design-Notizen in ein Wiki wie **XWiki**, während ihre Anforderungen, Work Items und Testkampagnen in **IBM Jazz (Engineering Lifecycle Management)** verwaltet werden. Beide Welten beziehen sich ständig aufeinander — und doch verbindet sie nichts.

Unser **XWiki–OSLC-Konnektor** schließt diese Lücke. Er macht aus XWiki und IBM Jazz zwei Tools, die nativ miteinander sprechen — über den offenen Standard **OSLC** — sodass Dokumentation und Engineering zu einem einzigen Traceability-Faden werden.

---

## Was ist XWiki?

**XWiki** ist eine Open-Source-Wiki-Plattform auf Enterprise-Niveau, konzipiert für kollaboratives Wissensmanagement. Weit mehr als ein einfaches Wiki, erlaubt XWiki den Aufbau echter strukturierter Anwendungen: Dokumentationsbasen, Referenzverzeichnisse, Prozeduren, reichhaltige Spezifikationsseiten — alles versioniert, mit feingranularer Rechteverwaltung und einer leistungsfähigen Extension-Engine.

In großen Organisationen ist XWiki eine häufige Wahl, um technische und fachliche Dokumentation zu zentralisieren — gerade weil es offen, erweiterbar und selbst hostbar ist.

Mehr über XWiki: [xwiki.org](https://www.xwiki.org).

---

## Was ist OSLC?

**OSLC (Open Services for Lifecycle Collaboration)** ist ein offener Standard zur Integration von Engineering-Lifecycle-Tools. Aufbauend auf den Prinzipien von *Linked Data* definiert er eine gemeinsame Art und Weise, wie verschiedene Tools sich gegenseitig referenzieren, darstellen und dauerhaft verknüpfen — ohne schwere Synchronisation und ohne Datenduplizierung.

IBM Jazz implementiert OSLC nativ. Indem unser Konnektor XWiki OSLC-kompatibel macht, können beide Plattformen mit genau denselben Standardmechanismen zusammenarbeiten, die IBM bereits zwischen seinen eigenen Tools nutzt (DOORS Next, EWM, ETM…).

---

## Was der Konnektor leistet

### OSLC-Traceability-Links zwischen XWiki und Jazz

Das Herzstück des Konnektors: Traceability-Links zwischen einer XWiki-Seite und einem Jazz-Artefakt erstellen — einer Anforderung, einem Work Item, einem Testfall. Diese Links sind bidirektional und navigierbar: Von Jazz aus gelangt man zur Dokumentationsseite, die das „Warum" erklärt; von XWiki aus steigt man hinab zur Anforderung oder zum Work Item, das das „Wie" verkörpert. Dokumentation ist kein totes Dokument mehr neben dem Projekt, sondern ein nachverfolgtes Glied in der Engineering-Kette.

### Native Vorschau von Jazz-Artefakten in XWiki

Wenn eine XWiki-Seite ein Jazz-Artefakt referenziert, rendert der Konnektor eine **native Vorschau** direkt in der Seite — mittels OSLC Compact Rendering. Beim Überfahren mit der Maus sieht der Nutzer Titel, Status und Kerninformationen des Artefakts, ohne XWiki zu verlassen oder Jazz zu öffnen. Die Dokumentation bleibt visuell aktuell, in Echtzeit, mit dem tatsächlichen Stand des Engineerings.

### XWiki als OSLC-Provider

Der Konnektor konsumiert nicht nur Jazz-Ressourcen: Er stellt **die XWiki-Seiten selbst als OSLC-Ressourcen** bereit. Ihre Dokumentationsseiten werden zu verknüpfbaren Artefakten, konsumierbar durch IBM Jazz (ELM, DOORS Next…) wie jede andere Lifecycle-Ressource. Aus einer Anforderung heraus kann ein Ingenieur auf die XWiki-Seite verweisen, die sie spezifiziert — und Jazz weiß sie darzustellen.

### Ein standardisierter Delegated Picker (Delegated UI)

Das Erstellen eines Links erfordert keinerlei URL-Handling oder Kopieren und Einfügen. Der Konnektor stützt sich auf die **OSLC Delegated UI**: Aus Jazz heraus öffnet sich ein Picker, um die zu verknüpfende XWiki-Seite zu suchen und auszuwählen — und umgekehrt — in einem Standarddialog, ohne das ursprüngliche Tool zu verlassen. Es ist dieselbe vertraute Geste, die nativ zwischen den IBM-Tools verwendet wird.

### Eine XWiki-Seite aus der Jazz-Vorschau bearbeiten

Der Konnektor geht über das bloße Betrachten hinaus: Aus der Vorschau eines in Jazz angezeigten XWiki-Links kann der Nutzer die **XWiki-Seite direkt bearbeiten**, ohne die Anwendung zu wechseln. Dokumentation wird genau dort korrigiert und angereichert, wo der Bedarf entsteht — im Fluss der Engineering-Arbeit.

### Integriert in das Jazz-Menü

Der Konnektor integriert sich **direkt in das Menü von IBM Jazz**. Die XWiki-bezogenen Funktionen sind dort verfügbar, wo Ingenieure bereits arbeiten — kein Drittanbieter-Tool zu öffnen, kein Kontextwechsel. Die Akzeptanz ist sofort gegeben, weil sich an den Gewohnheiten der Teams nichts ändert.

### Geteilte Authentifizierung mit Jazz

Kein zweites Konto, kein zusätzlicher Login zu verwalten. Der Konnektor **teilt die Authentifizierungsoberfläche mit Jazz**: Ein bereits an seiner Engineering-Plattform angemeldeter Nutzer greift nahtlos auf XWiki zu. Weniger Reibung für die Teams und eine einfachere Zugriffsverwaltung für Administratoren.

---

## Wie es in der Praxis abläuft

**1. Ein Ingenieur schreibt eine Spezifikation in XWiki**
Die Seite beschreibt den Kontext, die Architekturentscheidungen und die Geschäftsregeln. Sie ist das „Warum" des Projekts.

**2. Er verknüpft sie mit einer Anforderung in Jazz**
Aus der Anforderung heraus öffnet er den OSLC-Picker, findet die XWiki-Seite und erstellt den Link. Keine URL zu kopieren, keine technische Konfiguration.

**3. Traceability wird lebendig**
In Jazz zeigt die Anforderung nun eine Vorschau der XWiki-Seite mit Titel und Status, in Echtzeit aktualisiert. In XWiki verweist die Seite zurück auf die Anforderung.

**4. Dokumentation entwickelt sich weiter, ohne den Workflow zu verlassen**
Ein Detail zu präzisieren? Der Ingenieur bearbeitet die XWiki-Seite direkt aus der in Jazz angezeigten Vorschau. Dokumentation und Engineering schreiten gemeinsam voran, im selben Takt.

---

## Fazit

Unser XWiki–OSLC-Konnektor versöhnt zwei Welten, die immer im Dialog hätten stehen sollen: das in XWiki dokumentierte Wissen und die in IBM Jazz verwalteten Engineering-Artefakte. Auf Basis des offenen OSLC-Standards — genau jenem, den IBM zwischen seinen eigenen Tools nutzt — schafft er native, bidirektionale Traceability ohne Duplizierung, wo zuvor nur eine Lücke war.

**Möchten Sie mehr erfahren oder eine Demo vereinbaren?** [Kontaktieren Sie uns](/de/contact).
