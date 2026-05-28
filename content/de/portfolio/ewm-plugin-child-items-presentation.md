---
title: "Child Items Presentation - EWM-Plugin zur Steuerung untergeordneter Work Items vom übergeordneten Element aus"
date: 2026-04-28T10:00:00+02:00
draft: false
slug: "ewm-plugin-child-items-presentation"
tags: ["IBM EWM", "ELM", "Plugin", "Jazz", "Work Items"]
author: "Syncheo Engineering"
summary: "Syncheo hat ein Plugin für IBM Engineering Workflow Management (EWM) entwickelt, das die native Children-Präsentation in eine echte Steuerzentrale verwandelt: konfigurierbare Tabelle, Inline-Bearbeitung, Hinzufügen und Entfernen von untergeordneten Elementen — vollständig in den Save-/Cancel-Zyklus des Jazz-Editors integriert."
banner: "img/portfolio/ewm-childitems-plugin-banner.png"
translationKey: "ewm-plugin-child-items-presentation"
---

Über-/Untergeordnete Hierarchien strukturieren einen wesentlichen Teil der Arbeit in IBM Engineering Workflow Management (EWM, ehemals Rational Team Concert): ein Epic, das in Stories zerlegt wird, eine Task, die Sub-tasks bündelt, ein Defect, das seine Korrekturen zusammenfasst. Dennoch beschränkt sich die standardmäßig ausgelieferte Children-Präsentation auf eine minimalistische Liste von Kennungen und Bezeichnungen — ohne jede Sicht auf die fachlichen Attribute, die im Alltag wirklich zählen.

## Das Problem

Die native Children-Präsentation von EWM zeigt pro untergeordnetem Element nur eine Kennung und eine Zusammenfassung an. Um den Zustand, den Eigentümer, die geplante Iteration oder das betroffene Modul jedes untergeordneten Elements zu erfahren, muss der Benutzer jedes Work Item einzeln öffnen. Für Massenänderungen — etwa zehn untergeordnete Elemente nach einem Abstimmungstermin von einem gemeinsamen Zustand „Zu planen" auf „Geplant" zu setzen — muss jeder Editor erneut geöffnet und derselbe Handgriff wiederholt werden.

Auch das Hinzufügen eines untergeordneten Elements zu einem bestehenden übergeordneten Element ist wenig intuitiv: Es läuft über die Links oder über das Anlegen eines Work Items, dessen Beziehung man anschließend setzt. Letztlich dient der Editor des übergeordneten Elements nur dazu, die Existenz der untergeordneten Elemente festzustellen; er ist keine Steuerzentrale.

## Die Lösung

Syncheo hat **Child Items Presentation** entwickelt, eine Jazz-Präsentation, die die native Version in jedem Editor eines Work-Item-Typs ersetzt. Sie behält den Platz und die Rolle der offiziellen Children-Präsentation und ergänzt drei wesentliche Fähigkeiten: eine angereicherte und konfigurierbare Tabellenansicht, die Inline-Bearbeitung der untergeordneten Elemente sowie deren Hinzufügen / Entfernen direkt vom übergeordneten Element aus.

![Demonstration des Child Items Presentation-Plugins](/img/portfolio/ewm-childitems-plugin-demo.gif)

*Massenbearbeitung mehrerer untergeordneter Work Items aus dem Editor des übergeordneten Elements, Hinzufügen eines neuen untergeordneten Elements über den offiziellen Jazz-Dialog, Entfernen eines Links — alles mit einem einzigen Save-Klick gespeichert.*

Wie jede Jazz-Präsentation wird das Widget in der Process Configuration deklariert und integriert sich nativ in den Editor: keine eigene Save-Schaltfläche, kein paralleler Persistenzzyklus. Die Änderungen werden an die Working Copy des aktuellen Editors angehängt und beim Klick auf die globale Save-Schaltfläche der Symbolleiste gespeichert — genau wie alle anderen Felder.

