# Changelog

## README button (2026-11-16)

- Added the Deploy on Railway button for the published template (`cronicle`). No change to the app or the image.

## 0.9.146 (2026-11-16)

- First release of the template: Cronicle 0.9.146 on Node.js 24.22.3 (`node:24.22.3-trixie-slim`, pinned by digest).
- Storage on a volume at `/opt/cronicle/data`.
- The `admin` password comes from `ADMIN_PASSWORD` on the first boot (no `admin`/`admin` default).
- Fixed server hostname `cronicle`, so the server stays primary after a redeploy.
