---
title: "Child Items Presentation - Plugin EWM pour piloter les work items enfants depuis le parent"
date: 2026-04-28T10:00:00+02:00
draft: false
slug: "ewm-plugin-child-items-presentation"
tags: ["IBM EWM", "ELM", "Plugin", "Jazz", "Work Items"]
author: "Syncheo Engineering"
summary: "Syncheo a développé un plugin pour IBM Engineering Workflow Management (EWM) qui transforme la présentation Children native en véritable poste de pilotage : tableau configurable, édition en ligne, ajout et suppression d'enfants, le tout 100 % intégré au cycle Save / Cancel de l'éditeur Jazz."
banner: "img/portfolio/ewm-childitems-plugin-banner.png"
translationKey: "ewm-plugin-child-items-presentation"
---

Les hiérarchies parent / enfant structurent une part essentielle du travail dans IBM Engineering Workflow Management (EWM, ex-Rational Team Concert) : un Epic décomposé en Stories, une Task qui agrège des Sub-tasks, un Defect qui regroupe ses corrections. Pourtant, la présentation Children fournie en standard se limite à une liste minimaliste d'identifiants et de libellés, sans aucune visibilité sur les attributs métier qui comptent réellement au quotidien.

## Le problème

La présentation Children native d'EWM n'affiche, par enfant, qu'un identifiant et un résumé. Pour connaître l'état, le propriétaire, l'itération de planification ou le module concerné de chaque enfant, l'utilisateur doit ouvrir chaque work item un par un. Pour modifier en masse — par exemple repasser dix enfants d'un même état "À planifier" à "Planifié" après une réunion de cadrage — il faut rouvrir chaque éditeur et y rejouer le même geste.

L'ajout d'un enfant à un parent existant est lui aussi peu naturel : il passe par les liens, ou par la création d'un work item dont on positionne ensuite la relation. Au final, l'éditeur du parent ne sert qu'à constater l'existence des enfants ; il n'est pas un poste de pilotage.

## La solution

Syncheo a développé **Child Items Presentation**, une présentation Jazz qui remplace la version native dans n'importe quel éditeur de type de work item. Elle conserve la place et le rôle de la présentation Children officielle, et y ajoute trois capacités majeures : une vue tabulaire enrichie et configurable, l'édition en ligne des enfants, et l'ajout / suppression d'enfants directement depuis le parent.

[INSÉRER GIF ICI — `/img/portfolio/ewm-childitems-plugin-demo.gif`]

*Légende suggérée : édition en masse de plusieurs work items enfants depuis l'éditeur du parent, ajout d'un nouvel enfant via la dialog Jazz officielle, suppression d'un lien — le tout persisté en un seul clic Save.*

Comme toute présentation Jazz, le widget se déclare dans la Process Configuration et s'intègre nativement à l'éditeur : aucun bouton Save propre, aucun cycle de persistance parallèle. Les modifications sont attachées à la working copy de l'éditeur courant et persistées au clic sur le bouton Save global de la barre d'outils — exactement comme tous les autres champs.

## Les fonctionnalités en détail

### 1. Tableau d'enfants enrichi et configurable

Le tableau affiche par défaut trois colonnes : l'identifiant cliquable du work item, son type et son résumé. À cela s'ajoute la liste des colonnes voulues par le projet, déclarées dans la Process Configuration : Owned By, Priority, Severity, State, Filed Against, Planned For, Due Date, Estimate, Time Spent, Tags, Description, Created By, Resolution… ainsi que tous les attributs personnalisés du projet, énumérations comprises.

Chaque équipe configure ainsi sa propre vue : un projet de delivery affichera Owner / State / Iteration, un projet de maintenance affichera Severity / Filed Against / Resolution, sans aucun re-déploiement du plugin.

### 2. Édition en ligne

Une seconde propriété de configuration désigne, parmi les colonnes affichées, lesquelles sont modifiables directement dans le tableau. Au clic sur une cellule éditable, le widget Jazz approprié s'ouvre en place : sélecteur d'énumération pour State ou Severity, picker utilisateur pour Owned By, picker de catégorie ou d'itération pour Filed Against et Planned For, datepicker pour Due Date, éditeur de durée pour Estimate ou Time Spent, sélecteur de tags, etc. La sémantique est rigoureusement identique à celle des éditeurs Jazz natifs : aucune nouvelle habitude à acquérir.

Les modifications saisies sur plusieurs enfants ne déclenchent **aucune sauvegarde immédiate**. Elles sont accumulées dans la working copy de l'éditeur, et un unique clic Save les persiste toutes en une seule transaction côté serveur. Cancel les annule toutes. Aucune divergence possible entre l'éditeur et le tableau.

