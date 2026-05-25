# App Store Connect setup — RegisterBy

Step-by-step for an **Australia-based** solo founder. Complete in order.

---

## Part A — Apple Developer & app record

### 1. Apple Developer Program

- Enrol at [developer.apple.com/programs](https://developer.apple.com/programs/) if not already ($99 USD/year).
- Use **Xcode 26.3** as active Xcode:
  ```bash
  sudo xcode-select -s /Users/patrick_considine/Downloads/Xcode.app/Contents/Developer
  ```

### 2. Create the app in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**.
2. **Platforms:** iOS  
3. **Name:** RegisterBy  
4. **Primary language:** English (Australia)  
5. **Bundle ID:** select `com.registerby.app` (create in step 3 below if missing).  
6. **SKU:** e.g. `registerby-ios-001` (internal only, any unique string).  
7. **User access:** Full access.

### 3. Register Bundle ID (if needed)

1. [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers/list) → **+**.  
2. **App IDs** → **App** → Continue.  
3. **Description:** RegisterBy  
4. **Bundle ID:** Explicit → `com.registerby.app`  
5. Capabilities: none required for v1 (no push certificate — local notifications only).  
6. Register.

### 4. Xcode signing

1. Open `RegisterBy.xcodeproj`.  
2. Target **RegisterBy** → **Signing & Capabilities**.  
3. **Team:** your Apple Developer team.  
4. **Bundle Identifier:** `com.registerby.app`  
5. Ensure **Automatically manage signing** is on.

---

## Part B — In-App Purchase (RegisterBy Pro)

Product in code: **`registerby_pro_lifetime`** (non-consumable, one-time).

### 5. Create the IAP in App Store Connect

1. App Store Connect → **RegisterBy** → **Monetisation** → **In-App Purchases** (or **Features** → **In-App Purchases**).  
2. **+** → **Non-Consumable** → Create.  
3. Fill in:

| Field | Value |
|-------|--------|
| **Reference name** | RegisterBy Pro Lifetime |
| **Product ID** | `registerby_pro_lifetime` (must match code exactly) |
| **Display name** | RegisterBy Pro |
| **Description** | Unlimited products. One-time purchase. No subscription. |

4. **Pricing** → choose tier (e.g. **$9.99 AUD** / equivalent Tier 7 USD ~$6.99).  
5. **Review screenshot:** upload a screenshot of the paywall from simulator (required for review).  
6. Save → status should move toward **Ready to Submit** once metadata is complete.

### 6. Paid Applications Agreement (required for IAP)

1. App Store Connect → **Agreements, Tax, and Banking**.  
2. **Paid Applications** → **View and Agree to Terms** (if not done).  
3. Complete **Banking** and **Tax** for Australia (ABN if applicable — consult your accountant).

Without this, IAP will not work in production.

### 7. Sandbox testing (before real money)

1. App Store Connect → **Users and Access** → **Sandbox** → **Testers** → **+**.  
2. Create a sandbox Apple ID (fake email is fine, e.g. `registerby-test@yourdomain.com`).  
3. On your **iPhone** (not in Settings → Apple ID — use device Settings carefully):
   - **Settings → App Store → Sandbox Account** → sign in with sandbox tester.  
4. In Xcode: **Edit Scheme → Run → Options → StoreKit Configuration**  
   - For local: `RegisterBy/Configuration/Products.storekit`  
   - For sandbox: set to **None** when testing real App Store sandbox.  
5. Run on device → add 6th item → purchase Pro → confirm sandbox dialog shows **[Environment: Sandbox]**.

### 8. Restore purchases

Settings → Paywall → **Restore purchases** calls `AppStore.sync()` — test after a sandbox buy, then delete/reinstall app and restore.

---

## Part C — Listing metadata (AU primary + US/UK)

### 9. Localisations

Add three App Store localisations:

| Locale | Subtitle (30 chars) |
|--------|---------------------|
| **English (Australia)** — primary | `Warranty & receipt reminders` |
| **English (U.S.)** | Same or `Warranty deadline tracker` |
| **English (U.K.)** | Same as AU |

Copy description from plan / README. Keywords example (100 chars, no spaces after commas):

```
warranty,tracker,receipt,register,reminder,appliance,baby,return,expiry,claim,proof,purchase,deadline
```

### 10. Required URLs

| Field | What to use |
|-------|-------------|
| **Privacy Policy** | Host `docs/PRIVACY.md` on GitHub Pages/Notion — public URL |
| **Support URL** | Simple page with **registerby.app.support@gmail.com** (Notion/GitHub Pages) |

Support email is set in app code: `AppSettings.supportEmail`.

### 11. Availability

Enable: **Australia, New Zealand, United States, United Kingdom, Canada**.

### 12. App icon & screenshots

- Icon: already in `Assets.xcassets/AppIcon` (1024×1024).  
- Screenshots: 6.7" iPhone (iPhone 17 Pro Max sim) — onboarding, home, add product, detail, paywall.

---

## Part D — Submit

### 13. Archive & upload

1. Select **Any iOS Device (arm64)** as destination.  
2. **Product → Archive**.  
3. **Distribute App → App Store Connect → Upload**.  
4. Wait for processing in Connect (15–60 min).

### 14. Submit for review

1. Create version **1.0.0**.  
2. Attach build.  
3. Select **In-App Purchase** `registerby_pro_lifetime` for this version.  
4. Answer export compliance (typically **No** for encryption if only HTTPS).  
5. **Submit for Review**.

Review often asks for a **demo account** — not needed for RegisterBy (no login). Mention in notes: *"No account required; local-only data."*

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Product price shows `$6.99` placeholder | IAP not loaded — check Product ID match; use sandbox; wait for Connect propagation (up to 24h). |
| "Cannot connect to iTunes Store" | Sign in sandbox account on device; check agreements/banking. |
| Purchase succeeds but not Pro | Product ID mismatch; check `AppSettings.proProductID`. |
| Review prompt never shows | Normal in Simulator; Apple limits frequency; test on device after 3× Mark registered. |

---

## Code reference

| Item | Location |
|------|----------|
| Product ID | `AppSettings.proProductID` → `registerby_pro_lifetime` |
| StoreKit config (local) | `RegisterBy/Configuration/Products.storekit` |
| Purchase logic | `RegisterBy/Services/PurchaseManager.swift` |
| Review after register | `RegisterBy/Services/AppReview.swift` (3rd Mark registered) |

---

## RevenueCat — not required for v1

Stick with built-in **StoreKit 2** until you add subscriptions or a second app. See README if you add RevenueCat later.
