import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppColors defines core palette', () {
    expect(AppColors.primary.toARGB32(), 0xFF4F46E5);
    expect(AppColors.background.toARGB32(), 0xFFF7F6F3);
  });
}
