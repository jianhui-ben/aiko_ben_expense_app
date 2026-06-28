import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class SetBudgetAndDonutChart extends StatefulWidget {

  final double monthlyTransactionTotal;

  const SetBudgetAndDonutChart(
      {super.key, required this.monthlyTransactionTotal});

  @override
  State<SetBudgetAndDonutChart> createState() => _SetBudgetAndDonutChartState();
}

class _SetBudgetAndDonutChartState extends State<SetBudgetAndDonutChart> {
  //set a default here to avoid waiting for the async function to finish
  int budget = 2000;

  String? householdId;
  final _households = FirebaseFirestore.instance.collection('households');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = Provider.of<User?>(context)?.householdId;
    if (id != null && id != householdId) {
      householdId = id;
      fetchBudget();
    }
  }

  void fetchBudget() async {
    if (householdId == null) return;
    final docSnapshot = await _households.doc(householdId).get();
    if (!mounted || !docSnapshot.exists) return;
    setState(() {
      budget = (docSnapshot.get('monthlyBudget') as num).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      decoration: ShapeDecoration(
        color: Color(0x236750A4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Budget',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 16, // adjust this value to match the height of the Text widget
                child: IconButton(
                  padding: EdgeInsets.all(0), // remove padding to allow the icon to fill the container
                  icon: Icon(Icons.edit, size: 16), // adjust the icon size to match the height of the Text widget
                  onPressed: () => editBudget(context),
                ),
              ),
            ],
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 70,
              decoration: ShapeDecoration(
                color: Color(0xFFFCFCFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        animation: true,
                        animationDuration: 500,
                        radius: 30.0, // adjust the size of the donut chart here
                        lineWidth: 10.0, // adjust the width of the donut chart here
                        percent: widget.monthlyTransactionTotal / budget > 1
                            ? 1
                            : widget.monthlyTransactionTotal / budget,
                        // calculate the percentage here
                        center: Text(
                          '${(widget.monthlyTransactionTotal / budget * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                        ),
                        progressColor: Colors.green,
                        backgroundColor: Colors.grey,// adjust the color of the filled portion here
                      ),

                    ],
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remaining',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '\$${(budget - widget.monthlyTransactionTotal).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (budget - widget.monthlyTransactionTotal) < 0
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }



  void editBudget(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: budget.toString(), // Set the initial text to the current budget
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Budget'),
          content: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter new budget',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                setState(() {
                  budget = int.parse(controller.text);
                });

                if (householdId != null) {
                  await _households.doc(householdId).set(
                    {'monthlyBudget': budget},
                    SetOptions(merge: true),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
