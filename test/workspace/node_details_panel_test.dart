import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:knotwork/projects/workspace/investigation_page.dart';
import 'package:knotwork/providers/graph/graph_provider.dart';

class MockGraphProvider extends Mock implements GraphProvider {}
class MockDio extends Mock implements Dio {}

void main() {
  testWidgets('Displays node details and toggles minimize', (tester) async {
    final node = {
      "id": 1,
      "label": "Person",
      "properties": {"name": "John", "age": 30}
    };

    bool closed = false;

    await tester.pumpWidget(
      Provider<GraphProvider>.value(
        value: MockGraphProvider(),
        child: MaterialApp(
          home: NodeDetailsPanel(
            nodeDetails: node,
            onClose: () => closed = true,
          ),
        ),
      ),
    );

    expect(find.text("Node Details"), findsOneWidget);
    expect(find.text("ID: 1"), findsOneWidget);
    expect(find.text("name: John"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.minimize));
    await tester.pump();

    expect(find.text("name: John"), findsNothing);
  });
}