## Die Funktionen im Detail

### 1. Angereicherte, konfigurierbare Tabelle der untergeordneten Elemente

Die Tabelle zeigt standardmäßig drei Spalten an: die anklickbare Kennung des Work Items, seinen Typ und seine Zusammenfassung. Hinzu kommt die Liste der vom Projekt gewünschten Spalten, die in der Process Configuration deklariert werden: Owned By, Priority, Severity, State, Filed Against, Planned For, Due Date, Estimate, Time Spent, Tags, Description, Created By, Resolution… sowie alle benutzerdefinierten Attribute des Projekts, einschließlich Aufzählungen.

So konfiguriert jedes Team seine eigene Sicht: Ein Delivery-Projekt zeigt Owner / State / Iteration an, ein Wartungsprojekt zeigt Severity / Filed Against / Resolution an — ohne erneute Bereitstellung des Plugins.

### 2. Inline-Bearbeitung

Eine zweite Konfigurationseigenschaft legt fest, welche der angezeigten Spalten direkt in der Tabelle bearbeitbar sind. Beim Klick auf eine bearbeitbare Zelle öffnet sich das passende Jazz-Widget an Ort und Stelle: ein Aufzählungsselektor für State oder Severity, ein Benutzer-Picker für Owned By, ein Kategorie- oder Iterations-Picker für Filed Against und Planned For, ein Datepicker für Due Date, ein Dauer-Editor für Estimate oder Time Spent, ein Tag-Selektor und so weiter. Die Semantik ist exakt identisch mit der der nativen Jazz-Editoren: keine neue Gewohnheit zu erlernen.

Die an mehreren untergeordneten Elementen vorgenommenen Änderungen lösen **keine sofortige Speicherung** aus. Sie werden in der Working Copy des Editors gesammelt, und ein einziger Save-Klick speichert sie alle in einer einzigen serverseitigen Transaktion. Cancel verwirft sie alle. Zwischen Editor und Tabelle ist keine Abweichung möglich.

### 3. Hinzufügen bestehender oder neuer untergeordneter Elemente

Eine dezente Schaltfläche **Add Children** am unteren Rand der Tabelle öffnet den offiziellen Jazz-Dialog **Select Work Item** — genau jenen, den EWM zum Hinzufügen eines klassischen Links verwendet. Alle nativen Funktionen stehen zur Verfügung: Suche nach Kennung oder Text, Filter, Verlauf der jüngsten Auswahlen, Mehrfachauswahl und eine Schaltfläche **New**, um spontan ein neues Work Item zu erstellen.

Eine automatische Ausschlussliste macht es per Konstruktion unmöglich, das übergeordnete Element selbst oder ein bereits verknüpftes untergeordnetes Element erneut auszuwählen: kein Duplikat, keine Selbstreferenz. Die ausgewählten Work Items gelangen anschließend über dieselben APIs in die Working Copy wie die native Jazz-Präsentation — dieselben Garantien für die Modellkonsistenz, dasselbe Verhalten beim Speichern.

### 4. Visuelles Feedback „Speicherung ausstehend"

Sobald ein untergeordnetes Element über den Dialog hinzugefügt wird, erscheint sofort eine Zeile in der Tabelle, kursiv auf blassgelbem Hintergrund mit einem Sternchen vor der Kennung. Der Benutzer sieht sofort, dass der Vorgang berücksichtigt wurde und dass die Zeile rücknehmbar bleibt, solange das globale Save nicht angeklickt wurde. Beim Save wird die Tabelle automatisch aktualisiert, und die Zeile erhält ihr normales Erscheinungsbild zurück.

Dieses „ausstehende" Feedback deckt eine klassische Schwäche von Präsentationen ab, die auf die Working Copy einwirken: Ohne visuelles Signal kann der Benutzer zweifeln, ob er richtig geklickt hat, und klickt am Ende oft erneut.

### 5. Entfernen eines Links

