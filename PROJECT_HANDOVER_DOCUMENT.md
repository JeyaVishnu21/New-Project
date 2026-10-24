# Comprehensive Project Handover & Technical Specification Document
## Project: Campus Crowd Event Management & AI Crowd Monitoring System

> **Document Version**: 2.0 (Complete System Implementation)  
> **Target Audience**: AI Report Generation Engine / Academic Project Evaluation Committee / Technical Evaluators  
> **Domain**: Full-Stack Web Engineering, Applied Deep Learning (Computer Vision), Database Design, Public Safety & Facility Management  
> **Repository Root**: `code/`

---

## 1. Executive Summary & Project Overview

### 1.1 Project Title
**Campus Crowd Event Management and AI Density Monitoring System** (also referenced as *Crowd Event Management System*).

### 1.2 Academic Context & Purpose
This software system was conceived and engineered as an end-to-end college capstone / engineering project. It tackles two critical problems encountered in institutional environments:
1. **Administrative Event Chaos & Venue Double-Booking**: Campus clubs, departments, and student committees frequently schedule overlapping events, compete for limited campus auditoriums/seminar halls, and experience administrative bottlenecks in paper-based or informal approval channels.
2. **Crowd Safety & Overcrowding Hazards**: Campus auditoriums, open-air theatres, and sports complexes have strict fire-safety and structural capacity limits. Overcrowding presents serious safety risks. Traditional counting methods (manual clickers, head-turning) are imprecise, slow, and unrecorded.

### 1.3 High-Level Solution
The platform integrates:
- A **Public Event Discovery Portal** for students, faculty, and guests to explore confirmed campus events, multi-day festivals (fests), and check live crowd status.
- An **Organizer Portal** where student club leads propose events with preferred venues and schedules, track approval status, and—during the active event—upload crowd surveillance photos.
- An **Institutional Management Portal** where administrators review event proposals, inspect campus venue availability, automatically detect scheduling collisions, approve/reject proposals with institutional feedback, manage campus venues, and create umbrella festival series.
- An **AI Crowd Counting Pipeline** based on the state-of-the-art **CSRNet (Dilated Convolutional Neural Network)** that performs head-density estimation on uploaded event images in real time without facial recognition or biometric invasion.
- An **Automated Safety Alert Engine** that compares estimated headcount against venue capacity thresholds (`threshold = max(0, venue.capacity - 50)`), instantaneously dispatching visual warnings and capacity breach notifications.
- An **Institutional PDF Reporting Engine** combining ReportLab and Matplotlib to produce printable, official crowd audit reports containing timeline charts, peak occupancy metrics, and safety logs.

---

## 2. Technology Stack & System Specifications

| Tier | Component / Technology | Version / Specification | Role in Architecture |
| :--- | :--- | :--- | :--- |
| **Frontend Framework** | React.js | `^19.2.8` | Component-based dynamic User Interface |
| **Frontend Build Tool** | Vite | `^8.3.0` | Ultra-fast HMR development server and bundler |
| **Client-Side Routing** | React Router DOM | `^7.18.4` | Single-Page Application (SPA) client routing and role guards |
| **Frontend Styling** | Vanilla CSS3 (Pure) | Custom System (`styles.css` ~125KB) | Modern glassmorphism, responsive CSS variables, dark/light theme |
| **Frontend Code Quality**| Oxlint | `^1.81.0` | High-performance JavaScript/JSX linter |
| **Backend Framework** | Python Flask | `>=3.1.0` (Python 3.10 – 3.14) | Modular REST API server using Application Factory & Blueprints |
| **CORS Middleware** | Flask-CORS | `>=5.0.0` | Cross-Origin Resource Sharing with session cookie credentials |
| **Environment Config** | python-dotenv | `>=1.0.0` | `.env` environment variable isolation |
| **Database Engine** | MySQL / MariaDB | MySQL 8.x+ / InnoDB | Relational data persistence with strict foreign key constraints |
| **Database Driver** | PyMySQL | `>=1.1.0` | Python native DB-API connector with connection pooling |
| **Deep Learning Framework**| PyTorch & Torchvision | `torch>=2.0`, `torchvision` | CSRNet neural network inference and tensor processing |
| **Hardware Acceleration** | NVIDIA CUDA / CPU | RTX 3050 prioritized | Automatic hardware device acceleration with CPU fallback |
| **Image Processing** | Pillow (PIL) | `>=10.0.0` | Image decoding, format validation, uniform/blank frame detection |
| **PDF Generation** | ReportLab | `>=4.0.0` | Institutional publication-quality multi-page PDF generation |
| **Data Visualization** | Matplotlib | `>=3.8.0` (`Agg` headless) | Headcount timeline trend graph rendering for PDF export |

