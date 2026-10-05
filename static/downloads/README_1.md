# ChangeReqIf

Utilitaire Windows qui répare et normalise un export **ReqIF** (`.reqifz`) :

1. **Restauration des extensions des pièces jointes** : pour chaque pièce jointe, détecte le **vrai type de fichier** (via sa signature binaire) et lui applique la bonne extension — à la fois sur le fichier et dans les références du `.reqif`.
2. **Conformité du schéma XHTML ReqIF** : corrige automatiquement les non-conformités XSD (ex: texte direct et balises `<br/>` non encapsulés dans des `<blockquote>`), évitant ainsi les rejets stricts lors de la réimportation.
3. **Reconstruction d'archive** : produit une archive `<nom>.changed.reqifz` propre et prête à être réimportée.

Le fichier d'origine n'est jamais modifié : une nouvelle archive `.changed.reqifz` est produite à côté.

## Pourquoi

* **Pièces jointes sans extension** : dans beaucoup d'exports ReqIF (DOORS, DOORS Next, PTC...), les pièces jointes sont stockées sans extension (noms GUID). Sans extension, l'outil de lecture ou de gestion des exigences n'affiche pas correctement les images et documents intégrés.
* **Erreurs de validation de schéma XSD** : certains générateurs ReqIF produisent du XHTML non conforme aux spécifications strictes du W3C et du standard ReqIF (par exemple, des éléments *inline* ou du texte brut placés directement sous un `<blockquote>` sans balise `<p>`), ce qui bloque l'importation avec des erreurs de type `cvc-complex-type.2.4.a`.

## Fichiers

Deux fichiers, à garder **ensemble dans le même dossier** :

| Fichier | Rôle |
|---|---|
| `change.bat` | Le lanceur — c'est celui qu'on exécute en ligne de commande. |
| `change.ps1` | Toute la logique (détection dynamique du `.reqif`, assainissement XHTML, renommage binaire et reconstruction). |

## Pré-requis

* **Windows** avec **PowerShell 5.0 ou supérieur** (intégré par défaut sur Windows 10/11).
* Aucune modification de sécurité requise : le lanceur fonctionne même si l'exécution des scripts `.ps1` est restreinte (`ExecutionPolicy` sur *Restricted*, y compris via GPO).

## Utilisation

Dans une invite de commandes (`cmd`), depuis le dossier contenant le fichier :

```bat
change.bat "MonFichier.reqifz"
```

> **Note :** Conservez les guillemets si le chemin ou le nom du fichier contient des espaces.

### Résultat

Un fichier `MonFichier.changed.reqifz` est généré dans le même répertoire.

## Fonctionnalités & Détections

### Détection dynamique du fichier ReqIF
Le script recherche automatiquement le fichier `.reqif` présent à la racine de l'archive (qu'il se nomme `Requirements.reqif`, `Export.reqif` ou tout autre nom).

### Correction XHTML automatique
* Repère les balises `<blockquote>` (avec ou sans namespace, tel que `reqif-xhtml:blockquote`) contenant du texte libre ou des balises orphelines (`<br/>`).
* Encapsule automatiquement le contenu dans un paragraphe `<p>` conforme sans altérer le texte d'origine.

### Types de fichiers détectés
La détection s'appuie sur les « magic bytes » (signature binaire) du fichier :

* **Images** : `png`, `jpg`, `gif`, `bmp`, `tif`, `emf`, `wmf`
* **Documents** : `pdf`, `rtf`
* **Office récent (OOXML)** : `docx`, `xlsx`, `pptx`
* **Office hérité (OLE compound)** : `doc`, `xls`, `ppt`

Un fichier dont le type n'est **pas reconnu** est laissé intact (aucune extension arbitraire n'est ajoutée). Un fichier portant déjà la bonne extension n'est pas modifié.

## Déroulé du traitement

1. Extraction temporaire de l'archive `.reqifz`.
2. Détection dynamique du fichier principal `.reqif`.
3. Correction de structure XHTML pour satisfaire les contraintes du schéma XSD.
4. Analyse binaire de toutes les pièces jointes et renommage si nécessaire.
5. Mise à jour de toutes les références dans le fichier `.reqif` en une seule passe globale.
6. Recompression de l'archive vers `<nom>.changed.reqifz`.

## Dépannage

* **`Aucun fichier .reqif n'a été trouvé`** : l'archive fournie n'est pas un export ReqIF valide ou le fichier `.reqif` est manquant.
* **`change.ps1 est introuvable`** : vérifiez que `change.bat` et `change.ps1` sont situés dans le même répertoire.
* **Cas d'environnements très verrouillés (WDAC / AppLocker en Constrained Language Mode)** : si l'exécution en mémoire est interceptée par la politique de sécurité de l'entreprise, le script doit être signé numériquement.