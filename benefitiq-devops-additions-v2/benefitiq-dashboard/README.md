# BenefitIQ Dashboard

A production-grade loyalty analytics platform for tracking partner performance, customer segmentation, and benefit optimization strategies — built with React + FastAPI.

---

## Screenshots

### Login
![Login Page](./screenshots/login-page.png)
*Secure JWT-authenticated entry point with demo credentials for evaluators.*

### Executive Overview
![Executive Overview](./screenshots/dashboard-overview.png)
*Live KPI tiles, revenue vs target line chart, member segment breakdown, churn risk alerts, and benefit utilization — all on one canvas.*

### Partner Scoring
![Partner Scoring](./screenshots/partner-scoring.png)
*Sortable partner performance index with composite scoring, tier classification, revenue tracking, and growth indicators.*

### Negotiation Simulator
![Negotiation Simulator](./screenshots/negotiation-simulator.png)
*Slider-driven deal modeling with real-time ROI projection, risk scoring, break-even calculation, and AI-backed deal intelligence.*

### Merchant Insights
![Merchant Insights](./screenshots/merchant-insights.png)
*Emerging merchant radar scanning 1,847 merchants for high-potential integration candidates with growth signals.*

### Customer Segmentation
![Customer Segmentation](./screenshots/customer-segmentation.png)
*AI-clustered loyalty profiles with spend distribution charts, churn risk classification, and segment-level AI recommendations.*

### AI Recommendation Center
![AI Recommendations](./screenshots/ai-recommendations.png)
*Confidence-scored, segment-level action recommendations with projected lift metrics and one-click campaign activation.*

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18, Vite, Tailwind CSS, Framer Motion, Chart.js, React Router v6, Axios |
| Backend | FastAPI, PostgreSQL, SQLAlchemy 2.0, Pydantic v2, JWT Auth |
| Infrastructure | Docker, Docker Compose, Nginx, Terraform (AWS ECS/Fargate, ECR, VPC) |
| CI/CD | GitHub Actions (lint → test → build → push to GHCR) |
| Monitoring | Prometheus, Grafana |
| Testing | Pytest (backend), ESLint (frontend) |

---

## Features

- **Executive Overview** — Revenue vs target chart, live KPI tiles, churn risk monitoring
- **Partner Scoring** — Composite performance index with tier classification, sortable and filterable
- **Negotiation Simulator** — Real-time ROI modeling via sliders; risk score, break-even, margin, reach
- **Merchant Radar** — Emerging merchant discovery with growth signals and partner-fit analysis
- **Customer Segmentation** — Behavioral clustering with spend analytics and churn prediction
- **AI Recommendation Center** — Confidence-scored, segment-level actions with impact projections

---

## Quick Start

### Prerequisites

- Node.js ≥ 18
- Python ≥ 3.11
- Docker + Docker Compose

### Option A — Docker (recommended)

```bash
git clone https://github.com/YOUR_USERNAME/benefitiq-dashboard.git
cd benefitiq-dashboard

cp .env.example .env
docker-compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8000 |
| API Docs | http://localhost:8000/docs |

### Option B — Local Development

**Backend**
```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # edit DATABASE_URL and SECRET_KEY
python -m app.database.seed   # seed demo data
uvicorn app.main:app --reload --port 8000
```

**Frontend**
```bash
cd frontend
npm install
cp .env.example .env.local
npm run dev                   # http://localhost:5173
```

**Demo login:** `admin@benefitiq.com` / `demo1234`

---

## Project Structure

```
benefitiq-dashboard/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── charts/       # RevenueChart, SegmentDonut, NegotiationRadar, SpendBarChart
│   │   │   ├── layout/       # AppShell, Sidebar, Topbar
│   │   │   ├── tables/       # PartnerTable
│   │   │   └── ui/           # KPICard, Spinner, Badge, ProgressBar, AIInsightBox
│   │   ├── context/          # AuthContext (JWT)
│   │   ├── hooks/            # useApi, useDebounce
│   │   ├── pages/            # OverviewPage, PartnersPage, SegmentsPage,
│   │   │                     # NegotiatePage, MerchantsPage, RecommendationsPage
│   │   ├── services/         # api.js — typed Axios client + endpoint helpers
│   │   ├── styles/           # globals.css (Tailwind + design tokens)
│   │   └── utils/            # formatters.js
│   ├── vite.config.js
│   └── tailwind.config.js
├── backend/
│   └── app/
│       ├── routes/           # auth.py, overview.py, partners.py, data.py
│       ├── services/         # negotiation.py (pure business logic, testable)
│       ├── models/           # user.py, partner.py, segment.py, merchant.py
│       ├── schemas/          # schemas.py (Pydantic v2 request/response)
│       ├── middleware/       # auth.py (JWT dependency injection)
│       ├── database/         # engine.py (SQLAlchemy), seed.py
│       └── utils/            # security.py (JWT + bcrypt)
├── screenshots/              # UI screenshots for README
├── docs/                     # Architecture docs, git strategy
├── docker-compose.yml
├── nginx/nginx.conf
└── .env.example
```

---

## API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/login` | — | Returns JWT access token |
| GET | `/api/v1/auth/me` | ✓ | Current user profile |
| GET | `/api/v1/overview` | ✓ | KPIs + revenue series |
| GET | `/api/v1/partners` | ✓ | Partner list (sort, filter by tier) |
| GET | `/api/v1/partners/{id}` | ✓ | Single partner detail |
| GET | `/api/v1/segments` | ✓ | Customer segments |
| GET | `/api/v1/merchants` | ✓ | Merchant radar data |
| POST | `/api/v1/negotiate/simulate` | ✓ | ROI simulation |
| GET | `/api/v1/recommendations` | ✓ | AI recommendations by segment |

