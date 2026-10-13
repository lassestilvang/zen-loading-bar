# Zen Browser Mods

Personal modifications and stylesheets for [Zen Browser](https://zen-browser.app/) on macOS.

---

## 🚀 Installed Mods

### 1. Zen Loading Bar
Based on [shariarratul/ZenLoadingBar](https://github.com/shariarratul/ZenLoadingBar).
- **Top Screen Progress Bar**: Shows a sleek gradient progress bar along the top edge of the browser while the active page is loading.
- **Tab Background Fill**: Subtly fills the background of the loading tab in the sidebar as content loads.
- **Muted Tab Indicator**: Displays an orange/red indicator across the top when the selected tab is muted.

Files:
- [`ZenLoadingBar.css`](ZenLoadingBar.css): Contains the core styles, CSS variables, and layout rules.
- [`userChrome.css`](userChrome.css): Root entrypoint loaded by Zen Browser (imports `ZenLoadingBar.css`).

---

## 🛠️ How to Tweak `ZenLoadingBar.css`

Because the files in this directory are directly symlinked to your Zen profile, **any edits you make to `ZenLoadingBar.css` or `userChrome.css` here take effect immediately upon restarting Zen (Cmd+Q and reopen)**!

### 1. Adjusting Colors
Open [`ZenLoadingBar.css`](ZenLoadingBar.css) and look at the `:root` variables at the top:
```css
:root {
  /* Progress bar gradient colors */
  --progress-from:  #4c1d95;  /* Deep Purple */
  --progress-via-1: #7c3aed;  /* Bright Violet */
  --progress-via-2: #a855f7;  /* Purple Accent */
  --progress-to:    #ec4899;  /* Pink */

  /* Muted tab indicator gradient */
  --muted-from: #dc2626;      /* Red */
  --muted-to:   #f97316;      /* Orange */

  /* Tab background fill (inside tab bar) */
  --tab-fill-from: rgba(255, 255, 255, 0.15);
  --tab-fill-to:   rgba(255, 255, 255, 0.05);
}
```
You can change these to match your Zen theme (e.g., cyan/blue, sunset, green, monochrome, or Zen's native accent colors using `var(--zen-primary-color)`).

### 2. Height & Thickness
By default, the bar is `4px` high. Look for:
```css
.browserSidebarContainer.deck-selected::before {
  height: 4px !important;  /* Change to 2px, 3px, 6px, etc. */
}
```

### 3. Glow / Shadow
To make the glow more vibrant, subtle, or remove it entirely:
```css
filter: drop-shadow(0px 0px 10px rgba(139, 92, 246, 0.8)) !important;
/* To remove glow: filter: none !important; */
```

### 4. Animation Timing
Adjust the speed and curve of the progress updates:
```css
transition: width 0.5s ease-in-out, top 0.1s ease-in-out, background 0.2s ease !important;
```

### 5. Disable Tab Fill or Muted Tab Indicator
- To disable the fill inside the tabs: comment out the `/* Tab background progress fill */` block.
- To disable the 100% red bar when a tab is muted: remove or comment out the `&:has(.tabbrowser-tab[selected][muted]:not([busy]))` selector block.

---

## 💻 Syncing to Your Other MacBook

Firefox / Zen Sync syncs bookmarks, history, and extensions, but does **not** automatically sync raw local `userChrome.css` profile files. 

With this repository, syncing to your other MacBook is seamless:

1. **Push to a Git Remote** (e.g. GitHub private repo):
   ```bash
   git add .
   git commit -m "Add Zen Loading Bar mod"
   git remote add origin git@github.com:<your-user>/zen-mods.git
   git push -u origin main
   ```
2. **On your other MacBook**:
   ```bash
   git clone git@github.com:<your-user>/zen-mods.git ~/Sites/zen-mods
   cd ~/Sites/zen-mods
   ./install.sh
   ```
3. Restart Zen Browser (`Cmd+Q` and reopen).
