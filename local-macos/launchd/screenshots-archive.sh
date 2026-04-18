#!/usr/bin/env bash
# Moves screenshots older than 24h from the active folder to an archive folder,
# then asks iCloud to evict the local copy (keeping only the cloud placeholder).
#
# Expectation: the active folder is marked "Keep Downloaded" in Finder, and the
# archive folder is not — so macOS keeps recent files local and the evict call
# frees disk space for archived ones.
#
# Paths can be overridden via env vars (see below).

set -uo pipefail

SRC="${SCREENSHOTS_SRC:-$HOME/Desktop/screenshots}"
DST="${SCREENSHOTS_DST:-$HOME/Desktop/screenshots-archive}"
LOG="${SCREENSHOTS_LOG:-$HOME/Library/Logs/screenshots-archive.log}"
THRESHOLD_MIN="${SCREENSHOTS_THRESHOLD_MIN:-1440}"  # 1440 min = 24h

mkdir -p "$DST" "$(dirname "$LOG")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"
}

log "--- run start (src=$SRC dst=$DST threshold=${THRESHOLD_MIN}min) ---"

moved=0
evicted=0
failed=0

while IFS= read -r -d '' file; do
  base=$(basename "$file")
  target="$DST/$base"

  if [[ -e "$target" ]]; then
    stem="${base%.*}"
    ext="${base##*.}"
    if [[ "$stem" == "$base" ]]; then
      target="$DST/${base}-$(date +%s)"
    else
      target="$DST/${stem}-$(date +%s).${ext}"
    fi
  fi

  if mv "$file" "$target"; then
    moved=$((moved + 1))
    log "moved: $base"
    if brctl evict "$target" 2>>"$LOG"; then
      evicted=$((evicted + 1))
    else
      log "evict failed: $target"
    fi
  else
    failed=$((failed + 1))
    log "move failed: $file"
  fi
done < <(find "$SRC" -type f ! -name '.*' -mmin +"$THRESHOLD_MIN" -print0)

log "--- run end (moved=$moved evicted=$evicted failed=$failed) ---"
