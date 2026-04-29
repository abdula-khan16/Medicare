# MediCare - Semester Project Report (Filled Draft)

## Title Page Content

**Project Title:** MediCare  
**Session:** 2023-2027  
**Subject:** Mobile Application Development  
**Department:** Software Engineering  
**Faculty:** Computer Science and Information Technology  
**University:** Superior University, Lahore  
**Semester:** Spring 2026

---

## Plagiarism Free Certificate (Filled)

This is to certify that I, **Abdullah S/o Habib Ali**, group leader under registration number **SU92-BSSEM-F23-087**, Department of Software Engineering, Superior University Lahore, declare that this semester project report titled **"MediCare"** has been prepared by us and reviewed by our supervisor.  

Project Nature: **Development**  
Area of Specialization: **Mobile Health Care and Appointment Management in Pakistan**  

Project Group Members:  
1. Abdullah - SU92-BSSEM-F23-087 - @superior.edu.pk

---

## Dedication

This work is dedicated to our parents and teachers for their continuous support, guidance, and encouragement throughout our academic journey. We also dedicate this project to all healthcare workers whose dedication inspired us to design a practical digital healthcare solution.

---

## Acknowledgements

We are deeply thankful to our supervisor for valuable guidance, technical feedback, and constant motivation during the development of this semester project. We are also grateful to the faculty of Software Engineering, Superior University Lahore, for providing an academic environment that encouraged practical implementation. Finally, we thank our classmates and friends who supported us during testing and feedback sessions.

---

## Executive Summary

MediCare is a Flutter-based mobile healthcare application that digitizes the appointment and prescription workflow between patients and doctors. The project addresses common issues in traditional clinic processes such as manual queue handling, unstructured appointment records, and paper-based prescriptions that are difficult to track over time.

The application supports two primary roles: patient and doctor. A patient can register/login, search doctors, view available sessions, book appointments through a token-based queue mechanism, track upcoming appointments, and view prescriptions written by doctors. A doctor can manage profile information, create consultation sessions, monitor today's patient queue, write digital prescriptions, mark appointments complete, and access patient lists from backend records.

The system uses Firebase Authentication for secure sign-in/sign-up and Cloud Firestore as the real-time backend database. Core collections include users, sessions, appointments, and prescriptions. The architecture follows a service-oriented approach in Flutter, where dedicated services handle business logic and database operations, while UI screens focus on user interaction.

Technically, the project demonstrates integration of role-based access logic, CRUD operations, queue token generation, appointment status lifecycle management (pending/completed/cancelled), and backend-driven prescription visibility. Prescriptions are linked to patient IDs and fetched only for the authenticated patient, ensuring role-level data privacy in practical usage.

The implementation shows that a lightweight cross-platform mobile app can improve clinical workflow transparency, reduce manual coordination overhead, and provide better continuity of care through digital records. MediCare can be further extended with telemedicine, analytics dashboards, notifications, and report export in future versions.

---

## Chapter 1 - Introduction

### 1.1 Background
Healthcare appointments in many local clinics are still handled using manual registers and verbal queue management. Patients often face uncertainty about consultation order, while doctors spend time organizing non-clinical tasks. Paper prescriptions are frequently misplaced, and there is limited continuity between visits. With increasing smartphone penetration in Pakistan, mobile solutions can simplify these workflows for both clinics and patients.

### 1.2 Motivations and Challenges
The key motivation behind MediCare is to build a practical, student-level healthcare app that solves real clinic problems through digital workflows. Major challenges included role-based application flow, secure authentication, real-time backend consistency, appointment token management, and synchronizing prescription data with patient privacy constraints.

### 1.3 Goals and Objectives
- Build a role-based mobile app for doctors and patients.
- Implement secure authentication and user profile storage.
- Enable doctors to create consultation sessions with timing and slot logic.
- Allow patients to book appointments using a queue/token model.
- Provide doctor-side queue management and digital prescription writing.
- Ensure patients can view only their own prescriptions from backend data.
- Deliver a usable UI with clear navigation and practical workflow.

### 1.4 Literature Review / Existing Solutions
Popular healthcare platforms provide appointment booking and digital records, but many are either too complex, paid, web-first, or not localized for small clinic workflows. Existing solutions often emphasize hospital-scale management. MediCare focuses on a simplified mobile-first model suitable for individual practitioners and patients with limited setup.

