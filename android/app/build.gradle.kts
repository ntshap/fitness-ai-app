import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

fun localProperties(): Properties {
    val properties = Properties()
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(FileInputStream(localPropertiesFile))
    }
    return properties
}

android {
    namespace = "com.example.fitness_ai_app"
    
    // --- PERBAIKAN ADA DI SINI ---
    // Menaikkan versi compile SDK sesuai kebutuhan plugin camera
    compileSdk = 35
    // ---------------------------------

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.fitness_ai_app"
        minSdk = 26
        multiDexEnabled = true
        targetSdk = 34 // targetSdk bisa tetap 34 untuk saat ini
        versionCode = localProperties().getProperty("flutter.versionCode")?.toInt() ?: 1
        versionName = localProperties().getProperty("flutter.versionName") ?: "1.0"
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

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