---

## 3. High-Level Architecture & System Design

```
+---------------------------------------------------------------------------------------+
|                                    CLIENT BROWSER                                      |
|                                                                                       |
|  +--------------------+   +-----------------------+   +----------------------------+  |
|  |   Public Portal    |   |   Organizer Portal    |   |   Administrator Portal     |  |
|  | (Events & Fests)   |   | (Proposals & Uploads) |   | (Review, Venues, Alerts)   |  |
|  +---------+----------+   +-----------+-----------+   +-------------+--------------+  |
|            |                          |                             |                 |
|            +--------------------------+-----------------------------+                 |
|                                       | (HTTP REST + JSON + Session Cookies)          |
+---------------------------------------|-----------------------------------------------+
                                        v
+---------------------------------------------------------------------------------------+
|                                FLASK BACKEND SERVER                                   |
|                                                                                       |
|  +-----------------------+    +------------------------+   +-----------------------+  |
|  |  Session & Auth Guard |    |   Routing Blueprints   |   | Custom JSON Provider  |  |
|  |  (RBAC Middleware)    |    |  (11 Active Modules)   |   | (Time/Date/Decimal)   |  |
|  +-----------+-----------+    +-----------+------------+   +-----------------------+  |
|              |                            |                                           |
|              +----------------------------+                                           |
|                                           v                                           |
|  +---------------------+      +------------------------+   +-----------------------+  |
|  | Conflict Detection  |      | Event Happening Guard  |   | Threshold Alert Engine|  |
|  | (No double booking) |      | (Time-window checker)  |   | (Capacity - 50 Rule)  |  |
|  +---------------------+      +-----------+------------+   +-----------------------+  |
|                                           |                                           |
+-------------------------------------------|-------------------------------------------+
               |                            |                            |
               v                            v                            v
+-----------------------------+ +------------------------+ +----------------------------+
|   MySQL RELATIONAL DB       | |  LOCAL FILE STORAGE    | |   CSRNet AI INFERENCE      |
|                             | |                        | |                            |
| - users                     | | backend/uploads/       | | - VGG-16 Feature Backbone  |
| - venues                    | |   event_images/        | | - Dilated Convolutions (r=2)|
| - fest (series)             | |                        | | - Density Map Head         |
| - events                    | | (UUID-safe filenames,  | | - Automatic CUDA/CPU       |
| - images                    | |  atomic FS cleanup)    | | - Pretrained Checkpoints:  |
| - crowd_analyses            | |                        | |   ShanghaiTech Part B / A  |
| - alerts                    | |                        | | - Blank Image Filter       |
+-----------------------------+ +------------------------+ +----------------------------+
```

---

## 4. Deep Learning Crowd Density Estimation Pipeline (CSRNet)

### 4.1 Theory & Architecture Selection
Unlike object detection networks (YOLO, Faster R-CNN) that struggle with dense occlusions where individual heads are as small as 5–15 pixels, **CSRNet** (*Dilated Convolutional Neural Networks for Understanding the Highly Congested Scenes*, CVPR 2018) utilizes continuous density maps.

The network architecture is structured into two main components:
1. **Frontend Feature Extractor**:
   - First 10 convolutional layers from the VGG-16 backbone (pretrained on ImageNet).
   - Structured as: `Conv(3->64) -> Conv(64->64) -> MaxPool -> Conv(64->128) -> Conv(128->128) -> MaxPool -> Conv(128->256) -> Conv(256->256) -> Conv(256->256) -> MaxPool -> Conv(256->512) -> Conv(512->512) -> Conv(512->512)`.
   - Incorporates 3 pooling operations, producing intermediate representations downsampled by a spatial factor of $8$.
2. **Backend Contextual Aggregator (Dilated Convolutions)**:
   - 6 sequential dilated convolutional layers with a constant dilation rate $r = 2$.
   - Filter channels: `512 -> 512 -> 512 -> 256 -> 128 -> 64`.
   - The dilated convolution (atrous convolution) computes:
     $$y[i] = \sum_{k} x[i + r \cdot k] \cdot w[k]$$
     This enlarges the receptive field exponentially without pooling or downsampling, avoiding spatial resolution degradation.
