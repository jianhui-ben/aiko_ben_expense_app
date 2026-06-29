import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/category_breakdown.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/household_split.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/month_overview.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/no_spend_streak.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/recurring_expenses.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/six_month_trend.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/smart_insights_feed.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/weekday_rhythm.dart';
import 'package:aiko_ben_expense_app/screens/insights/charts/year_in_review_teaser.dart';
import 'package:aiko_ben_expense_app/screens/insights/period_range.dart';
import 'package:flutter/material.dart';

/// Phase 1 + 2 redesigned month view: a scrollable dashboard of purposeful
/// modules. Each module reads the household transaction stream from its
/// ancestor provider, so no filtered list needs to be threaded in.
class MonthlyDashboard extends StatelessWidget {
  const MonthlyDashboard({super.key});

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
          SmartInsightsFeed(),
          MonthOverview(),
          SizedBox(height: AppSpacing.lg),
          CategoryBreakdown(period: InsightPeriod.month),
          SizedBox(height: AppSpacing.lg),
          SixMonthTrend(),
          SizedBox(height: AppSpacing.lg),
          WeekdayRhythm(),
          SizedBox(height: AppSpacing.lg),
          NoSpendStreak(),
          SizedBox(height: AppSpacing.lg),
          HouseholdSplit(period: InsightPeriod.month),
          SizedBox(height: AppSpacing.lg),
          RecurringExpenses(),
          SizedBox(height: AppSpacing.lg),
          YearInReviewTeaser(),
        ],
      ),
    );
  }
}
