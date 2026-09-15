import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus_celebration_hall/main.dart';
import 'package:campus_celebration_hall/services/app_state.dart';

void main() {
  testWidgets('Campus Celebration Hall smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const CampusCelebrationHallApp(),
      ),
    );

    // Verify Splash Screen elements render
    expect(find.text('Campus Celebration Hall'), findsOneWidget);
    expect(
      find.text('“Celebrate Together. Respect Campus Time.”'),
      findsOneWidget,
    );
  });
}
