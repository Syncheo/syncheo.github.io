---
title: "ReqIF : quand les pièces jointes DOORS deviennent invisibles après import"
date: 2026-07-30T10:00:00+02:00
draft: false
tags: ["ReqIF", "IBM DOORS", "DOORS Next", "Ingénierie des exigences", "ALM", "PowerShell", "Syncheo"]
categories: ["Expertise Technique"]
author: "Syncheo Engineering"
description: "Après un export ReqIF depuis IBM DOORS, les images et objets OLE ne s'affichent plus dans l'outil cible. Explication de la cause racine et utilitaire PowerShell qui rend leur extension aux pièces jointes en s'appuyant sur la signature binaire."
banner: "img/blog/reqif-attachments-banner.png"
translationKey: "reqif-pieces-jointes-doors"
---

Vous exportez un module depuis **IBM DOORS** ou **DOORS Next Generation** au format **ReqIF** (`.reqifz`), vous l'importez dans un autre outil de gestion des exigences, et le texte arrive correctement — mais les **images et objets embarqués restent vides**. C'est un cas classique d'échange ReqIF, et la cause est plus subtile qu'un simple problème de compatibilité. Cet article explique la cause du problème et propose un utilitaire prêt à l'emploi pour le corriger.

<!--more-->

## En bref

Un fichier `.reqifz` est une archive ZIP contenant `Requirements.reqif` et l'ensemble des pièces jointes. DOORS y stocke ces pièces jointes **sans extension** (leurs noms sont des GUID du type `_3dcc85d5-...`). L'outil cible se fie à l'extension pour savoir comment afficher un fichier : privé d'extension, il ne l'affiche pas. L'utilitaire présenté ici — `change.bat` + `change.ps1` — détecte le **vrai type de chaque pièce jointe par sa signature binaire**, lui rend son extension, met à jour toutes les références dans `Requirements.reqif`, et reconstruit une archive `.changed.reqifz` réimportable.

---

## Le problème

Le format ReqIF (*Requirements Interchange Format*) est un standard de l'OMG conçu précisément pour échanger des exigences entre outils hétérogènes. En pratique, l'échange du texte fonctionne bien ; ce sont les **pièces jointes embarquées** — captures d'écran, schémas, objets OLE issus de Word ou Excel — qui posent problème lors d'un aller-retour DOORS ↔ autre outil.

Le flux est le suivant : DOORS produit une archive `.reqifz`, qui contient le document XML `Requirements.reqif` accompagné des fichiers binaires des pièces jointes. Ces fichiers sont nommés d'après un identifiant unique (GUID) **et ne portent aucune extension**. L'outil qui importe l'archive détermine le mode d'affichage à partir de l'extension du fichier ; en son absence, il ne sait pas qu'il s'agit d'un PNG ou d'un PDF, et n'affiche rien.

## Pourquoi ça casse

Trois mécanismes se combinent pour produire ce résultat.

**Le stockage sans extension.** C'est la cause immédiate. DOORS exporte les pièces jointes sous leur nom interne (GUID), sans suffixe de type. Un outil cible strict ne devine pas le type à partir du contenu et se contente de l'extension — qui n'existe pas.

**Les aperçus des objets OLE.** Conformément à la norme ReqIF, un objet qui n'est pas une image (un tableau Excel, un document Word) est enrobé d'une **image d'aperçu**. On retrouve donc des paires de fichiers : un fichier de base déclaré `type="text/rtf"` et son `_<guid>_alternative_image.png` déclaré `type="image/png"`. Les références se font dans le XML via des balises `<object data="nom" type="mime/type">`. Une option d'export de DOORS convertit par ailleurs certains objets OLE en `.rtf`, ce qui ajoute encore de la variété aux types présents.

**Le type MIME n'est pas fiable.** On pourrait être tenté de se fier au `type` MIME déclaré dans le XML pour rebaptiser les fichiers. C'est un piège. Sur un export réel de **461 fichiers**, **55 (soit 12 %) étaient en réalité des PNG mais étiquetés `text/rtf`** par DOORS — confirmé par l'outil `file`. Renommer ces fichiers d'après leur MIME les aurait transformés en `.rtf` et aurait cassé leur affichage. La **signature binaire (les *magic bytes*) est la seule source de vérité** ; le MIME ne sert que de repli pour les types exotiques que la signature ne couvre pas.

## La solution

L'utilitaire tient en deux fichiers à conserver dans le même dossier : `change.bat`, le lanceur, et `change.ps1`, qui contient toute la logique. Il procède ainsi : il extrait l'archive, détecte le vrai type de chaque pièce jointe par sa signature binaire (avec repli sur le MIME si nécessaire), renomme chaque fichier avec la bonne extension **et** met à jour toutes ses références dans `Requirements.reqif` en une seule passe, puis reconstruit une archive `<nom>.changed.reqifz` prête à être réimportée. Le fichier d'origine n'est jamais modifié.