3. **Density Prediction Head**:
   - A $1 \times 1$ Convolutional layer mapping 64 channels to a single continuous channel ($1 \times H/8 \times W/8$).
   - The estimated crowd count $N$ is obtained via numerical spatial integration:
     $$N = \sum_{h=1}^{H/8} \sum_{w=1}^{W/8} D(h, w)$$

### 4.2 Checkpoint Weights & Model Parameters
- **Total Model Parameters**: 16,263,361 float32 weights (~65 MB).
- **Default Production Checkpoint**: `shanghaitech_part_b.pth` (trained on ShanghaiTech Part B for sparse-to-medium campus settings, fixed Gaussian kernel $\sigma=15$).
- **Benchmark Dense Checkpoint**: `shanghaitech_part_a.pth` (trained on ShanghaiTech Part A for congested gatherings, geometry-adaptive kernels).
- **VRAM Footprint**: ~65 MB static weight memory + ~100 MB activation memory at 1080p, running within 200 MB total VRAM (optimized for NVIDIA RTX 3050 4GB).

### 4.3 Preprocessing & Image Quality Safeguards
- **ImageNet Normalization**: Input RGB images are converted to tensors and normalized with mean `[0.485, 0.456, 0.406]` and standard deviation `[0.229, 0.224, 0.225]`.
- **Thread-Safe Lazy Singleton**: Managed by `CrowdPredictor` with Python `threading.Lock()` so concurrent inference requests do not corrupt GPU memory.
- **Blank / Solid Color Image Rejection**: Custom C-accelerated `getextrema()` filter detects solid test images or dark lens caps (variance $\le 1$ across RGB channels) and rejects them with HTTP 422 to prevent false density hallucination.
- **Integrity Validation**: Pillow `verify()` checks file headers to prevent corrupted or malicious payload uploads.

---

## 5. Database Schema & Data Modeling

The system operates on the relational database `crowd_event_db` (MySQL 8.x+ InnoDB, `utf8mb4_unicode_ci`).

```
+-----------------------------------------------------------------------------------+
|                                 DATABASE ENTITY RELATIONSHIPS                      |
|                                                                                   |
|      +------------------+                    +--------------------+               |
|      |      users       |                    |        fest        |               |
|      +------------------+                    +--------------------+               |
|      | id (PK)          |<-------+           | id (PK)            |<------+       |
|      | name             |        |           | name               |       |       |
|      | email (UNIQUE)   |        |           | description        |       |       |
|      | password_hash    |        |           | start_date         |       |       |
|      | role (ENUM)      |        |           | end_date           |       |       |
|      +------------------+        |           +--------------------+       |       |
|               |                  |                     |                  |       |
|               | 1                |                     | 0..1             |       |
|               |                  |                     |                  |       |
|               v N                |                     v N                |       |
|      +------------------+        |           +--------------------+       |       |
|      |      events      |--------+           |       venues       |       |       |
|      +------------------+                    +--------------------+       |       |
|      | id (PK)          |                    | id (PK)            |<---+  |       |
|      | organizer_id(FK) |                    | name               |    |  |       |
|      | venue_id (FK)    |------------------->| location           |    |  |       |
|      | series_id (FK)   |--------------------+ capacity           |    |  |       |
|      | event_name       |                    | status (ENUM)      |    |  |       |
|      | status (ENUM)    |                    +--------------------+    |  |       |
|      | requested_date   |                                              |  |       |
|      | requested_times  |                                              |  |       |
|      | approved_date    |                                              |  |       |
|      | approved_times   |                                              |  |       |
|      | category         |                                              |  |       |
|      +------------------+                                              |  |       |
|         | 1          | 1                                               |  |       |
|         |            |                                                 |  |       |
|         v N          v N                                               |  |       |
|  +--------------+  +--------------+                                    |  |       |
|  |    images    |  |    alerts    |------------------------------------+  |       |
|  +--------------+  +--------------+                                       |       |
|  | id (PK)      |  | id (PK)      |                                       |       |
|  | event_id(FK) |  | event_id(FK) |                                       |       |
|  | image_path   |  | user_id (FK) |                                       |       |
|  | status (ENUM)|  | detected_cnt |                                       |       |
|  +--------------+  | threshold    |                                       |       |
|         | 1        | message      |                                       |       |
|         |          | status (ENUM)|                                       |       |
|         v 1 (UNIQUE)+--------------+                                       |       |
|  +-------------------+                                                    |       |
|  |  crowd_analyses   |                                                    |       |
|  +-------------------+                                                    |       |
|  | id (PK)           |                                                    |       |
|  | image_id (FK,UNQ) |                                                    |       |
|  | predicted_count   |                                                    |       |
|  | model_name        |                                                    |       |
|  | processing_status |                                                    |       |
|  +-------------------+                                                    |       |
+-----------------------------------------------------------------------------------+
```

