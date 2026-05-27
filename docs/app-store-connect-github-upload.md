# App Store Connect upload from GitHub Actions

The compile-only workflow proves the app builds. App Store Connect still needs a signed archive uploaded before the build selector appears on the version page.

Use the manual `iOS App Store Upload` workflow after adding these repository secrets in GitHub:

- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_PRIVATE_KEY`

The App Store Connect app bundle ID is `com.nhscareercoach.app`.

## Encoding files for secrets

The private key can be pasted as the raw `.p8` file contents. If you prefer encoding it first, use:

```sh
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

Paste that value into `APP_STORE_CONNECT_API_PRIVATE_KEY`.

## Running the upload

1. Open GitHub Actions.
2. Select `iOS App Store Upload`.
3. Click `Run workflow`.
4. Leave `build_number` empty unless you need a specific CFBundleVersion.

After Apple finishes processing, the build should appear in App Store Connect under the iOS version's Build section.
