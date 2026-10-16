#!/usr/bin/env bash
set -euo pipefail

NDK_VERSION="28.2.13676358"
SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/usr/local/lib/android/sdk}}"
SDKMANAGER="${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager"
NDK_DIR="${SDK_ROOT}/ndk/${NDK_VERSION}"
CLANG="${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"

is_valid_ndk() {
  [[ -f "${NDK_DIR}/source.properties" ]] &&
    grep -Fq "Pkg.Revision = ${NDK_VERSION}" "${NDK_DIR}/source.properties" &&
    [[ -x "${CLANG}" ]]
}

if is_valid_ndk; then
  echo "Verified cached Android NDK ${NDK_VERSION}"
  exit 0
fi

if [[ ! -x "${SDKMANAGER}" ]]; then
  echo "Android SDK manager not found: ${SDKMANAGER}" >&2
  exit 1
fi

for attempt in 1 2 3; do
  echo "Installing Android NDK ${NDK_VERSION}, attempt ${attempt}/3"
  rm -rf "${NDK_DIR}" "${SDK_ROOT}/.temp" "${HOME}/.android/cache"
  yes | "${SDKMANAGER}" --sdk_root="${SDK_ROOT}" --licenses >/dev/null 2>&1 || true
  if "${SDKMANAGER}" --sdk_root="${SDK_ROOT}" --install "ndk;${NDK_VERSION}" && is_valid_ndk; then
    echo "Verified Android NDK ${NDK_VERSION}"
    exit 0
  fi
  echo "NDK installation attempt ${attempt}/3 failed or produced an invalid package; clearing partial downloads." >&2
  rm -rf "${NDK_DIR}" "${SDK_ROOT}/.temp" "${HOME}/.android/cache"
  sleep $((attempt * 5))
done

echo "Unable to install a valid Android NDK ${NDK_VERSION} after three attempts." >&2
exit 1
