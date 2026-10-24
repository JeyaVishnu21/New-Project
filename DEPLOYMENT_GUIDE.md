# Complete Deployment Guide (MongoDB & Production Setup)
## Campus Crowd Event Management & AI Crowd Monitoring System

This project is now **100% configured for MongoDB**, completely eliminating the need for MySQL. You can deploy it quickly to the cloud using MongoDB Atlas and cloud hosting platforms like **Render**, **Railway**, or with **Docker**.

---

## 1. Project Directory Structure

The files in the repository have been organized cleanly for production:

```
code/
├── backend/                  # Flask REST API, PyTorch AI Inference, and Mongo Adapter
│   ├── ai/                   # CSRNet Neural Network Model and Predictor Pipeline
│   ├── config/               # Settings, MongoDB Adapter, and Database Routing
│   ├── db/                   # MongoDB Migration Scripts & JSON Snapshots
│   ├── middleware/           # Authentication and Role Guards
│   ├── models/               # Data access logic (Users, Events, Venues, Alerts, Reports)
│   ├── routes/               # API Blueprints (Auth, Events, Images, Dashboards, Public)
│   ├── uploads/              # Storage directory for uploaded event crowd photos
│   ├── Dockerfile            # Production Docker image for Backend
│   ├── Procfile              # Process manager configuration for Cloud hosting
│   ├── requirements.txt      # Python dependencies (pymongo, torch, gunicorn, etc.)
│   └── app.py                # Flask application factory
│
├── frontend/                 # React 19 + Vite Single-Page Application
│   ├── src/                  # React components, pages, context, and styles
│   ├── Dockerfile            # Production multi-stage Nginx container for Frontend
│   ├── nginx.conf            # Reverse proxy configuration for API and static files
│   └── package.json          # Node dependencies
│
├── database_backups/         # SQL backups and historical database snapshots
├── docs/                     # ER diagrams, specifications, and architecture docs
├── scripts/                  # Diagnostics and verification helper scripts
│
├── docker-compose.yml        # 1-Command Full Stack Orchestration (Mongo + Backend + Frontend)
├── render.yaml               # 1-Click Infrastructure Blueprint for Render.com
├── Procfile                  # Cloud deployment process file
└── DEPLOYMENT_GUIDE.md        # This deployment documentation
```

---

## 2. MongoDB Setup (Local & Cloud Atlas)

All existing MySQL tables were migrated directly into MongoDB collections with preserved IDs:
- `users`: 16 documents
- `venues`: 6 documents
- `fest`: 5 documents
- `events`: 24 documents
- `images`: 9 documents
- `crowd_analyses`: 9 documents
- `alerts`: 55 documents
- `counters`: Atomic auto-increment ID tracker

### Option A: Local MongoDB (For Development)
1. Ensure MongoDB service is running locally (`mongodb://localhost:27017/`).
2. Your `backend/.env` is already configured with:
   ```ini
   DB_ENGINE=mongodb
   MONGO_URI=mongodb://localhost:27017/
   MONGO_DB_NAME=crowd_event_db
   ```
3. To re-import or refresh the data snapshot at any time:
   ```bash
   cd backend
   python db/migrate_to_mongo.py
   ```

### Option B: MongoDB Atlas (Free Cloud Database for Deployment)
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) and create a **Free (M0) Cluster**.
2. Click **Database Access** -> Add a Database User (e.g. username `crowd_admin`, password `your_password`).
3. Click **Network Access** -> Add IP Address -> Select **Allow Access From Anywhere** (`0.0.0.0/0`).
4. Click **Clusters** -> **Connect** -> **Connect your application** -> Copy the connection string:
   ```
   mongodb+srv://crowd_admin:<password>@cluster0.abcde.mongodb.net/?retryWrites=true&w=majority
   ```
5. Run the migration script once from your terminal to populate your cloud Atlas cluster:
   ```bash
   cd backend
   python -c "from db.migrate_to_mongo import run_migration; run_migration('YOUR_ATLAS_CONNECTION_STRING', 'crowd_event_db')"
   ```
6. Set `MONGO_URI` in your production environment variables to this Atlas connection string.

---

## 3. How to Deploy

### Method 1: 1-Command Deployment with Docker Compose (Recommended)

You can launch the entire stack (MongoDB, Backend, and Frontend) locally or on any VPS (AWS EC2, DigitalOcean, Linode) with one single command:

```bash
docker compose up --build -d
```

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000/api/health
- **MongoDB**: localhost:27017

To stop the containers:
```bash
docker compose down
```

---

### Method 2: Deploy to Render.com (Free & Easy)

Render supports both the Flask backend and the React frontend:

#### Step 1: Deploy Backend (Web Service)
1. Push your repository to GitHub.
2. Sign in to [Render.com](https://render.com) and click **New +** -> **Web Service**.
3. Connect your repository.
4. Fill in the settings:
   - **Root Directory**: `backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn --bind 0.0.0.0:$PORT "app:create_app()"`
5. Under **Environment Variables**, add:
   - `DB_ENGINE`: `mongodb`
   - `MONGO_URI`: `your_mongodb_atlas_connection_string`
   - `MONGO_DB_NAME`: `crowd_event_db`
   - `SECRET_KEY`: `any_random_secure_string_here`
   - `DEBUG`: `False`
6. Click **Create Web Service**. Once deployed, copy your backend URL (e.g., `https://crowd-backend.onrender.com`).

#### Step 2: Deploy Frontend (Static Site)
1. In Render, click **New +** -> **Static Site**.
2. Connect the same repository.
3. Configure settings:
   - **Root Directory**: `frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
4. Under **Environment Variables**, add:
   - `VITE_API_URL`: `https://crowd-backend.onrender.com/api`
5. Click **Create Static Site**.
6. Once deployed, copy your frontend URL (e.g. `https://crowd-frontend.onrender.com`), go back to your **Backend Service** -> **Environment Variables**, and set:
   - `CORS_ORIGINS`: `https://crowd-frontend.onrender.com`

---

### Method 3: Deploy to Railway.app

1. Go to [Railway.app](https://railway.app) and create a **New Project**.
2. Select **Provision MongoDB** to get an instant cloud MongoDB database.
3. Add a new service from your GitHub repo for `backend`:
   - Set environment variables:
     - `DB_ENGINE=mongodb`
     - `MONGO_URI=${{MongoDB.MONGO_URL}}`
     - `MONGO_DB_NAME=crowd_event_db`
   - Start command: `gunicorn --bind 0.0.0.0:$PORT "app:create_app()"`
4. Add a new service from your GitHub repo for `frontend`:
   - Set `VITE_API_URL=https://<your-backend-railway-url>/api`
   - Build command: `npm run build`
   - Start command: `npx serve -s dist -l $PORT`

---

## 4. Local Execution Commands

### Run Backend Locally (with MongoDB):
```bash
cd backend
# Activate your venv if not active
.\venv\Scripts\activate   # Windows
# Start server
python app.py
```
Backend runs at `http://127.0.0.1:5000`.

### Run Frontend Locally:
```bash
cd frontend
npm install
npm run dev
```
Frontend runs at `http://localhost:3000`.