### 1.5 Gap Analysis
Identified gaps in simpler clinic contexts:
- No lightweight role-based mobile app tailored for appointment + queue + prescription flow.
- Limited continuity between appointment and prescription records.
- Manual queue systems without digital token tracking.
- Weak accessibility for patients to retrieve previous medication instructions.

### 1.6 Proposed Solution
MediCare provides:
- Firebase-authenticated doctor/patient accounts.
- Doctor session creation with date/time and slot controls.
- Patient booking with automatic token/checkup ID generation.
- Doctor queue screen with complete/cancel actions.
- Digital prescription writing linked to appointment and patient.
- Patient prescription screen that fetches only authenticated patient data.

### 1.7 Project Plan
Development was executed in iterative phases:
1. Requirements and UI planning.
2. Authentication and role logic.
3. Doctor and patient module development.
4. Firestore backend integration.
5. Queue and prescription workflow completion.
6. Testing, refinement, and documentation.

#### 1.7.1 Work Breakdown Structure
- Module 1: Auth and onboarding
- Module 2: Doctor dashboard and sessions
- Module 3: Patient discovery and booking
- Module 4: Queue and prescription backend
- Module 5: Testing and final report

#### 1.7.2 Roles and Responsibility Matrix
- Abdullah: Requirement analysis, Flutter UI implementation, Firebase integration, service-layer logic, final documentation.

#### 1.7.3 Gantt Chart (Textual)
- Week 1-2: Planning and wireframing
- Week 3-4: Auth and role management
- Week 5-7: Doctor and patient core modules
- Week 8-9: Queue and prescription implementation
- Week 10: Testing and bug fixes
- Week 11-12: Report preparation and final review

### 1.8 Report Outline
This report presents project context, requirements, analysis and design, implementation details, testing outcomes, and future recommendations.

---

## Chapter 2 - Software Requirement Specifications (SRS)

### 2.1 Introduction
This SRS defines the software requirements for MediCare mobile application release v1.0.

#### 2.1.1 Purpose
To specify functional and non-functional requirements for a role-based medical appointment and prescription system for Android/iOS using Flutter and Firebase.

#### 2.1.2 Document Conventions
Requirement IDs follow format:
- FR-x for functional requirements
- NFR-x for non-functional requirements

#### 2.1.3 Intended Audience and Reading Suggestions
- Supervisor and faculty evaluators
- Developers and future maintainers
- QA/testing reviewers

#### 2.1.4 Product Scope
MediCare supports patient-doctor interaction through account management, appointment booking, queue processing, and digital prescriptions.

#### 2.1.5 References
- Flutter Documentation
- Firebase Authentication Documentation
- Cloud Firestore Documentation
- GetX package documentation

### 2.2 Overall Description

#### 2.2.1 Product Perspective
MediCare is a standalone cross-platform mobile app with Firebase backend services.

#### 2.2.2 Product Functions
- User registration/login by role
- Doctor profile and session management
- Doctor discovery by patients
- Appointment booking with token generation
- Queue status handling
- Prescription creation and retrieval

#### 2.2.3 User Classes and Characteristics
- **Patient:** books appointments and views prescriptions.
- **Doctor:** manages sessions, queue, and prescriptions.

#### 2.2.4 Operating Environment
- Flutter mobile runtime
- Android and iOS devices
- Firebase backend (Auth + Firestore)

#### 2.2.5 Design and Implementation Constraints
- Internet required for backend operations
- Firebase free-tier limits
- Client-side role navigation constraints

#### 2.2.6 User Documentation
- In-app labels and screens
- Final project report and demo walkthrough

#### 2.2.7 Assumptions and Dependencies
- Users provide valid email/phone
- Firebase project configured correctly
- Device has stable internet connectivity

### 2.3 External Interface Requirements

#### 2.3.1 User Interfaces
- Separate home dashboards for patient and doctor
- Queue cards, booking cards, and prescription cards

#### 2.3.2 Hardware Interfaces
- Smartphone touchscreen device

#### 2.3.3 Software Interfaces
- Firebase Auth API
- Cloud Firestore API
- GetX navigation/state utilities

#### 2.3.4 Communication Interfaces
- HTTPS communication between app and Firebase

### 2.4 System Features

#### 2.4.1 Feature 1: Authentication and Role Routing
- **Description/Priority:** High priority secure user access.
- **Stimulus/Response:** User enters credentials -> system validates -> navigates to doctor/patient home.
- **Functional Requirements:**
  - FR-1: System shall allow user registration with role.
  - FR-2: System shall authenticate users via email/password.
  - FR-3: System shall route users according to stored role.

