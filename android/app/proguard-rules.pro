# Keep rules for the release build.
#
# This file was empty while the release build ran minification with R8 full
# mode, which produced a class that failed JVM verification and crashed the app
# at launch inside FirebaseInitProvider:
#
#   java.lang.VerifyError: Verifier rejected class W.p ...
#   expected Reference: java.lang.RuntimeException
#
# Debug builds do not minify, so it only appeared in a production-style build.

# --- Flutter ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Firebase ---
# Firebase discovers components reflectively through ComponentRegistrar, so
# those implementations must survive removal and renaming. Everything else in
# Firebase ships its own consumer rules and does not need blanket keeping —
# doing that added 33MB to the APK and fixed nothing.
-keepnames class com.google.firebase.components.ComponentRegistrar
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keepclassmembers class * {
    @com.google.firebase.components.Component <methods>;
}

# firebase-sessions is Dagger-generated and reads its config through AndroidX
# DataStore with Kotlin property delegates. This is the subsystem named in the
# launch crash:
#   SessionsSettings.getDataStore -> DataStore -> VerifyError
-keep class com.google.firebase.sessions.** { *; }
-keep class androidx.datastore.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Crashlytics needs line numbers and source files to symbolicate reports; strip
# them and every crash report becomes unreadable.
-keepattributes SourceFile,LineNumberTable

# The actual cause of the launch VerifyError.
#
# R8 full mode merges classes aggressively. When it merges an exception subclass
# into another class, a catch handler's register no longer holds the type the
# verifier expects, and the whole class is rejected at load time:
#
#   register v7 has type Reference: W.p
#   but expected Reference: java.lang.RuntimeException
#
# Members are kept too, not just the class name. Keeping only the name still
# let R8 merge the type away, and the crash reproduced unchanged.
-keep class * extends java.lang.Throwable { *; }

# --- Yandex Mobile Ads ---
#
# The launch VerifyError came from here, not Firebase. De-obfuscating the crash
# through R8's mapping file gave:
#
#   com.google.android.gms.auth.api.signin.internal.zbn
#     .l(int, com.yandex.div.storage.database.StorageStatement[])
#     -> com.yandex.div.core.DivPreloader$TicketImpl
#
# A Google Sign-In class cannot take Yandex storage statements and return a
# DivKit ticket. That signature only exists because R8 full mode horizontally
# merged unrelated classes from both SDKs into one, leaving a register holding
# the merged type where the verifier required a RuntimeException.
#
# DivKit ships inside the Yandex ads SDK under com.yandex.div, which the
# previous rules did not cover — they only named com.yandex.mobile.ads.
-keep class com.yandex.** { *; }
-keep class com.monetization.** { *; }
-dontwarn com.yandex.**

# --- General ---
# Annotations and signatures are needed for reflection and generics.
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
