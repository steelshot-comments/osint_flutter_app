import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:knotwork/projects/workspace/investigation_page.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';

class MockGraphProvider extends Mock implements GraphProvider {}
class MockWebViewController extends Mock implements WebViewController {}

void main() {
  late MockGraphProvider graph;
  late MockWebViewController controller;

  setUp(() {
    graph = MockGraphProvider();
    controller = MockWebViewController();
    when(() => graph.nodes).thenReturn([]);
    when(() => graph.edges).thenReturn([]);
  });

  testWidgets('onMessage populates selectedNode', (tester) async {
    await tester.pumpWidget(
      Provider<GraphProvider>.value(
        value: graph,
        child: const MaterialApp(home: WebView()),
      ),
    );

    // Find state object
    final state = tester.state(find.byType(WebView)) as dynamic;

    final fakeMessage = JavaScriptMessage(message: jsonEncode({"id": 10}));

    state.onMessage(fakeMessage);
    await tester.pump();

    expect(state.selectedNode["id"], equals(10));
  });

  testWidgets('searchGraph calls runJavaScript()', (tester) async {
    when(() => controller.runJavaScript(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      Provider<GraphProvider>.value(
        value: graph,
        child: const MaterialApp(home: WebView()),
      ),
    );

    final state = tester.state(find.byType(WebView)) as dynamic;
    state._controller = controller;
    
    state.searchGraph("abc", ["label1"]);

    verify(() => controller.runJavaScript(any())).called(1);
  });
}
