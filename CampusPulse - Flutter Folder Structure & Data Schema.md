# CampusPulse – Flutter Folder Structure & Data Schemas

This document defines the **recommended Flutter project structure** and **Firestore data schemas** for the CampusPulse application. It is designed for **team collaboration**, **scalability**, and **hackathon-speed development**.

## 1\. Flutter Mobile App Folder Structure

The structure follows **feature-based modular architecture**, which is ideal for large apps and hackathons.

lib/

│

├── main.dart

├── app.dart

│

├── core/

│ ├── constants/

│ │ ├── app\_colors.dart

│ │ ├── app\_strings.dart

│ │ └── app\_assets.dart

│ │

│ ├── services/

│ │ ├── firebase\_service.dart

│ │ ├── auth\_service.dart

│ │ ├── location\_service.dart

│ │ ├── notification\_service.dart

│ │ ├── gemini\_service.dart

│ │ └── maps\_service.dart

│ │

│ ├── utils/

│ │ ├── validators.dart

│ │ ├── helpers.dart

│ │ └── permissions.dart

│ │

│ └── widgets/

│ ├── custom\_button.dart

│ ├── custom\_textfield.dart

│ └── loading\_indicator.dart

│

├── models/

│ ├── user\_model.dart

│ ├── campus\_model.dart

│ ├── issue\_model.dart

│ ├── notice\_model.dart

│ ├── feedback\_model.dart

│ └── location\_model.dart

│

├── features/

│ ├── auth/

│ │ ├── screens/

│ │ │ ├── welcome\_screen.dart

│ │ │ ├── email\_verification\_screen.dart

│ │ │ ├── invite\_code\_screen.dart

│ │ │ └── location\_check\_screen.dart

│ │ ├── controllers/

│ │ │ └── auth\_controller.dart

│ │ └── auth\_module.dart

│ │

│ ├── dashboard/

│ │ ├── screens/

│ │ │ └── home\_dashboard.dart

│ │ └── widgets/

│ │ └── dashboard\_tile.dart

│ │

│ ├── campus\_map/

│ │ ├── screens/

│ │ │ └── campus\_map\_screen.dart

│ │ ├── controllers/

│ │ │ └── map\_controller.dart

│ │ └── widgets/

│ │ └── place\_marker.dart

│ │

│ ├── issue\_reporting/

│ │ ├── screens/

│ │ │ ├── report\_issue\_screen.dart

│ │ │ └── issue\_detail\_screen.dart

│ │ ├── controllers/

│ │ │ └── issue\_controller.dart

│ │ └── widgets/

│ │ └── issue\_card.dart

│ │

│ ├── notices/

│ │ ├── screens/

│ │ │ ├── notices\_screen.dart

│ │ │ └── event\_detail\_screen.dart

│ │ ├── controllers/

│ │ │ └── notice\_controller.dart

│ │ └── widgets/

│ │ └── notice\_tile.dart

│ │

│ ├── ai\_assistant/

│ │ ├── screens/

│ │ │ └── ai\_chat\_screen.dart

│ │ ├── controllers/

│ │ │ └── ai\_controller.dart

│ │ └── widgets/

│ │ └── chat\_bubble.dart

│ │

│ └── feedback/

│ ├── screens/

│ │ └── feedback\_screen.dart

│ ├── controllers/

│ │ └── feedback\_controller.dart

│ └── widgets/

│ └── feedback\_card.dart

│

├── routes/

│ └── app\_routes.dart

│

├── state/

│ ├── user\_state.dart

│ ├── campus\_state.dart

│ └── app\_state.dart

│

└── theme/

└── app\_theme.dart

## 2\. Firestore Database Structure (High-Level)

Firestore

│

├── campuses/

│ └── {campusId}

│ ├── name

│ ├── allowedDomains\[\]

│ ├── geoBoundary

│ └── createdAt

│

├── users/

│ └── {userId}

│ ├── campusId

│ ├── email

│ ├── isVerified

│ ├── role

│ ├── createdAt

│

├── locations/

│ └── {locationId}

│ ├── campusId

│ ├── name

│ ├── type

│ ├── latitude

│ ├── longitude

│

├── issues/

│ └── {issueId}

│ ├── campusId

│ ├── title

│ ├── description

│ ├── category

│ ├── mediaUrl

│ ├── location

│ ├── status

│ ├── createdBy

│ ├── createdAt

│

├── notices/

│ └── {noticeId}

│ ├── campusId

│ ├── title

│ ├── description

│ ├── type

│ ├── attachmentUrl

│ ├── createdAt

│

├── feedbacks/

│ └── {feedbackId}

│ ├── campusId

│ ├── message

│ ├── category

│ ├── upvotes

│ ├── createdAt

│

└── invite\_codes/

└── {codeId}

├── campusId

├── code

├── expiresAt

├── role

## 3\. Data Schemas (Field-Level)

### 3.1 User Schema

userId: string

campusId: string

email: string

role: student | admin

isVerified: boolean

createdAt: timestamp

### 3.2 Issue Schema

issueId: string

campusId: string

title: string

description: string

category: electrical | plumbing | internet | other

mediaUrl: string

location: { lat, lng }

status: pending | in\_progress | resolved

createdBy: userId

createdAt: timestamp

### 3.3 Notice/Event Schema

noticeId: string

campusId: string

title: string

description: string

type: notice | event

attachmentUrl: string

createdAt: timestamp

### 3.4 Feedback Schema

feedbackId: string

campusId: string

message: string

category: academics | facilities | admin

upvotes: number

createdAt: timestamp

### 3.5 Campus Location Schema

locationId: string

campusId: string

name: string

type: lab | classroom | office | hostel

latitude: number

longitude: number

## 4\. Why This Structure Works

*   Feature isolation for team collaboration
*   Clean separation of UI, logic, and services
*   Easy to scale modules
*   Firebase-friendly
*   Hackathon efficient

## 5\. Next Recommended Steps

*   Define Firestore security rules
*   Create admin-only collections
*   Add analytics events
*   Prepare dummy seed data