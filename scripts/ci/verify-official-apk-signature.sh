#!/usr/bin/env bash
set -euo pipefail

apk="$1"
trusted_fingerprint="$2"
apksigner="$3"
verification_log="$4"
evidence_file="$5"

fail() {
  echo "::error::$1" >&2
  exit 1
}

[[ -s "$apk" ]] || fail "Release APK is missing or empty."
[[ -n "$trusted_fingerprint" ]] || fail "ARVIN_RELEASE_CERT_SHA256 is missing; official signer cannot be trusted."
[[ -x "$apksigner" ]] || fail "apksigner executable is missing."

mkdir -p "$(dirname "$verification_log")" "$(dirname "$evidence_file")"
"$apksigner" verify --verbose --print-certs "$apk" 2>&1 | tee "$verification_log"

actual="$(awk -F': ' '/Signer #1 certificate SHA-256 digest:/ {print $2; exit}' "$verification_log" | tr -d '[:space:]:' | tr '[:lower:]' '[:upper:]')"
expected="$(printf '%s' "$trusted_fingerprint" | tr -d '[:space:]:' | tr '[:lower:]' '[:upper:]')"
[[ "$actual" =~ ^[A-F0-9]{64}$ ]] || fail "apksigner did not return a valid SHA-256 signer fingerprint."
[[ "$expected" =~ ^[A-F0-9]{64}$ ]] || fail "Trusted signer fingerprint must be 64 hexadecimal characters (colons optional)."
[[ "$actual" == "$expected" ]] || fail "APK signer fingerprint does not match the independently trusted release certificate."

printf 'SIGNATURE_VERIFICATION=apksigner-verified\nSIGNING_CERT_SHA256=%s\n' "$actual" > "$evidence_file"
echo "OFFICIAL_APK_SIGNATURE=verified"
echo "SIGNING_CERT_SHA256=$actual"
