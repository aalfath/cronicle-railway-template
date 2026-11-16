# Cronicle on Railway

This repo packages [Cronicle](https://github.com/jhuckaby/Cronicle), a task scheduler and runner with a web UI, as a Railway template. Railway builds the service straight from this repo.

- **Cronicle version:** 0.9.146 (official release tarball, checked against its SHA-256)
- **Base image:** `node:24.22.3-trixie-slim`, pinned by digest
- **Upstream has no official Docker image.** `cronicle/cronicle` on Docker Hub is the separate "Cronicle Edge" fork, so this repo builds the upstream release itself.

## What the template deploys

One service, `Cronicle`:

- the Cronicle web UI and scheduler on Railway's `PORT` (3012), with a public Railway domain
- a volume at `/opt/cronicle/data` with all of Cronicle's storage: events, categories, users, API keys, job history and job logs
- the health check `/api/app/ping`

Cronicle runs as a single primary server. Jobs run inside this container (shell scripts, HTTP requests, or your own plugins). `curl` and `ps` are installed for jobs.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `ADMIN_PASSWORD` | generated secret | Password for the `admin` account. It's applied only on the first boot. Change it later in the UI (My Account) |
| `CRONICLE_secret_key` | generated secret | Shared secret Cronicle uses to sign server and API traffic |
| `PORT` | `3012` | Port the web UI listens on |

The upstream default login `admin` / `admin` is never active here: the start script replaces its password before the server starts.

Any Cronicle setting from [`config.json`](https://github.com/jhuckaby/Cronicle/blob/master/docs/Configuration.md) can be set with a `CRONICLE_<key>` variable, using `__` for nested keys. Examples:

- `CRONICLE_smtp_hostname`, `CRONICLE_smtp_port`, `CRONICLE_email_from` for e-mail notifications
- `CRONICLE_job_memory_max` for the default job memory limit (bytes)
- `CRONICLE_base_app_url` if you use a custom domain (by default it's `https://` plus the Railway domain)

## First login

Open the service's public URL, log in as `admin` with the `ADMIN_PASSWORD` value from the service's Variables tab, and give it up to a minute after a deploy to take the primary role.

## How updates reach you

Railway shows an "update available" notice for this template when a change is merged to this repo's `main` branch. Read [`CHANGELOG.md`](CHANGELOG.md) first, then apply the update from your project. Your data stays on the volume.

## Files

- `Dockerfile`: downloads and builds the pinned Cronicle release
- `start.sh`: sets Railway-specific settings, initialises storage on the first boot and starts Cronicle in the foreground
