---
title: "Syncheo Connect — XWiki ↔ IBM Jazz Connector (OSLC)"
subtitle: "Link your XWiki pages natively to IBM Jazz engineering artifacts, through the OSLC standard"
date: 2026-08-26T10:00:00+01:00
draft: false
author: "Syncheo"
description: "A native OSLC connector between XWiki and IBM Jazz (ELM): create traceability links between your documentation pages and your requirements, work items or tests, with preview and editing straight from Jazz."
summary: "Our XWiki–OSLC connector makes your documentation wiki and your IBM Jazz engineering platform talk to each other. Bidirectional traceability links, native preview of Jazz artifacts inside XWiki, editing an XWiki page from the Jazz preview, an OSLC delegated picker, Jazz menu integration and shared authentication — all without leaving your tools."
tags: ["XWiki", "IBM Jazz", "OSLC", "ELM", "Traceability", "Syncheo"]
translationKey: "xwiki-oslc-connector"
banner: "img/banners/xwiki-oslc-banner.png"
---

In most engineering organizations, documentation lives on one side and engineering artifacts on the other. Teams write their specifications, architecture guides and design notes in a wiki like **XWiki**, while their requirements, work items and test campaigns are managed in **IBM Jazz (Engineering Lifecycle Management)**. The two worlds constantly answer each other — yet nothing links them.

Our **XWiki–OSLC connector** bridges that gap. It turns XWiki and IBM Jazz into two tools that talk natively, through the open **OSLC** standard, so that documentation and engineering become a single traceability thread.

---

## What is XWiki?

**XWiki** is an enterprise-grade open source wiki platform, designed for collaborative knowledge management. Far more than a simple wiki, XWiki lets you build genuinely structured applications: documentation bases, repositories, procedures, rich specification pages — all versioned, with fine-grained access control and a powerful extension engine.

It is a common choice in large organizations for centralizing technical and functional documentation, precisely because it is open, extensible and self-hostable.

Learn more about XWiki: [xwiki.org](https://www.xwiki.org).

---

## What is OSLC?

**OSLC (Open Services for Lifecycle Collaboration)** is an open standard for integrating engineering lifecycle tools. Built on *linked data* principles, it defines a common way for different tools to reference, display and link each other's resources — without heavy synchronization or data duplication.

IBM Jazz implements OSLC natively. By making XWiki OSLC-compatible, our connector lets both platforms collaborate using the very same standard mechanisms IBM already uses between its own tools (DOORS Next, EWM, ETM…).

---

## What the connector does

### OSLC traceability links between XWiki and Jazz

The heart of the connector: creating traceability links between an XWiki page and a Jazz artifact — a requirement, a work item, a test case. These links are bidirectional and navigable: from Jazz, you reach the documentation page that explains the "why"; from XWiki, you drill down to the requirement or work item that embodies the "how". Documentation stops being a dead document beside the project and becomes a traced link in the engineering chain.

### Native preview of Jazz artifacts inside XWiki

When an XWiki page references a Jazz artifact, the connector renders a **native preview** right inside the page, using OSLC compact rendering. On hover, the user sees the artifact's title, status and key information without leaving XWiki or opening Jazz. Documentation stays visually up to date, in real time, with the actual state of engineering.

### XWiki exposed as an OSLC provider

The connector does more than consume Jazz resources: it exposes **XWiki pages themselves as OSLC resources**. Your documentation pages become linkable artifacts, consumable by IBM Jazz (ELM, DOORS Next…) like any other lifecycle resource. From a requirement, an engineer can point to the XWiki page that specifies it — and Jazz will know how to display it.

### A standard delegated picker (Delegated UI)

Creating a link requires no URL handling or copy-pasting. The connector relies on the **OSLC delegated UI**: from Jazz, a picker opens to search and choose the XWiki page to link — and vice versa — in a standard dialog, without leaving the originating tool. It's the same familiar gesture used natively between IBM tools.

### Edit an XWiki page from the Jazz preview

The connector goes beyond mere consultation: from the preview of an XWiki link displayed in Jazz, the user can **edit the XWiki page directly**, without switching applications. Documentation is corrected and enriched exactly where the need appears — in the flow of engineering work.

### Integrated into the Jazz menu

The connector integrates **directly into the IBM Jazz menu**. XWiki-related functions are available where engineers already work, with no third-party tool to open and no context to switch. Adoption is immediate because nothing changes in the teams' habits.

### Shared authentication with Jazz

No second account, no extra login to manage. The connector **shares the authentication interface with Jazz**: a user already logged into their engineering platform accesses XWiki seamlessly. Less friction for teams, and simpler access management for administrators.

---

## How it works in practice

**1. An engineer writes a specification in XWiki**
The page describes the context, the architecture choices and the business rules. It is the "why" of the project.

**2. They link it to a requirement in Jazz**
From the requirement, they open the OSLC picker, find the XWiki page and create the link. No URL to copy, no technical setup.

**3. Traceability comes alive**
In Jazz, the requirement now shows a preview of the XWiki page, with its title and status, updated in real time. In XWiki, the page points back to the requirement.

**4. Documentation evolves without leaving the workflow**
A detail to clarify? The engineer edits the XWiki page directly from the preview shown in Jazz. Documentation and engineering move forward together, at the same pace.

---

## Conclusion

Our XWiki–OSLC connector reconciles two worlds that should always have been in dialogue: the knowledge documented in XWiki and the engineering artifacts managed in IBM Jazz. By building on the open OSLC standard — the very one IBM uses between its own tools — it creates native, bidirectional traceability with no duplication, where there was only a gap.

**Want to learn more or schedule a demonstration?** [Contact us](/en/contact).
