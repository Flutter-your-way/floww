import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/main.dart';

void main() {
  test('all visual modes expose app theme extensions', () {
    for (final mode in AppThemeMode.values) {
      final theme = AppTheme.buildTheme(mode);

      expect(theme.extension<AppColorTokens>(), isNotNull);
      expect(theme.extension<AppGradientTokens>(), isNotNull);
    }
  });

  testWidgets('app renders with the selected visual mode', (tester) async {
    await tester.pumpWidget(const MainApp(initialMode: AppThemeMode.flow));

    expect(find.text('data'), findsOneWidget);
    expect(find.text('Get Started'), findsWidgets);
  });
}
