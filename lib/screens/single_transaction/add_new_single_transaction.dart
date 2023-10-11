
import 'package:aiko_ben_expense_app/models/category.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/single_transaction/numeric_keypad.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNewSingleTransaction extends StatefulWidget {

  final DateTime selectedDate;
  final int? transactionAmount;

  const AddNewSingleTransaction({super.key, required this.selectedDate, this.transactionAmount});

  @override
  State<AddNewSingleTransaction> createState() => _AddNewSingleTransactionState();
}

class _AddNewSingleTransactionState extends State<AddNewSingleTransaction> {

  final FocusNode _focus = FocusNode(); // 1) init _focus to let user directly input number from keypad

  late Map data;
  TextEditingController dateInput = TextEditingController();
  TextEditingController transactionAmountInput = TextEditingController();
  TextEditingController transactionCommentInput = TextEditingController();

  @override
  void initState() {
    dateInput.text = DateFormat('MM/dd/yyyy').format(widget.selectedDate);
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
    data = ModalRoute.of(context)?.settings.arguments as Map<String, Object?>;
    final User? user= context.read<User?>();

    //TO-DO: here we should retrieve category icon and text from the categoryId
    Category category = data["category"];

    return Scaffold(appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
      child: Column(
          children: [
            // SizedBox(height: 30,),
            Container(
              // color: Colors.yellow,  //for debugging
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(category.categoryIcon.icon,
                      size: 50, //
                      color: Color(0xFF6200EE)),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    // padding: EdgeInsets.all(15),
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 32, 15, 32),
                      child: TextField(
                        controller: dateInput,
                        //editing controller of this TextField
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 2)),
                          hintText: "MM/DD/YYYY",
                          labelText: 'Transaction Date',
                          suffixIcon: Align(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat('MM/dd/yyyy')
                                          .format(pickedDate);
                                  setState(() {
                                    dateInput.text = formattedDate;
                                  });
                                } else {
                                  print(
                                      "Date is not selected from the day picker, so default today will be used");
                                }
                              },
                              child: CircleAvatar(
                                child: const Icon(Icons.calendar_today,
                                    color: Color(0xFF6200EE)),
                              ),
                            ),
                          ),
                        ),
                        readOnly: false,
                        //set it true, so that user will not able to edit text
                        inputFormatters: [
                          // only allow date be input
                          // FilteringTextInputFormatter.allow(RegExp(r'^\d{41}-\d{2}-\d{2}$')),
                          DateTextFormatter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 30,),
            Container(
              // color: Colors.blue, //for debugging
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.12,
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
                  style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold,), // Style for entered text
                  // textAlign: TextAlign.center, // Center the text horizontally
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 10, 0),
              child: Row(
                children: [
                  Text("Description: "),
                  Container(
                    // color: Colors.yellow, //for debugging
                    width: 250,
                    // height: 80,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: TextField(
                        controller: transactionCommentInput,
                        // Your other properties here
                        decoration: InputDecoration(
                          border: UnderlineInputBorder( // Use UnderlineInputBorder to add an underline border
                            borderSide: BorderSide(color: Color(0xFF6200EE)), // Customize the underline color
                          ), // Remove the outline border
                        ),
                        // style: TextStyle(fontSize: 5.0,), // Style for entered text
                        // textAlign: TextAlign.center, // Center the text horizontally
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.05,
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6), // Adjust margin as needed
              child: ElevatedButton(
                onPressed: () async {
                  await DatabaseService(uid: user!.uid).addNewTransaction(
                      category.categoryId,
                      double.tryParse(transactionAmountInput.text)!,
                      transactionCommentInput.text, DateFormat('MM/dd/yyyy').parse(dateInput.text));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6200EE), // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text(
                  'ADD',
                  style: TextStyle(fontSize: 18.0), // Adjust the text style as needed
                ),
              ),
            ),
            const Spacer(),
            // 6) if hasFocus show keyboard, else show empty container
            // _focus.hasFocus
            //     ? NumericKeypad(
            //   controller: transactionAmountInput, focusNode: _focus,
            // )
            //     : Container(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 50),
              child: NumericKeypad(
                controller: transactionAmountInput, focusNode: _focus,
              ),
            )
        ],
      ),
    ),
    );
  }
}
