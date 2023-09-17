
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNewSingleTransaction extends StatefulWidget {
  const AddNewSingleTransaction({super.key});

  @override
  State<AddNewSingleTransaction> createState() => _AddNewSingleTransactionState();
}

class _AddNewSingleTransactionState extends State<AddNewSingleTransaction> {

  late Map data;
  TextEditingController dateInput = TextEditingController(text: DateFormat('MM/dd/yyyy').format(DateTime.now()));
  TextEditingController transactionAmountInput = TextEditingController(text: "0");
  TextEditingController transactionCommentInput = TextEditingController();

  @override
  Widget build(BuildContext context) {

    data = ModalRoute.of(context)?.settings.arguments as Map<String, Object?>;
    final User? user= context.read<User?>();

    //TO-DO: here we should retrieve category icon and text from the categoryId
    Icon _defaultCategoryIcon = Icon(Icons.shopping_cart);
    String _defaultCategoryName = "shopping";

    var _transactionAmount;

    return Scaffold(appBar: AppBar(),
    body: Center(
      child: Column(
          children: [
            // SizedBox(height: 30,),
            Container(
              // color: Colors.yellow,  //for debugging
              width: 350,
              height: 150,
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(_defaultCategoryIcon.icon,
                      size: 55, //
                      color: Color(0xFF6200EE)),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    // padding: EdgeInsets.all(15),
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 40, 15, 40),
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
            SizedBox(height: 10,),
            Container(
              // color: Colors.blue, //for debugging
              width: 350,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 50, 0),
                child: TextField(
                  controller: transactionAmountInput,
                  // Your other properties here
                  decoration: InputDecoration(
                    prefixText: '\$ ', // Add a dollar sign as a prefix
                    border: InputBorder.none, // Remove the outline border
                    // border: OutlineInputBorder(), //for debugging
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            SizedBox(height: 50,),
            Container(
              height: 50,
              width: 300, // Forces the button to take the full width of the screen
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6), // Adjust margin as needed
              child: ElevatedButton(
                onPressed: () async {
                  print(user!.uid);
                  await DatabaseService(uid: user!.uid).addNewTransaction(
                      data["categoryId"],
                      double.tryParse(transactionAmountInput.text)!,
                      transactionCommentInput.text);
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


        ],
      ),
    ),
    );
  }
}
