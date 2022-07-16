import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushe_flutter/pushe.dart';

void main() {
  const MethodChannel channel = MethodChannel('pushe_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  test('Passing', () {});

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
