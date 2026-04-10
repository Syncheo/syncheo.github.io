---
title: "Reverse Proxy pour IBM Jazz ELM : Guide Complet Nginx & IHS"
date: 2026-03-27T12:00:00+01:00
draft: false
tags: ["IBM Jazz", "ELM", "Nginx", "IHS", "Reverse Proxy", "SSL", "CORS", "DevOps"]
categories: ["Expertise Technique"]
author: "Syncheo Engineering"
description: "Comment configurer un reverse proxy Nginx ou IBM HTTP Server devant une plateforme IBM ELM (JTS, CCM, QM, RM, GC) — SSL, CORS, réécriture d'URL et guide de renommage des serveurs."
banner: "img/blog/reverse-proxy-jazz-banner.png"
translationKey: "reverse-proxy-jazz"
---

Exposer une plateforme IBM ELM (Engineering Lifecycle Management) derrière un reverse proxy est une étape incontournable pour tout déploiement en production. Cela permet de centraliser les accès, gérer les certificats SSL en un seul endroit et rendre l'URL publique indépendante de l'infrastructure interne.

<!--more-->

Ce guide couvre deux implémentations : **Nginx** (solution open-source répandue) et **IBM HTTP Server (IHS)** (le serveur Apache fourni par IBM, recommandé pour ELM). Les configurations présentées ont été validées en production sur des environnements Jazz multi-serveurs.

---

## Architecture Cible

```
Internet
    │
    ▼
[Reverse Proxy : 443]          ← URL publique unique
    │
    ├──→ jazz1:9443  (JTS, RM)
    ├──→ jazz2:9443  (CCM, QM)
    └──→ jazz3:9443  (GC, RS)
```

Le reverse proxy est le seul point exposé sur Internet. Les serveurs Jazz internes communiquent entre eux via leurs URLs internes (port 9443), et le proxy se charge de tout adapter.

---

## Les 5 Défis Techniques à Résoudre

### 1. Réécriture des URLs dans les réponses Jazz

Jazz intègre ses propres URLs dans les réponses HTTP (headers `Location`, contenu HTML, JSON, JavaScript). Si ces URLs pointent vers `jazz1:9443` et que l'utilisateur accède depuis `jazz.mondomaine.net`, tout se casse.

**Solution Nginx** — directive `sub_filter` :
```nginx
sub_filter "https://jazz1.syncheo.tech:9443" "https://jazz1.syncheo.tech";
sub_filter ':9443/' '/';
sub_filter_once off;
```

> ⚠️ **Piège Nginx** : `sub_filter` n'interpole pas les variables `$host`. Il faut utiliser une `map{}` pour créer des variables statiques par hostname.

**Solution IHS** — directive `ProxyHTMLURLMap` :
```apache
ProxyHTMLURLMap https://jazz1\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz2\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz3\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

`ProxyHTMLURLMap` est plus puissant que `sub_filter` : il parse réellement le HTML et comprend la structure des attributs (`href`, `src`, `action`…).

---

### 2. Décompression des réponses avant réécriture

Jazz compresse ses réponses en gzip. Un proxy ne peut pas réécrire du texte compressé.

**Solution Nginx** :
```nginx
proxy_set_header Accept-Encoding "";
```
On demande à Jazz de ne pas compresser en supprimant le header `Accept-Encoding`.

**Solution IHS** :
```apache
RequestHeader unset Accept-Encoding
SetOutputFilter INFLATE;PROXY-HTML
```
IHS offre une option plus élégante : `INFLATE` décompresse la réponse à la volée avant que `PROXY-HTML` ne la réécrive, puis la recomprime pour le client.

---

### 3. Réécriture des headers de redirection

Quand Jazz émet une redirection HTTP (`Location: https://jazz1:9443/jts/...`), le navigateur suivrait l'URL interne. Il faut intercepter ces headers.

**Nginx** :
```nginx
proxy_redirect https://127.0.0.1:9443/  /;
proxy_redirect ~*^https://jazz[1-3]\.kse\.ksegroup\.net:9443(/.*)$  $1;
```

**IHS** :
```apache
ProxyPassReverse / https://127.0.0.1:9443/
ProxyPassReverse / https://jazz1.syncheo.tech:9443/
ProxyPassReverse / https://jazz2.syncheo.tech:9443/
ProxyPassReverse / https://jazz3.syncheo.tech:9443/
```

---

### 4. CORS pour les applications Jazz

Jazz utilise des requêtes cross-origin (OSLC, widgets EWM, API REST). Le header `Access-Control-Allow-Origin` ne supporte pas le wildcard `*` quand `credentials: true` est requis — il faut une valeur dynamique.

**Piège Nginx** — les blocs `if()` n'héritent pas des `add_header` du parent. Il faut **redéclarer tous les headers CORS** dans le bloc `OPTIONS` :

```nginx
if ($request_method = 'OPTIONS') {
    add_header 'Access-Control-Allow-Origin'      '$cors_origin' always;
    add_header 'Access-Control-Allow-Methods'     'GET, POST, OPTIONS, PUT, DELETE, PATCH' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    add_header 'Access-Control-Allow-Headers'     '...' always;
    add_header 'Access-Control-Max-Age'           1728000;
    return 204;
}
```

**IHS** gère cela proprement avec `<If>` qui hérite bien du contexte parent :

```apache
<If "%{REQUEST_METHOD} == 'OPTIONS'">
    Header always set Access-Control-Max-Age "1728000"
    Return 204
</If>
```

---

### 5. SSL vers le backend Jazz

Les serveurs Jazz utilisent souvent des certificats auto-signés en interne.

**Nginx** — désactivation implicite via `proxy_pass https://` (accepte tout par défaut).