### 5.1 Tables Specification

#### 1. `users`
- `id` (INT, PK, Auto Increment)
- `name` (VARCHAR(100), NOT NULL): Full name.
- `email` (VARCHAR(150), NOT NULL, UNIQUE): Institutional login email.
- `password_hash` (VARCHAR(255), NOT NULL): Werkzeug salted hash (PBKDF2 / scrypt).
- `role` (ENUM('administrator', 'organizer'), NOT NULL): Role access definition.
- `created_at`, `updated_at` (TIMESTAMP).

#### 2. `venues`
- `id` (INT, PK, Auto Increment)
- `name` (VARCHAR(100), NOT NULL): Venue designation (e.g. "Main Auditorium").
- `location` (VARCHAR(255), NOT NULL): Campus building, floor, or zone.
- `capacity` (INT, NOT NULL, DEFAULT 0): Safe headcount occupancy limit.
- `status` (ENUM('available', 'unavailable'), NOT NULL, DEFAULT 'available').
- `created_at`, `updated_at` (TIMESTAMP).

#### 3. `fest` (Aliased as `event_series`)
- `id` (INT, PK, Auto Increment)
- `name` (VARCHAR(150), NOT NULL): Festival / symposium title (e.g. "Legacy 2K26").
- `description` (TEXT, NULL): Festival themes, guidelines.
- `start_date`, `end_date` (DATE, NULL): Festival timeline.
- `created_at`, `updated_at` (TIMESTAMP).

#### 4. `events`
- `id` (INT, PK, Auto Increment)
- `organizer_id` (INT, NOT NULL, FK -> `users.id`, ON DELETE RESTRICT)
- `venue_id` (INT, NULL, FK -> `venues.id`, ON DELETE SET NULL)
- `series_id` (INT, NULL, FK -> `fest.id`, ON DELETE SET NULL)
- `event_name` (VARCHAR(150), NOT NULL)
- `description` (TEXT, NULL)
- `status` (ENUM('pending', 'approved', 'rejected', 'completed', 'cancelled'), DEFAULT 'pending')
- `requested_date` (DATE, NOT NULL): Initial date requested by organizer.
- `requested_start_time`, `requested_end_time` (TIME, NOT NULL): Initial times requested.
- `approved_date` (DATE, NULL): Official date assigned by administrator.
- `approved_start_time`, `approved_end_time` (TIME, NULL): Official time window assigned by administrator.
- `category` (VARCHAR(50), DEFAULT 'General'): Technical, Cultural, Sports, Arts, etc.
- `expected_participants` (INT, NULL): Expected attendee count.
- `rejection_reason` (VARCHAR(255), NULL): Institutional administrative reason if rejected.
- `created_at`, `updated_at` (TIMESTAMP).

