---
title: "Show Workitem Workflow - Plugin EWM pour visualiser les etats et transitions dans l'editeur"
date: 2026-04-15T10:00:00+02:00
draft: false
slug: "ewm-plugin-show-workflow"
tags: ["IBM EWM", "ELM", "Plugin", "Jazz", "Workflow"]
author: "Syncheo Engineering"
summary: "Syncheo a developpe un plugin pour IBM Engineering Workflow Management (EWM) qui affiche le diagramme d'etats complet d'un work item directement dans son editeur, sans quitter la page."
banner: "img/portfolio/ewm-workflow-plugin-banner.png"
translationKey: "ewm-plugin-show-workflow"
---

IBM Engineering Workflow Management (EWM) expose pour chaque work item son état courant, mais nulle part dans l'éditeur il n'est possible de voir l'ensemble du workflow : quels états existent, quelles transitions y mènent, comment passer d'un état à un autre. Pour un contributeur qui ne connaît pas la configuration du projet, c'est une boîte noire.

## Le problème

La définition du workflow -- états, groupes d'états, transitions étiquetées -- est accessible uniquement depuis l'interface d'administration de la zone de processus. Cela pose trois difficultés concrètes : les contributeurs n'ont généralement pas les droits d'administration nécessaires, l'ouverture de l'admin impose un changement complet de contexte qui fait perdre le work item en cours, et l'information est présentée sous une forme tabulaire peu exploitable. Résultat : un développeur qui veut savoir s'il peut passer un work item directement de "Nouveau" à "Résolu" doit soit interroger un administrateur, soit ouvrir l'admin dans un autre onglet et parcourir plusieurs écrans.

## Le plugin Show Workitem Workflow

Syncheo a développé un plugin pour EWM qui résout ce problème en exposant le workflow complet du work item courant directement dans son éditeur, sous la forme d'un diagramme d'états interactif.

Un nouveau bouton apparaît dans la barre d'outils de l'éditeur de work item. Son icône représente un schéma de workflow stylisé ; son tooltip est "Show Workitem Workflow". Au survol du bouton, une bulle se déploie à proximité et affiche le diagramme du workflow associé au type du work item ouvert. La bulle reste visible tant que le pointeur se trouve sur le bouton ou sur la bulle elle-même, puis se referme automatiquement dès que l'utilisateur s'éloigne. Aucune navigation, aucun rechargement de page.

Le diagramme est rendu en SVG vectoriel : parfaitement net quel que soit le zoom du navigateur ou la résolution de l'écran. Les états sont organisés en colonnes selon leur groupe EWM ("Ouverts", "En cours", "Résolus / Fermés"), avec des couleurs distinctes par groupe. Les transitions apparaissent sous forme de flèches étiquetées avec le nom de l'action. Pendant la création d'un work item -- avant le premier enregistrement, donc sans identifiant réel -- le bouton est grisé et la bulle ne s'ouvre pas.

![Démonstration du plugin Show Workitem Workflow](/img/portfolio/ewm-workflow-plugin-demo.gif)

## Sous le capot

Le plugin se dépose sur le serveur Jazz (côté `ccm`) et se compose de deux moitiés indépendantes.

**Côté serveur**, un service REST modélisé Jazz expose le workflow d'un work item via une URL dédiée. Il s'appuie sur les services internes EWM pour lire la définition de workflow attachée au type du work item, énumérer ses états et transitions, et renvoyer le tout en JSON.

**Côté client**, une extension Jazz ajoute le bouton à la barre d'outils et gère le hover, la création de la bulle, l'appel REST et le rendu du diagramme. Le rendu graphique est entièrement réalisé dans le navigateur, sans aucun appel réseau externe. Aucune installation de composant supplémentaire sur le serveur Jazz n'est requise.

## Compatibilité

Le plugin cible **IBM Engineering Workflow Management** sur les plateformes Jazz récentes. Il fonctionne dans tous les navigateurs modernes supportés par EWM : Chrome, Edge, Firefox. Aucune ressource externe n'est chargée à l'exécution.

## Composants open source

Le plugin intègre des composants tiers dont les licences sont redistribuables. Un fichier de mention et le texte intégral de chaque licence sont livrés avec le plugin pour respecter les obligations légales de chaque composant embarqué.
