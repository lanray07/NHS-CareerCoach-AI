# App Store Connect upload from GitHub Actions

The compile-only workflow proves the app builds. App Store Connect still needs a signed archive uploaded before the build selector appears on the version page.

Use the manual `iOS App Store Upload` workflow after adding these repository secrets in GitHub:

- `ASC_API_KEY_ID`
- `ASC_API_ISSUER_ID`
- `ASC_API_PRIVATE_KEY_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`

The App Store Connect app bundle ID is `com.nhscareercoach.app`, so the provisioning profile must be an App Store distribution profile for that bundle ID.

## Encoding files for secrets

On macOS:

```sh
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
base64 -i ios_distribution.p12 | pbcopy
base64 -i NHS_CareerCoach_App_Store.mobileprovision | pbcopy
```

Paste those values into the matching `*_BASE64` GitHub secrets.

## Running the upload

1. Open GitHub Actions.
2. Select `iOS App Store Upload`.
3. Click `Run workflow`.
4. Leave `build_number` empty unless you need a specific CFBundleVersion.

After Apple finishes processing, the build should appear in App Store Connect under the iOS version's Build section.
