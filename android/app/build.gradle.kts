import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- THIS IS THE KOTLIN CODE TO READ YOUR .env FILE ---
val envProperties = Properties()
// --- THIS IS THE FIX ---
// It must look in the PARENT folder (../) for the .env file.
val envPropertiesFile = File(rootProject.projectDir, "../.env")
// ----------------------
if (envPropertiesFile.exists()) {
    envPropertiesFile.reader().use { reader ->
        envProperties.load(reader)
    }
}
// ---------------------------------------------------

android {
    namespace = "com.example.jomjalan"
    compileSdk = flutter.compileSdkVersion
    
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.jomjalan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // This line reads the key from the 'envProperties' val
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = envProperties.getProperty("ANDROID_MAPS_KEY", "")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}