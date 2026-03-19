---
title: "Sicherung von ALM-Workflows: Native GitGuardian-Integration in IBM EWM"
date: 2026-03-18T11:30:00+01:00
draft: false
author: "Syncheo"
description: "Bidirektionale Integrationsarchitektur zwischen IBM Engineering Workflow Management und GitGuardian zur Erkennung von Secrets."
categories: ["DevSecOps", "Software-Engineering"]
tags: ["IBM EWM", "GitGuardian", "Jazz Platform", "Security", "Plugin-Entwicklung"]
translationKey: "ewm-gitguardian-integration"
banner: "img/blog/ewm-gitguardian-banner.png"
---

In einer Zeit zunehmender Cyber-Bedrohungen ist die präventive Erkennung von "Secret Leaks" (API-Schlüssel, Zertifikate, Anmeldedaten) im Quellcode zu einer zentralen Governance-Aufgabe geworden.

<!--more-->

Um dieser Herausforderung zu begegnen, wurde eine bidirektionale Integrationslösung zwischen **IBM Engineering Workflow Management (EWM)** und **GitGuardian** entwickelt. Diese ermöglicht die Absicherung des Software Development Life Cycle (SDLC), ohne die Agilität der Teams zu beeinträchtigen.

## Ein hybrider Ansatz: Client- und Serverseitig

Die Architektur dieser Lösung basiert auf zwei komplementären Komponenten, die eine vollständige Flexibilität bei der Umsetzung der Unternehmens-Sicherheitsrichtlinien bieten.

### 1. Serverseitige Erweiterung: Die institutionelle Kontrollinstanz
Das serverseitige Plugin agiert als abschließende Instanz während der Bereitstellung (*Delivery*) von Change Sets. Seine Aufgabe ist es, die strikte Compliance des Codes sicherzustellen, bevor dieser in den gemeinsamen Stream integriert wird.

* **Automatisierte Blockierung:** Je nach Konfiguration kann das Plugin die Auslieferung verhindern, wenn der GitGuardian-Scanner eine Schwachstelle identifiziert.
* **Rückverfolgbarkeit und Audit:** Im Falle einer Anomalie erstellt das System automatisch einen Vorfall im GitGuardian-Dashboard.
* **Work-Item-Anreicherung:** Ein Kommentar wird automatisch in das mit dem Change Set verknüpfte EWM Work Item eingefügt. Dies informiert die Projektbeteiligten über die Art der Schwachstelle, wobei die Vertraulichkeit gewahrt bleibt: Das betroffene Secret selbst wird niemals in den Logs oder Kommentaren offengelegt.

### 2. Clientseitige Erweiterung: Agilität für Entwickler
Das clientseitige Plugin setzt so früh wie möglich an – direkt in der IDE des Entwicklers – und fördert damit den "Shift Left Security"-Ansatz.

* **Interaktive Warnmeldung:** Entwickler werden sofort über potenzielle Schwachstellen informiert, noch bevor der Code ihren Arbeitsplatz verlässt.
* **Ausnahmemanagement (Override):** Im Gegensatz zur strikten serverseitigen Prüfung bietet die Client-Erweiterung die Möglichkeit, eine Blockierung zu umgehen. Diese Funktion ist entscheidend für den Umgang mit "False Positives" oder dokumentierten, akzeptierten Risiken, um Engpässe im Bereitstellungsprozess zu vermeiden.

---

## Funktionale Zusammenfassung

| Merkmal | Server-Plugin (Pre-Condition) | Client-Plugin (Pre-Check) |
| :--- | :--- | :--- |
| **Zielsetzung** | Globale Compliance & Audit | Produktivität & Shift-Left |
| **Aktion** | Blockierend oder Informativ | Blockierend mit manuellem Bypass |
| **GitGuardian-Integration** | Automatische Incident-Erstellung | Echtzeit-Analyse |
| **EWM-Feedback** | Kommentar im Work Item | Benutzerbenachrichtigung (UI) |

---

## Fazit

Die Synergie zwischen **IBM EWM** und **GitGuardian** transformiert die Anwendungssicherheit von einer wahrgenommenen Einschränkung in einen integrierten, transparenten Prozess. Durch die Kombination präziser serverseitiger Kontrollen mit flexiblen Client-Tools können Unternehmen die Integrität ihres Software-Portfolios mit höchster Präzision gewährleisten.