**IHS** — désactivation explicite requise :
```apache
SSLProxyEngine          on
SSLProxyVerify          none
SSLProxyCheckPeerCN     off
SSLProxyCheckPeerName   off
SSLProxyCheckPeerExpire off
```

> 💡 Mettre `SSLProxyVerify require` si les backends ont des certificats valides — meilleure pratique de sécurité.

---

## Guide de Renommage des Serveurs

Voici les endroits **précis** à modifier quand vous renommez vos serveurs Jazz.

### Cas 1 — Changement du nom de domaine public

Exemple : `jazz.syncheo.tech` → `jazz.monentreprise.com`

| Fichier | Directive | Ancienne valeur | Nouvelle valeur |
|---|---|---|---|
| nginx.conf | `server_name` | `jazz[1-3].kse...` | `jazz[1-3].monentreprise.com` |
| nginx.conf | `map $host $internal_url` | clés `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `map $host $external_url` | valeurs `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `if ($http_origin ~*` | regex `jazz[1-3]...` | regex `jazz[1-3]...` |
| ihs.conf | `ServerName` | `jazz.kse...` | `jazz.monentreprise.com` |
| ihs.conf | `ProxyHTMLURLMap` (×3) | `jazz[1-3]...` | `jazz[1-3]...` |
| ihs.conf | `SetEnvIf Origin` | regex `jazz...` | regex `jazz...` |
| ihs.conf | `SSLCertificateFile` | `jazz...crt` | `jazz...crt` |

> ⚠️ **Ne pas oublier** : les Public URIs Jazz sont configurées à l'installation dans l'interface d'administration JTS (`https://votre-jts/jts/admin`). Si vous changez le nom public, il faut aussi les mettre à jour dans Jazz — c'est une opération sensible qui nécessite un redémarrage des services.

---

### Cas 2 — Renommage d'un serveur backend interne

Exemple : `jazz1` → `jazz-prod-jts`

**Dans nginx.conf**, modifier les blocs `map{}` :
```nginx
map $host $internal_url {
    jazz-prod-jts.syncheo.tech  "https://jazz-prod-jts.syncheo.tech:9443";
    # ...
}
```

**Dans ihs.conf**, modifier les `ProxyHTMLURLMap` et `ProxyPassReverse` :
```apache
ProxyPassReverse / https://jazz-prod-jts.syncheo.tech:9443/
ProxyHTMLURLMap https://jazz-prod-jts\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

---

### Cas 3 — Migration vers des serveurs séparés (scale-out)

Quand JTS/RM, CCM/QM et GC/RS migrent chacun sur leur propre machine :

**Nginx** :
```nginx
location ~ ^/(jts|rm) {
    proxy_pass https://10.0.0.1:9443;
    # ... mêmes directives sub_filter, CORS, etc.
}

location ~ ^/(ccm|qm) {
    proxy_pass https://10.0.0.2:9443;
}

location ~ ^/(gc|rs) {
    proxy_pass https://10.0.0.3:9443;
}
```

**IHS** :
```apache
<Location ~ "^/(jts|rm)">
    ProxyPass        https://10.0.0.1:9443
    ProxyPassReverse https://10.0.0.1:9443/
    # ... mêmes directives ProxyHTMLURLMap, CORS, etc.
</Location>
```

---

## Checklist de Validation Post-Configuration

Après toute modification, vérifiez ces points dans l'ordre :

**1. Test SSL** :
```bash
openssl s_client -connect jazz.syncheo.tech:443 -servername jazz.syncheo.tech
```

**2. Test de redirection HTTP→HTTPS** :
```bash
curl -I http://jazz.syncheo.tech
# Attendu : HTTP/1.1 301 Moved Permanently + Location: https://...
```

**3. Test d'accès JTS** :
```bash
curl -k https://jazz.syncheo.tech/jts/auth/authrequired
# Attendu : 200 ou 401 (pas d'erreur proxy)
```

**4. Test CORS preflight** :
```bash
curl -I -X OPTIONS https://jazz.syncheo.tech/jts/ \
  -H "Origin: https://jazz.syncheo.tech" \
  -H "Access-Control-Request-Method: POST"
# Attendu : 204 + Access-Control-Allow-Origin présent
```

**5. Vérification des SANs du certificat** :
```bash
openssl x509 -in /etc/nginx/ssl/jazz.crt -text -noout | grep -A5 "Subject Alternative"
```

---

## Nginx vs IHS : Que Choisir ?

| Critère | Nginx | IBM HTTP Server |
|---|---|---|
| **Recommandation IBM** | Non officielle | ✅ Officielle |
| **Réécriture HTML** | `sub_filter` (textuel) | `mod_proxy_html` (parsing HTML) |
| **Gestion CORS `if()`** | ⚠️ Headers non hérités | ✅ Héritage correct |
| **Gzip transparent** | Désactivation upstream | Décompression à la volée |
| **Performance** | ✅ Excellente | Bonne |
| **Communauté** | Large | IBM Support |

Pour un environnement IBM ELM en production, **IHS est recommandé** — la gestion native de `mod_proxy_html` évite les pièges de `sub_filter`, et le support IBM couvre l'ensemble de la stack.

---

## Conclusion

La configuration d'un reverse proxy devant IBM Jazz est complexe principalement à cause de trois points : la réécriture des URLs internes dans les réponses, la gestion du CORS avec credentials, et le déchiffrement SSL vers les backends. Les configurations présentées ici ont été éprouvées en production et couvrent ces trois aspects.

En cas de doute sur une migration ou un renommage, n'hésitez pas à contacter l'équipe **Syncheo** — c'est exactement le type d'intervention que nous réalisons au quotidien pour nos clients IBM ELM.
