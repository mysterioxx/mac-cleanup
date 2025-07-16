#0. created by Abhishek Ruhela github.com/mysterioxx

#!/bin/bash

LOG="$HOME/mac_cleanup_log.txt"
exec > "$LOG" 2>&1  # Log all output

echo "🧹 Starting Mac Cleanup..."

# 1. Clear User Caches (safe)
echo "➡ Clearing user cache..."
rm -rf "$HOME/Library/Caches/"*

# 2. Delete Installer Files (.dmg, .pkg) from Downloads
echo "➡ Removing .dmg and .pkg files from Downloads..."
find "$HOME/Downloads" -type f \( -iname "*.dmg" -o -iname "*.pkg" \) -exec rm -v {} \;

# 3. Clear pip cache
echo "➡ Removing pip cache..."
rm -rf "$HOME/Library/Caches/pip"

# 4. Clean Homebrew cache
echo "➡ Cleaning Homebrew cache..."
if command -v brew >/dev/null 2>&1; then
    brew cleanup -s || echo "⚠️ Brew cleanup failed"
    rm -rf "$HOME/Library/Caches/Homebrew"
else
    echo "🔸 Homebrew not found, skipping..."
fi

# 5. Skip purge (sudo not allowed in Automator by default)
echo "🔸 Skipping purge command — sudo not supported inside Automator."

# 6. Notify user
/usr/bin/osascript -e 'display notification "Mac cleanup completed successfully." with title "✅ Mac Cleaner"'

# 7. Wait for 10 seconds
echo "⏳ Waiting for 10 seconds so the app stays open..."
sleep 10

# 8. Ask if the user wants to restart
RESTART_CHOICE=$(/usr/bin/osascript <<EOF
set userChoice to button returned of (display dialog "Mac cleanup complete!\n\n• Cache cleared\n• Installer files removed\n• pip & Homebrew cleaned\n\nWould you like to restart your Mac now?" buttons {"Later", "Restart Now"} default button "Later" with title "✅ Cleanup Complete")
return userChoice
EOF
)

if [[ "$RESTART_CHOICE" == "Restart Now" ]]; then
    echo "🔄 User chose to restart. Restarting system..."
    osascript -e 'tell app "System Events" to restart'
else
    echo "🕒 User chose to restart later. Exiting script."
fi

exit 0