# Overleaf Docker Local

Local fork to build and run Overleaf Community Edition with Docker.

This fork is tailored for local development:

- Ubuntu 24.04 in the base image.
- Node installed with nvm.
- Community image build using Yarn workspaces.
- `docker-compose.yml` with Overleaf, MongoDB, Redis, and Postgres.
- Single-node MongoDB replica set to support history/project creation.
- `history-v1` and `project-history` services enabled.
- Automatic email confirmation support for local environments.
- LaTeX compile output correctly served by internal nginx.

## Clone with submodules

```sh
git clone --recurse-submodules https://github.com/tomieiro/overleaf-docker.git
```

If the repository is already cloned:

```sh
git submodule update --init --recursive
```

To update the submodule to the latest `main` commit:

```sh
git submodule update --remote --init --recursive
```

## Build

```sh
make build-base
make build-community
```

`docker compose up --build` alone is not enough on a clean machine, because it
only builds the `sharelatex/sharelatex` image defined in Compose. The base
image `sharelatex/sharelatex-base:latest`, used by the main Dockerfile `FROM`,
must exist first.

## First startup

For a new environment, or after changing `Dockerfile-base`:

```sh
git submodule update --init --recursive
make build-base
SHARELATEX_PORT=8080 docker compose up --build -d
```

This will:

- sync the `src/overleaf` submodule
- build `sharelatex/sharelatex-base`
- rebuild `sharelatex/sharelatex`
- start Overleaf, MongoDB, Redis, and Postgres

## App rebuild

If you changed only Overleaf source code in `src/overleaf` or the main
`Dockerfile`, and the base image already exists locally:

```sh
SHARELATEX_PORT=8080 docker compose up --build -d
```

## Automatic email confirmation

This fork supports automatic email confirmation for local environments.

- `AUTO_EMAIL_CONFIRMATION=1`: enable auto-confirmation.
- `AUTO_EMAIL_CONFIRMATION=0`: disable auto-confirmation.
- `AUTO_CONFIRM_EMAIL_INTERVAL_MS`: auto-confirmation interval (default `5000` ms).

In the current `docker-compose.yml`, `AUTO_EMAIL_CONFIRMATION` is enabled by
default.

## Start locally

```sh
SHARELATEX_PORT=8080 docker compose up -d
```

Open:

```text
http://localhost:8080
```

## Local login

Create or reset users with scripts/admin tools from the running Overleaf
container.

## First admin (bootstrap)

On first initialization (no admin user in the database), use:

```text
http://localhost:8080/launchpad
```

This flow creates the first admin user. After registration, the system
redirects to `/project`.

If you prefer CLI:

```sh
docker compose exec sharelatex \
  node /var/www/sharelatex/services/web/modules/server-ce-scripts/scripts/create-user.mjs \
  --admin \
  --email=your-email@domain.com
```

## Internal services

The main container runs services via runit. Main services in this fork:

- `web-sharelatex`
- `clsi-sharelatex`
- `project-history-sharelatex`
- `history-v1-sharelatex`
- `document-updater-sharelatex`
- `real-time-sharelatex`
- `filestore-sharelatex`
- `docstore-sharelatex`
- `email-autoconfirm-sharelatex`
- `nginx`

Quick check:

```sh
docker compose exec sharelatex sv status /etc/service/*
```

## LaTeX compilation

CLSI listens internally on `127.0.0.1:3013`.

Web uses this service to compile and internal nginx serves output files on
routes such as:

```text
/project/<project-id>/build/<build-id>/output/output.pdf
/project/<project-id>/user/<user-id>/build/<build-id>/output/output.pdf
```

This prevents rendering errors caused by attempting to fetch PDFs from an
incorrect internal port.
