import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSign;

  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(symbol: '\$', decimalDigits: 2)
        .format(amount);
    final text = showSign && amount > 0 ? '+$formatted' : formatted;

    return Text(
      text,
      style: style ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
    );
  }
}
