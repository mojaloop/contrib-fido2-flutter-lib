import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fido2_client/fido2_client.dart';

void main() {
  const MethodChannel channel = MethodChannel('fido2_client');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Fido2Client.platformVersion, '42');
  });
}
