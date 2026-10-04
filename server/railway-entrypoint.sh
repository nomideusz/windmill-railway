#!/bin/bash
# Windmill seeds admin@windmill.dev / changeme on first boot, and whoever reaches a
# public URL first could take it. So boot once on localhost, replace that account
# with WINDMILL_ADMIN_EMAIL / WINDMILL_ADMIN_PASSWORD, and only then serve on $PORT
# (Railway routes nothing to a deploy until its healthcheck passes).
set -euo pipefail
api=http://127.0.0.1:8001/api

PORT=8001 SERVER_BIND_ADDR=127.0.0.1 windmill &
pid=$!
until curl -sf "$api/version" >/dev/null; do
  kill -0 $pid 2>/dev/null || { echo "windmill exited during setup"; exit 1; }
  sleep 1
done

login() { curl -sf "$api/auth/login" -H 'content-type: application/json' \
  -d "$(jq -n --arg e "$1" --arg p "$2" '{email:$e,password:$p}')"; }

if seed=$(login admin@windmill.dev changeme); then
  echo "first boot: creating $WINDMILL_ADMIN_EMAIL and removing the default admin"
  curl -sf "$api/users/create" -H "authorization: Bearer $seed" -H 'content-type: application/json' \
    -d "$(jq -n --arg e "$WINDMILL_ADMIN_EMAIL" --arg p "$WINDMILL_ADMIN_PASSWORD" \
          '{email:$e,password:$p,super_admin:true,name:"Admin",skip_email:true}')" \
    || echo "$WINDMILL_ADMIN_EMAIL already exists (earlier boot stopped halfway)"
  me=$(login "$WINDMILL_ADMIN_EMAIL" "$WINDMILL_ADMIN_PASSWORD")
  curl -sf -X DELETE "$api/users/delete/admin@windmill.dev" -H "authorization: Bearer $me"
  echo
  # Still able to log in with changeme means the swap failed: refuse to go public.
  ! login admin@windmill.dev changeme >/dev/null || { echo "default admin still active"; exit 1; }
fi

kill $pid; wait $pid || true
exec windmill "$@"
