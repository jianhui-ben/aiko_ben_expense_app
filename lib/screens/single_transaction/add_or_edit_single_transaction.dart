
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/numeric_keypad.dart';
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

    return Scaffold(
      body: Column(
          children: [
            // drag handler
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Opacity(
                opacity: 0.40,
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: Color(0xFF79747E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 50, 0),
                child: TextField(
                  controller: transactionAmountInput,
                  keyboardType: TextInputType.none,
                  focusNode: _focus, // pass focusNode to our textfield
                  decoration: InputDecoration(
                    prefix: Text('\$ '), // Add a dollar sign as a prefix
                    border: InputBorder.none, // Remove the outline border
                    // border: OutlineInputBorder(), //for debugging
                  ),
                  // keyboardType: TextInputType.numberWithOptions(decimal: true),
                  // Allow decimal input
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\$?\d+\.?\d{0,2}')), // Format as currency
                  ],
                  style: transactionAmountInputTextStyle, // Style for entered text
                  // textAlign: TextAlign.center, // Center the text horizontally
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.08,
              child: TextField(
                controller: transactionCommentInput,
                decoration: InputDecoration(
                  hintText: "Description: ex. Trader Joes",
                  hintStyle: inputBoxHintTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Remove the underline
                  ),
                  filled: true,
                  fillColor: Color(0xFFE6E0E9),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),                    ),
                // style: TextStyle(fontSize: 5.0,), // Style for entered text
                // textAlign: TextAlign.center, // Center the text horizontally
              ),
            ),
            // 6) if hasFocus show keyboard, else show empty container
            // _focus.hasFocus
            //     ? NumericKeypad(
            //   controller: transactionAmountInput, focusNode: _focus,
            // )
            //     : Container(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 50),
              child: Container(
                // height: MediaQuery.of(context).size.height * 0.3,
                child: NumericKeypad(
                  controller: transactionAmountInput, focusNode: _focus,
                  onSubmit: () => _submitToDatabase(user),
                  onSetDate: (DateTime date) {
                    dateInput.text = DateFormat('MM/dd/yyyy').format(date);
                  },
                ),
              ),
            )
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
        await DatabaseService(uid: user!.uid).addNewTransaction(
            widget.category.categoryId,
            double.tryParse(transactionAmountInput.text)!,
            transactionCommentInput.text,
            DateFormat('MM/dd/yyyy').parse(dateInput.text));
      } else {
        await DatabaseService(uid: user!.uid).editTransactionById(
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
