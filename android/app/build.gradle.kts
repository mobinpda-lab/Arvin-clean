plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val officialReleaseRequested = System.getenv("ARVIN_OFFICIAL_RELEASE") == "true"
val releaseStoreFile = System.getenv("ARVIN_RELEASE_STORE_FILE")
val releaseStorePassword = System.getenv("ARVIN_RELEASE_STORE_PASSWORD")
val releaseKeyAlias = System.getenv("ARVIN_RELEASE_KEY_ALIAS")
val releaseKeyPassword = System.getenv("ARVIN_RELEASE_KEY_PASSWORD")

if (officialReleaseRequested) {
    require(!releaseStoreFile.isNullOrBlank()) {
        "Official Release requested, but ARVIN_RELEASE_STORE_FILE is missing."
    }
    require(!releaseStorePassword.isNullOrBlank()) {
        "Official Release requested, but ARVIN_RELEASE_STORE_PASSWORD is missing."
    }
    require(!releaseKeyAlias.isNullOrBlank()) {
        "Official Release requested, but ARVIN_RELEASE_KEY_ALIAS is missing."
    }
    require(!releaseKeyPassword.isNullOrBlank()) {
        "Official Release requested, but ARVIN_RELEASE_KEY_PASSWORD is missing."
    }
}

android {
    namespace = "com.example.arvin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.arvin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (officialReleaseRequested) {
            create("arvinProduction") {
                storeFile = file(requireNotNull(releaseStoreFile))
                storePassword = requireNotNull(releaseStorePassword)
                keyAlias = requireNotNull(releaseKeyAlias)
                keyPassword = requireNotNull(releaseKeyPassword)
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            if (officialReleaseRequested) {
                // Fail closed: official signing cannot fall back to the Debug certificate.
                signingConfig = signingConfigs.getByName("arvinProduction")
            } else {
                // Development/PR-only Release-variant builds are explicitly non-production.
                // The workflow labels these artifacts as Debug-key-signed; never publish them.
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
