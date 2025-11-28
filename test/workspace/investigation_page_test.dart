import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:knotwork/projects/workspace/investigation_page.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';
import 'package:knotwork/providers/webview_provider.dart';

class MockGraphProvider extends Mock implements GraphProvider {}
class MockWebViewProvider extends Mock implements WebViewProvider {}

void main() {
  testWidgets('Tools bar renders and buttons call provider methods', (tester) async {
    final graph = MockGraphProvider();
    final web = MockWebViewProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GraphProvider>.value(value: graph),
          ChangeNotifierProvider<WebViewProvider>.value(value: web),
        ],
        child: MaterialApp(home: InvestigationPage()),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    verify(() => graph.toggleFilterPanelVisible()).called(1);
  });
}