#### 5. `images`
- `id` (INT, PK, Auto Increment)
- `event_id` (INT, NOT NULL, FK -> `events.id`, ON DELETE CASCADE)
- `image_path` (VARCHAR(255), NOT NULL): Relative storage path (`uploads/event_images/...`).
- `uploaded_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `processing_status` (ENUM('pending', 'processing', 'completed', 'failed'), DEFAULT 'pending').

#### 6. `crowd_analyses`
- `id` (INT, PK, Auto Increment)
- `image_id` (INT, NOT NULL, UNIQUE, FK -> `images.id`, ON DELETE CASCADE)
- `predicted_count` (INT, NOT NULL): Headcount estimate derived by CSRNet.
- `analysis_timestamp` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `processing_status` (ENUM('pending', 'completed', 'failed'), DEFAULT 'completed')
- `model_name` (VARCHAR(50), DEFAULT 'CSRNet')
- `created_at`, `updated_at` (TIMESTAMP).

#### 7. `alerts`
- `id` (INT, PK, Auto Increment)
- `event_id` (INT, NOT NULL, FK -> `events.id`, ON DELETE CASCADE)
- `user_id` (INT, NOT NULL, FK -> `users.id`, ON DELETE CASCADE): Recipient administrator or organizer.
- `crowd_analysis_id` (INT, NULL, FK -> `crowd_analyses.id`, ON DELETE SET NULL)
- `detected_count` (INT, NOT NULL): Estimated headcount triggering alert.
- `threshold` (INT, NOT NULL): Safe capacity threshold value.
- `message` (VARCHAR(255), NOT NULL): Institutional alert text.
- `status` (ENUM('unread', 'read'), DEFAULT 'unread')
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP).

---

## 6. Core Business Logic & Algorithms

### 6.1 Venue Scheduling Conflict Detection Engine
To prevent physical venue collisions, `VenueModel.check_conflict()` validates any proposed schedule against existing `approved` events.

```sql
SELECT id, event_name, approved_date, approved_start_time, approved_end_time
FROM events
WHERE venue_id = %s
  AND status = 'approved'
  AND approved_date = %s
  AND id != %s
  AND (
      (approved_start_time < %s AND approved_end_time > %s)
  )
LIMIT 1;
```
If an overlap exists, the administrator's allocation is blocked with **HTTP 409 Conflict**, naming the colliding event and its time range.

### 6.2 Event Happening Time-Window Gating
Surveillance photo uploads are restricted to maintain data integrity. An organizer cannot upload images before an event starts or after it finishes. `EventModel.is_event_happening()` evaluates:
1. `event.status == 'approved'`.
2. Management final schedule (`approved_date`, `approved_start_time`, `approved_end_time`) is set.
3. `approved_date == server_today_date`.
4. `approved_start_time <= current_server_time < approved_end_time`.
If any condition fails, upload is rejected with a clear message (e.g. *"Photo upload is blocked: event starts today at 14:00:00. Uploads open when the event starts."*).

### 6.3 Event Auto-Completion Cycle
Whenever queries run, `EventModel.auto_update_completed_events()` runs an atomic update transitioning approved events to `completed` once their `approved_date` and `approved_end_time` have passed.

### 6.4 Crowd Safety Alert Formula
When CSRNet analyzes an image, `AlertModel.evaluate_and_create_alerts()` calculates:
$$\text{Threshold} = \max(0, \text{venue.capacity} - 50)$$
- **Condition 1 (Critical Capacity Breach)**: If $\text{predicted\_count} \ge \text{venue.capacity}$, a critical alert is dispatched:  
  *"CRITICAL CAPACITY BREACH: Event '[Name]' has reached [Count] attendees (Venue capacity: [Capacity])"*.
- **Condition 2 (High Crowd Warning)**: If $\text{predicted\_count} \ge \text{Threshold}$ and $\text{predicted\_count} < \text{venue.capacity}$, a warning alert is dispatched:  
  *"HIGH CROWD WARNING: Event '[Name]' has [Count] attendees approaching capacity limit [Capacity]"*.
- **Recipient Distribution**: Alerts are created in the database for the event's organizer and all campus administrators.

---

## 7. Complete REST API Reference

All API routes are prefixed with `/api`. Authentication uses HttpOnly server-side session cookies (`credentials: 'include'`).

### 7.1 Authentication & Profile (`/api/auth`)
| Method | Endpoint | Access | Description | Request Body |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/register` | Public | Registers Organizer or Administrator. Admin requires `administrator_code`. | `{ name, email, password, role, administrator_code }` |
| `POST` | `/api/auth/login` | Public | Authenticates credentials and starts session. | `{ email, password }` |
| `POST` | `/api/auth/logout` | Authenticated | Terminates server-side session. | None |
| `GET` | `/api/auth/me` | Authenticated | Fetches current user session profile. | None |

