import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushe/pushe.dart';

void main() {
  const MethodChannel channel = MethodChannel('pushe');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await Pushe.platformVersion, '42');
  });
}