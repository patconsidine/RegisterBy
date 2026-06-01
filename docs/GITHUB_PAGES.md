# Host privacy & support pages (GitHub Pages)

Use these URLs in **App Store Connect** once Pages is enabled.

| Page | URL |
|------|-----|
| **Privacy Policy** | `https://patconsidine.github.io/RegisterBy/` |
| **Support** | `https://patconsidine.github.io/RegisterBy/support.html` |

## Enable GitHub Pages (one time)

1. Open https://github.com/patconsidine/RegisterBy  
2. **Settings** → **Pages** (left sidebar).  
3. **Build and deployment** → **Source:** Deploy from a branch.  
4. **Branch:** `master` → folder **`/docs`** → **Save**.  
5. Wait 1–3 minutes. GitHub shows the live URL (should match the table above).

## Update the site

Edit `docs/index.html` (privacy) or `docs/support.html` (support), commit, and push to `master`. Pages rebuilds automatically.

## Make the repo public (for free Pages)

GitHub Pages on a **private** repo needs a paid plan. For RegisterBy, making the repo **public** is the usual free option — only the website and source code are visible (not your users’ app data).

### On github.com

1. Open https://github.com/patconsidine/RegisterBy  
2. **Settings** (repo settings, not your profile).  
3. Scroll to the **Danger Zone** (bottom).  
4. **Change repository visibility** → **Change visibility** → **Make public**.  
5. Read the confirmation → type the repo name → confirm.

### In GitHub Desktop (alternative)

1. **Repository** → **Repository settings…**  
2. If there is a visibility option, follow prompts — otherwise use the website steps above (Desktop often sends you to the browser).

### After it’s public

1. **Settings** → **Pages** → Source: branch **`main`**, folder **`/docs`** → **Save**.  
2. Wait 1–3 minutes.  
3. Open https://patconsidine.github.io/RegisterBy/ and https://patconsidine.github.io/RegisterBy/support.html  

Your app’s user data never lives in GitHub — only this project’s Swift code and the two HTML pages.

## Private repository note

If you prefer to stay **private**, you need GitHub Pro (or similar) for Pages, or host `index.html` / `support.html` elsewhere (Notion, Cloudflare Pages, etc.).

## Keep in sync

- Markdown source for privacy: `docs/PRIVACY.md` (update both `.md` and `index.html` when policy changes).  
- In-app links use `AppSettings.privacyPolicyURL` and `AppSettings.supportPageURL`.