### 7.2 Venues Management (`/api/venues`)
| Method | Endpoint | Access | Description | Request Body |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/venues` | Authenticated | Lists all campus venues. | None |
| `POST` | `/api/venues` | Administrator | Creates a new venue. | `{ name, location, capacity, status }` |
| `PUT` | `/api/venues/<id>` | Administrator | Updates venue details. | `{ name, location, capacity, status }` |
| `PATCH`| `/api/venues/<id>/status`| Administrator | Toggles available/unavailable. | `{ status }` |
| `DELETE`| `/api/venues/<id>`| Administrator | Deletes unused venue. | None |

### 7.3 Events & Proposals (`/api/events`, `/api/administrator/events`)
| Method | Endpoint | Access | Description | Request Body |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/events` | Organizer | Lists all events owned by authenticated organizer. | None |
| `POST` | `/api/events` | Organizer | Submits a new event proposal. | `{ event_name, description, requested_date, requested_start_time, requested_end_time, category, venue_id, series_id }` |
| `GET` | `/api/administrator/events` | Administrator | Lists all campus events across all organizers. | None |
| `GET` | `/api/administrator/events/pending` | Administrator | Lists pending event requests. | None |
| `PATCH`| `/api/administrator/events/<id>/status` | Administrator | Approves or rejects event with reason. | `{ status: 'approved'\|'rejected', rejection_reason }` |
| `PATCH`| `/api/administrator/events/<id>/allocation` | Administrator | Sets final venue, date, times, and expected count (with collision check). | `{ venue_id, approved_date, approved_start_time, approved_end_time, expected_participants }` |
| `PATCH`| `/api/administrator/events/<id>/assign-fest` | Administrator | Associates event with a fest. | `{ series_id }` |

### 7.4 Fests & Series (`/api/administrator/fests`, `/api/public/fests`)
| Method | Endpoint | Access | Description | Request Body |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/administrator/fests` | Administrator | Lists all registered campus fests. | None |
| `POST` | `/api/administrator/fests` | Administrator | Registers a new campus festival. | `{ name, description, start_date, end_date }` |
| `DELETE`| `/api/administrator/fests/<id>` | Administrator | Deletes a fest (supports `reassign_to`).| `{ reassign_to }` |
| `GET` | `/api/administrator/fests/<id>/approved-events` | Administrator | Lists approved events under a fest. | None |

### 7.5 Images & AI Crowd Analysis (`/api/events/<id>/images`, `/api/images`)
| Method | Endpoint | Access | Description | Request / Query |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/events/<id>/images` | Organizer (Owner) | Uploads event surveillance image (time-window gated). | `multipart/form-data; file: image` |
| `GET` | `/api/events/<id>/images` | Authenticated | Retrieves image gallery for an event. | None |
| `POST` | `/api/images/<id>/analyze` | Organizer/Admin | Executes CSRNet crowd inference on image. | None |
| `GET` | `/api/images/<id>/analysis` | Organizer/Admin | Retrieves inference headcount and density stats. | None |
| `GET` | `/uploads/event_images/<filename>` | Authenticated | Serves stored event image file. | Path parameter |

### 7.6 Real-Time Safety Alerts (`/api/alerts`)
| Method | Endpoint | Access | Description | Query / Body |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/alerts` | Authenticated | Fetches crowd threshold alerts. | `?unread_only=true&scope=user\|all` |
| `GET` | `/api/alerts/unread-count` | Authenticated | Unread alerts badge counter. | None |
| `PATCH`| `/api/alerts/<id>/read` | Authenticated | Marks individual alert as read. | None |
| `POST` | `/api/alerts/mark-all-read` | Authenticated | Marks all unread alerts as read. | None |

### 7.7 Reports & Institutional PDF Generation (`/api/reports`)
| Method | Endpoint | Access | Description | Query / Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/reports/events` | Authenticated | Lists all events available for reporting. | None |
| `GET` | `/api/reports/events/<id>` | Authenticated | Complete analytics summary (peak crowd, history, alerts). | Returns JSON Report |
| `GET` | `/api/reports/events/<id>/pdf` | Authenticated | Generates and downloads institutional PDF audit report. | `application/pdf` binary |

