---
title: "Reverse Proxy für IBM Jazz ELM: Vollständiger Nginx- & IHS-Leitfaden"
date: 2026-03-27T12:00:00+01:00
draft: false
tags: ["IBM Jazz", "ELM", "Nginx", "IHS", "Reverse Proxy", "SSL", "CORS", "DevOps"]
categories: ["Technische Expertise"]
author: "Syncheo Engineering"
description: "So konfigurieren Sie einen Nginx- oder IBM-HTTP-Server-Reverse-Proxy vor einer IBM-ELM-Plattform (JTS, CCM, QM, RM, GC) — SSL, CORS, URL-Umschreibung und ein Leitfaden zur Server-Umbenennung."
banner: "img/blog/reverse-proxy-jazz-banner.png"
translationKey: "reverse-proxy-jazz"
---

Eine IBM-ELM-Plattform (Engineering Lifecycle Management) hinter einem Reverse Proxy bereitzustellen, ist ein unverzichtbarer Schritt für jedes Produktiv-Deployment. Damit lassen sich Zugriffe zentralisieren, SSL-Zertifikate an einer einzigen Stelle verwalten und die öffentliche URL unabhängig von der internen Infrastruktur halten.

<!--more-->

Dieser Leitfaden behandelt zwei Implementierungen: **Nginx** (die weit verbreitete Open-Source-Lösung) und **IBM HTTP Server (IHS)** (der von IBM ausgelieferte, auf Apache basierende Server, empfohlen für ELM). Die hier gezeigten Konfigurationen wurden produktiv auf Jazz-Umgebungen mit mehreren Servern validiert.

---

## Zielarchitektur

```
Internet
    │
    ▼
[Reverse Proxy: 443]           ← einzige öffentliche URL
    │
    ├──→ jazz1:9443  (JTS, RM)
    ├──→ jazz2:9443  (CCM, QM)
    └──→ jazz3:9443  (GC, RS)
```

Der Reverse Proxy ist der einzige zum Internet exponierte Punkt. Die internen Jazz-Server kommunizieren untereinander über ihre internen URLs (Port 9443), und der Proxy übernimmt die gesamte Anpassung.

---

## Die 5 zu lösenden technischen Herausforderungen

### 1. Umschreiben der URLs in Jazz-Antworten

Jazz bettet eigene URLs in die HTTP-Antworten ein (`Location`-Header, HTML-Inhalt, JSON, JavaScript). Zeigen diese URLs auf `jazz1:9443`, während der Benutzer über `jazz.meinedomain.net` zugreift, bricht alles zusammen.

**Nginx-Lösung** — die Direktive `sub_filter`:
```nginx
sub_filter "https://jazz1.syncheo.tech:9443" "https://jazz1.syncheo.tech";
sub_filter ':9443/' '/';
sub_filter_once off;
```

> ⚠️ **Nginx-Falle**: `sub_filter` interpoliert keine `$host`-Variablen. Sie müssen einen `map{}`-Block verwenden, um statische Variablen pro Hostname zu erzeugen.

**IHS-Lösung** — die Direktive `ProxyHTMLURLMap`:
```apache
ProxyHTMLURLMap https://jazz1\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz2\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz3\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

`ProxyHTMLURLMap` ist leistungsfähiger als `sub_filter`: Es parst das HTML tatsächlich und versteht die Struktur der Attribute (`href`, `src`, `action`…).

---

### 2. Dekomprimierung der Antworten vor dem Umschreiben

Jazz komprimiert seine Antworten mit gzip. Ein Proxy kann komprimierten Text nicht umschreiben.

**Nginx-Lösung**:
```nginx
proxy_set_header Accept-Encoding "";
```
Sie weisen Jazz an, nicht zu komprimieren, indem Sie den Header `Accept-Encoding` entfernen.

**IHS-Lösung**:
```apache
RequestHeader unset Accept-Encoding
SetOutputFilter INFLATE;PROXY-HTML
```
IHS bietet eine elegantere Option: `INFLATE` dekomprimiert die Antwort im laufenden Betrieb, bevor `PROXY-HTML` sie umschreibt, und komprimiert sie anschließend wieder für den Client.

---

### 3. Umschreiben der Redirect-Header

Wenn Jazz eine HTTP-Weiterleitung ausgibt (`Location: https://jazz1:9443/jts/...`), würde der Browser der internen URL folgen. Diese Header müssen abgefangen werden.

