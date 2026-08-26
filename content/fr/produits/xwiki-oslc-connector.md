---
title: "Syncheo Connect — Connecteur XWiki ↔ IBM Jazz (OSLC)"
subtitle: "Reliez nativement vos pages XWiki aux artefacts d'ingénierie IBM Jazz, grâce au standard OSLC"
date: 2026-08-26T10:00:00+01:00
draft: false
author: "Syncheo"
description: "Un connecteur OSLC natif entre XWiki et IBM Jazz (ELM) : créez des liens de traçabilité entre vos pages de documentation et vos exigences, tickets ou tests, avec aperçu et édition directement depuis Jazz."
summary: "Notre connecteur XWiki–OSLC fait dialoguer votre wiki de documentation et votre plateforme d'ingénierie IBM Jazz. Liens de traçabilité bidirectionnels, aperçu natif des artefacts Jazz dans XWiki, édition d'une page XWiki depuis l'aperçu Jazz, sélecteur OSLC délégué, intégration au menu Jazz et authentification partagée — le tout sans quitter ses outils."
tags: ["XWiki", "IBM Jazz", "OSLC", "ELM", "Traçabilité", "Syncheo"]
translationKey: "xwiki-oslc-connector"
banner: "img/banners/xwiki-oslc-banner.png"
---

Dans la plupart des organisations d'ingénierie, la documentation vit d'un côté et les artefacts d'ingénierie de l'autre. Les équipes rédigent leurs spécifications, guides d'architecture et notes de conception dans un wiki comme **XWiki**, tandis que leurs exigences, tickets et campagnes de test sont gérés dans **IBM Jazz (Engineering Lifecycle Management)**. Les deux mondes se répondent en permanence — mais rien ne les relie.

Notre **connecteur XWiki–OSLC** comble ce fossé. Il fait de XWiki et d'IBM Jazz deux outils qui se parlent nativement, via le standard ouvert **OSLC**, pour que la documentation et l'ingénierie ne forment plus qu'un seul fil de traçabilité.

---

## Qu'est-ce que XWiki ?

**XWiki** est une plateforme wiki open source de niveau entreprise, pensée pour la gestion collaborative de la connaissance. Bien au-delà d'un simple wiki, XWiki permet de créer de véritables applications structurées : bases documentaires, référentiels, procédures, pages de spécification riches, le tout versionné, avec gestion fine des droits et un moteur d'extensions puissant.

C'est un choix fréquent dans les grandes organisations pour centraliser la documentation technique et fonctionnelle, précisément parce qu'il est ouvert, extensible et hébergeable sur site.

