# Tenant Organization User Journey in CoachQA

This document outlines the **complete end-to-end user journey** for a **Tenant Organization** using the CoachQA platform — from initial sign-up to full usage of all Quality Assistance modules.

---

## 🎯 Overview

In CoachQA, each **tenant** represents an independent organization (e.g., a company or department) with its own isolated:

- Users
- Squads
- Data (coaching logs, scorecards, maturity, feedback, etc.)

---

## 1. 📝 **Tenant Registration & Onboarding**

### Steps:

1. Admin visits `https://coachqav2.netlify.app/`
2. Clicks **"Sign Up as a New Organization"**
3. Enters:
    - Organization Name
    - Admin Name + Email
    - Password
4. System creates:
    - New `tenant_id`
    - Admin user account
    - Empty state for squads and data modules

➡️ Admin is redirected to the **Dashboard** with a welcome modal.

---

## 2. 🧩 **Squad Creation** (via Squad Management Module)

### Goal:

Set up squads under the tenant to track quality metrics and coaching.

### Actions (Admin):

- Navigate to **Squad Management**
- Create squads with:
    - Name (e.g., "Checkout Squad")
    - Tribe (optional)
    - Description
    - QE assigned (optional)
    - Status = Active

✅ These squads become selectable across all modules.

---

## 3. 👤 **User Invitations & Role Assignment**

### Roles Supported:

- **Admin** (full control)
- **QE / Coach** (logs coaching, sees impact)
- **Squad Member** (Dev, PO, Designer)
- **Manager / VP** (dashboards only)

### Flow:

- Admin invites users via email (or CSV import in future)
- Assigns role + squad mapping

Example: `jane@company.com → QE → assigned to Checkout Squad`

---

## 4. 🧪 **Active Module Usage**

Each user interacts based on their role. Below is a journey per module.

### ✅ Coaching Tracker (QE)

- Log enablement sessions (strategy, pairing, exploratory, etc.)
- View own timeline
- Manager views aggregate activity

### 📊 Squad Scorecard (All roles)

- Squad sees test coverage, bugs, quality score
- QE/Manager uses this to prioritize coaching

### 🧠 Maturity Ladder (Squad + QE)

- Squad self-assesses current maturity level (1–5)
- QE facilitates discussion, logs insights
- Trend tracking per squad

### 📋 Feedback Form (360°)

- POs/Devs give feedback to QEs post-sprint
- QE sees personal dashboard
- Manager reviews for performance calibration

### 🛠 Enablement Hub

- Self-serve access to checklists, templates, videos
- QEs upload new materials
- Admin moderates categories

### 📈 QE Impact Timeline

- QEs and Managers see how coaching efforts lead to improved maturity/coverage/feedback

### 🧾 Test Debt Register

- Squad logs known test gaps during retros
- QE sees where to focus effort
- Manager sees aging risk areas

### 🔄 Change Management Tracker

- Leadership sees adoption level of QAa model per squad
- Track coaching effort vs. maturity movement

### 📈 Career Framework (QEs)

- QEs self-reflect on level (e.g., Coach → Practice Lead)
- Managers review growth
- Helps with quarterly reviews and learning paths

---

## 5. 🔐 Access & Isolation by Tenant

- All squads, logs, scorecards, and users are scoped to their `tenant_id`
- No cross-tenant visibility
- Shared services (AI models, templates) can be tenant-customized

---

## 6. 🚦 Lifecycle Actions

- ✅ Add/Edit/Archive squads
- ✅ Reassign QEs
- ✅ Promote users to admin or manager
- ✅ Export reports (Scorecards, Debt, Feedback)

---

## 🧠 Future Add-ons

- Tenant-level dashboards & KPIs
- SSO + SCIM for large orgs
- Slack/MS Teams integrations per tenant
- AI assistant: "How’s my org’s test maturity this quarter?"

---

## 📌 Summary

The tenant journey ensures every organization has:

- Full control over their squads and users
- Modular, role-specific interactions
- Clear visibility into quality health and coaching impact
- Full separation from other organizations

CoachQA = Scalable, AI-powered Quality Assistance for orgs of all sizes.