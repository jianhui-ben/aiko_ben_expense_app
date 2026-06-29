import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/category_breakdown.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/household_split.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/week_daily_trend.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/week_overview.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:flutter/material.dart';

/// Week view: a recent, fast-moving lens — how this week compares to last,
/// daily spend, and where it went. Drops the longer-horizon trend modules.
class WeeklyDashboard extends StatelessWidget {
  const WeeklyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: const [
          WeekOverview(),
          SizedBox(height: AppSpacing.lg),
          WeekDailyTrend(),
          SizedBox(height: AppSpacing.lg),
          CategoryBreakdown(period: InsightPeriod.week),
          SizedBox(height: AppSpacing.lg),
          HouseholdSplit(period: InsightPeriod.week),
        ],
      ),
    );
  }
}
