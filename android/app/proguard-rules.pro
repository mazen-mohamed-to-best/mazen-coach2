## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Sqflite
-keep class com.tekartik.sqflite.** { *; }

## Crypto
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

## Gson
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

## Retrofit / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**

## Flutter local notifications
-keep class com.dexterous.** { *; }
