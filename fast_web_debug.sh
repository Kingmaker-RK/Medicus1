#!/bin/bash

# 1. KILL STALE PROCESSES
# This fixes the "Waiting for another flutter command to release the startup lock" issue.
echo "🧹 Cleaning up stale Flutter/Dart processes..."
pkill -f flutter
pkill -f dart

# 2. REMOVE LOCK FILE
# This ensures we don't wait for a lock that doesn't exist anymore.
echo "🔓 Removing Flutter lock file..."
rm -f /home/user/flutter/bin/cache/lockfile

# 3. FAST WEB SERVE
# -d web-server: Doesn't launch a new Chrome window (faster start).
# --web-port 3000: Uses a fixed port so you can bookmark 'http://localhost:3000'.
# --web-hostname 0.0.0.0: Accessible from host if needed.
# --web-renderer html: (Optional) Faster download/startup than CanvasKit, good for dev.
echo "🚀 Starting Flutter Web Server on port 3000..."
echo "👉 Open http://localhost:3000 in your browser."
echo "NOTE: The terminal will say 'Waiting for connection from debug service'. This is NORMAL."
echo "      It just means it's ready for you to open the page. Once you open it, Hot Reload works."

/home/user/flutter/bin/flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
