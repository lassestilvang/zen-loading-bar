#!/usr/bin/env bash
# ==============================================================================
# Zen Browser Mod Installer for macOS & Linux
# Symlinks mods from this directory to your Zen Browser profile(s)
# and enables custom stylesheet support in user.js.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "🔍 Detecting Zen Browser profiles on $OS..."

CANDIDATE_ROOTS=()

# 1. Custom path supplied as CLI argument
if [ $# -ge 1 ] && [ -d "$1" ]; then
  CANDIDATE_ROOTS+=("$1")
else
  # 2. OS-specific default paths
  if [ "$OS" = "Darwin" ]; then
    CANDIDATE_ROOTS+=(
      "${HOME}/Library/Application Support/zen/Profiles"
    )
  elif [ "$OS" = "Linux" ]; then
    CANDIDATE_ROOTS+=(
      # Standard / Native / Tarball / AUR
      "${HOME}/.zen/Profiles"
      "${HOME}/.zen"
      "${HOME}/.config/zen/Profiles"
      "${HOME}/.config/zen"
      # Flatpak (Flathub)
      "${HOME}/.var/app/app.zen_browser.zen/.zen/Profiles"
      "${HOME}/.var/app/app.zen_browser.zen/.zen"
      # Snap
      "${HOME}/snap/zen-browser-snap/common/.zen/Profiles"
      "${HOME}/snap/zen-browser-snap/common/.zen"
    )
  fi
fi

shopt -s nullglob nocasematch
PROFILES=()
SEEN_PATHS=()

is_profile_dir() {
  local dir="$1"
  [ -f "$dir/prefs.js" ] || [ -f "$dir/compatibility.ini" ] || [ -f "$dir/zen-themes.json" ] || [ -d "$dir/chrome" ]
}

add_profile() {
  local p="$1"
  local real_p
  real_p="$(cd "$p" 2>/dev/null && pwd || echo "$p")"
  if [ ${#SEEN_PATHS[@]} -gt 0 ]; then
    for seen in "${SEEN_PATHS[@]}"; do
      if [ "$seen" = "$real_p" ]; then
        return 0
      fi
    done
  fi
  SEEN_PATHS+=("$real_p")
  PROFILES+=("$p")
}

if [ ${#CANDIDATE_ROOTS[@]} -gt 0 ]; then
  for root in "${CANDIDATE_ROOTS[@]}"; do
    [ -d "$root" ] || continue

    # Case A: The root itself is a profile directory
    if is_profile_dir "$root"; then
      add_profile "$root"
      continue
    fi

    # Case B: The root contains profile subdirectories
    for p in "$root"/*; do
      [ -d "$p" ] || continue
      bname="$(basename "$p")"

      # Match typical profile names or profiles containing markers
      if [[ "$bname" =~ (twilight|release|default|alpha) ]] || is_profile_dir "$p"; then
        # Ignore cache or non-profile system folders
        if [[ "$bname" != *"cache"* ]] && [[ "$bname" != "Crash Reports" ]] && [[ "$bname" != "Pending Pings" ]]; then
          add_profile "$p"
        fi
      fi
    done
  done
fi

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "❌ No Zen profiles could be found automatically."
  echo ""
  echo "💡 Tip: You can find your profile folder inside Zen Browser by visiting: about:profiles"
  echo "Then run this script passing the profile path directly:"
  echo "   ./install.sh /path/to/your/profile"
  exit 1
fi

echo "Found profile(s):"
for p in "${PROFILES[@]}"; do
  echo " • $(basename "$p") ($p)"
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
if [ "$OS" = "Darwin" ]; then
  echo "🔄 Please completely restart Zen Browser (Cmd+Q, then reopen) to apply changes."
else
  echo "🔄 Please completely restart Zen Browser (Ctrl+Q, then reopen) to apply changes."
fi
