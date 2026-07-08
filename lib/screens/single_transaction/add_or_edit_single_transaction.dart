
import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/numeric_keypad.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/category_preferences.dart';
import 'package:aiko_ben_expense_app/services/category_usage_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/widgets/category_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddOrEditSingleTransaction extends StatefulWidget {
  final Category category;
  final DateTime selectedDate;
  final double? transactionAmount;
  final String? transactionComment;
  final String? transactionId;

  const AddOrEditSingleTransaction({
    super.key,
    required this.category,
    required this.selectedDate,
    this.transactionAmount,
    this.transactionComment,
    this.transactionId,
  });

  @override
  State<AddOrEditSingleTransaction> createState() =>
      _AddOrEditSingleTransaction();
}

class _AddOrEditSingleTransaction extends State<AddOrEditSingleTransaction> {
  final FocusNode _focus = FocusNode();

  late Category _selectedCategory;
  TextEditingController dateInput = TextEditingController();
  TextEditingController transactionAmountInput = TextEditingController();
  TextEditingController transactionCommentInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    dateInput.text = DateFormat('MM/dd/yyyy').format(widget.selectedDate);

    if (widget.transactionId != null) {
      transactionAmountInput.text = widget.transactionAmount.toString();
      transactionCommentInput.text = widget.transactionComment.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focus);
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _changeCategory() async {
    final user = context.read<User?>();
    if (user?.householdId == null) return;

    final householdId = user!.householdId!;
    final categories = await getHouseholdCategoriesMap(householdId);
    final pinnedIds = await getHouseholdPinnedCategoryIds(householdId);
    if (!mounted) return;
    final transactions = context.read<List<Transaction>?>() ?? const [];
    final usageCounts = computeUsageCounts(transactions);
    final lastUsed = await CategoryPreferences.getLastUsedCategory(householdId);

    if (!mounted) return;
    await showCategoryPickerSheet(
      context: context,
      householdId: householdId,
      categories: categories,
      pinnedCategoryIds: pinnedIds,
      usageCounts: usageCounts,
      lastUsedCategoryId: lastUsed,
      onCategorySelected: (category) {
        setState(() => _selectedCategory = category);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.read<User?>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: _changeCategory,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: const IconThemeData(
                      color: AppColors.categoryAccent,
                      size: 20,
                    ),
                    child: _selectedCategory.categoryIcon,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _selectedCategory.categoryName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: TextField(
              controller: transactionAmountInput,
              keyboardType: TextInputType.none,
              focusNode: _focus,
              showCursor: false,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                prefixStyle: transactionAmountInputTextStyle,
                hintText: '0',
                hintStyle: transactionAmountInputTextStyle,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\$?\d+\.?\d{0,2}')),
              ],
              style: transactionAmountInputTextStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: TextField(
              controller: transactionCommentInput,
              decoration: InputDecoration(
                hintText: 'Description: ex. Trader Joes',
                hintStyle: inputBoxHintTextStyle,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: NumericKeypad(
              controller: transactionAmountInput,
              focusNode: _focus,
              onSubmit: () => _submitToDatabase(user),
              onSetDate: (DateTime date) {
                dateInput.text = DateFormat('MM/dd/yyyy').format(date);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitToDatabase(User? user) async {
    if (transactionAmountInput.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid transaction amount. Please enter a valid number.',
          ),
        ),
      );
      return;
    }

    final householdId = user!.householdId!;
    await CategoryPreferences.saveLastUsedCategory(
      householdId,
      _selectedCategory.categoryId,
    );

    if (widget.transactionId == null) {
      await DatabaseService(householdId: householdId).addNewTransaction(
        _selectedCategory.categoryId,
        double.tryParse(transactionAmountInput.text)!,
        transactionCommentInput.text,
        DateFormat('MM/dd/yyyy').parse(dateInput.text),
        createdByUid: AuthService().currentUser?.uid,
        createdByName: AuthService().currentUser?.displayName,
      );
    } else {
      await DatabaseService(householdId: householdId).editTransactionById(
        widget.transactionId!,
        _selectedCategory.categoryId,
        double.tryParse(transactionAmountInput.text)!,
        transactionCommentInput.text,
        DateFormat('MM/dd/yyyy').parse(dateInput.text),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
