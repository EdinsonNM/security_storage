# security_storage

A Flutter plugin to store data in secure storage using fingeprint:

* Android: Uses androidx with KeyStore.
## Android
Requirements:
- Android: API Level >= 23
- MainActivity must extend FlutterFragmentActivity

```kotlin
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
```
Methods | Description
--- | --- 
init | initialize the value to write
read | read safe value from keystore
write | write a safe value to the keystore
delete | remove a safe value from the keystore