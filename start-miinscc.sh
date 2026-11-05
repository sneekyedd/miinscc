#!/bin/sh
# Starts MiiNSCC (Mac / Linux): quietly gets the latest version first, then opens it in your browser.
cd "$(dirname "$0")"
if command -v git >/dev/null 2>&1; then
  # MiiNSCC moved to its own repository (github.com/sneekyedd/miinscc): switch this copy over
  # once, by itself. It's the same history, so nothing is lost.
  if git remote get-url origin 2>/dev/null | grep -qi "sneekyedd/mii-hub"; then
    git remote set-url origin https://github.com/sneekyedd/miinscc.git
    git fetch --quiet origin main >/dev/null 2>&1 && git checkout --quiet -B main origin/main >/dev/null 2>&1
  fi
  git pull --ff-only --quiet >/dev/null 2>&1
fi
if command -v open >/dev/null 2>&1; then open index.html; else xdg-open index.html >/dev/null 2>&1; fi
