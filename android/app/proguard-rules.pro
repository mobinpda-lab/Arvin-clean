# R8 compatibility for optional Flutter plugin bindings.
# These classes are conditionally present depending on the resolved Flutter plugin
# graph and are referenced from GeneratedPluginRegistrant. Suppress only the
# known optional package references; do not suppress arbitrary missing classes.

-dontwarn com.github.dart_lang.jni.**
-dontwarn com.github.dart_lang.jni_flutter.**
-dontwarn dev.flutter.plugins.integration_test.**
-dontwarn dev.fluttercommunity.plus.androidalarmmanager.**
-dontwarn dev.fluttercommunity.plus.share.**
-dontwarn io.flutter.plugins.sharedpreferences.**
-dontwarn net.nfet.flutter.printing.**
-dontwarn com.jvoltci.saf.**

# Preserve plugin entry points when the corresponding plugin dependency is present.
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }
-keep class dev.flutter.plugins.integration_test.** { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class net.nfet.flutter.printing.** { *; }
-keep class com.jvoltci.saf.** { *; }
