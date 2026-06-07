import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/app/app.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'USE_MOCK_DATA=true');
  });

  testWidgets('App boots into login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HealthApp()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Health App'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
