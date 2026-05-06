plugins {
    id("com.android.application")
    // Temporarily disable Firebase for testing
    // id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.company.compass"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.company.compass"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
  // Temporarily disable Firebase dependencies for testing
  // Import the Firebase BoM
  // implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

  // Firebase Analytics
  // implementation("com.google.firebase:firebase-analytics")
  
  // Firebase Cloud Messaging (FCM) for notifications
  // implementation("com.google.firebase:firebase-messaging")
  
  // Core library desugaring
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
flutter {
    source = "../.."
}
