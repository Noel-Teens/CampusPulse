# 🎓 CampusPulse

**One Campus. One App. Every Problem Solved.**

CampusPulse is a **smart campus mobile application** built using **Flutter** and powered by **Google technologies**. It unifies multiple campus utilities—navigation, issue reporting, announcements, anonymous feedback, and AI-powered assistance—into a single, secure, and scalable platform.

This project is designed for a **national-level GDG hackathon** and intentionally avoids Google OAuth and domain ownership requirements.

---

## 🚀 Key Features

- 🧭 **Smart Campus Navigation**  
  Interactive campus map with buildings, facilities, and walking directions.

- 🛠 **Geo-Tagged Issue Reporting**  
  Report infrastructure issues with images, location, and live status tracking.

- 🤖 **AI Campus Assistant**  
  Ask campus-related questions and get intelligent responses powered by Gemini AI.

- 📢 **Notices & Events Hub**  
  Centralized announcements with real-time push notifications.

- 🗳 **Anonymous Feedback & Polls**  
  Safe, anonymous feedback system with AI-generated insights for administrators.

---

## 🧠 Why CampusPulse?

Campuses often rely on fragmented tools such as notice boards, WhatsApp groups, and manual complaint systems. CampusPulse replaces this chaos with **one unified app** that is:

- Simple to use
- Secure without OAuth
- Scalable to multiple campuses
- Built entirely on Google’s developer ecosystem

---

## 🏗️ Tech Stack

| Layer | Technology |
|------|-----------|
| Frontend | Flutter |
| Backend | Firebase (BaaS) |
| Database | Firestore |
| Storage | Firebase Storage |
| Maps | Google Maps SDK |
| AI | Gemini API |
| Notifications | Firebase Cloud Messaging |

---

## 🔐 Security & Access Control

CampusPulse prevents outsiders from accessing campus data using a **multi-layer verification system**:

- Firebase Anonymous Authentication
- Campus email domain verification
- Admin-issued invite/access codes
- One-time location (campus boundary) validation
- Firestore security rules for backend enforcement

No Google OAuth or custom domain is required.

---

## 📱 Application Workflow (High Level)

```
Install App
 → Campus Verification
 → Home Dashboard
 → Select Feature
 → Problem Solved
```

The dashboard acts as a **single-click gateway** to all campus services.

---

## 🧩 Project Structure (Overview)

The app follows a **feature-based modular architecture**, making it easy for teams to collaborate and scale.

```
lib/
 ├── core/
 ├── models/
 ├── features/
 │    ├── auth/
 │    ├── dashboard/
 │    ├── campus_map/
 │    ├── issue_reporting/
 │    ├── notices/
 │    ├── ai_assistant/
 │    └── feedback/
 ├── routes/
 └── theme/
```

---

## 🧪 MVP Scope (Hackathon)

### Included
- Campus map & navigation
- Issue reporting system
- AI campus assistant
- Notices & events
- Secure access control

### Planned Enhancements
- Admin web dashboard
- Indoor navigation
- QR-based onboarding
- Multi-language support

---

## 📌 Future Vision

CampusPulse aims to become a **campus operating system** that connects students, faculty, and administrators through one intelligent platform.

---

> _CampusPulse — simplifying campus life, one click at a time._
