import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Compose for home widget
    id("org.jetbrains.kotlin.plugin.compose")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    buildFeatures {
        compose = true
    }
    namespace = "com.cowboydodartinc.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    defaultConfig {
        applicationId = "com.cowboydodartinc.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
      create("release") {
          keyAlias = keystoreProperties["keyAlias"] as String
          keyPassword = keystoreProperties["keyPassword"] as String
          storeFile = keystoreProperties["storeFile"]?.let { file(it) }
          storePassword = keystoreProperties["storePassword"] as String
      }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
  implementation("com.google.android.gms:play-services-ads-identifier:18.1.0")
  // strictly() blocks Gradle from upgrading via transitive resolution —
  // the home_widget plugin declares `1.+` and would otherwise pick the
  // latest alpha (1.3.0-alpha01 at time of writing), which requires
  // compileSdk 37 + AGP 9.x and breaks the build.
  implementation("androidx.glance:glance-appwidget") {
    version {
      strictly("1.1.1")
    }
  }
  implementation("androidx.appcompat:appcompat:1.7.0")
}