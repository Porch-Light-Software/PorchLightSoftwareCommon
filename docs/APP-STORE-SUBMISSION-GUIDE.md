# App Store Submission Guide — Porch Light Software

This guide walks through every step needed to go from a new Apple Developer account
to live apps on the App Store for FastTrack, MoodTrack, and SubTrack.

Follow the steps in order. Steps marked **[ONCE]** only need to be done one time for
the whole organization. Steps marked **[PER APP]** must be repeated for each of the
three apps.

---

## Prerequisites

- A Mac running macOS 13 (Ventura) or later
- Xcode 15 or later installed (free from the Mac App Store)
- Flutter SDK installed (`flutter --version` should succeed)
- Ruby 3.x and Bundler installed (`gem install bundler`)
- A GitHub account with access to the Porch-Light-Software organization
- A credit card for the $99/year Apple Developer Program fee

---

## Step 1 — Create an Apple Developer Account [ONCE]

1. Open https://developer.apple.com/programs/ in a browser.
2. Click **Enroll**.
3. Sign in with your Apple ID (or create one if you don't have one).
4. Choose entity type:
   - **Individual** — if you are a sole developer; your legal name appears on the App Store.
   - **Organization** — if you have a legal business entity (LLC, Inc., etc.); requires a
     D-U-N-S number (free, takes 1–2 business days to obtain at fedgov.dnb.com/webform).
   - For "Porch Light Software" as a published name, you likely want **Organization**.
5. Complete the enrollment form and pay the $99 annual fee.
6. Apple reviews organization enrollments within 24–48 hours.

Once approved:
- Go to https://developer.apple.com/account
- Note your **Team ID** (10-character alphanumeric string in the top-right corner under
  your name, or under Membership details). Save this — it is `APPLE_TEAM_ID`.
- Your Apple ID email is `APPLE_ID`.

Update `docs/PUBLISHER.md` and `fastlane/publisher.rb` with these values.

---

## Step 2 — Create App Store Connect Entries [PER APP]

Repeat for FastTrack, MoodTrack, and SubTrack.

1. Go to https://appstoreconnect.apple.com and sign in.
2. Click **My Apps**, then the **+** button, then **New App**.
3. Fill in:
   - **Platforms**: iOS
   - **Name**: FastTrack (or MoodTrack / SubTrack)
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select from the dropdown. If it doesn't appear, first register it at
     developer.apple.com > Identifiers > + > App IDs.
     - FastTrack: `com.porchlightsoftware.fasttrack`
     - MoodTrack: `com.porchlightsoftware.moodtrack`
     - SubTrack: `com.porchlightsoftware.subtrack`
   - **SKU**: Use the bundle ID without dots (e.g., `comporchlightsoftwarefasttrack`).
     This is an internal identifier and never shown to users.
   - **User Access**: Full Access
4. Click **Create**.

The app entry is now created. You'll fill in screenshots, descriptions, and pricing later.

### Register App Identifiers (if not auto-populated)

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click **+**, choose **App IDs**, then **App**.
3. Enter:
   - **Description**: FastTrack
   - **Bundle ID**: Explicit — `com.porchlightsoftware.fasttrack`
   - **Capabilities**: Enable **In-App Purchase** (for the Remove Ads purchase).
     Enable **Push Notifications** only if your app uses them.
4. Click **Continue**, then **Register**.
5. Repeat for MoodTrack and SubTrack.

---

## Step 3 — Generate a Distribution Certificate and Export as .p12 [ONCE]

A single distribution certificate covers all apps under your team.

### Generate the Certificate

1. Open **Keychain Access** on your Mac (Applications > Utilities > Keychain Access).
2. From the menu: **Keychain Access > Certificate Assistant > Request a Certificate From
   a Certificate Authority**.
3. Enter your email address and a Common Name (e.g., "Porch Light Software Distribution").
4. Select **Saved to disk**, click **Continue**, and save the `.certSigningRequest` file
   to your Desktop.
5. Go to https://developer.apple.com/account/resources/certificates/list
6. Click **+**, select **Apple Distribution** (for both App Store and Ad Hoc), click
   **Continue**.
7. Upload the `.certSigningRequest` file you just created.
8. Click **Generate**, then **Download**. This saves a file named
   `distribution.cer` (or similar) to your Downloads folder.
9. Double-click the downloaded `.cer` file to install it into Keychain Access.

### Export as .p12

1. In **Keychain Access**, select the **login** keychain and the **My Certificates** category.
2. Find the certificate you just installed — it will be named something like
   **Apple Distribution: Porch Light Software (XXXXXXXXXX)**.
3. Right-click it and choose **Export "Apple Distribution: ..."**.
4. Choose **Personal Information Exchange (.p12)** format.
5. Save it as `PorchLightDistribution.p12` somewhere safe (e.g., a private folder — do NOT
   commit this to git).
6. Set a strong password when prompted. Save this password — it will become the
   `CERTIFICATE_PASSWORD` GitHub secret.

### Encode as Base64

Run this command in Terminal, replacing the path with where you saved the file:

```bash
base64 -i ~/Desktop/PorchLightDistribution.p12 | pbcopy
```

This copies the Base64-encoded certificate to your clipboard. You'll paste it into GitHub
secrets in Step 5.

---

## Step 4 — Create Provisioning Profiles [PER APP]

Each app needs its own provisioning profile. Repeat for FastTrack, MoodTrack, and SubTrack.

1. Go to https://developer.apple.com/account/resources/profiles/list
2. Click **+**.
3. Under **Distribution**, select **App Store Connect**, click **Continue**.
4. Select the App ID for the app (e.g., `com.porchlightsoftware.fasttrack`), click
   **Continue**.
5. Select the distribution certificate you generated in Step 3, click **Continue**.
6. Name the profile: `FastTrack AppStore Distribution` (use a descriptive name).
7. Click **Generate**, then **Download**.

### Encode as Base64

```bash
base64 -i ~/Downloads/FastTrack_AppStore_Distribution.mobileprovision | pbcopy
```

Keep this Base64 string — it will become the per-app `PROVISIONING_PROFILE_BASE64` secret.

Repeat for MoodTrack and SubTrack, saving each Base64 string separately.

---

## Step 5 — Create an App Store Connect API Key [ONCE]

The API key allows Fastlane to upload builds without password prompts.

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click **Generate API Key** (or the **+** button).
3. Give it a name: `Porch Light Software CI`.
4. Set **Access**: **App Manager** (sufficient for uploading builds).
5. Click **Generate**.
6. **Download the .p8 key file immediately** — you can only download it once.
   Save it as `AuthKey_XXXXXXXXXX.p8` where `XXXXXXXXXX` is the Key ID shown.
7. Note:
   - **Key ID**: shown in the table (10-character string) — this is
     `APP_STORE_CONNECT_API_KEY_ID`.
   - **Issuer ID**: shown at the top of the page (UUID format) — this is
     `APP_STORE_CONNECT_API_ISSUER_ID`.

### Encode the .p8 Key as Base64

```bash
base64 -i ~/Downloads/AuthKey_XXXXXXXXXX.p8 | pbcopy
```

This becomes `APP_STORE_CONNECT_API_KEY`.

---

## Step 6 — Set Up GitHub Organization-Level Secrets [ONCE]

These secrets are shared across all three app repositories.

1. Go to https://github.com/organizations/Porch-Light-Software/settings/secrets/actions
2. For each secret below, click **New organization secret**, paste the value, and set
   **Repository access** to **All repositories** (or select the three app repos specifically).

| Secret Name | Value | Where to Find It |
|-------------|-------|-----------------|
| `APPLE_ID` | Your Apple ID email | Apple Developer account |
| `APPLE_TEAM_ID` | 10-char Team ID | developer.apple.com/account > Membership |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID (10 chars) | App Store Connect > API Keys |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID (UUID) | App Store Connect > API Keys |
| `APP_STORE_CONNECT_API_KEY` | Base64-encoded .p8 file | Step 5 above |
| `CERTIFICATE_P12_BASE64` | Base64-encoded .p12 file | Step 3 above |
| `CERTIFICATE_PASSWORD` | Password set when exporting .p12 | Step 3 above |

Note: `CERTIFICATE_P12_BASE64` and `CERTIFICATE_PASSWORD` are org-level because the
single distribution certificate covers all apps.

---

## Step 7 — Set Per-App Repository Secrets [PER APP]

Each app has a unique provisioning profile, so this secret lives in each app's repo.

### For FastTrack

1. Go to https://github.com/Porch-Light-Software/FastTrack/settings/secrets/actions
2. Click **New repository secret**.
3. Name: `PROVISIONING_PROFILE_BASE64`
4. Value: The Base64 string from Step 4 for FastTrack's provisioning profile.
5. Click **Add secret**.

Repeat for MoodTrack and SubTrack using their respective Base64-encoded profiles.

---

## Step 8 — Fill in TODO Placeholders [ONCE]

Now that you have the Apple Developer account details, update the TODO values in the
following files.

### `fastlane/publisher.rb`

Open `/c/source/PorchLightSoftwareCommon/fastlane/publisher.rb` and update:

```ruby
APPLE_ID      = ENV["APPLE_ID"]      || "you@porchlightsoftware.com"
APPLE_TEAM_ID = ENV["APPLE_TEAM_ID"] || "ABCDE12345"   # your actual Team ID
ITC_TEAM_ID   = ENV["ITC_TEAM_ID"]   || "123456789"    # your App Store Connect team ID
```

The ITC Team ID (App Store Connect team ID) is a numeric string. Find it at
https://appstoreconnect.apple.com — it appears in the URL when you visit your team page,
or you can retrieve it with:

```bash
bundle exec fastlane run latest_testflight_build_number app_identifier:"com.porchlightsoftware.fasttrack"
```

Fastlane will print the ITC Team ID if your account has access to multiple teams.

### Each App's `ios/fastlane/Appfile`

In each app repo, the `ios/fastlane/Appfile` should look like:

```ruby
require_relative "../../../../PorchLightSoftwareCommon/fastlane/publisher.rb"

app_identifier "com.porchlightsoftware.fasttrack"   # change per app
apple_id       PorchLightPublisher::APPLE_ID
team_id        PorchLightPublisher::APPLE_TEAM_ID
itc_team_id    PorchLightPublisher::ITC_TEAM_ID
```

### `docs/PUBLISHER.md`

Update the Apple Developer Account table with the real Team ID and ITC Team ID.

---

## Step 9 — Update AdMob App IDs in Info.plist [PER APP]

Google AdMob requires a real App ID in `Info.plist`. The test ID
(`ca-app-pub-3940256099942544~1458002511`) must be replaced before submission.

### Get Real AdMob App IDs

1. Go to https://admob.google.com and sign in (or create an account).
2. Click **Apps** in the left sidebar.
3. Click **Add App**.
4. Select **iOS**, choose **No** for "Does your app have a Google Play or App Store
   listing yet?" if the app isn't live yet.
5. Enter the app name (FastTrack, MoodTrack, SubTrack).
6. Click **Add App**. Google will show you an **App ID** in the format
   `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`.
7. Copy this App ID.

### Update Info.plist

In each app repo, open `ios/Runner/Info.plist` and update:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

Replace the value with the real App ID for that specific app. Each app has its own
AdMob App ID — do not reuse them across apps.

Repeat for all three apps.

---

## Step 10 — Create ExportOptions.plist in Each App [PER APP]

Flutter's `flutter build ipa` command requires an `ExportOptions.plist` file to know
how to sign the build. Create `ios/ExportOptions.plist` in each app repo:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>teamID</key>
  <string>ABCDE12345</string>
  <key>uploadBitcode</key>
  <false/>
  <key>uploadSymbols</key>
  <true/>
  <key>signingStyle</key>
  <string>manual</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>com.porchlightsoftware.fasttrack</key>
    <string>FastTrack AppStore Distribution</string>
  </dict>
</dict>
</plist>
```

Replace `ABCDE12345` with your actual Team ID and adjust the bundle ID and provisioning
profile name to match each app.

---

## Step 11 — Take Screenshots on Mac [PER APP]

App Store listings require screenshots for specific device sizes. The
`take_screenshots.sh` script automates capturing them using Flutter's integration test
framework.

### Prerequisites

Each app must have screenshot integration tests in:
- `integration_test/screenshot_test.dart` — the test that navigates to each screen
- `test_driver/integration_test.dart` — the driver file (minimal boilerplate)

### Run the Script

```bash
cd /path/to/PorchLightSoftwareCommon/scripts
./take_screenshots.sh --app FastTrack
```

Screenshots are saved to `FastTrack/screenshots/` organized by simulator name.

### Required Screenshot Sizes

The App Store requires at least one of these sets:

| Device | Screen Size | Simulator Name |
|--------|-------------|----------------|
| iPhone 16 Pro Max | 6.7" | iPhone 16 Pro Max |
| iPhone 14 Plus | 6.5" | iPhone 14 Plus |
| iPhone 8 Plus | 5.5" | iPhone 8 Plus |

You must provide 6.7" and 6.5" screenshots. 5.5" (legacy) is optional but covers older
devices shown in search results.

### Upload Screenshots to App Store Connect

After running the script:
1. Go to your app in App Store Connect.
2. Click on your app version under **iOS App**.
3. Scroll to **App Previews and Screenshots**.
4. Drag the screenshot files from the `screenshots/` folder into the appropriate
   device slots.

---

## Step 12 — Trigger a TestFlight Deployment [PER APP]

Once all secrets are configured and the code is ready, trigger a build by pushing a
version tag.

### Bump Version Numbers First

In each app's `pubspec.yaml`, update the version:

```yaml
version: 1.0.0+1   # format: marketingVersion+buildNumber
```

The build number (`+1`) must increment with every upload to TestFlight. The marketing
version (`1.0.0`) is what users see.

Also update `ios/Runner.xcodeproj` via Xcode or by editing
`ios/Flutter/Generated.xcconfig`:

```
FLUTTER_BUILD_NAME=1.0.0
FLUTTER_BUILD_NUMBER=1
```

### Push a Tag to Trigger CI

The GitHub Actions workflow in each app repo should be configured to trigger on tags.
A typical workflow trigger in the app's `.github/workflows/deploy.yml`:

```yaml
on:
  push:
    tags:
      - 'v*'
```

To trigger a deployment:

```bash
cd /path/to/FastTrack
git add pubspec.yaml ios/
git commit -m "Bump version to 1.0.0+1"
git tag v1.0.0
git push origin main --tags
```

This pushes the commit and the tag, which triggers the CI workflow. The workflow calls
the reusable workflow in this shared repo:

```yaml
jobs:
  deploy:
    uses: Porch-Light-Software/PorchLightSoftwareCommon/.github/workflows/flutter-ios-deploy.yml@main
    with:
      bundle_id: com.porchlightsoftware.fasttrack
      app_name: FastTrack
      lane: beta
    secrets: inherit
```

### Monitor the Build

1. Go to https://github.com/Porch-Light-Software/FastTrack/actions
2. Click on the running workflow to see live logs.
3. A successful run uploads the `.ipa` to TestFlight.
4. Go to https://appstoreconnect.apple.com > your app > TestFlight to see the build
   appear (takes 5–30 minutes for Apple's processing).

---

## Step 13 — Install and Test via TestFlight

Before submitting for App Store review, test the build through TestFlight.

1. In App Store Connect, go to your app > **TestFlight** > **Internal Testing**.
2. Add yourself and any testers as Internal Testers (must be members of your App Store
   Connect team).
3. Enable the build for testing by clicking the toggle next to the build.
4. Install the **TestFlight** app on your iPhone (free on the App Store).
5. You'll receive an email invitation — open it on your iPhone and install the app.
6. Thoroughly test all features, purchases, and ad display.

For **External Testing** (up to 10,000 testers outside your org):
1. Go to **External Groups** > **Add a Build**.
2. Apple will review the build for external testing (usually 1 business day).

---

## Step 14 — Prepare App Store Listing [PER APP]

Before submitting for review, complete the App Store listing in App Store Connect.

### Required Fields

- **App Name** (30 chars max): FastTrack
- **Subtitle** (30 chars max): Brief tagline
- **Description** (4000 chars max): Full app description
- **Keywords** (100 chars max): Comma-separated search terms
- **Support URL**: https://porchlightsoftware.com/support
- **Marketing URL** (optional): https://porchlightsoftware.com
- **Privacy Policy URL**: https://porchlightsoftware.com/privacy

### Screenshots

Upload screenshots captured in Step 11. Each device size slot needs 3–10 screenshots.

### App Review Information

- **Sign-In Required**: No (if your app doesn't require login)
- **Notes**: Mention that the app uses AdMob ads and has a Remove Ads IAP.
- **Contact Information**: support@porchlightsoftware.com

### Content Rating

Complete the content rating questionnaire. Most utility apps will receive a 4+ rating.

### Pricing

1. Click **Pricing and Availability**.
2. Set **Price**: Free.
3. Availability: Select all territories (or start with United States).

### In-App Purchase Setup

1. Go to **Monetization** > **In-App Purchases** > **+**.
2. Type: **Non-Consumable** (for Remove Ads — purchased once, lasts forever).
3. **Reference Name**: Remove Ads
4. **Product ID**: `com.porchlightsoftware.fasttrack.removeads`
5. **Price**: $4.99 (Tier 5)
6. Add a display name and description for each language.
7. Submit the IAP (it gets reviewed alongside the app).

---

## Step 15 — Submit for App Store Review [PER APP]

Once the listing is complete and the TestFlight build is tested:

1. In App Store Connect, go to your app > **+ Version or Platform** if you don't have a
   version yet, or select the existing version.
2. Scroll to **Build** and click **+** to attach the TestFlight build you tested.
3. Review all required fields — App Store Connect will flag anything missing.
4. Click **Add for Review** (top right).
5. Answer the Export Compliance questions:
   - If your app uses standard HTTPS, select **No** for custom encryption.
6. Click **Submit to App Review**.

### Review Timeline

- First submission: typically 24–48 hours.
- Subsequent updates: often same-day.
- You'll receive an email when approved or if rejected.

### If Rejected

- Read the rejection reason carefully in **Resolution Center**.
- Fix the issue (could be metadata, a bug, missing privacy disclosures, etc.).
- Resubmit — no need to re-upload a build unless the issue is in the code.

---

## Quick Reference — Common Commands

```bash
# Check Flutter environment
flutter doctor

# Run locally on iOS simulator
flutter run

# Build IPA manually (for testing the build process)
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

# Deploy FastTrack to TestFlight manually (from FastTrack repo)
cd ios && bundle exec fastlane beta

# Deploy all apps (from PorchLightSoftwareCommon/scripts/)
./deploy_all.sh

# Deploy one app
./deploy_all.sh fasttrack

# Take screenshots
./take_screenshots.sh --app FastTrack
```

---

## Troubleshooting

**"No signing certificate found"**
The certificate is not in the Keychain or the .p12 Base64 secret is wrong. Re-export
the .p12 and re-encode it. Verify with:
```bash
echo "$CERTIFICATE_P12_BASE64" | base64 --decode | openssl pkcs12 -info -passin pass:"$CERTIFICATE_PASSWORD"
```

**"Provisioning profile doesn't match"**
The bundle ID in `ExportOptions.plist` must exactly match the provisioning profile's
bundle ID and the profile name must match what is in your Developer account.

**"Missing compliance"**
When uploading to TestFlight, if prompted about export compliance, you can set
`ITSAppUsesNonExemptEncryption = NO` in `ios/Runner/Info.plist` if your app only
uses standard HTTPS (Apple's HTTPS encryption is exempt):
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**"Build processing" stuck in TestFlight**
Apple's processing can take up to 30 minutes. If it exceeds 1 hour, check
https://developer.apple.com/system-status/ for outages.

**AdMob ads not showing**
Ensure the real AdMob App ID (not the test ID) is in `Info.plist`. Also ensure the
AdMob account is approved and the ad units are active.

**Flutter build fails in CI**
Check that `flutter pub get` ran successfully. Check that `ios/Podfile.lock` is
committed to the repo so CocoaPods uses consistent versions.
