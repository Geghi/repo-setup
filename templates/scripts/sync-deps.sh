#!/bin/sh
set -e
sync() {
  lock=$1
  shift
  [ -f "$lock" ] || return 0
  stamp=$(git rev-parse --git-path "deps-$(echo "$lock" | tr / _).sha")
  new=$(git hash-object "$lock")
  [ "$(cat "$stamp" 2>/dev/null)" = "$new" ] && return 0
  "$@"
  echo "$new" > "$stamp"
}
{{ONE_LINE_PER_LOCKFILE — e.g. `sync frontend/package-lock.json npm ci --prefix frontend` and `sync backend/uv.lock uv sync --directory backend`}}