Deux détails d'implémentation méritent d'être soulignés. Le remplacement des noms dans le XML est **sûr vis-à-vis des noms imbriqués** : le nom d'un fichier de base n'est jamais altéré à l'intérieur du nom plus long de son aperçu `_alternative_image.png`, et l'encodage du `.reqif` est préservé par une lecture-écriture octet-à-octet. Par ailleurs, le lanceur `.bat` charge le code PowerShell **en mémoire**, ce qui contourne une `ExecutionPolicy` positionnée sur *Restricted* — l'utilitaire fonctionne donc même sur un poste verrouillé par GPO.

### Utilisation

Depuis une invite de commande, dans le dossier contenant le `.reqifz` :

```bat
change.bat "MonFichier.reqifz"
```

Le résultat est un fichier `MonFichier.changed.reqifz` créé à côté de l'original. Conservez les guillemets si le chemin contient des espaces.

### Types de fichiers gérés

La détection couvre les images (`png`, `jpg`, `gif`, `bmp`, `tif`, `emf`, `wmf`), les documents (`pdf`, `rtf`), l'Office récent au format OOXML (`docx`, `xlsx`, `pptx`) et l'Office ancien au format OLE (`doc`, `xls`, `ppt`). Un fichier dont le type n'est pas reconnu est laissé intact plutôt que de se voir attribuer une extension à l'aveugle. Sur l'export réel de validation, l'utilitaire a traité l'ensemble sans aucun type non reconnu ni incohérence introduite, la mise à jour d'un `.reqif` de 15 Mo prenant environ 0,3 seconde.

## Autres approches

Le script est un contournement efficace, mais ce n'est pas la seule voie. Selon votre marge de manœuvre, corriger le problème plus en amont peut être préférable.

| Approche | Principe | Quand la privilégier |
|----------|----------|----------------------|
| **À la source** | Ajuster les paramètres d'export ReqIF de DOORS (notamment le réglage de conversion OLE → RTF) pour coller à ce que l'outil cible sait lire. | Vous maîtrisez la configuration d'export DOORS et l'échange est récurrent. |
| **Outil cible conforme** | Utiliser un importeur qui respecte la norme (lecture du MIME et des références d'objets), comme ReqView, Polarion ou Jama (DX). | Le choix de l'outil cible est encore ouvert, ou son importeur est configurable. |
| **Script de post-traitement** | Rendre les extensions après export, en se fiant à la signature binaire (l'utilitaire présenté ici). | L'export et l'outil cible sont figés et il faut une solution immédiate côté fichier. |

Une nuance importante : la documentation de **Jama déconseille explicitement de renommer les extensions** des pièces jointes. Le script assume donc son statut de contournement, spécifique à un couple export DOORS / outil cible donné. Si vous pouvez agir à la source ou choisir un importeur conforme, ces options sont plus pérennes.

## Téléchargements

Les deux fichiers de l'utilitaire, ainsi que sa documentation :

<a href="/downloads/change.bat" download><code>change.bat</code></a> — le lanceur (à exécuter)<br>
<a href="/downloads/change.ps1" download><code>change.ps1</code></a> — la logique de détection et de reconstruction<br>
<a href="/downloads/README.md" download><code>README.md</code></a> — documentation complète (pré-requis, dépannage, notes techniques)

Gardez `change.bat` et `change.ps1` **dans le même dossier**. Pré-requis : Windows avec PowerShell 5.0 ou supérieur (présent par défaut sur Windows 10/11).

## Sources

- [Why OLE object is not visible after importing ReqIF file into DOORS — jazz.net](https://jazz.net/forum/questions/241237/why-ole-object-is-not-visible-after-importing-reqif-file-in-to-doors)
- [ReqIF roundtrip to DOORS NG — problem with images — reqif.academy](https://www.reqif.academy/forums/topic/reqif-roundtrip-to-doors-ng-problem-with-images/)
- [ReqIF export without images — jazz.net](https://jazz.net/forum/questions/266492/reqif-export-without-images)
- [Handling OLEs and RTF Files in DX Imports from DOORS to Jama — Jama Software](https://support.jamasoftware.com/hc/en-us/articles/34970364995213-Handling-OLEs-and-RTF-Files-in-DX-Imports-from-DOORS-to-Jama)
- [ReqIF Import/Export — Polarion](https://qademo.polarion.com/polarion/help/topic/com.polarion.xray.doc.user/ugDocsReqIfImportExport.html)
- [Import ReqIF — ReqView](https://www.reqview.com/doc/import-reqif/)
- [Requirements Interchange Format — Wikipedia](https://en.wikipedia.org/wiki/Requirements_Interchange_Format)
