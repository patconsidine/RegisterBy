# App Store metadata & screenshots — RegisterBy

Copy-paste ready for App Store Connect (after Developer Program enrolment).  
**Primary locale:** English (Australia). Also add English (U.S.) and English (U.K.).

---

## App identity

| Field | Value |
|-------|--------|
| **App name** | RegisterBy |
| **Subtitle** (30 chars max) | `Warranty & receipt reminders` (28 chars) |
| **Bundle ID** | `com.registerby.app` |
| **SKU** | `registerby-ios-001` (any unique string) |
| **Category** | Productivity (or Finance — check competitor listings) |
| **Age rating** | 4+ (no restricted content) |
| **Copyright** | `© 2026 Patrick Considine` |

**Privacy URL:** https://patconsidine.github.io/RegisterBy/  
**Support URL:** https://patconsidine.github.io/RegisterBy/support.html  
**Marketing URL** (optional): same support page or leave blank

---

## Promotional text (170 chars max — editable anytime)

```
New purchase? Set register-by, return, and warranty dates in 30 seconds. Get reminded before bonus coverage expires—not just when the warranty ends.
```

(169 characters)

---

## Description (paste into App Store Connect)

```
RegisterBy keeps three deadlines straight for everything you buy:

• REGISTER BY — Many brands need online registration in 30–90 days for full coverage (appliances, baby gear, electronics).
• RETURN BY — Store return windows are separate from manufacturer warranties.
• WARRANTY ENDS — Know when coverage expires so you can claim before it's too late.

WHY REGISTERBY
→ Action dashboard shows what needs attention this week
→ Receipt and serial number photos stored on your iPhone only
→ Tap to open manufacturer registration pages you save per item
→ Mark items registered when done—reminders adjust automatically

BUILT FOR NEW PARENTS & HOMEOWNERS
Track baby monitors, strollers, fridges, washers, and power tools in one calm timeline—not another cluttered finance app.

PRIVACY
No account. No ads. No server uploads. Your photos stay on device.

FREE: Track up to 5 products.
PRO (one-time purchase): Unlimited products. No subscription.

RegisterBy reminds you—it does not register warranties on your behalf. Always confirm deadlines in your product manual or receipt.
```

---

## Keywords (100 chars — no spaces after commas)

```
warranty,tracker,receipt,register,reminder,appliance,baby,return,expiry,claim,proof,purchase,deadline
```

(99 characters)

---

## What’s New (version 1.0.0)

```
Welcome to RegisterBy 1.0 — track register-by dates, return windows, and warranty expiry with local reminders. Receipt and serial photos stay on your iPhone.
```

---

## Review notes (for Apple reviewer)

```
RegisterBy is a local-only warranty reminder app. No login.

To test Pro: add 6 products — paywall appears on the 6th. Use Sandbox Apple ID (StoreKit Configuration = None on device).

Sample flow: Add product → set dates → view detail timeline → Settings → Privacy/Support links work in Safari.

No server; data is SwiftData + on-device photos only.
```

---

## Screenshot plan (5–6 frames)

Use **iPhone 17 Pro Max** simulator (6.7" — required for modern listings).  
**Light mode** is usually clearest for App Store; take one dark-mode set later if you want.

| # | Screen to capture | Suggested caption (optional overlay in Preview/Keynote) |
|---|-------------------|--------------------------------------------------------|
| 1 | Onboarding screen 1 (“Don’t lose warranty money”) | Register before the deadline |
| 2 | Home → **Action needed** with 2–3 sample items | See what needs attention |
| 3 | Product **detail** — timeline + receipt thumbnail | Register · return · warranty |
| 4 | **Add product** — Photos section visible (camera row) | Snap receipt & serial |
| 5 | **Paywall** (add 6th item or Settings → Upgrade) | Pay once — no subscription |
| 6 | **Settings** (optional) | Reminders you control |

### Sample data for screenshots (add before capturing)

Create 3–4 fake items so Home/Action looks alive:

| Name | Category | Notes |
|------|----------|--------|
| Dyson V15 | Appliance | Register due soon |
| Baby monitor | Baby | Return window |
| MacBook Air | Electronics | Warranty ends later |

Use purchase dates a few weeks ago so register-by dates feel urgent (orange banner on detail).

### How to capture (Xcode)

1. Open `RegisterBy.xcodeproj` → select **iPhone 17 Pro Max** simulator.
2. Run the app (⌘R). Complete onboarding or reset: delete app in sim → run again.
3. Add sample products above.
4. Navigate to the screen → **⌘S** in Simulator saves a PNG to Desktop,  
   or **File → Save Screen** in Simulator menu.
5. Repeat for each frame.

**IAP review screenshot:** same as frame 5 (paywall). Apple requires one image when you create the non-consumable IAP.

### Upload sizes

Connect accepts the simulator export for 6.7" Display. If Connect asks for more sizes, use the same images — Xcode 26 / Connect often scales from 6.7".

---

## Localisation tweaks (optional, same English)

| Locale | Subtitle alternative |
|--------|---------------------|
| English (U.S.) | `Warranty deadline tracker` |
| English (U.K.) | `Warranty & receipt reminders` |

Description can stay identical for v1.

---

## Pricing reminder (Pro IAP)

| Storefront | Suggested tier |
|------------|----------------|
| US | $6.99 |
| AU | ~$9.99 AUD (equivalent tier) |
| UK | ~£5.99 |

Product ID: `registerby_pro_lifetime` (non-consumable).  
Display name: **RegisterBy Pro**

---

## Pre-submit checklist

- [ ] GitHub Pages live (privacy + support URLs open in Safari)
- [ ] 5–6 screenshots on Desktop
- [ ] Paywall screenshot saved for IAP metadata
- [ ] Description + keywords pasted into Connect
- [ ] Availability: AU, NZ, US, UK, CA
- [ ] Paid Applications agreement + banking/tax complete
- [ ] Sandbox tester created
- [ ] Device test: 6th item → sandbox purchase → restore