Pour en savoir plus sur XWiki : [xwiki.org](https://www.xwiki.org).

---

## Qu'est-ce qu'OSLC ?

**OSLC (Open Services for Lifecycle Collaboration)** est un standard ouvert d'intégration des outils du cycle de vie de l'ingénierie. Fondé sur les principes du *linked data*, il définit une façon commune pour des outils différents de se référencer, de s'afficher les uns les autres et de créer des liens durables entre leurs ressources — sans imposer de synchronisation lourde ni de duplication des données.

IBM Jazz implémente OSLC nativement. En rendant XWiki compatible OSLC, notre connecteur permet aux deux plateformes de collaborer avec les mêmes mécanismes standards qu'IBM utilise déjà entre ses propres outils (DOORS Next, EWM, ETM…).

---

## Ce que fait le connecteur

### Des liens de traçabilité OSLC entre XWiki et Jazz

Le cœur du connecteur : créer des liens de traçabilité entre une page XWiki et un artefact Jazz — une exigence, un work item, un cas de test. Ces liens sont bidirectionnels et navigables : depuis Jazz, on remonte à la page de documentation qui explique le « pourquoi » ; depuis XWiki, on descend vers l'exigence ou le ticket qui matérialise le « comment ». La documentation cesse d'être un document mort à côté du projet : elle devient un maillon tracé de la chaîne d'ingénierie.

### Un aperçu natif des artefacts Jazz dans XWiki

Quand une page XWiki référence un artefact Jazz, le connecteur en affiche un **aperçu natif** directement dans la page, grâce au rendu compact OSLC. Au survol du lien, l'utilisateur voit le titre, le statut et les informations clés de l'artefact sans quitter XWiki ni ouvrir Jazz. La documentation reste à jour visuellement, en temps réel, avec l'état réel de l'ingénierie.

### XWiki exposé comme fournisseur OSLC

Le connecteur ne se contente pas de consommer les ressources Jazz : il expose **les pages XWiki elles-mêmes comme des ressources OSLC**. Vos pages de documentation deviennent des artefacts liables, consommables par IBM Jazz (ELM, DOORS Next…) comme n'importe quelle autre ressource du cycle de vie. Un ingénieur peut ainsi, depuis une exigence, pointer vers la page XWiki qui la spécifie — et Jazz saura l'afficher.

### Un sélecteur délégué (Delegated UI) standard

Créer un lien ne demande aucune manipulation d'URL ni copier-coller. Le connecteur s'appuie sur l'**interface déléguée OSLC** : depuis Jazz, un sélecteur s'ouvre pour rechercher et choisir la page XWiki à lier — et inversement — dans une fenêtre standard, sans quitter l'outil d'origine. C'est le même geste, familier, que celui utilisé nativement entre les outils IBM.

### Éditer une page XWiki depuis l'aperçu Jazz

Le connecteur va plus loin que la simple consultation : depuis l'aperçu d'un lien XWiki affiché dans Jazz, l'utilisateur peut **modifier directement la page XWiki**, sans changer d'application. La documentation se corrige et s'enrichit à l'endroit même où le besoin apparaît — au fil du travail d'ingénierie.

### Intégré au menu de Jazz

Le connecteur s'intègre **directement dans le menu d'IBM Jazz**. Les fonctions liées à XWiki sont accessibles là où les ingénieurs travaillent déjà, sans outil tiers à ouvrir ni contexte à changer. L'adoption est immédiate parce que rien ne bouge dans les habitudes des équipes.

### Une authentification partagée avec Jazz

Pas de second compte, pas de nouvelle connexion à gérer. Le connecteur **partage l'interface d'authentification avec Jazz** : l'utilisateur déjà connecté à sa plateforme d'ingénierie accède à XWiki de façon transparente. Moins de friction pour les équipes, et une gestion des accès simplifiée pour les administrateurs.

---

## Comment ça se passe en pratique

**1. Un ingénieur rédige une spécification dans XWiki**
La page décrit le contexte, les choix d'architecture et les règles métier. C'est le « pourquoi » du projet.

**2. Il la relie à une exigence dans Jazz**
Depuis l'exigence, il ouvre le sélecteur OSLC, retrouve la page XWiki et crée le lien. Aucune URL à copier, aucune configuration technique.

**3. La traçabilité devient vivante**
Dans Jazz, l'exigence affiche désormais un aperçu de la page XWiki, avec son titre et son état, mis à jour en temps réel. Dans XWiki, la page pointe en retour vers l'exigence.

**4. La documentation évolue sans quitter le flux de travail**
Un détail à préciser ? L'ingénieur édite la page XWiki directement depuis l'aperçu affiché dans Jazz. Documentation et ingénierie avancent ensemble, au même rythme.

---

## Conclusion

Notre connecteur XWiki–OSLC réconcilie deux mondes qui devraient toujours avoir dialogué : la connaissance documentée dans XWiki et les artefacts d'ingénierie gérés dans IBM Jazz. En s'appuyant sur le standard ouvert OSLC — celui-là même qu'IBM utilise entre ses propres outils — il crée une traçabilité native, bidirectionnelle et sans duplication, là où il n'existait qu'un fossé.

**Vous souhaitez en savoir plus ou organiser une démonstration ?** [Contactez-nous](/fr/contact).
