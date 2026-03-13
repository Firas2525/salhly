plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.salhlysyr.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring required by some dependencies
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.salhlysyr.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 7       // عدّل مع كل إصدار جديد
        versionName = "1.0.1" // عدّل النسخة
    }

    signingConfigs {
        create("release") {
            keyAlias = "salhlyKey"          // Alias من keystore
            keyPassword = "salhly123456" // استبدل بالقيمة الحقيقية
            storeFile = file("key.jks")     // مسار keystore داخل android/app/
            storePassword = "salhly123456" // استبدل بالقيمة الحقيقية
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // فعل تصغير الكود
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            // لتفعيل Proguard إذا أردت تصغير الكود:
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Add desugaring library dependency for core library desugaring
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
