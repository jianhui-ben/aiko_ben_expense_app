import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SetBudgetAndDonutChart extends StatefulWidget {

  final double monthlyTransactionTotal;

  const SetBudgetAndDonutChart({super.key, required this.monthlyTransactionTotal});


  @override
  State<SetBudgetAndDonutChart> createState() => _SetBudgetAndDonutChartState();
}

class _SetBudgetAndDonutChartState extends State<SetBudgetAndDonutChart> {
  //TO-DO: setting budget and sending to firebase
  int budget = 2000;


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
                        percent: widget.monthlyTransactionTotal / budget, // calculate the percentage here
                        center: Text(
                          (widget.monthlyTransactionTotal / budget * 100).toStringAsFixed(0) + '%',
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
                        'Balance',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '\$${budget.toStringAsFixed(0)}',
                        // Replace with your monthly total variable
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: () {
                setState(() {
                  budget = int.parse(controller.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
