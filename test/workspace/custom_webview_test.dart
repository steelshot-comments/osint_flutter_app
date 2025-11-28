import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:knotwork/projects/workspace/webview/custom_webview.dart';

class MockWebViewController extends Mock implements WebViewController {}
class FakeJavaScriptMessage extends Fake implements JavaScriptMessage {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeJavaScriptMessage());
  });

  late MockWebViewController controller;
  late Map<String, dynamic> data;
  late bool messageCallbackCalled;

  setUp(() {
    controller = MockWebViewController();
    data = {"value": 123};
    messageCallbackCalled = false;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CustomWebView(
        assetUrl: 'assets/sample.html',
        controller: controller,
        data: data,
        onMessage: (msg) => messageCallbackCalled = true,
      ),
    );
  }

  // ----------------------------
  // TEST 1: Initialization
  // ----------------------------
  testWidgets('initializes the WebViewController correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    verify(() => controller.setJavaScriptMode(JavaScriptMode.unrestricted)).called(1);

    verify(() => controller.addJavaScriptChannel(
      'FlutterGraphChannel',
      onMessageReceived: any(named: 'onMessageReceived'),
    )).called(1);

    verify(() => controller.loadFlutterAsset('assets/sample.html')).called(1);
  });

  // ----------------------------
  // TEST 2: Page finished triggers data update
  // ----------------------------
  testWidgets('onPageFinished triggers updateGraphData', (tester) async {
    when(() => controller.runJavaScript(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    // Capture NavigationDelegate
    final captured = verify(
      () => controller.setNavigationDelegate(captureAny()),
    ).captured;

    final delegate = captured.first as NavigationDelegate;

    // Simulate page finished
    delegate.onPageFinished?.call("assets/sample.html");

    final expectedJson = jsonEncode(data);
    verify(() => controller.runJavaScript("window.updateGraphData($expectedJson)")).called(1);
  });

  // ----------------------------
  // TEST 3: didUpdateWidget calls JS update when data changes
  // ----------------------------
  testWidgets('didUpdateWidget triggers JS update when data changes', (tester) async {
    when(() => controller.runJavaScript(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    data = {"value": 999};

    await tester.pumpWidget(
      MaterialApp(
        home: CustomWebView(
          assetUrl: 'assets/sample.html',
          controller: controller,
          data: data,
          onMessage: (_) {},
        ),
      ),
    );

    final expectedJson = jsonEncode(data);
    verify(() => controller.runJavaScript("window.updateGraphData($expectedJson)")).called(1);
  });

  // ----------------------------
  // TEST 4: onMessage callback invoked
  // ----------------------------
  testWidgets('JS message triggers onMessage callback', (tester) async {
    late void Function(JavaScriptMessage) savedCallback;

    when(
      () => controller.addJavaScriptChannel(
        'FlutterGraphChannel',
        onMessageReceived: any(named: 'onMessageReceived'),
      ),
    ).thenAnswer((invocation) async {
      savedCallback = invocation.namedArguments[#onMessageReceived]
          as void Function(JavaScriptMessage);
    });

    await tester.pumpWidget(createWidgetUnderTest());

    savedCallback(FakeJavaScriptMessage());

    expect(messageCallbackCalled, isTrue);
  });

  // ----------------------------
  // TEST 5: build returns WebViewWidget
  // ----------------------------
  testWidgets('build returns WebViewWidget', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(WebViewWidget), findsOneWidget);
  });
}

// | Test   | What it Checks                                                            |
// | ------ | ------------------------------------------------------------------------- |
// | Test 1 | Controller receives JS mode setting, channel registration, and asset load |
// | Test 2 | Page load completion triggers graph update JS                             |
// | Test 3 | Updating `data` triggers JS update                                        |
// | Test 4 | JavaScript message invokes callback                                       |
// | Test 5 | Widget builds expected UI                                                 |
