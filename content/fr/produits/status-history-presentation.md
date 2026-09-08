---
title: "Status History Presentation — Widget IBM EWM / Jazz"
subtitle: "Visualisez l'historique des statuts d'un work item sous forme de frise chronologique"
description: "Widget open source (jazz-community) que Syncheo a récupéré sur GitHub et repackagé pour une installation simple sur les dernières versions de Jazz : l'évolution des statuts d'un work item affichée sous forme graphique, directement dans l'éditeur."
date: 2026-09-07T10:00:00+02:00
draft: false
slug: "status-history-presentation"
tags: ["IBM EWM", "ELM", "Jazz", "Work Items", "Open Source", "Historique"]
author: "Syncheo Engineering"
summary: "Un widget open source de la communauté Jazz, récupéré sur GitHub et repackagé par Syncheo pour s'installer facilement sur les dernières versions d'IBM Jazz. Il affiche l'historique des statuts d'un work item sous forme de frise chronologique, directement dans l'éditeur."
banner: "img/banners/status-history-banner.png"
translationKey: "status-history-presentation"
aliases: ["/fr/portfolio/status-history-presentation/"]
---

IBM Engineering Workflow Management (EWM / RTC) conserve tout l'historique d'un work item, mais pour les tickets qui accumulent beaucoup de modifications, il devient très difficile de **suivre l'évolution du statut dans le temps**. **Status History Presentation** est un widget open source de la communauté Jazz qui répond exactement à ce besoin : Syncheo l'a **récupéré sur GitHub et repackagé** pour qu'il s'installe simplement sur les dernières versions d'IBM Jazz. Il affiche, directement dans l'éditeur de work item, une **frise chronologique** des changements de statut.

## Le problème

L'historique natif d'un work item mélange tous les attributs modifiés — résumé, propriétaire, estimation, commentaires — au fil des enregistrements. Pour répondre à une question aussi simple que « quand ce ticket est-il passé *En cours*, et combien de temps est-il resté *En revue* ? », il faut parcourir manuellement des dizaines de lignes et reconstituer mentalement la chronologie. Sur un work item qui vit plusieurs mois, l'exercice est fastidieux et source d'erreurs.

## Une frise, deux modes de lecture

Le widget ne retient que les changements de statut : chaque étape de la vie du ticket devient une pastille sur une ligne de temps, de la création jusqu'à l'état courant. On lit d'un coup d'œil par quels états le work item est passé, dans quel ordre et à quel moment. Le rendu s'appuie sur du SVG, net à tout niveau de zoom. Deux modes d'affichage sont proposés selon ce que l'on souhaite mettre en avant.

### Mode USER — les contributeurs en vedette

<figure class="post-figure post-figure--right post-figure--narrow">
  <img src="/img/portfolio/status-history-user.png" alt="Status History en mode USER : les avatars des contributeurs sur la frise">
  <figcaption>Mode <code>timeline=USER</code> : l'avatar de chaque contributeur sur la frise.</figcaption>
</figure>

En mode USER (`timeline=USER`), le réglage par défaut, chaque étape de la frise affiche la photo de profil de la personne à l'origine du changement. La carte associée rappelle la date et le statut atteint — *En cours*, *Nouveau*, etc. C'est la lecture idéale pour savoir, en un coup d'œil, **qui** a fait avancer le ticket et **quand**, sans ouvrir l'historique complet.

### Mode STATUS — les transitions en vedette

<figure class="post-figure post-figure--left post-figure--narrow">
  <img src="/img/portfolio/status-history-status.png" alt="Status History en mode STATUS : les icônes de statut sur la frise">
  <figcaption>Mode <code>timeline=STATUS</code> : l'icône de chaque statut sur la frise.</figcaption>
</figure>

En mode STATUS (`timeline=STATUS`), ce sont les icônes de statut qui occupent la frise, tandis que la carte met en avant l'auteur du changement. L'accent porte alors sur les **transitions elles-mêmes** : on suit le cheminement du ticket à travers ses états successifs, l'information sur les personnes passant au second plan.

## Historique détaillé au survol

L'option `enableDetailedHistory` contrôle le niveau de détail affiché au survol d'une étape de la frise.

### Vue détaillée (`enableDetailedHistory = true`)

<figure class="post-figure post-figure--right">
  <img src="/img/portfolio/status-history-detailed.png" alt="Infobulle détaillée avec enableDetailedHistory activé">
  <figcaption>Infobulle complète : tous les attributs du work item à cet instant de son histoire.</figcaption>
</figure>

Activée, elle déploie au survol une infobulle complète reprenant l'ensemble des attributs du work item tels qu'ils étaient à ce moment précis de son histoire : récapitulatif, description, type, gravité, priorité, planification, ID, souscripteurs… Un instantané complet sans quitter l'éditeur, utile pour comprendre le contexte exact d'un changement d'état.

### Vue compacte (`enableDetailedHistory = false`)

<figure class="post-figure post-figure--left">
  <img src="/img/portfolio/status-history-not-detailed.png" alt="Infobulle compacte avec enableDetailedHistory désactivé">
  <figcaption>Infobulle compacte : auteur, date et statut.</figcaption>
</figure>

Désactivée, le survol se limite à une infobulle compacte : auteur, date et statut atteint. C'est le bon compromis lorsqu'on privilégie la lisibilité et la performance, notamment sur des work items à l'historique très fourni.

D'autres options de confort complètent le tableau, comme des icônes agrandies ou un indicateur d'échéance (`soonDays`) qui signale par un code couleur les délais proches. Techniquement, il s'agit d'une *Non-Attribute-based Presentation* : une section que l'on ajoute à la configuration de l'éditeur de work item depuis l'administration de la zone de projet (Work Items → Editor Presentations), sans développement côté serveur.

## Installation simplifiée par Syncheo

Le projet d'origine était initialement vérifié à partir de RTC 6.0.3. Syncheo l'a repackagé sous forme d'update-site prêt à déployer, aligné sur les **dernières versions de la plateforme IBM Jazz** : plus besoin de reconstruire le build ni de l'adapter aux versions récentes, l'installation se fait directement.

## Origine et licence

Status History Presentation est un projet open source de la **[jazz-community](https://github.com/jazz-community/rtc-statushistory-presentation)**, publié sous **licence MIT** (© **Siemens AG**) ; il intègre l'icône de calendrier de Font Awesome (CC BY 4.0). Le travail de Syncheo porte sur le repackaging et l'adaptation aux dernières versions de Jazz, dans le respect de cette licence.

## Compatibilité

Le widget cible **IBM Engineering Workflow Management (EWM / RTC)** sur les plateformes Jazz récentes. Il fonctionne dans tous les navigateurs modernes supportés par EWM : Chrome, Edge, Firefox.

## Le dépôt d'origine

Le projet open source d'origine est disponible sur GitHub : [jazz-community/rtc-statushistory-presentation](https://github.com/jazz-community/rtc-statushistory-presentation).
