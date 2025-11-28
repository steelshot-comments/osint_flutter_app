import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:knotwork/projects/workspace/webview/filters.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';

class MockGraphProvider extends Mock implements GraphProvider {}

void main() {
  testWidgets('Filter chips display labels and searchGraph is called', (tester) async {
    final mockGraph = MockGraphProvider();
    when(() => mockGraph.nodeLabels).thenReturn(["Person", "Movie"]);
    when(() => mockGraph.edgeLabels).thenReturn(["ACTED_IN"]);
    when(() => mockGraph.labelColors).thenReturn({
      "Person": Colors.red,
      "Movie": Colors.blue,
      "ACTED_IN": Colors.green,
    });

    int searchCalls = 0;

    await tester.pumpWidget(
      Provider<GraphProvider>.value(
        value: mockGraph,
        child: MaterialApp(
          home: FilterPanel(searchGraph: (_, __) => searchCalls++),
        ),
      ),
    );

    expect(find.text("Person"), findsOneWidget);
    expect(find.text("Movie"), findsOneWidget);

    await tester.tap(find.text("Person"));
    await tester.pump();

    expect(searchCalls, greaterThan(0));
  });
}
