import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()

val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}


android {

    // Identificador actual de la aplicación
    namespace = "com.example.girls_boutique_app"

    // SDK de compilación de Flutter
    compileSdk = flutter.compileSdkVersion

    // NDK requerido por las dependencias del proyecto
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {

        // Identificador actual registrado en Firebase
        applicationId = "com.example.girls_boutique_app"

        // Versión mínima de Android
        minSdk = 23

        // SDK objetivo
        targetSdk = flutter.targetSdkVersion

        // Versión de la aplicación
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {

        create("release") {

            // Alias de la clave
            keyAlias = keystoreProperties.getProperty("keyAlias")

            // Contraseña de la clave
            keyPassword = keystoreProperties.getProperty("keyPassword")

            // Ubicación del archivo de firma
            storeFile = keystoreProperties
                .getProperty("storeFile")
                ?.let { file(it) }

            // Contraseña del almacén
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {

        release {

            // Utilizar la firma de producción
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
