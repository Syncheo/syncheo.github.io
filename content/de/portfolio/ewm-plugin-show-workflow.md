---
title: "Show Workitem Workflow - EWM-Plugin zur Visualisierung von Zuständen und Übergängen im Editor"
date: 2026-04-15T10:00:00+02:00
draft: false
slug: "ewm-plugin-show-workflow"
tags: ["IBM EWM", "ELM", "Plugin", "Jazz", "Workflow"]
author: "Syncheo Engineering"
summary: "Syncheo hat ein Plugin für IBM Engineering Workflow Management (EWM) entwickelt, das das vollständige Zustandsdiagramm eines Work Items direkt im Editor anzeigt, ohne die Seite zu verlassen."
banner: "img/portfolio/ewm-workflow-plugin-banner.png"
translationKey: "ewm-plugin-show-workflow"
---

IBM Engineering Workflow Management (EWM) zeigt für jedes Work Item den aktuellen Zustand an, aber nirgendwo im Editor lässt sich der gesamte Workflow einsehen: welche Zustände existieren, welche Übergänge dorthin führen, wie man von einem Zustand zum nächsten gelangt. Für eine Mitarbeiterin oder einen Mitarbeiter, die die Projektkonfiguration nicht kennen, ist der Workflow eine Blackbox.

## Das Problem

Die Workflow-Definition – Zustände, Zustandsgruppen, beschriftete Übergänge – ist ausschließlich über die Administrationsoberfläche des Prozessbereichs zugänglich. Daraus ergeben sich drei konkrete Schwierigkeiten: Mitwirkende haben in der Regel nicht die erforderlichen Administrationsrechte, das Öffnen der Administration erzwingt einen vollständigen Kontextwechsel, bei dem das aktuelle Work Item verloren geht, und die Informationen werden in einer schwer auswertbaren tabellarischen Form präsentiert. Das Ergebnis: Eine Entwicklerin oder ein Entwickler, die wissen wollen, ob ein Work Item direkt von „Neu" auf „Behoben" gesetzt werden kann, müssen entweder die Administration befragen oder die Admin-Oberfläche in einem weiteren Tab öffnen und mehrere Bildschirme durchgehen.

## Das Show-Workitem-Workflow-Plugin

Syncheo hat ein Plugin für EWM entwickelt, das dieses Problem löst, indem es den vollständigen Workflow des aktuellen Work Items direkt im Editor in Form eines interaktiven Zustandsdiagramms verfügbar macht.

In der Symbolleiste des Work-Item-Editors erscheint ein neuer Button. Sein Symbol stellt ein stilisiertes Workflow-Schema dar; sein Tooltip lautet „Show Workitem Workflow". Beim Überfahren des Buttons öffnet sich in der Nähe eine Sprechblase, die das Workflow-Diagramm des Typs des geöffneten Work Items anzeigt. Die Sprechblase bleibt sichtbar, solange sich der Mauszeiger über dem Button oder über der Sprechblase selbst befindet, und schließt sich automatisch, sobald die Anwenderin oder der Anwender sich entfernt. Keine Navigation, kein Neuladen der Seite.

Das Diagramm wird als Vektor-SVG gerendert: bei jedem Browser-Zoom und jeder Bildschirmauflösung gestochen scharf. Die Zustände sind in Spalten nach ihrer EWM-Gruppe organisiert („Offen", „In Bearbeitung", „Behoben / Geschlossen") und werden mit unterschiedlichen Farben pro Gruppe dargestellt. Übergänge erscheinen als beschriftete Pfeile mit dem Namen der Aktion. Während der Erstellung eines Work Items – vor dem ersten Speichern und damit ohne reale Kennung – ist der Button ausgegraut, und die Sprechblase öffnet sich nicht.

![Demonstration des Show-Workitem-Workflow-Plugins](/img/portfolio/ewm-workflow-plugin-demo.gif)

## Unter der Haube

Das Plugin wird auf dem Jazz-Server (auf der `ccm`-Seite) installiert und besteht aus zwei voneinander unabhängigen Hälften.

**Serverseitig** stellt ein Jazz-modellierter REST-Service den Workflow eines Work Items über eine dedizierte URL bereit. Er nutzt die internen EWM-Dienste, um die mit dem Work-Item-Typ verknüpfte Workflow-Definition auszulesen, deren Zustände und Übergänge aufzuzählen und das Ganze als JSON zurückzugeben.

**Clientseitig** fügt eine Jazz-Erweiterung den Button in die Symbolleiste ein und kümmert sich um Hover-Verhalten, Sprechblasenerzeugung, REST-Aufruf und Diagramm-Rendering. Das grafische Rendering findet vollständig im Browser statt, ohne externe Netzwerkaufrufe. Auf dem Jazz-Server ist keine zusätzliche Komponenteninstallation erforderlich.

## Kompatibilität

Das Plugin richtet sich an **IBM Engineering Workflow Management** auf aktuellen Jazz-Plattformen. Es läuft in allen modernen, von EWM unterstützten Browsern: Chrome, Edge, Firefox. Zur Laufzeit werden keine externen Ressourcen geladen.

## Open-Source-Komponenten

Das Plugin enthält Drittanbieter-Komponenten mit weiterverteilbaren Lizenzen. Eine Notice-Datei sowie der vollständige Lizenztext jeder Komponente werden mit dem Plugin ausgeliefert, um den rechtlichen Verpflichtungen der jeweils eingebundenen Komponente zu entsprechen.