Ein kleines, dezentes Kreuz am Ende jeder Zeile — standardmäßig hellgrau, beim Überfahren rot — entfernt die untergeordnete Referenz aus der Working Copy. Wie beim Hinzufügen markiert das Entfernen den Editor als dirty, wird aber erst beim Save gespeichert: Ein Cancel stellt die ursprüngliche Liste der untergeordneten Elemente vollständig wieder her.

### 6. Integration in den Jazz-Editor

Der gesamte Zyklus aus Save / Cancel / Dirty-State wird an den Host-Jazz-Editor delegiert. Das Plugin beobachtet die globale Save-Schaltfläche, fasst die clientseitigen Änderungen in einem einzigen Serveraufruf zusammen und aktualisiert die Tabelle, sobald die Persistenz bestätigt ist. Die internen Widgets folgen dem Standard-Lebenszyklus des Editors, was das Ausbleiben von Speicherlecks beim Schließen garantiert — auch nach mehreren Zyklen aus Hinzufügen / Entfernen.

## Architektur und Integration

Child Items Presentation wird als klassisches Jazz-Plugin paketiert und auf dem **ccm**-Server bereitgestellt — genauso wie eine offizielle Präsentation. Es ist vollständig auf dem Standard-Stack des Jazz-Editors entwickelt und **verwendet systematisch die internen EWM-Komponenten** für den Picker, das Hinzufügen, das Entfernen und die Zellenbearbeitung. Diese Strategie der Wiederverwendung — statt der Neuimplementierung — garantiert eine perfekte visuelle und funktionale Kompatibilität mit dem restlichen Editor und begrenzt die Wartungslast bei EWM-Versionsupgrades drastisch.

Serverseitig nutzt das Abrufen der untergeordneten Elemente die Standard-Abfragedienste von EWM, mit einer dynamischen Projektion der Felder entsprechend der Widget-Konfiguration: Es werden nur die tatsächlich angezeigten Attribute abgerufen. Die Änderungen werden in einem einzigen Aufruf gebündelt, um die Serverlast auch dann zu schonen, wenn mehrere Dutzend untergeordnete Elemente gleichzeitig betroffen sind.

## Konfiguration

Das Widget wird in der Process Configuration jedes Editors eines Work-Item-Typs deklariert — anstelle der nativen Children-Präsentation oder ergänzend dazu. Zwei Eigenschaften genügen zur Steuerung:

- `attributes`: die Liste der als zusätzliche Spalten anzuzeigenden Attribute, durch Kommas getrennt. Alle nativen Attribute und alle benutzerdefinierten Attribute des Projekts werden unterstützt.
- `editable`: die Liste der Attribute, unter den angezeigten, die inline bearbeitbar sein sollen.

Zur Anpassung dieser Eigenschaften ist keine erneute Bereitstellung erforderlich: Das Bearbeiten der Process Configuration genügt, und jeder Work-Item-Typ kann seine eigene Konfiguration erhalten.

## Vorteile

Child Items Presentation verwandelt den Editor des übergeordneten Work Items in eine echte Steuerzentrale für seine untergeordneten Elemente. Die Teams gewinnen eine konsolidierte Sicht auf ihre Hierarchien, können Dutzende untergeordnete Elemente in Masse bearbeiten, ohne jeden Editor zu öffnen, fügen Links direkt vom übergeordneten Element aus hinzu und entfernen sie — und behalten jederzeit das Sicherheitsnetz von Cancel.

Da es sich strikt in den nativen Save-/Cancel-Zyklus von EWM einfügt und auf den offiziellen internen Komponenten aufbaut, führt das Plugin keine neue, zu erlernende Gewohnheit für den Benutzer ein, kein Risiko einer Desynchronisierung mit dem Jazz-Datenmodell und keine erneute Bereitstellung, um die Anzeige an ein neues Projekt oder einen neuen Work-Item-Typ anzupassen.
