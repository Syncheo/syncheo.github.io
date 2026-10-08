---
title: "PlantUML im ELM-Menü: Diagramme mit einem Klick"
date: 2026-10-08T10:00:00+02:00
draft: false
tags: ["PlantUML", "OSLC", "IBM ELM", "Jazz", "Open Liberty", "Diagramme", "UML", "Syncheo"]
categories: ["Technische Expertise"]
author: "Syncheo Engineering"
description: "Ein winziges OSLC-Jar genügt, um einen PlantUML-Server als Jazz-Anwendung zu veröffentlichen: Er erscheint im Administrationsmenü und im Banner von ELM, und Anwender erstellen Diagramme, ohne ihre Umgebung zu verlassen."
banner: "img/blog/plantuml-oslc-banner.png"
translationKey: "plantuml-elm-menu"
---

In einem **IBM-ELM**-Projekt braucht man regelmäßig ein Diagramm: einen Nachrichtenablauf, einen Zustandsautomaten, eine Architektur, einen Prozess. Allzu oft wird es in einem externen Werkzeug gezeichnet, als Bild exportiert und von Hand eingefügt — und niemand traut sich mehr, es anzufassen. Mit **PlantUML** wird das Diagramm als Text geschrieben. Es bleibt die Aufgabe, es den ELM-Anwendern an der richtigen Stelle zur Verfügung zu stellen. Genau das leistet eine sehr kleine Komponente, die wir soeben umgesetzt haben.

<!--more-->

## Kurz gefasst

[PlantUML](https://plantuml.com/) ist ein Open-Source-Werkzeug, das aus einer Textbeschreibung Diagramme erzeugt (Sequenz, Klassen, Aktivitäten, Zustände, Komponenten, Anwendungsfälle, Gantt usw.). Wir haben es auf **Open Liberty** bereitgestellt und ein **Jar mit wenigen Klassen** ergänzt, das die Jazz-(OSLC-)Discovery-Dokumente veröffentlicht: PlantUML meldet sich dann wie jede andere ELM-Anwendung beim JTS an und **erscheint im Menü**, neben DOORS Next, EWM, ETM oder Report Builder.

<img src="/img/blog/plantuml-jazz-menu.png" alt="ELM-Administrationsmenü mit PlantUML neben den anderen Jazz-Anwendungen" style="max-width:320px;width:100%;">

*Das Menü „Serveradministration“ einer ELM-Instanz: PlantUML ist unter dem eigenen Kontext `/plantuml` aufgeführt.*

---

## Warum PlantUML für ELM-Anwender

Ein als Text beschriebenes Diagramm bringt Engineering-Teams mehrere konkrete Vorteile:

- **Geschwindigkeit**: Wenige Zeilen Text ergeben ein sauberes Diagramm; das Layout ist automatisch, niemand richtet Kästchen aus.
- **Einheitlichkeit**: Alle Diagramme haben denselben Stil, unabhängig vom Autor.
- **Wartbarkeit**: Ein Diagramm zu ändern heißt, eine Textzeile zu ändern, statt neu zu zeichnen.
- **Nachvollziehbarkeit**: Der Quelltext lässt sich leicht kopieren, vergleichen und zusammen mit anderen Ergebnissen aufbewahren.

Es fehlte lediglich ein **integrierter** Zugang: Das Werkzeug soll dort sein, wo die Anwender ohnehin arbeiten, ohne eine weitere URL merken zu müssen.

## So funktioniert es

Der PlantUML-Server (der vom Projekt gelieferte `plantuml-server`) ist eine gewöhnliche Webanwendung. Damit ELM sie erkennt, muss der JTS einige Discovery-Dokumente lesen können. Unser Jar, im `WEB-INF/lib` des PlantUML-WAR abgelegt, veröffentlicht sie:

| URL | Inhalt |
|-----|--------|
| `/rootservices` | Services-Wurzel (Titel) |
| `/scr` | Service Contribution Resource |
| `/application-about` | Herausgeber, Version, Kennung, Symbol |
| `/home-menu` | Eintrag für das Jazz-Bannermenü |

Die Registrierung in Jazz erfolgt dann wie bei jeder Anwendung: im JTS unter *Administration > Server > Register application* mit der URL des `/scr`.

### Konfiguration

Titel, Version, Kennung, Beschreibung und Symbol werden über Java-Eigenschaften (`jvm.options`) oder Umgebungsvariablen (`server.env`) festgelegt, mit sinnvollen Standardwerten. Hinter einem Reverse Proxy wie Nginx verhindert eine Eigenschaft für die externe URL, dass die veröffentlichten Links den internen Port enthalten.

### Voraussetzungen

Java 17 oder höher, Maven zum Kompilieren und Open Liberty mit den **Jakarta-EE-11**-Features (`servlet-6.1`, `pages-4.0`, …) — nicht mit älteren Java-EE-Features mischen.

## Was diese Komponente nicht leistet

Zum Umfang: Es handelt sich um eine **leichtgewichtige Integration**, die lediglich die Menü- und Identitätsdokumente veröffentlicht. Es gibt weder einen OAuth-Registrierungsendpunkt noch einen OSLC-Servicekatalog, und PlantUML wird nicht in die Oberflächen der anderen Anwendungen eingebettet. Es ist kein eigenständiges Produkt, sondern eine kleine Ergänzung, die ein nützliches Werkzeug direkt für die Anwender erreichbar macht.

## Weiterführend

Dasselbe Prinzip gilt für andere Webanwendungen, die eine ELM-Umgebung ergänzen: ein internes Werkzeug, ein Wiki, ein Dashboard … Wenige Klassen genügen, damit sie ins Jazz-Menü aufgenommen werden. Diesen Ansatz haben wir bereits bei mehreren unserer Anwendungen genutzt.

Möchten Sie Ihren ELM-Anwendern PlantUML anbieten oder eine weitere Anwendung in Ihr Jazz-Menü einbinden? [Kontaktieren Sie uns](/de/contact).

## Quellen

- [PlantUML — offizielle Website](https://plantuml.com/)
- [PlantUML Server — plantuml.com](https://plantuml.com/server)
- [Open Liberty](https://openliberty.io/)
