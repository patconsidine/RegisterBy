# RegisterBy

Warranty deadline tracker for iOS — register-by, return window, and expiry reminders. Data stays on your device.

## Requirements

- **Xcode 26.3** (or Xcode 15+ with iOS 17 SDK)
- iOS **17.0+**
- Apple Developer account (for device / App Store)

## Use Xcode 26 from Downloads

If your default `xcode-select` points to an older Xcode:

```bash
sudo xcode-select -s /Users/patrick_considine/Downloads/Xcode.app/Contents/Developer
xcodebuild -version   # should show Xcode 26.3
```

## Open the project

### Option A — XcodeGen (recommended)

```bash
brew install xcodegen   # once
cd ~/Projects/RegisterBy
xcodegen generate
open RegisterBy.xcodeproj
```

### Option B — Already generated

If `RegisterBy.xcodeproj` exists:

```bash
open ~/Projects/RegisterBy/RegisterBy.xcodeproj
```

## Configure signing

1. Select the **RegisterBy** target → **Signing & Capabilities**
2. Set your **Team**
3. Change **Bundle Identifier** if needed (default `com.registerby.app`)

## In-app purchases (local testing)

1. **Editor → Run** scheme → **Options** → **StoreKit Configuration** → `RegisterBy/Configuration/Products.storekit`
2. Product ID: `registerby_pro_lifetime` (non-consumable)
3. Create the same product in **App Store Connect** before release

## Run

1. Choose an iPhone simulator or device
2. **Product → Run** (⌘R)

## Features (v1)

- Add products with register-by, return, and warranty dates
- Category smart defaults (Baby, Appliance, etc.)
- Local notifications
- Receipt & serial photos (on-device)
- Brand registration links (AU / UK / US)
- 5 items free → **RegisterBy Pro** one-time unlock

## Privacy & support (public URLs)

After enabling GitHub Pages (`docs/GITHUB_PAGES.md`):

- Privacy: https://patconsidine.github.io/RegisterBy/
- Support: https://patconsidine.github.io/RegisterBy/support.html

No account, no analytics SDK, no server. Photos and data stored locally via SwiftData and the app documents directory.

## App Store Connect checklist

Full step-by-step: **[docs/APP_STORE_CONNECT.md](docs/APP_STORE_CONNECT.md)**  
Store copy & screenshots: **[docs/APP_STORE_METADATA.md](docs/APP_STORE_METADATA.md)**

- [ ] Create app **RegisterBy** in App Store Connect
- [ ] Create non-consumable IAP **`registerby_pro_lifetime`**
- [ ] Complete Paid Applications agreement + banking/tax
- [ ] Test with **Sandbox** Apple ID on a real device
- [ ] Primary locale: **English (Australia)** + US/UK localisations
- [ ] Enable GitHub Pages → privacy + support URLs (see `docs/GITHUB_PAGES.md`)
- [ ] Archive and submit 1.0.0

## License

Private / unpublished — all rights reserved.
