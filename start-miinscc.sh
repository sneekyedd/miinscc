#!/bin/sh
# Starts MiiNSCC (Mac / Linux): quietly gets the latest version first, then opens it in your browser.
cd "$(dirname "$0")"
if [ "$1" = "stop" ]; then pkill -f "serve.py 8765" && echo "MiiNSCC server stopped."; exit 0; fi
if command -v git >/dev/null 2>&1; then
  # MiiNSCC moved to its own repository (github.com/sneekyedd/miinscc): switch this copy over
  # once, by itself. It's the same history, so nothing is lost.
  if git remote get-url origin 2>/dev/null | grep -qi "sneekyedd/mii-hub"; then
    git remote set-url origin https://github.com/sneekyedd/miinscc.git
    git fetch --quiet origin main >/dev/null 2>&1 && git checkout --quiet -B main origin/main >/dev/null 2>&1
  fi
  git pull --ff-only --quiet >/dev/null 2>&1
fi
# a tiny web server on this computer only (http://localhost:8765), unless it's already running
PORT=8765
if ! (curl -s -o /dev/null "http://localhost:$PORT/" 2>/dev/null); then
  if command -v python3 >/dev/null 2>&1; then
    nohup python3 "$(pwd)/serve.py" "$PORT" >/dev/null 2>&1 &
  elif command -v node >/dev/null 2>&1; then
    nohup npx --yes serve -l "tcp://127.0.0.1:$PORT" . >/dev/null 2>&1 &
  else
    # no way to run a server: open the file directly instead
    if command -v open >/dev/null 2>&1; then open index.html; else xdg-open index.html >/dev/null 2>&1; fi
    exit 0
  fi
  sleep 1.5
fi
if command -v open >/dev/null 2>&1; then open "http://localhost:$PORT/"; else xdg-open "http://localhost:$PORT/" >/dev/null 2>&1; fi
# (to stop the server later: ./start-miinscc.sh stop)
