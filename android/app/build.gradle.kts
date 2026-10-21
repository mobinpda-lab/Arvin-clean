plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is enabled only when a trusted keystore and all credentials are
// supplied by the build environment. The debug certificate is never a release fallback.
val releaseStoreFile = System.getenv("ARVIN_RELEASE_STORE_FILE")?.takeIf { it.isNotBlank() }
val releaseStorePassword = System.getenv("ARVIN_RELEASE_STORE_PASSWORD")?.takeIf { it.isNotBlank() }
val releaseKeyAlias = System.getenv("ARVIN_RELEASE_KEY_ALIAS")?.takeIf { it.isNotBlank() }
val releaseKeyPassword = System.getenv("ARVIN_RELEASE_KEY_PASSWORD")?.takeIf { it.isNotBlank() }
val hasTrustedReleaseSigning =
    releaseStoreFile != null &&
    releaseStorePassword != null &&
    releaseKeyAlias != null &&
    releaseKeyPassword != null &&
    project.file(releaseStoreFile).isFile

gradle.taskGraph.whenReady {
    val releasePackagingRequested = allTasks.any { task ->
        task.name.endsWith("Release") &&
            (task.name.startsWith("assemble") ||
                task.name.startsWith("bundle") ||
                task.name.startsWith("package"))
    }
    if (releasePackagingRequested && !hasTrustedReleaseSigning) {
        throw GradleException(
            "Release build blocked: trusted release signing inputs are missing. Supply " +
                "ARVIN_RELEASE_STORE_FILE, ARVIN_RELEASE_STORE_PASSWORD, " +
                "ARVIN_RELEASE_KEY_ALIAS, and ARVIN_RELEASE_KEY_PASSWORD. " +
                "Debug signing is not permitted for release builds."
        )
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
        if (hasTrustedReleaseSigning) {
            create("release") {
                storeFile = file(requireNotNull(releaseStoreFile))
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Never fall back to the debug certificate for a release build.
            signingConfig = if (hasTrustedReleaseSigning) {
                signingConfigs.getByName("release")
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
