# Complete Deployment Guide (MongoDB & Production Setup)
## Campus Crowd Event Management & AI Crowd Monitoring System

This project is now **100% configured for MongoDB**, completely eliminating the need for MySQL. You can deploy it quickly to the cloud using MongoDB Atlas and cloud hosting platforms like **Render**, **Vercel**, or **Railway**.

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
│   ├── Procfile              # Process manager configuration for Cloud hosting
│   ├── requirements.txt      # Python dependencies (pymongo, torch, gunicorn, etc.)
│   └── app.py                # Flask application factory
│
├── frontend/                 # React 19 + Vite Single-Page Application
│   ├── src/                  # React components, pages, context, and styles
│   ├── vercel.json           # Vercel SPA routing rewrite configuration
│   ├── .env.example          # Template environment variable for VITE_API_URL
│   └── package.json          # Node dependencies
│
├── database_backups/         # SQL backups and historical database snapshots
├── docs/                     # ER diagrams, specifications, and architecture docs
├── scripts/                  # Diagnostics and verification helper scripts
│
├── render.yaml               # Infrastructure blueprint for Render.com
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

## 3. How to Deploy Cloud Services


---

### Method 2: Deploy Frontend on Vercel + Backend on Render (Recommended Cloud Setup)

This decouples the static frontend onto Vercel's global CDN and hosts the Flask + PyTorch AI backend on Render's Python runtime.

#### Step 1: Deploy Backend to Render (Web Service)
1. Push your repository to GitHub.
2. Sign in to [Render.com](https://render.com) and click **New +** -> **Web Service**.
3. Connect your GitHub repository.
4. Configure service settings:
   - **Name**: `crowd-event-backend` (or your choice)
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn --bind 0.0.0.0:$PORT "app:create_app()"`
   - **Instance Type**: `Free`
5. Under **Environment Variables**, click **Add Environment Variable**:
   - `PYTHON_VERSION`: `3.11.0`
   - `DB_ENGINE`: `mongodb`
   - `MONGO_URI`: `your_mongodb_atlas_connection_string`
   - `MONGO_DB_NAME`: `crowd_event_db`
   - `SECRET_KEY`: `<generate_random_key_or_render_generate>`
   - `DEBUG`: `False`
   - `SESSION_COOKIE_SAMESITE`: `None`
   - `SESSION_COOKIE_SECURE`: `True`
6. Click **Create Web Service**. Wait for the build to finish.
7. Once deployed, copy your backend URL (e.g. `https://crowd-event-backend.onrender.com`).
   - Test it by opening `https://crowd-event-backend.onrender.com/api/health` in your browser. It should respond `{"status": "healthy"}`.

#### Step 2: Deploy Frontend to Vercel
1. Sign in to [Vercel](https://vercel.com) and click **Add New...** -> **Project**.
2. Import your GitHub repository.
3. In the project configuration:
   - **Framework Preset**: `Vite`
   - **Root Directory**: Click *Edit* and select `frontend` (crucial!)
   - **Build Command**: `npm run build` (default)
   - **Output Directory**: `dist` (default)
4. Expand **Environment Variables** and add:
   - **Key**: `VITE_API_URL`
   - **Value**: `https://crowd-event-backend.onrender.com/api` *(replace with your actual Render backend URL followed by `/api`)*
5. Click **Deploy**.
6. When deployment finishes, copy your live Vercel frontend URL (e.g. `https://crowd-analysis-client.vercel.app`).

#### Step 3: Link Backend CORS to your Vercel URL
1. Go back to your [Render Dashboard](https://dashboard.render.com).
2. Select your backend web service (`crowd-event-backend`) -> **Environment**.
3. Add or update the `CORS_ORIGINS` variable:
   - **Key**: `CORS_ORIGINS`
   - **Value**: `https://your-app-name.vercel.app` *(exact URL of your Vercel frontend without trailing slash)*
4. Click **Save Changes**. Render will automatically redeploy with the updated CORS policy.


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
