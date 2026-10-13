#!/usr/bin/env bash
# ==============================================================================
# Zen Browser Mod Installer for macOS
# Symlinks mods from this directory to your Zen Browser profile(s)
# and enables custom stylesheet support in user.js.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZEN_PROFILES_DIR="${HOME}/Library/Application Support/zen/Profiles"

if [ ! -d "$ZEN_PROFILES_DIR" ]; then
  echo "❌ Zen profiles directory not found at: $ZEN_PROFILES_DIR"
  exit 1
fi

echo "🔍 Searching for Zen profiles in $ZEN_PROFILES_DIR..."

shopt -s nullglob nocasematch
PROFILES=()
for p in "$ZEN_PROFILES_DIR"/*; do
  if [ -d "$p" ]; then
    bname="$(basename "$p")"
    if [[ "$bname" =~ (twilight|release|default) ]]; then
      PROFILES+=("$p")
    fi
  fi
done

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "⚠️  No matching Zen profiles found. Falling back to all directories in Profiles:"
  for p in "$ZEN_PROFILES_DIR"/*; do
    if [ -d "$p" ]; then
      PROFILES+=("$p")
    fi
  done
fi

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "❌ No profile directories found in $ZEN_PROFILES_DIR"
  exit 1
fi

echo "Found profile(s):"
for p in "${PROFILES[@]}"; do
  echo " • $(basename "$p")"
done

for profile in "${PROFILES[@]}"; do
  bname="$(basename "$profile")"
  echo ""
  echo "📦 Installing mods into: $bname"

  # 1. Ensure custom stylesheets are enabled via user.js
  USER_JS="$profile/user.js"
  PREF_LINE='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

  if [ -f "$USER_JS" ]; then
    if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$USER_JS"; then
      echo "$PREF_LINE" >> "$USER_JS"
      echo "  ✅ Enabled custom stylesheets in existing user.js"
    else
      echo "  ℹ️  Custom stylesheets already enabled in user.js"
    fi
  else
    echo "$PREF_LINE" > "$USER_JS"
    echo "  ✅ Created user.js with custom stylesheets enabled"
  fi

  # 2. Ensure chrome directory exists
  CHROME_DIR="$profile/chrome"
  mkdir -p "$CHROME_DIR"

  # 3. Symlink CSS files from repo to profile/chrome
  for file in "$SCRIPT_DIR"/*.css; do
    if [ -f "$file" ]; then
      fname="$(basename "$file")"
      target="$CHROME_DIR/$fname"
      if [ -L "$target" ] || [ -f "$target" ]; then
        rm -f "$target"
      fi
      ln -sf "$file" "$target"
      echo "  🔗 Linked $fname -> $target"
    fi
  done
done

echo ""
echo "✨ Installation complete!"
echo "🔄 Please completely restart Zen Browser (Cmd+Q, then reopen) to apply changes."