### 7.8 Public Discovery Portal (`/api/public`)
| Method | Endpoint | Access | Description | Query Parameters |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/public/events` | Public | Filtered list of approved/completed events. | `?search=&year=&month=&category=&status=&series_id=&limit=` |
| `GET` | `/api/public/events/<id>` | Public | Single event detailed view with venue & crowd. | Path parameter |
| `GET` | `/api/public/fests` | Public | Public list of campus fests. | None |
| `GET` | `/api/public/fests/<id>` | Public | Single fest detail with associated events. | Path parameter |
| `GET` | `/api/public/venues` | Public | Campus venues directory with capacities. | None |
| `GET` | `/api/public/categories`| Public | Distinct event categories in system. | None |

### 7.9 Dashboards & Health Check (`/api/organizer/dashboard`, `/api/administrator/dashboard`, `/api/health`)
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/organizer/dashboard` | Organizer | Summary counters (pending, approved, upcoming, total) and recent events. |
| `GET` | `/api/administrator/dashboard` | Administrator | System-wide statistics, pending request queue, upcoming events, venue stats. |
| `GET` | `/api/health` | Public | System status, database connection readiness, and active timestamp. |

---

## 8. Frontend Architecture & User Interface Design

### 8.1 Architecture & State Flow
- **Single-Page Application (SPA)**: Rooted at `App.jsx`, utilizing React Router v7.
- **Session Continuity**: `AuthContext.jsx` queries `/api/auth/me` on bootstrap. Maintains the active user object without storing credentials in `localStorage` or `sessionStorage`.
- **Route Protection**: `ProtectedRoute.jsx` intercepts unauthorized navigation attempts and redirects users based on their active role.
- **Unified API Client**: `services/api.js` centralizes fetch queries, dynamic hostname detection (`127.0.0.1` vs `localhost`), and unified HTTP status handling.

### 8.2 Frontend Component & Page Map

```
frontend/src/
├── main.jsx                     # Vite React root mount
├── App.jsx                      # Router, role protection guards, shell layout
├── styles.css                   # Custom ~125KB modern CSS design system
├── context/
│   └── AuthContext.jsx          # User authentication state & session provider
├── services/
│   └── api.js                   # API client layer for all backend endpoints
├── components/
│   ├── Sidebar.jsx              # Auto-hiding responsive navigation drawer with alert counters
│   ├── Navbar.jsx               # Header with user profile and quick navigation
│   ├── ProtectedRoute.jsx       # Role-based route guard
│   ├── CrowdAlertsView.jsx      # Interactive safety alert inbox (read/unread, badge indicators)
│   ├── CrowdReportsView.jsx     # Analytics viewer, history charts, and PDF download triggers
│   ├── EventTable.jsx           # Reusable data table for event listings
│   ├── EventDetailsModal.jsx    # Pop-up modal for quick event inspection
│   ├── StatCard.jsx             # Metric counter cards with subtle hover animations
│   ├── StatusBadge.jsx          # Color-coded status indicators (Approved, Pending, Rejected, High Crowd)
│   └── Loading.jsx              # Loading spinner component
└── pages/
    ├── Home.jsx                 # Public discovery portal (search, filters, category tabs, event cards)
    ├── FestDetails.jsx          # Public festival showcase with timeline and grouped events
    ├── EventDetails.jsx         # Public detailed event view with venue details and live crowd status
    ├── Login.jsx                # Two-role login portal
    ├── Register.jsx             # Registration with admin passkey verification
    ├── OrganizerDashboard.jsx   # Event proposal submission, image upload, live AI inference, and alerts
    └── AdministratorDashboard.jsx# Proposal review queue, conflict-checked venue allocation, fest & venue CRUD
```

---

## 9. Security, Validation & Error Handling

1. **Password Security**: Passwords are never stored in plaintext. They are hashed using Werkzeug PBKDF2/scrypt key derivation before saving to MySQL. Minimum length of 6 characters is enforced.
2. **Privilege Escalation Defense**: Registering with `role = 'administrator'` requires a secret pre-shared authorization key (`ADMINISTRATOR_REGISTRATION_CODE`). Unauthorized attempts receive HTTP 403 Forbidden.
3. **Session Integrity**: Session cookies are configured with `HTTPONLY=True`, `SAMESITE='Lax'`, and an isolated secret key.
4. **Data Isolation & Multi-Tenancy**:
   - Organizers can only inspect, edit, or upload images to events where `event.organizer_id == session['user_id']`.
   - Administrators possess campus-wide authority across all departments.
   - Public discovery routes scrub internal administrator notes, rejection rationales, and alerts.
