---
title: "Securing ALM Workflows: Native GitGuardian Integration within IBM EWM"
date: 2026-03-18T11:30:00+01:00
draft: false
author: "Syncheo"
description: "Bidirectional integration architecture between IBM Engineering Workflow Management and GitGuardian for secret detection."
categories: ["DevSecOps", "Software Engineering"]
tags: ["IBM EWM", "GitGuardian", "Jazz Platform", "Security", "Plugin Development"]
translationKey: "ewm-gitguardian-integration"
---

In an era of escalating cyber threats, the proactive detection of secret leaks (API keys, certificates, credentials) within source code has become a governance imperative. To address this challenge, a bidirectional integration solution between **IBM Engineering Workflow Management (EWM)** and **GitGuardian** has been developed, securing the Software Development Life Cycle (SDLC) without compromising team agility.

## A Hybrid Approach: Client and Server-Side

The architecture of this solution relies on two complementary components, providing total flexibility in managing corporate security policies.

### 1. Server-Side Extension: The Institutional Safeguard
The server-side plugin acts as the final authority during the delivery of *change sets*. Its role is to ensure strict code compliance before integration into the common stream.

* **Automated Blocking:** Depending on the configuration, the plugin can prohibit delivery if a vulnerability is detected by the GitGuardian analyzer.
* **Traceability and Audit:** In the event of an anomaly, the system automatically generates an incident within the GitGuardian dashboard.
* **Work Item Enrichment:** A comment is injected into the EWM Work Item linked to the *change set*. This message alerts stakeholders to the nature of the flaw while adhering to confidentiality principles: the secret itself is never exposed in logs or comments.

### 2. Client-Side Extension: Developer Agility
The client-side plugin intervenes at the earliest stage, directly within the developer's IDE, promoting "Shift Left Security."

* **Interactive Alerting:** Developers are instantly informed of a potential vulnerability before the code even leaves their workstation.
* **Exception Management (Override):** Unlike the rigidity of the server-side check, the client extension offers the possibility to bypass a block. This feature is crucial for managing false positives or documented and accepted risks, thus preventing any bottlenecks in the delivery process.

---

## Functional Summary

| Feature | Server Plugin (Pre-Condition) | Client Plugin (Pre-Check) |
| :--- | :--- | :--- |
| **Objective** | Global Compliance & Audit | Productivity & Shift-Left |
| **Action** | Blocking or Informative | Blocking with Manual Bypass |
| **GitGuardian Integration** | Automatic Incident Creation | Real-time Analysis |
| **EWM Feedback** | Work Item Comment | User Notification (UI) |

---

## Conclusion

This synergy between **IBM EWM** and **GitGuardian** transforms application security from a perceived constraint into an integrated, transparent process. By combining the rigor of server-side controls with the flexibility of client-side tools, organizations can now guarantee the integrity of their software assets with surgical precision.