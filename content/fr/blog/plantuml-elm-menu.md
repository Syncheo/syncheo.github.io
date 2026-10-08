---
title: "PlantUML dans le menu d'ELM : des diagrammes à un clic"
date: 2026-10-08T10:00:00+02:00
draft: false
tags: ["PlantUML", "OSLC", "IBM ELM", "Jazz", "Open Liberty", "Diagrammes", "UML", "Syncheo"]
categories: ["Expertise Technique"]
author: "Syncheo Engineering"
description: "Un minuscule jar OSLC suffit pour publier un serveur PlantUML comme une application Jazz : il apparaît dans le menu d'administration et la bannière d'ELM, et les utilisateurs créent leurs diagrammes sans quitter leur environnement."
banner: "img/blog/plantuml-oslc-banner.png"
translationKey: "plantuml-elm-menu"
---

Dans un projet **IBM ELM**, on a régulièrement besoin d'un schéma : une séquence d'échanges, une machine à états, une architecture, un processus. Trop souvent, il est dessiné dans un outil externe, exporté en image, puis collé à la main — et personne n'ose plus y toucher. Avec **PlantUML**, le diagramme s'écrit en texte. Reste à le rendre accessible aux utilisateurs ELM, au bon endroit. C'est ce que fait un tout petit composant que nous venons de réaliser.

<!--more-->

## En bref

[PlantUML](https://plantuml.com/) est un outil libre qui génère des diagrammes (séquence, classes, activités, états, composants, cas d'utilisation, Gantt, etc.) à partir d'une description textuelle. Nous l'avons déployé sur **Open Liberty** et ajouté un **jar de quelques classes** qui publie les documents de découverte Jazz (OSLC) : PlantUML se déclare alors auprès du JTS comme n'importe quelle application ELM et **apparaît dans le menu**, à côté de DOORS Next, EWM, ETM ou Report Builder.

<img src="/img/blog/plantuml-jazz-menu.png" alt="Menu d'administration d'ELM listant PlantUML avec les autres applications Jazz" style="max-width:320px;width:100%;">

*Le menu « Administration du serveur » d'une instance ELM : PlantUML y figure sous son propre contexte `/plantuml`.*

---

## Pourquoi PlantUML pour les utilisateurs ELM

Un diagramme décrit en texte a plusieurs avantages concrets pour des équipes d'ingénierie :

- **Rapidité** : quelques lignes de texte produisent un schéma propre ; la mise en page est automatique, personne ne passe de temps à aligner des boîtes.
- **Cohérence** : tous les diagrammes partagent le même style, quel que soit l'auteur.
- **Maintenabilité** : modifier un diagramme, c'est modifier une ligne de texte, et non reprendre un dessin.
- **Traçabilité** : le texte source se copie, se compare et se conserve facilement avec les autres livrables.

Il manquait simplement un accès **intégré** : que l'outil soit là où les utilisateurs travaillent déjà, sans avoir à connaître une URL de plus.

## Comment ça marche

Le serveur PlantUML (le `plantuml-server` fourni par le projet) est une application web classique. Pour qu'ELM la reconnaisse, le JTS doit pouvoir lire quelques documents de découverte. Notre jar, à déposer dans `WEB-INF/lib` du WAR PlantUML, les publie :

| URL | Contenu |
|-----|---------|
| `/rootservices` | Racine des services (titre) |
| `/scr` | Service Contribution Resource |
| `/application-about` | Éditeur, version, identifiant, icône |
| `/home-menu` | Entrée du menu de la bannière Jazz |

L'enregistrement dans Jazz se fait ensuite comme pour toute application : dans le JTS, *Administration > Server > Register application*, en indiquant l'URL du `/scr`.

### La configuration

Le titre, la version, l'identifiant, la description et l'icône se règlent par propriétés Java (`jvm.options`) ou variables d'environnement (`server.env`), avec des valeurs par défaut raisonnables. Derrière un reverse proxy comme Nginx, une propriété d'URL externe évite que les liens publiés contiennent le port interne.

### Les prérequis

Java 17 ou plus, Maven pour compiler, et Open Liberty avec les features **Jakarta EE 11** (`servlet-6.1`, `pages-4.0`, …) — à ne pas mélanger avec d'anciennes features Java EE.

## Ce que ce composant ne fait pas

Soyons clairs sur son périmètre. Il s'agit d'une **intégration légère** : il publie les documents de menu et d'identité, c'est tout. Il n'y a pas de point d'enregistrement OAuth ni de catalogue de services OSLC, et il n'intègre pas PlantUML dans l'interface des autres applications. Ce n'est pas un produit à part entière, mais un petit plus qui rend un outil utile directement accessible aux utilisateurs.

## Pour aller plus loin

Le même principe s'applique à d'autres applications web complémentaires d'un environnement ELM : un outil interne, un wiki, un tableau de bord… Quelques classes suffisent pour qu'elles rejoignent le menu Jazz. C'est une approche que nous avons déjà utilisée sur plusieurs de nos applications.

Vous souhaitez proposer PlantUML à vos utilisateurs ELM, ou intégrer une autre application à votre menu Jazz ? [Contactez-nous](/fr/contact).

## Sources

- [PlantUML — site officiel](https://plantuml.com/)
- [PlantUML Server — plantuml.com](https://plantuml.com/server)
- [Open Liberty](https://openliberty.io/)