5. **File Upload Hardening**:
   - Only `.jpg`, `.jpeg`, and `.png` file extensions are permitted.
   - Max file size is capped at 10 MB (`MAX_CONTENT_LENGTH`).
   - Image payload is strictly validated using Pillow header verification.
   - Stored filenames are generated using timestamped UUIDs (`event_{id}_{timestamp}_{uuid}.jpg`) to prevent directory traversal or name collision attacks.
   - Atomic cleanup: if a database insert fails after an image is saved to disk, the orphaned file is automatically deleted.

---

## 10. Test Suites & Quality Assurance

The codebase includes an extensive suite of automated unit, integration, and verification test scripts in `backend/tests/`:

| Test Script | Scope & Tested Functionality |
| :--- | :--- |
| `test_stage4_venue_event.py` | Complete Stage 4 event proposal lifecycle, venue allocation, and conflict detection (HTTP 409). |
| `test_step4a_suite.py` | Comprehensive verification of venue CRUD, status toggling, and event request queues. |
| `test_administrator_fest_registry.py` | Campus fest creation, editing, event assignment, and deletion. |
| `verify_step4c.py` | Operational review table, schedule allocation, and conflict detection under load. |
| `verify_step4e.py` | End-to-end management workflow (proposals, reviews, approvals, rejections). |
| `ai/test_inference.py` | Verifies CSRNet single-image and batch inference, checking memory usage and tensor shapes. |
| `ai/evaluate.py` | Computes MAE, MSE, RMSE, and MAPE across ground-truth annotated benchmark datasets. |
| `ai/evaluate_ucf_cc_50.py` | Benchmarks CSRNet against the challenging UCF-CC-50 dataset. |
| `ai/test_dense_model.py` | Validates model performance on highly congested scenes with ShanghaiTech Part A weights. |

---

## 11. Environment Configuration & Setup Guide

### 11.1 Prerequisites
- **Python**: 3.10 to 3.14
- **Node.js**: 18.x or 20.x+
- **MySQL Server**: 8.0+ or MariaDB 10.5+

### 11.2 Environment Variables (`backend/.env`)
```env
# Server
HOST=127.0.0.1
PORT=5000
DEBUG=True
SECRET_KEY=college_crowd_event_mgmt_secret_key_2026

# MySQL Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=crowd_event_db

# Security & Secret Passkey
ADMINISTRATOR_REGISTRATION_CODE=college_mgmt_secret_2026

# CORS Origins
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://localhost:5173,http://127.0.0.1:5173

# Storage
MAX_CONTENT_LENGTH=10485760
```

### 11.3 Step-by-Step Installation & Execution

#### Step 1: Database Setup
1. Create the database in MySQL:
   ```sql
   CREATE DATABASE IF NOT EXISTS crowd_event_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. Run database migration and seeding:
   ```powershell
   python backend\config\init_db.py
   python backend\db\seed.py
   ```

#### Step 2: Backend Setup & Execution
1. Activate the Python virtual environment:
   ```powershell
   .\backend\venv\Scripts\Activate.ps1
   ```
2. Install dependencies:
   ```powershell
   pip install -r backend\requirements.txt
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121  # Optional: for CUDA GPU acceleration
   ```
3. Start the Flask server:
   ```powershell
   python backend\app.py
   ```
   *The backend will start at `http://127.0.0.1:5000`.*

#### Step 3: Frontend Setup & Execution
1. Navigate to the frontend directory:
   ```powershell
   cd frontend
   npm install
   ```
2. Start the Vite development server:
   ```powershell
   npm run dev
   ```
   *The frontend dashboard will be available at `http://localhost:3000` or `http://localhost:5173`.*

---

## 12. Summary for AI Report Generation Engine

When generating academic project reports, conference papers, or system documentation based on this document, highlight the following standout achievements:
1. **Holistic Integration**: Combines traditional web database workflows (event scheduling, multi-day festivals, venue allocation) with computer vision (dilated CNN density estimation).
2. **Ethical AI & Privacy Preservation**: Uses density maps and head counts rather than facial recognition or biometric tracking, complying with privacy standards and ethical AI guidelines.
3. **Algorithmic Rigor**: Implements mathematical collision detection to prevent double-booking, server-side temporal gating for surveillance photo uploads, and an automated alert threshold formula (`capacity - 50`).
4. **Production Polish**: Features an automated PDF reporting service with dynamic Matplotlib charts, atomic database-file transaction synchronization, role-based session guards, and an Oxlint-verified React SPA.
