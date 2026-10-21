# Release APK signing guard

Date: 2026-10-21

## Release policy

A successful APK build is not proof of a safe release. The Release variant must use a dedicated organization-controlled signing key, and the produced APK must pass Android `apksigner verify`. The Release variant must never fall back to the debug signing certificate.

## Required GitHub Actions secrets

Configure these repository or environment secrets before expecting the `apk (release)` job to pass:

- `ARVIN_RELEASE_KEYSTORE_BASE64`: the complete release keystore file encoded as one Base64 string. Keep the original keystore in the organization's approved secure vault; never commit it.
- `ARVIN_RELEASE_KEYSTORE_PASSWORD`: keystore password.
- `ARVIN_RELEASE_KEY_ALIAS`: exact alias of the release key.
- `ARVIN_RELEASE_KEY_PASSWORD`: password for that key.

The workflow decodes the keystore into the runner's temporary directory, restricts file permissions, and does not upload the keystore. Passwords are passed to Gradle through masked GitHub Actions secrets, not source files.

## Validation and artifact identity

For Release, the workflow must:
1. fail with a clear error when any required secret is absent;
2. build the APK from the checked-out revision;
3. verify the APK signature using Android SDK `apksigner`;
4. record the checked-out `GITHUB_SHA` and SHA-256 of the actual APK file in the job summary;
5. name the artifact with the workflow checkout SHA.

These checks prove artifact creation and cryptographic signature verification only. Device installation, update/upgrade behavior, application identity/version acceptance, and end-user rollout remain separate acceptance gates.

## Current limitation

This change defines the secret contract and fails closed. It does not create a signing key and does not prove that the repository already has the four secrets configured. Until a trusted release key is provisioned and the Release job passes the independent signature audit, official release remains NO-GO.
