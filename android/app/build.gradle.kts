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
    }

    buildTypes {
        release {
            // Android Gradle Plugin enables v1/v2 signing by default when a signing
            // config is attached. CI must explicitly verify v1/v2/v3 with apksigner.
            // No debug-signing fallback is permitted.
            if (arvinProductionSigningConfigured) {
                signingConfig = signingConfigs.getByName("production")
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
