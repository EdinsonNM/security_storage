import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_storage/security_storage.dart';

void main() {
  const MethodChannel channel = MethodChannel('security_storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
