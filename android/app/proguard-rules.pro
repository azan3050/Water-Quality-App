# Suppress warnings for Flutter's internal classes
-dontwarn io.flutter.embedding.**

# Suppress the specific warning from the build log
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Keep Flutter's main entry points
-keep class io.flutter.embedding.android.FlutterActivity
-keep class io.flutter.embedding.android.FlutterFragment

# Broadly keep all TensorFlow Lite classes
-keep class org.tensorflow.** { *; }

# Add more specific rules for the GPU delegate to be absolutely safe
-keep class org.tensorflow.lite.gpu.** { *; }