### 3. Ajout d'enfants existants ou nouveaux

Un bouton **Add Children** discret en pied de tableau ouvre la dialog officielle Jazz **Select Work Item** — celle-là même qu'utilise EWM pour ajouter un lien classique. Toutes les fonctionnalités natives sont disponibles : recherche par identifiant ou par texte, filtres, historique des sélections récentes, sélection multiple, et bouton **New** pour créer un nouveau work item à la volée.

Une liste d'exclusion automatique empêche par construction de re-sélectionner le parent lui-même ou un enfant déjà rattaché : pas de doublon, pas d'auto-référence. Les work items sélectionnés rejoignent ensuite la working copy par les mêmes API que la présentation Jazz native — mêmes garanties de cohérence du modèle, même comportement à l'enregistrement.

### 4. Feedback visuel "en attente de Save"

Dès qu'un enfant est ajouté via la dialog, une ligne apparaît immédiatement dans le tableau, stylée en italique sur fond jaune pâle avec un astérisque devant l'identifiant. L'utilisateur voit instantanément que l'opération est prise en compte, et que la ligne reste annulable tant que le Save global n'a pas été cliqué. Au Save, le tableau se rafraîchit automatiquement et la ligne reprend son apparence normale.

Ce feedback "en attente" couvre une faiblesse classique des présentations qui agissent sur la working copy : sans signal visuel, l'utilisateur peut douter d'avoir bien cliqué et finit souvent par re-cliquer.

### 5. Suppression de lien

Une petite croix discrète en bout de chaque ligne — gris clair par défaut, rouge au survol — retire la référence enfant de la working copy. Comme pour l'ajout, la suppression marque l'éditeur dirty mais n'est persistée qu'au Save : un Cancel restaure intégralement la liste d'enfants initiale.

### 6. Intégration éditeur Jazz

L'ensemble du cycle Save / Cancel / dirty state est délégué à l'éditeur Jazz hôte. Le plugin observe le bouton Save global, regroupe les modifications côté client en un appel unique au serveur, puis rafraîchit le tableau dès que la persistance est confirmée. Les widgets internes suivent le cycle de vie standard de l'éditeur, ce qui garantit l'absence de fuite mémoire à la fermeture, y compris après plusieurs cycles d'ajout / suppression.

## Architecture et intégration

Child Items Presentation est packagé comme un plugin Jazz classique, déployé sur le serveur **ccm** au même titre qu'une présentation officielle. Il est entièrement développé sur la stack standard de l'éditeur Jazz et **réutilise systématiquement les composants internes EWM** pour le picker, l'ajout, la suppression et l'édition des cellules. Cette stratégie de réutilisation — plutôt que de ré-implémentation — garantit une compatibilité visuelle et fonctionnelle parfaite avec le reste de l'éditeur, et limite drastiquement la dette de maintenance face aux montées de version EWM.

Côté serveur, la récupération des enfants utilise les services d'interrogation standard d'EWM, avec une projection dynamique des champs en fonction de la configuration du widget : seuls les attributs réellement affichés sont rapatriés. Les modifications sont batchées en un appel unique pour ménager la charge serveur même quand plusieurs dizaines d'enfants sont touchés simultanément.

## Configuration

Le widget se déclare dans la Process Configuration de n'importe quel éditeur de type de work item, à la place — ou en complément — de la présentation Children native. Deux propriétés suffisent à le piloter :

- `attributes` : la liste des attributs à afficher en colonnes supplémentaires, séparés par des virgules. Tous les attributs natifs et tous les attributs personnalisés du projet sont supportés.
- `editable` : la liste des attributs, parmi ceux affichés, qui doivent être modifiables en ligne.

Aucun redéploiement n'est nécessaire pour ajuster ces propriétés : la modification de la Process Configuration suffit, et chaque type de work item peut recevoir sa propre configuration.

## Bénéfices

Child Items Presentation transforme l'éditeur du work item parent en véritable poste de pilotage de ses enfants. Les équipes gagnent une vision consolidée de leurs hiérarchies, peuvent éditer en masse des dizaines d'enfants sans ouvrir chaque éditeur, ajoutent et retirent des liens directement depuis le parent, et conservent le filet de sécurité de Cancel à tout moment.

Parce qu'il s'inscrit rigoureusement dans le cycle Save / Cancel natif d'EWM et qu'il s'appuie sur les composants internes officiels, le plugin n'introduit aucune nouvelle habitude à acquérir côté utilisateur, aucun risque de désynchronisation avec le modèle de données Jazz, et aucun re-déploiement pour adapter l'affichage à un nouveau projet ou à un nouveau type de work item.
