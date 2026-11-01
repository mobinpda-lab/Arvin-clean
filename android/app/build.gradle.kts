import java.io.File

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Production signing material is injected by a protected CI environment only.
// Never commit a keystore or credentials. When credentials are absent, release
// builds remain unsigned (never debug-signed) and are not production releasable.
val arvinProductionKeystorePath = System.getenv("ARVIN_KEYSTORE_PATH")
val arvinProductionStorePassword = System.getenv("ARVIN_KEYSTORE_PASSWORD")
val arvinProductionKeyAlias = System.getenv("ARVIN_KEY_ALIAS")
val arvinProductionKeyPassword = System.getenv("ARVIN_KEY_PASSWORD")
val arvinProductionSigningInputs = listOf(
    arvinProductionKeystorePath,
    arvinProductionStorePassword,
    arvinProductionKeyAlias,
    arvinProductionKeyPassword,
)
val arvinProductionSigningHasAnyInput = arvinProductionSigningInputs.any { !it.isNullOrBlank() }
val arvinProductionSigningConfigured =
    arvinProductionSigningInputs.all { !it.isNullOrBlank() } &&
        File(arvinProductionKeystorePath.orEmpty()).isFile

// Staging uses a separate, non-production key supplied by CI. CI creates an
// ephemeral test keystore for verification; no signing material is committed.
val arvinStagingKeystorePath = System.getenv("ARVIN_STAGING_KEYSTORE_PATH")
val arvinStagingStorePassword = System.getenv("ARVIN_STAGING_KEYSTORE_PASSWORD")
val arvinStagingKeyAlias = System.getenv("ARVIN_STAGING_KEY_ALIAS")
val arvinStagingKeyPassword = System.getenv("ARVIN_STAGING_KEY_PASSWORD")
val arvinStagingSigningInputs = listOf(
    arvinStagingKeystorePath,
    arvinStagingStorePassword,
    arvinStagingKeyAlias,
    arvinStagingKeyPassword,
)
val arvinStagingSigningHasAnyInput = arvinStagingSigningInputs.any { !it.isNullOrBlank() }
val arvinStagingSigningConfigured =
    arvinStagingSigningInputs.all { !it.isNullOrBlank() } &&
        File(arvinStagingKeystorePath.orEmpty()).isFile

if (arvinStagingSigningHasAnyInput && !arvinStagingSigningConfigured) {
    throw GradleException(
        "Incomplete staging signing configuration. Supply ARVIN_STAGING_KEYSTORE_PATH, " +
            "ARVIN_STAGING_KEYSTORE_PASSWORD, ARVIN_STAGING_KEY_ALIAS and " +
            "ARVIN_STAGING_KEY_PASSWORD as a complete set."
    )
}

if (arvinProductionSigningHasAnyInput && !arvinProductionSigningConfigured) {
    throw GradleException(
        "Incomplete production signing configuration. Supply ARVIN_KEYSTORE_PATH, " +
            "ARVIN_KEYSTORE_PASSWORD, ARVIN_KEY_ALIAS and ARVIN_KEY_PASSWORD via protected CI secrets."
    )
}

if (!arvinProductionSigningConfigured) {
    logger.warn(
        "PRODUCTION_SIGNING=NOT_CONFIGURED; release APK will be unsigned and MUST NOT be distributed."
    )
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
        // is added automatically by Flutter. You can force using the value of versionCode
        // by specifying the -P force-version-code-ignoring-abi=true flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (arvinProductionSigningConfigured) {
            create("production") {
                storeFile = file(arvinProductionKeystorePath!!)
                storePassword = arvinProductionStorePassword!!
                keyAlias = arvinProductionKeyAlias!!
                keyPassword = arvinProductionKeyPassword!!
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
        if (arvinStagingSigningConfigured) {
            create("staging") {
                storeFile = file(arvinStagingKeystorePath!!)
                storePassword = arvinStagingStorePassword!!
                keyAlias = arvinStagingKeyAlias!!
                keyPassword = arvinStagingKeyPassword!!
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            // No debug-signing fallback is permitted for production release.
            if (arvinProductionSigningConfigured) {
                signingConfig = signingConfigs.getByName("production")
            }
        }
        create("staging") {
            initWith(getByName("release"))
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            isDebuggable = false
            matchingFallbacks += listOf("release")
            // Never inherit production signing or fall back to the debug key.
            signingConfig = if (arvinStagingSigningConfigured) {
                signingConfigs.getByName("staging")
            } else {
                null
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
