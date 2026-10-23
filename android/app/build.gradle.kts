import java.io.File

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningRequired = providers.gradleProperty("arvinReleaseSigningRequired")
    .map { it.toBoolean() }
    .getOrElse(false)
val releaseKeystorePath = providers.environmentVariable("ARVIN_RELEASE_KEYSTORE_PATH").orNull
val releaseStorePassword = providers.environmentVariable("ARVIN_RELEASE_STORE_PASSWORD").orNull
val releaseKeyAlias = providers.environmentVariable("ARVIN_RELEASE_KEY_ALIAS").orNull
val releaseKeyPassword = providers.environmentVariable("ARVIN_RELEASE_KEY_PASSWORD").orNull

val releaseSigningValues = listOf(
    releaseKeystorePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword
)
val hasCompleteReleaseSigning = releaseSigningValues.all { !it.isNullOrBlank() } &&
    releaseKeystorePath?.let { File(it).isFile } == true

if (releaseSigningRequired && !hasCompleteReleaseSigning) {
    throw GradleException(
        "Release signing was required, but the owner-controlled keystore or required signing environment values are missing."
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
        applicationId = "com.example.arvin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasCompleteReleaseSigning) {
            create("ownerRelease") {
                storeFile = File(requireNotNull(releaseKeystorePath))
                storePassword = requireNotNull(releaseStorePassword)
                keyAlias = requireNotNull(releaseKeyAlias)
                keyPassword = requireNotNull(releaseKeyPassword)
            }
        }
    }

    buildTypes {
        release {
            // Ordinary CI may build an unsigned validation APK. Distribution builds
            // must pass -ParvinReleaseSigningRequired=true and supply owner secrets.
            if (hasCompleteReleaseSigning) {
                signingConfig = signingConfigs.getByName("ownerRelease")
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
