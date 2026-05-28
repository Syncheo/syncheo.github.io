---
title: "Reverse Proxy for IBM Jazz ELM: Complete Nginx & IHS Guide"
date: 2026-03-27T12:00:00+01:00
draft: false
tags: ["IBM Jazz", "ELM", "Nginx", "IHS", "Reverse Proxy", "SSL", "CORS", "DevOps"]
categories: ["Technical Expertise"]
author: "Syncheo Engineering"
description: "How to configure an Nginx or IBM HTTP Server reverse proxy in front of an IBM ELM platform (JTS, CCM, QM, RM, GC) — SSL, CORS, URL rewriting and a server renaming guide."
banner: "img/blog/reverse-proxy-jazz-banner.png"
translationKey: "reverse-proxy-jazz"
---

Exposing an IBM ELM (Engineering Lifecycle Management) platform behind a reverse proxy is an unavoidable step for any production deployment. It centralises access, lets you manage SSL certificates in a single place, and makes the public URL independent of the internal infrastructure.

<!--more-->

This guide covers two implementations: **Nginx** (the widely used open-source solution) and **IBM HTTP Server (IHS)** (the Apache-based server shipped by IBM, recommended for ELM). The configurations shown here have been validated in production on multi-server Jazz environments.

---

## Target Architecture

```
Internet
    │
    ▼
[Reverse Proxy: 443]           ← single public URL
    │
    ├──→ jazz1:9443  (JTS, RM)
    ├──→ jazz2:9443  (CCM, QM)
    └──→ jazz3:9443  (GC, RS)
```

The reverse proxy is the only point exposed to the Internet. The internal Jazz servers communicate with each other through their internal URLs (port 9443), and the proxy takes care of adapting everything.

---

## The 5 Technical Challenges to Solve

### 1. Rewriting URLs in Jazz responses

Jazz embeds its own URLs in HTTP responses (`Location` headers, HTML content, JSON, JavaScript). If those URLs point to `jazz1:9443` while the user accesses the platform from `jazz.mydomain.net`, everything breaks.

**Nginx solution** — the `sub_filter` directive:
```nginx
sub_filter "https://jazz1.syncheo.tech:9443" "https://jazz1.syncheo.tech";
sub_filter ':9443/' '/';
sub_filter_once off;
```

> ⚠️ **Nginx pitfall**: `sub_filter` does not interpolate `$host` variables. You must use a `map{}` block to create static per-hostname variables.

**IHS solution** — the `ProxyHTMLURLMap` directive:
```apache
ProxyHTMLURLMap https://jazz1\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz2\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
ProxyHTMLURLMap https://jazz3\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

`ProxyHTMLURLMap` is more powerful than `sub_filter`: it actually parses the HTML and understands the structure of attributes (`href`, `src`, `action`…).

---

### 2. Decompressing responses before rewriting

Jazz compresses its responses with gzip. A proxy cannot rewrite compressed text.

**Nginx solution**:
```nginx
proxy_set_header Accept-Encoding "";
```
You ask Jazz not to compress by stripping the `Accept-Encoding` header.

**IHS solution**:
```apache
RequestHeader unset Accept-Encoding
SetOutputFilter INFLATE;PROXY-HTML
```
IHS offers a more elegant option: `INFLATE` decompresses the response on the fly before `PROXY-HTML` rewrites it, then recompresses it for the client.

---

### 3. Rewriting redirect headers

When Jazz issues an HTTP redirect (`Location: https://jazz1:9443/jts/...`), the browser would follow the internal URL. These headers must be intercepted.

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

### 4. CORS for Jazz applications

Jazz uses cross-origin requests (OSLC, EWM widgets, REST API). The `Access-Control-Allow-Origin` header does not support the `*` wildcard when `credentials: true` is required — it needs a dynamic value.

**Nginx pitfall** — `if()` blocks do not inherit `add_header` directives from the parent. You must **redeclare every CORS header** inside the `OPTIONS` block:

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

**IHS** handles this cleanly with `<If>`, which correctly inherits the parent context:

```apache
<If "%{REQUEST_METHOD} == 'OPTIONS'">
    Header always set Access-Control-Max-Age "1728000"
    Return 204
</If>
```

---

### 5. SSL to the Jazz backend

Jazz servers often use self-signed certificates internally.

**Nginx** — implicitly disabled via `proxy_pass https://` (accepts everything by default).

**IHS** — explicit disabling required:
```apache
SSLProxyEngine          on
SSLProxyVerify          none
SSLProxyCheckPeerCN     off
SSLProxyCheckPeerName   off
SSLProxyCheckPeerExpire off
```

