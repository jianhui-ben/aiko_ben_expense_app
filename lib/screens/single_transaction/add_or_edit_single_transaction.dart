
import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/numeric_keypad.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
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

  const AddOrEditSingleTransaction(
      {super.key,
      required this.category,
      required this.selectedDate,
      this.transactionAmount,
      this.transactionComment,
      this.transactionId});

  @override
  State<AddOrEditSingleTransaction> createState() => _AddOrEditSingleTransaction();
}

class _AddOrEditSingleTransaction extends State<AddOrEditSingleTransaction> {

  final FocusNode _focus = FocusNode(); // 1) init _focus to let user directly input number from keypad

  late Map data;
  TextEditingController dateInput = TextEditingController();
  TextEditingController transactionAmountInput = TextEditingController();
  TextEditingController transactionCommentInput = TextEditingController();

  @override
  void initState() {
    dateInput.text = DateFormat('MM/dd/yyyy').format(widget.selectedDate);

    // if transactionId exists, it's not a new transaction
    if (widget.transactionId != null) {
      transactionAmountInput.text = widget.transactionAmount.toString();
      transactionCommentInput.text = widget.transactionComment.toString();
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focus); // Request focus for the transaction amount field when the screen loads
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus
      ..removeListener(_onFocusChange)
      ..dispose(); // 3) removeListener and dispose
  }

  void _onFocusChange() {
    setState(() {});
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
          // drag handle
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
          // category label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: const IconThemeData(
                  color: AppColors.categoryAccent,
                  size: 20,
                ),
                child: widget.category.categoryIcon,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.category.categoryName,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // amount entry
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
          // description
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
        SnackBar(
          content: Text('Invalid transaction amount. Please enter a valid number.'),
        ),
      );
    } else {
      if (widget.transactionId == null) {
        await DatabaseService(householdId: user!.householdId).addNewTransaction(
            widget.category.categoryId,
            double.tryParse(transactionAmountInput.text)!,
            transactionCommentInput.text,
            DateFormat('MM/dd/yyyy').parse(dateInput.text),
            createdByUid: AuthService().currentUser?.uid,
            createdByName: AuthService().currentUser?.displayName);
      } else {
        await DatabaseService(householdId: user!.householdId).editTransactionById(
            widget.transactionId!,
            widget.category.categoryId,
            double.tryParse(transactionAmountInput.text)!,
            transactionCommentInput.text,
            DateFormat('MM/dd/yyyy').parse(dateInput.text));
      }
      Navigator.pop(context);
    }
  }
}
