# GridPulse

GridPulse is a lightweight application monitoring dashboard built for the Group 3 Kubernetes Application Deployment capstone.

## Technology

- Node.js and Express
- HTML, CSS and vanilla JavaScript
- Node.js built-in test runner

## Current application features

- Dashboard served by the Express application
- `GET /health` health endpoint
- `GET /version` version endpoint
- Runtime environment configuration through `NODE_ENV`
- Basic JSON 404 and 500 error handling
- Automated endpoint tests

## Requirements

- Node.js 20 or newer (Node.js 24 is suitable)
- npm

## Run locally

```powershell
npm install
npm start
```

Open http://localhost:3000 in your browser.

## Development mode

```powershell
npm run dev
```

Node's watch mode restarts the server when server-side files change.

## Run tests

```powershell
npm test
```

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3000` | HTTP port used by the server |
| `NODE_ENV` | `development` | Runtime environment |
| `APP_VERSION` | `1.0.0` | Version reported by the API |

Example PowerShell session:

```powershell
$env:NODE_ENV = "production"
$env:APP_VERSION = "1.0.0"
npm start
```

## API examples

- `GET /health` returns application name, status, version and environment.
- `GET /version` returns application name and version.

## Scope note

This repository currently contains the application source and local tests only. Docker, Kubernetes, GitHub Actions, GHCR and Terraform files will be added and tested in later capstone stages. The Azure infrastructure must not be provisioned without explicit project approval.