> 💡 Set `SSLProxyVerify require` if the backends have valid certificates — a better security practice.

---

## Server Renaming Guide

Here are the **exact** places to change when you rename your Jazz servers.

### Case 1 — Changing the public domain name

Example: `jazz.syncheo.tech` → `jazz.mycompany.com`

| File | Directive | Old value | New value |
|---|---|---|---|
| nginx.conf | `server_name` | `jazz[1-3].kse...` | `jazz[1-3].mycompany.com` |
| nginx.conf | `map $host $internal_url` | keys `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `map $host $external_url` | values `jazz[1-3]...` | `jazz[1-3]...` |
| nginx.conf | `if ($http_origin ~*` | regex `jazz[1-3]...` | regex `jazz[1-3]...` |
| ihs.conf | `ServerName` | `jazz.kse...` | `jazz.mycompany.com` |
| ihs.conf | `ProxyHTMLURLMap` (×3) | `jazz[1-3]...` | `jazz[1-3]...` |
| ihs.conf | `SetEnvIf Origin` | regex `jazz...` | regex `jazz...` |
| ihs.conf | `SSLCertificateFile` | `jazz...crt` | `jazz...crt` |

> ⚠️ **Do not forget**: the Jazz Public URIs are configured at install time in the JTS administration interface (`https://your-jts/jts/admin`). If you change the public name, you must also update them in Jazz — a sensitive operation that requires a restart of the services.

---

### Case 2 — Renaming an internal backend server

Example: `jazz1` → `jazz-prod-jts`

**In nginx.conf**, edit the `map{}` blocks:
```nginx
map $host $internal_url {
    jazz-prod-jts.syncheo.tech  "https://jazz-prod-jts.syncheo.tech:9443";
    # ...
}
```

**In ihs.conf**, edit the `ProxyHTMLURLMap` and `ProxyPassReverse` directives:
```apache
ProxyPassReverse / https://jazz-prod-jts.syncheo.tech:9443/
ProxyHTMLURLMap https://jazz-prod-jts\.kse\.ksegroup\.net:9443  https://jazz.syncheo.tech  Riex
```

---

### Case 3 — Migrating to separate servers (scale-out)

When JTS/RM, CCM/QM and GC/RS each move to their own machine:

**Nginx**:
```nginx
location ~ ^/(jts|rm) {
    proxy_pass https://10.0.0.1:9443;
    # ... same sub_filter, CORS, etc. directives
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
    # ... same ProxyHTMLURLMap, CORS, etc. directives
</Location>
```

---

## Post-Configuration Validation Checklist

After any change, check these points in order:

**1. SSL test**:
```bash
openssl s_client -connect jazz.syncheo.tech:443 -servername jazz.syncheo.tech
```

**2. HTTP→HTTPS redirect test**:
```bash
curl -I http://jazz.syncheo.tech
# Expected: HTTP/1.1 301 Moved Permanently + Location: https://...
```

**3. JTS access test**:
```bash
curl -k https://jazz.syncheo.tech/jts/auth/authrequired
# Expected: 200 or 401 (no proxy error)
```

**4. CORS preflight test**:
```bash
curl -I -X OPTIONS https://jazz.syncheo.tech/jts/ \
  -H "Origin: https://jazz.syncheo.tech" \
  -H "Access-Control-Request-Method: POST"
# Expected: 204 + Access-Control-Allow-Origin present
```

**5. Certificate SAN verification**:
```bash
openssl x509 -in /etc/nginx/ssl/jazz.crt -text -noout | grep -A5 "Subject Alternative"
```

---

## Nginx vs IHS: Which to Choose?

| Criterion | Nginx | IBM HTTP Server |
|---|---|---|
| **IBM recommendation** | Unofficial | ✅ Official |
| **HTML rewriting** | `sub_filter` (text-based) | `mod_proxy_html` (HTML parsing) |
| **CORS `if()` handling** | ⚠️ Headers not inherited | ✅ Correct inheritance |
| **Transparent gzip** | Upstream disabling | On-the-fly decompression |
| **Performance** | ✅ Excellent | Good |
| **Community** | Large | IBM Support |

For a production IBM ELM environment, **IHS is recommended** — native `mod_proxy_html` handling avoids the pitfalls of `sub_filter`, and IBM support covers the whole stack.

---

## Conclusion

Configuring a reverse proxy in front of IBM Jazz is complex mainly because of three points: rewriting internal URLs in responses, handling CORS with credentials, and SSL decryption towards the backends. The configurations presented here have been proven in production and cover all three aspects.

If you have any doubt about a migration or a renaming operation, feel free to contact the **Syncheo** team — this is exactly the kind of work we carry out every day for our IBM ELM customers.
