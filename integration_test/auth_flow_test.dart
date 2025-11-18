import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:knotwork/auth/auth_screen.dart';
import 'dart:convert';
import 'package:knotwork/home_screen.dart';
import 'dart:io';
import 'dart:async';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

class FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return FakeHttpRequest();
  }
}

class FakeHttpRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpResponse();
  }
}

class FakeHttpResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  final _data = utf8.encode('{"token":"fake_token"}');

  @override
  Future<List<int>> get first async => _data;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final stream = Stream<List<int>>.value(_data);

    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<List<List<int>>> toList() async => [_data];

  @override
  Future<List<int>> reduce(
      List<int> Function(List<int>, List<int>) combine) async {
    return combine(<int>[], _data);
  }

  @override
  int get contentLength => _data.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  bool get persistentConnection => false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Successful login flow navigates to HomeScreen",
      (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides();

    await tester.pumpWidget(MaterialApp(
      home: LoginPage(),
    ));

    // Switch to login page
    await tester.tap(find.text("Already have an account? Sign in"));
    await tester.pumpAndSettle();

    // Enter username + password
    await tester.enterText(find.byType(TextFormField).at(0), "john");
    await tester.enterText(find.byType(TextFormField).at(1), "pass123");

    // Tap login
    await tester.tap(find.text("Log in"));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // If your login() uses Navigator.pushReplacement to go to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
