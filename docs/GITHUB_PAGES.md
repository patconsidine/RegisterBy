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

## Private repository note

Free GitHub Pages for **private** repos requires a paid GitHub plan. If Pages is unavailable, either make the repo **public** (only the docs are exposed as a website, not your whole machine) or host the same HTML files on Notion / another host.

## Keep in sync

- Markdown source for privacy: `docs/PRIVACY.md` (update both `.md` and `index.html` when policy changes).  
- In-app links use `AppSettings.privacyPolicyURL` and `AppSettings.supportPageURL`.