Full interactive docs at `/docs` (Swagger UI) when running locally.

---

## Environment Variables

**Backend `.env`**
```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/benefitiq
SECRET_KEY=change-this-to-a-secure-random-string-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

**Frontend `.env.local`**
```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_APP_NAME=BenefitIQ
```

---

## Running Tests

```bash
cd backend
source venv/bin/activate
pytest tests/ -v
```

---

## Git Workflow

```bash
git init
git add .
git commit -m "feat: initial BenefitIQ dashboard — production scaffold"

git remote add origin https://github.com/YOUR_USERNAME/benefitiq-dashboard.git
git branch -M main
git push -u origin main
```

Recommended branch strategy: `main` (stable) → `develop` (integration) → `feature/page-name`

---

## CI/CD

[#cicd](#cicd)

`.github/workflows/ci-cd.yml` runs on every push/PR:

1. **Backend** — Ruff lint, Pytest
2. **Frontend** — ESLint, Vite build
3. **On push to `main` only** — authenticates to AWS via GitHub's OIDC
   provider (no static AWS keys stored as secrets), builds both Docker
   images, pushes them to ECR tagged with `latest` and the commit SHA, then
   forces a new ECS deployment so the running service picks up the new
   image

This requires the AWS infrastructure in `terraform/` to already be
provisioned — see `terraform/README.md` for the one-time setup (the deploy
role, ECR repos, and ECS cluster/service this workflow depends on) and
which repo secrets/variables to set afterward.

---

## Monitoring

[#monitoring](#monitoring)

The backend exposes Prometheus metrics at `/metrics` (via
`prometheus-fastapi-instrumentator`) — request counts, latency histograms,
in-progress requests. `docker-compose up` also starts:

| Service    | URL                   | Purpose                          |
| ---------- | --------------------- | --------------------------------- |
| Prometheus | http://localhost:9090 | Scrapes `/metrics` every 15s      |
| Grafana    | http://localhost:3001 | Dashboards (datasource auto-provisioned, default login `admin` / `admin`) |

---

## Infrastructure as Code

[#infrastructure-as-code](#infrastructure-as-code)

`terraform/` provisions the AWS resources to run this on ECS Fargate: VPC,
subnets, security groups, ECR repositories, ECS cluster, and a backend task
definition + service. See `terraform/README.md` for setup steps and — just
as importantly — what's deliberately left out (no ALB yet, no RDS, no
remote state, single AZ pair). It's a starting point, not a
production-hardened deployment, and is described that way on purpose.

---

## Deployment Checklist

- [ ] Set `SECRET_KEY` to a secure random value (`openssl rand -hex 32`)
- [ ] Point `DATABASE_URL` to production PostgreSQL
- [ ] Set `ALLOWED_ORIGINS` to your production domain
- [ ] Set `VITE_API_BASE_URL` to your production API URL
- [ ] Enable HTTPS in Nginx config
- [ ] Run `alembic upgrade head` instead of `create_all` in production

---

## License

MIT License — see [LICENSE](./LICENSE) for details.