**Nginx**:
```nginx
proxy_redirect https://127.0.0.1:9443/  /;
proxy_redirect ~*^https://jazz[1-3]\.kse\.ksegroup\.net:9443(/.*)$  $1;
```

**IHS**:
```apache
ProxyPassReverse / https://127.0.0.1:9443/
ProxyPassReverse / https://jazz1.syncheo.tech:9443/
ProxyPassReverse / https://jazz2.syncheo.tech:9443/
ProxyPassReverse / https://jazz3.syncheo.tech:9443/
```

---

### 4. CORS für Jazz-Anwendungen

Jazz verwendet Cross-Origin-Anfragen (OSLC, EWM-Widgets, REST-API). Der Header `Access-Control-Allow-Origin` unterstützt den Platzhalter `*` nicht, wenn `credentials: true` erforderlich ist — es wird ein dynamischer Wert benötigt.

**Nginx-Falle** — `if()`-Blöcke erben keine `add_header`-Direktiven vom übergeordneten Kontext. Sie müssen **alle CORS-Header** innerhalb des `OPTIONS`-Blocks **erneut deklarieren**:

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

**IHS** löst dies sauber mit `<If>`, das den übergeordneten Kontext korrekt erbt:

```apache
<If "%{REQUEST_METHOD} == 'OPTIONS'">
    Header always set Access-Control-Max-Age "1728000"
    Return 204
</If>
```

---

### 5. SSL zum Jazz-Backend

Jazz-Server verwenden intern häufig selbstsignierte Zertifikate.

**Nginx** — implizit deaktiviert über `proxy_pass https://` (akzeptiert standardmäßig alles).

**IHS** — explizite Deaktivierung erforderlich:
```apache
SSLProxyEngine          on
SSLProxyVerify          none
SSLProxyCheckPeerCN     off
SSLProxyCheckPeerName   off
SSLProxyCheckPeerExpire off
```

> 💡 Setzen Sie `SSLProxyVerify require`, wenn die Backends über gültige Zertifikate verfügen — die bessere Sicherheitspraxis.

---

## Leitfaden zur Server-Umbenennung

Hier sind die **genauen** Stellen, die Sie ändern müssen, wenn Sie Ihre Jazz-Server umbenennen.

### Fall 1 — Änderung des öffentlichen Domainnamens

Beispiel: `jazz.syncheo.tech` → `jazz.meinunternehmen.com`

| Datei | Direktive | Alter Wert | Neuer Wert |
|---|---|---|---|
| nginx.conf | `server_name` | `jazz[1-3].kse...` | `jazz[1-3].meinunternehmen.com` |
| nginx.conf | `map $host $internal_url` | Schlüssel `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `map $host $external_url` | Werte `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `if ($http_origin ~*` | Regex `jazz[1-3]...` | Regex `jazz[1-3]...` |
| ihs.conf | `ServerName` | `jazz.kse...` | `jazz.meinunternehmen.com` |
| ihs.conf | `ProxyHTMLURLMap` (×3) | `jazz[1-3]...` | `jazz[1-3]...` |
| ihs.conf | `SetEnvIf Origin` | Regex `jazz...` | Regex `jazz...` |
| ihs.conf | `SSLCertificateFile` | `jazz...crt` | `jazz...crt` |

> ⚠️ **Nicht vergessen**: Die Jazz Public URIs werden bei der Installation in der JTS-Administrationsoberfläche konfiguriert (`https://ihr-jts/jts/admin`). Wenn Sie den öffentlichen Namen ändern, müssen Sie sie auch in Jazz aktualisieren — ein sensibler Vorgang, der einen Neustart der Dienste erfordert.

---

### Fall 2 — Umbenennung eines internen Backend-Servers

Beispiel: `jazz1` → `jazz-prod-jts`