#### 2.4.2 Feature 2: Appointment and Queue Management
- **Description/Priority:** High priority clinic workflow.
- **Stimulus/Response:** Patient books a session -> token generated -> appears in doctor queue.
- **Functional Requirements:**
  - FR-4: System shall create appointment with token/checkup ID.
  - FR-5: Doctor shall view today's pending queue.
  - FR-6: Doctor shall mark appointments complete/cancelled.

#### 2.4.3 Feature 3: Prescription Management
- **Description/Priority:** High priority patient continuity.
- **Stimulus/Response:** Doctor writes medicines -> prescription saved -> patient views own records.
- **Functional Requirements:**
  - FR-7: Doctor shall add multiple medicines per prescription.
  - FR-8: System shall link prescription to appointment and patient.
  - FR-9: Patient shall fetch only own prescriptions.

### 2.5 Nonfunctional Requirements

#### 2.5.1 Performance Requirements
- Typical screen-to-data response should be within acceptable mobile network latency.

#### 2.5.2 Safety Requirements
- Input validation to reduce erroneous submissions.

#### 2.5.3 Security Requirements
- Authenticated access via Firebase Authentication.
- Data separation by patient/doctor role and IDs.

#### 2.5.4 Software Quality Attributes
- Usability: clean role-based interface.
- Maintainability: service-layer separation.
- Reliability: backend persistence in Firestore.

#### 2.5.5 Business Rules
- One appointment belongs to one patient and one doctor.
- Queue order depends on token number.
- Completed appointment can have linked prescription.

### 2.6 Other Requirements
- Future support for notifications and teleconsultation.

---

## Chapter 3 - Use Case Analysis / System Analysis

### 3.1 Use Case Model (Actors)
- Patient
- Doctor
- Firebase Backend (supporting external system)

### 3.2 Use Case Descriptions (Major)
1. Register/Login User  
2. Create Doctor Session  
3. Find and Book Doctor Appointment  
4. View Doctor Queue  
5. Write Prescription  
6. View Patient Prescriptions  
7. Manage Profile Data

### Key Use Case Example - Write Prescription
- **Primary Actor:** Doctor
- **Precondition:** Doctor authenticated and patient appointment exists.
- **Main Flow:** Open queue -> select patient -> add medicine list + notes -> save.
- **Postcondition:** Prescription stored in backend and appointment status updated.

---

## Chapter 4 - System Design

### 4.1 Architecture Diagram (Textual Description)
MediCare follows a 3-layer flow:
1. **Presentation Layer:** Flutter screens for patient/doctor/auth.
2. **Service Layer:** `DoctorService` and `PatientService` encapsulate business logic.
3. **Backend Layer:** Firebase Auth + Firestore collections (`users`, `sessions`, `appointments`, `prescriptions`).

### 4.2 Domain Model (Core Entities)
- User (doctor/patient)
- Session
- Appointment
- Prescription
- Medicine Item

### 4.3 Entity Relationship Description
- One Doctor -> many Sessions
- One Session -> many Appointments
- One Patient -> many Appointments
- One Appointment -> zero/one Prescription
- One Prescription -> many Medicines

### 4.4 Class Diagram (Conceptual)
- `DoctorService`: doctor CRUD, sessions, queue, prescriptions
- `PatientService`: patient profile, booking, appointments, prescriptions
- UI Screen classes call services and render backend data

### 4.5 Sequence Diagram Narratives
- **Booking sequence:** Patient screen -> `PatientService.bookAppointment()` -> Firestore transaction -> token returned -> UI confirmation.
- **Prescription sequence:** Doctor queue -> write screen -> `DoctorService.writePrescription()` -> save prescription + complete appointment -> patient prescriptions fetch.

### 4.6 Operation Contracts (Sample)
- `bookAppointment(patientId, doctorId, sessionId, date, time)`  
  Returns token/checkup ID and persists appointment.
- `writePrescription(...)`  
  Persists medicines and updates appointment status.

### 4.7 Activity Diagram Narrative
Auth -> Role-based dashboard -> Module action (book/create/write) -> Firestore update -> UI refresh.

### 4.8 State Transition Narrative (Appointment)
`pending` -> `completed` or `cancelled`

### 4.9 Component Diagram Narrative
Components: Auth Module, Patient Module, Doctor Module, Shared Constants, Service Layer, Firebase Connector.

### 4.10 Deployment Diagram Narrative
Client mobile app deployed on smartphone; backend hosted on Firebase cloud services.

