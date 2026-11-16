#!/bin/sh
# Start Cronicle as a single primary server in the foreground.
set -e
cd /opt/cronicle

DATA_DIR=/opt/cronicle/data
mkdir -p "$DATA_DIR" logs

# Container hostnames change on every deploy, but Cronicle stores the primary
# server by hostname. A fixed hostname keeps the same server primary after redeploys.
export HOSTNAME=cronicle

# Settings from Railway. Any CRONICLE_<key> variable (use __ for nesting)
# overrides conf/config.json, e.g. CRONICLE_smtp_hostname.
export CRONICLE_WebServer__http_port="${PORT:-3012}"
if [ -z "${CRONICLE_base_app_url:-}" ]; then
  if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
    export CRONICLE_base_app_url="https://${RAILWAY_PUBLIC_DOMAIN}"
  else
    export CRONICLE_base_app_url="http://localhost:${PORT:-3012}"
  fi
fi
export CRONICLE_queue_dir="${CRONICLE_queue_dir:-data/queue}"
export CRONICLE_debug_level="${CRONICLE_debug_level:-4}"

# The secret key signs server-to-server traffic and API sessions.
if [ -z "${CRONICLE_secret_key:-}" ]; then
  if [ ! -s "$DATA_DIR/.secret_key" ]; then
    node -e 'process.stdout.write(require("crypto").randomBytes(32).toString("hex"))' > "$DATA_DIR/.secret_key"
  fi
  CRONICLE_secret_key="$(cat "$DATA_DIR/.secret_key")"
  export CRONICLE_secret_key
fi

# First boot: create the storage, then replace the upstream admin/admin
# account's password with ADMIN_PASSWORD (or a generated one).
if ! node bin/storage-cli.js get global/users > /dev/null 2>&1; then
  echo "[cronicle-start] First boot: initialising storage in $DATA_DIR"
  node bin/storage-cli.js setup > /dev/null
  if [ -z "${ADMIN_PASSWORD:-}" ]; then
    ADMIN_PASSWORD="$(node -e 'process.stdout.write(require("crypto").randomBytes(12).toString("base64url"))')"
    echo "[cronicle-start] ADMIN_PASSWORD was empty, generated password for 'admin': $ADMIN_PASSWORD"
  fi
  node bin/storage-cli.js admin admin "$ADMIN_PASSWORD" > /dev/null
  echo "[cronicle-start] Storage ready. Log in as 'admin' with ADMIN_PASSWORD."
fi
unset ADMIN_PASSWORD

# Console (Railway logs): debug and error lines only. Storage transactions
# still go to Cronicle's own log files in /opt/cronicle/logs.
exec node lib/main.js --foreground --echo "debug error" --color 0