**In nginx.conf** die `map{}`-Blöcke anpassen:
```nginx
map $host $internal_url {
    jazz-prod-jts.syncheo.tech  "https://jazz-prod-jts.syncheo.tech:9443";
    # ...
}
```

**In ihs.conf** die Direktiven `ProxyHTMLURLMap` und `ProxyPassReverse` anpassen:
```apache
ProxyPassReverse / https://jazz-prod-jts.syncheo.tech:9443/
ProxyHTMLURLMap https://jazz-prod-jts\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

---

### Fall 3 — Migration auf getrennte Server (Scale-out)

Wenn JTS/RM, CCM/QM und GC/RS jeweils auf ihre eigene Maschine umziehen:

**Nginx**:
```nginx
location ~ ^/(jts|rm) {
    proxy_pass https://10.0.0.1:9443;
    # ... dieselben sub_filter-, CORS- usw. Direktiven
}

location ~ ^/(ccm|qm) {
    proxy_pass https://10.0.0.2:9443;
}

location ~ ^/(gc|rs) {
    proxy_pass https://10.0.0.3:9443;
}
```

**IHS**:
```apache
<Location ~ "^/(jts|rm)">
    ProxyPass        https://10.0.0.1:9443
    ProxyPassReverse https://10.0.0.1:9443/
    # ... dieselben ProxyHTMLURLMap-, CORS- usw. Direktiven
</Location>
```

---

## Validierungs-Checkliste nach der Konfiguration

Prüfen Sie nach jeder Änderung diese Punkte der Reihe nach:

**1. SSL-Test**:
```bash
openssl s_client -connect jazz.syncheo.tech:443 -servername jazz.syncheo.tech
```

**2. Test der HTTP→HTTPS-Weiterleitung**:
```bash
curl -I http://jazz.syncheo.tech
# Erwartet: HTTP/1.1 301 Moved Permanently + Location: https://...
```

**3. Test des JTS-Zugriffs**:
```bash
curl -k https://jazz.syncheo.tech/jts/auth/authrequired
# Erwartet: 200 oder 401 (kein Proxy-Fehler)
```

**4. CORS-Preflight-Test**:
```bash
curl -I -X OPTIONS https://jazz.syncheo.tech/jts/ \
  -H "Origin: https://jazz.syncheo.tech" \
  -H "Access-Control-Request-Method: POST"
# Erwartet: 204 + Access-Control-Allow-Origin vorhanden
```

**5. Überprüfung der SANs des Zertifikats**:
```bash
openssl x509 -in /etc/nginx/ssl/jazz.crt -text -noout | grep -A5 "Subject Alternative"
```

---

## Nginx vs. IHS: Was wählen?

| Kriterium | Nginx | IBM HTTP Server |
|---|---|---|
| **IBM-Empfehlung** | Inoffiziell | ✅ Offiziell |
| **HTML-Umschreibung** | `sub_filter` (textbasiert) | `mod_proxy_html` (HTML-Parsing) |
| **CORS-`if()`-Handhabung** | ⚠️ Header nicht vererbt | ✅ Korrekte Vererbung |
| **Transparentes gzip** | Deaktivierung upstream | Dekomprimierung im laufenden Betrieb |
| **Performance** | ✅ Ausgezeichnet | Gut |
| **Community** | Groß | IBM Support |

Für eine produktive IBM-ELM-Umgebung wird **IHS empfohlen** — die native Handhabung von `mod_proxy_html` vermeidet die Fallstricke von `sub_filter`, und der IBM-Support deckt den gesamten Stack ab.

---

## Fazit

Die Konfiguration eines Reverse Proxy vor IBM Jazz ist vor allem wegen dreier Punkte komplex: dem Umschreiben interner URLs in den Antworten, der Handhabung von CORS mit Anmeldedaten und der SSL-Entschlüsselung zu den Backends. Die hier vorgestellten Konfigurationen haben sich produktiv bewährt und decken alle drei Aspekte ab.

Bei Zweifeln zu einer Migration oder Umbenennung kontaktieren Sie gerne das **Syncheo**-Team — genau diese Art von Einsatz führen wir täglich für unsere IBM-ELM-Kunden durch.
