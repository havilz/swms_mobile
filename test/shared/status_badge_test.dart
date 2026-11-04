import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swms_mobile/shared/ui/atoms/status_badge.dart';

void main() {
  testWidgets('shows localized report status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'in_progress')),
      ),
    );

    expect(find.text('Sedang ditangani'), findsOneWidget);
  });
}
