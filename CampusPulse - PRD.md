# Project Requirement Document (PRD)

## Project Name: CampusPulse

**Tagline:** One Campus. One App. Every Problem Solved.

## 1\. Purpose & Vision

### 1.1 Purpose

CampusPulse aims to provide a **single, unified mobile platform** that solves multiple real-world campus problems such as navigation, issue reporting, communication gaps, and lack of student feedback mechanisms. The platform leverages **Google technologies** and is built using **Flutter**, without requiring OAuth verification or domain ownership.

### 1.2 Vision

To create a **smart, connected campus ecosystem** where students, faculty, and administrators can interact efficiently through one application.

## 2\. Problem Statement

Educational campuses face recurring challenges:

*   Difficulty navigating large campuses
*   Delayed or ignored infrastructure complaints
*   Fragmented communication channels
*   Lack of safe and anonymous feedback systems
*   Absence of a centralized campus utility app

CampusPulse addresses all these challenges through a **modular, scalable mobile application**.

## 3\. Solution Overview

CampusPulse is a **modular smart campus application** where each module addresses a specific campus problem, while all modules operate under a **single app, backend, and security layer**.

## 4\. Target Users

| User Type | Description |
| --- | --- |
| Students | Primary users of all features |
| Faculty | View notices, feedback summaries |
| Campus Admin | Manage issues, events, analytics |
| Visitors | Limited access (map-only) |

## 5\. Platform & Technology

### 5.1 Platforms

*   Android (Primary)
*   iOS (Optional / Demo-ready)

### 5.2 Technology Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter |
| Backend | Firebase (BaaS) |
| Database | Firestore |
| Storage | Firebase Storage |
| Maps | Google Maps SDK |
| AI | Gemini API |
| Notifications | Firebase Cloud Messaging |

## 6\. Access Control & Security (Outsider Prevention)

CampusPulse uses **multi-layer access control** without OAuth.

### 6.1 Authentication

*   Firebase Anonymous Authentication (initial session)
*   No Google Sign-In

### 6.2 Campus Verification Layers

#### a) Campus Email Verification

*   Users must verify using official campus email
*   Domain whitelisting (e.g., @college.edu)

#### b) Invite / Access Code

*   Admin-generated codes
*   Department or batch-specific
*   Expirable and revocable

#### c) One-Time Location Validation

*   First-login GPS validation
*   Confirms user is inside campus boundary
*   No continuous tracking

### 6.3 Backend Enforcement

Firestore security rules allow data access **only if**:

*   User is verified
*   Campus ID matches data campus ID

## 7\. Application Workflow

### 7.1 User Onboarding Workflow

Install App → Anonymous Session → Email Verification → Invite Code → Location Check → Access Granted

Once verified, the user gains full access to all campus modules.

### 7.2 Home Dashboard Workflow

The dashboard serves as a **single entry point** to all features:

*   Campus Map
*   Report Issue
*   Ask Campus AI
*   Notices & Events
*   Feedback & Polls

One click leads directly to problem resolution.

## 8\. Core Feature Modules & Workflows

### 8.1 Smart Campus Map & Navigation

**Description:  
**Interactive campus map to locate buildings, facilities, and navigate efficiently.

**Workflow:**

*   Load Google Map
*   Fetch campus locations from Firestore
*   Display user location
*   Search and navigate to buildings

**Technologies Used:**

*   Google Maps SDK
*   Places API

### 8.2 Geo-Tagged Issue Reporting System

**Description:  
**Allows students to report infrastructure issues with images and location.

**Workflow:**

*   User submits issue
*   Media uploaded to Firebase Storage
*   Location auto-tagged
*   Issue stored in Firestore
*   Admin notified via FCM
*   Status tracking enabled

**Technologies Used:**

*   Firestore
*   Firebase Storage
*   Google Maps SDK

### 8.3 AI-Powered Campus Assistant

**Description:  
**An intelligent chatbot that answers campus-related queries.

**Workflow:**

*   User submits question
*   Context fetched from Firestore
*   Query sent to Gemini API
*   AI response displayed

**Technologies Used:**

*   Gemini API
*   Firebase

### 8.4 Notices & Events System

**Description:  
**Centralized platform for campus announcements.

**Workflow:**

*   Admin posts notice/event
*   Stored in Firestore
*   Push notification sent
*   Users filter and view content

**Technologies Used:**

*   Firestore
*   Firebase Cloud Messaging

### 8.5 Anonymous Feedback & Polling

**Description:  
**Allows students to submit feedback safely and anonymously.

**Workflow:**

*   Anonymous feedback submission
*   Stored without identity
*   Upvoting enabled
*   Gemini summarizes feedback trends

**Technologies Used:**

*   Firestore
*   Gemini API

## 9\. Non-Functional Requirements

| Requirement | Description |
| --- | --- |
| Performance | App loads under 3 seconds |
| Scalability | Multi-campus ready |
| Security | Role-based access |
| Usability | Simple, intuitive UI |
| Privacy | No continuous tracking |

## 10\. MVP Scope (Hackathon Version)

### Must-Have

*   Campus Map
*   Issue Reporting
*   AI Assistant
*   Notices
*   Access Control

### Nice-to-Have

*   Feedback analytics
*   Admin dashboard
*   Indoor navigation

## 11\. Success Metrics

*   Reduced issue resolution time
*   Increased student participation
*   Improved information visibility
*   Positive judge and user feedback

## 12\. Future Enhancements

*   QR-based onboarding
*   IoT-based smart infrastructure
*   Multi-language support
*   Campus theming
*   Attendance & facility analytics

## 13\. Conclusion

CampusPulse is a **secure, scalable, and intelligent smart campus solution** that consolidates multiple campus utilities into a single Flutter application powered by Google technologies. It is practical, impactful, and perfectly suited for a national-level GDG hackathon.