### 4.11 Data Flow Diagram (Level 0/1 Narrative)
Patient and doctor send requests via app UI -> service methods -> Firestore reads/writes -> updated data returned to UI.

---

## Chapter 5 - Implementation

### 5.1 Important Flow Control / Pseudocode
1. User login -> auth success -> fetch role -> route to corresponding home.
2. Book appointment -> check session slots -> generate token -> save appointment.
3. Queue completion -> update status.
4. Prescription creation -> save medicine list -> patient fetches own records.

### 5.2 Components, Libraries, Web Services
- Flutter framework
- Dart language
- Firebase Authentication
- Cloud Firestore
- GetX (navigation and utility)
- intl package (date formatting)

### 5.3 Deployment Environment
- Flutter SDK environment
- Android emulator/device (primary)
- Firebase project with configured Auth + Firestore rules

### 5.4 Tools and Techniques
- IDE: Cursor/VS Code compatible Flutter workflow
- Real-time backend integration
- Component-based UI structuring
- Iterative development and feature testing

### 5.5 Best Practices / Coding Standards
- Service layer for backend logic separation
- Reusable constants for colors/text styles
- Input validation before backend calls
- Defensive defaults when backend data is missing

### 5.6 Version Control
Git-based local version management used during development and iterative enhancements.

---

## Chapter 6 - Testing and Evaluation

### 6.1 Use Case Testing
Verified major flows: registration, login, role routing, session creation, booking, queue handling, prescription writing, prescription viewing.

### 6.2 Equivalence Partitioning
Inputs divided into valid/invalid classes for email, phone, password, and required fields.

### 6.3 Boundary Value Analysis
Tested minimum and missing input boundaries for forms and slot calculations.

### 6.4 Data Flow Testing
Tracked data paths from UI -> services -> Firestore and back to UI.

### 6.5 Unit Testing (Manual Functional Units)
Service methods manually validated through UI triggers and database output verification.

### 6.6 Integration Testing
Validated integrated flow among authentication, appointment booking, queue updates, and prescription retrieval.

### 6.7 Performance Testing
Observed acceptable response for normal CRUD operations on stable internet.

### 6.8 Stress Testing
Basic repeated interactions were performed (booking, queue refresh, status updates) without crashes in normal usage conditions.

---

## Chapter 7 - Summary, Conclusion and Future Enhancements

### 7.1 Project Summary
MediCare successfully demonstrates a functional healthcare mobile app that digitizes patient-doctor workflows using Flutter and Firebase.

### 7.2 Achievements and Improvements
- Role-based login and dashboards implemented.
- Real-time appointment and queue logic implemented.
- Prescription workflow connected doctor to patient records.
- Backend-driven data replaced static dummy content.

### 7.3 Critical Review
The project is functionally complete for core requirements, but production readiness requires stronger automated testing, richer analytics, and stricter backend rule hardening.

### 7.4 Lessons Learnt
- Importance of data modeling before UI development.
- Service-layer abstraction improves maintainability.
- Real-time backend features require careful status and consistency handling.

### 7.5 Future Enhancements / Recommendations
- Push notifications for appointments and reminders
- Advanced search and filtering
- PDF prescription export/share
- Telemedicine video consultation
- Multi-language support
- Admin dashboard and analytics
- Cloud Functions for backend automation

---

## Reference and Bibliography

[1] Flutter Team, "Flutter Documentation," [Online]. Available: https://docs.flutter.dev/  
[2] Google Firebase, "Firebase Authentication Documentation," [Online]. Available: https://firebase.google.com/docs/auth  
[3] Google Firebase, "Cloud Firestore Documentation," [Online]. Available: https://firebase.google.com/docs/firestore  
[4] Jonatas Borges et al., "GetX Package Documentation," [Online]. Available: https://pub.dev/packages/get  
[5] Dart Team, "Dart Language Tour," [Online]. Available: https://dart.dev/guides

---

## Appendix A - User Manual (Short)

1. Register as patient or doctor.  
2. Login with email/password.  
3. Patient: Find doctor -> book appointment -> view prescriptions.  
4. Doctor: Create session -> open queue -> write prescription/complete checkup.  

## Appendix B - Administrator Manual (Short)

- Configure Firebase project and app keys.  
- Enable Email/Password authentication.  
- Maintain Firestore collections: users, sessions, appointments, prescriptions.  

## Appendix C - Promotional Material (Short)

**MediCare:** A smart, simple clinic workflow app for digital appointments, queue handling, and prescriptions.
