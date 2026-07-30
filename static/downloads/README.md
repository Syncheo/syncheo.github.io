# ChangeReqIf

Utilitaire Windows qui corrige un export **ReqIF** (`.reqifz`) : pour chaque
pièce jointe, il détecte le **vrai type de fichier** (via sa signature binaire)
et lui applique la bonne extension — à la fois sur le fichier et dans les
références de `Requirements.reqif` — puis reconstruit une archive
`<nom>.changed.reqifz` prête à être réimportée.

Le fichier d'origine n'est pas modifié : une nouvelle archive `.changed.reqifz`
est produite à côté.

## Pourquoi

Dans un export ReqIF, les pièces jointes sont souvent stockées **sans
extension** (noms de type GUID). Sans extension, l'outil de lecture des
exigences n'affiche pas correctement les images ou documents. Ce script leur
rend leur extension d'origine en se basant sur le contenu réel du fichier, et
non sur une supposition.

## Fichiers

Deux fichiers, à garder **ensemble dans le même dossier** :

| Fichier | Rôle |
|---------|------|
| `change.bat` | Le lanceur — c'est celui qu'on exécute. |
| `change.ps1` | Toute la logique (détection, renommage, reconstruction). |

## Pré-requis

- **Windows** avec **PowerShell 5.0 ou supérieur** (présent par défaut sur
  Windows 10/11).
- Aucune configuration nécessaire : le lanceur fonctionne même si l'exécution
  des scripts `.ps1` est désactivée (`ExecutionPolicy` sur *Restricted*, y
  compris imposée par GPO). Le code est chargé en mémoire et exécuté, ce qui
  n'est pas soumis à cette restriction.

## Utilisation

Dans une invite de commande, depuis le dossier contenant le `.reqifz` :

```bat
change.bat "MonFichier.reqifz"
```

> Gardez les guillemets si le chemin contient des espaces.

### Exemple

```bat
change.bat "MonFichier.reqifz"
```

Résultat : un fichier `MonFichier.reqifz` est créé dans
le même dossier.

## Types de fichiers détectés

La détection se fait sur la signature (« magic bytes »), indépendamment du nom :

- **Images** : `png`, `jpg`, `gif`, `bmp`, `tif`, `emf`, `wmf`
- **Documents** : `pdf`, `rtf`
- **Office récent (OOXML)** : `docx`, `xlsx`, `pptx`
- **Office ancien (OLE)** : `doc`, `xls`, `ppt`

Un fichier dont le type n'est **pas reconnu** est laissé intact (aucune
extension n'est ajoutée à l'aveugle). Un fichier qui porte déjà la bonne
extension n'est pas retouché.

## Déroulé

1. Extraction de l'archive `.reqifz` dans un dossier temporaire.
2. Détection du type de chaque pièce jointe.
3. Renommage des fichiers concernés + mise à jour de toutes leurs références
   dans `Requirements.reqif`, en une seule passe.
4. Reconstruction de l'archive `<nom>.changed.reqifz`.

## Notes techniques

- **Performance** : la mise à jour du `.reqif` se fait en une seule passe
  (une regex regroupant tous les noms), adaptée aux exports de plusieurs Mo
  contenant des centaines de pièces jointes.
- **Sûreté des remplacements** : un nom n'est jamais remplacé à l'intérieur
  d'un nom plus long (par ex. le préfixe d'un fichier `..._alternative_image.png`
  n'est pas altéré). L'encodage du `.reqif` est préservé (lecture/écriture
  octet-à-octet).
- **Détection Office ancien** : heuristique (recherche des noms de flux internes
  dans l'en-tête du fichier). Fiable en pratique.

## Dépannage

- **« l'exécution de scripts est désactivée sur ce système »** en lançant
  directement `change.ps1` : c'est normal. Utilisez `change.bat`, prévu pour
  contourner cette restriction.
- **« change.ps1 est introuvable »** : vérifiez que `change.bat` et `change.ps1`
  sont bien dans le même dossier.
- **`Requirements.reqif introuvable`** : l'archive fournie n'est pas un export
  ReqIF valide (le fichier `Requirements.reqif` est attendu à sa racine).
- **Cas très verrouillés (AppLocker / WDAC en *Constrained Language Mode*)** :
  même le lanceur peut être bloqué ; il faudrait alors signer le script.
