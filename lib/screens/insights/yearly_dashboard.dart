import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/category_breakdown.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/household_split.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/year_in_review_teaser.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/year_monthly_trend.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/year_overview.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:flutter/material.dart';

/// Year view: the big picture — year-to-date pace, month-by-month spend, the
/// annual category mix, the household split, and the "Year in Review" recap.
class YearlyDashboard extends StatelessWidget {
  const YearlyDashboard({super.key});

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
          YearOverview(),
          SizedBox(height: AppSpacing.lg),
          YearMonthlyTrend(),
          SizedBox(height: AppSpacing.lg),
          CategoryBreakdown(period: InsightPeriod.year),
          SizedBox(height: AppSpacing.lg),
          HouseholdSplit(period: InsightPeriod.year),
          SizedBox(height: AppSpacing.lg),
          YearInReviewTeaser(),
        ],
      ),
    );
  }
}
