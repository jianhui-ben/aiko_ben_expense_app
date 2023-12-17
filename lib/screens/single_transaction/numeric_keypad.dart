import 'package:flutter/material.dart';


//reference: https://medium.com/@henryifebunandu/create-custom-keyboard-for-your-flutter-app-20926a0aaf19

class NumericKeypad extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() onSubmit;

  const NumericKeypad(
      {super.key, required this.controller, required this.focusNode, required this.onSubmit});

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {

  late FocusNode _focusNode;
  late TextEditingController _controller;
  late TextSelection _selection;
  String? operation;

  @override
  void initState() {
    super.initState();
    // add listener to controller
    _controller = widget.controller..addListener(_onSelectionChanged);
    _selection = _controller.selection;
    _focusNode = widget.focusNode;
  }

  @override
  void dispose() {
    // remove listener
    _controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {
      // update selection on change (updating position too)
      _selection = _controller.selection;
    });
    // print('Cursor position: ${_selection.base.offset}'); // print position
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> numericButtons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    final List<String> operations = ['=', '+', '-', 'S'];

    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
            children: numericButtons.map((List<String> row) {
              return Row(
                children: row.map((String button) {
                  return _buildButton(button, onPressed: button == '⌫' ? _backspace : null);
                }).toList(),
              );
            }).toList(),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Column(
            children: [
              Row(children: [_buildButton('=', onPressed: _calculate),],),
              Row(children: [_buildButton('+', onPressed: _summation),],),
              Row(children: [_buildButton('-', onPressed: _subtract),],),
              Row(children: [submitOrCalculateButton(onSubmit: _submit),],),
            ],
          ),
        ),
      ],
    );
  }

  // hide keyboard for future usage
  _hideKeyboard() => _focusNode.unfocus();

  // Individual keys
  Widget _buildButton(String text, {VoidCallback? onPressed}) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed ?? () => _input(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 30.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
      ),
    );
  }

  void _backspace() {
    int position = _selection.base.offset; // cursor position
    final value = _controller.text; // string in out textfield

    // 1) only erase when string in textfield is not empty and when position is not zero (at the start)
    if (value.isNotEmpty && position != 0) {
      var suffix = value.substring(position, value.length); // 2) get string after cursor position
      _controller.text = value.substring(0, position - 1) + suffix; // 3) get string before the cursor and append to
      // suffix after removing the last char before the cursor
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: position - 1)); // 4) update the cursor
    }
  }

  void _input(String text) {

    int position = _selection.base.offset; // gets position of cursor
    var value = _controller.text; // text in our textfield

    if (value.isNotEmpty) {
      var suffix = value.substring(position, value.length); // 1) suffix: the string
      // from the position of the cursor to the end of the text in the controller

      value = value.substring(0, position) + text + suffix; // 2) value.substring gets
      // a new string from start of the string in our textfield, appends the new input to our
      // new string and appends the suffix to it.

      _controller.text = value; // 3) set our controller text to the gotten value
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: position + 1)); // 4) update selection
      // to update our position.
    } else {
      value = _controller.text + text; // 5) appends controller text and new input
      // and assigns to value
      _controller.text = value; // 6) set our controller text to the gotten value
      _controller.selection =
          TextSelection.fromPosition(const TextPosition(offset: 1)); // 7) since this is the first input
      // set position of cursor to 1, so the cursor is placed at the end
    }
  }

  void _summation() {
    operation = '+';
    _controller.text = _controller.text + operation!;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
  }

  void _subtract() {
    operation = '-';
    _controller.text = _controller.text + operation!;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
  }

  void _submit() {
    widget.onSubmit();
  }

  void _calculate() {
    // now the controller.text would be a string like this 135+24
    // i use this method to extract 135 and 24 from the string and do the summation
    // and then set the controller.text to the result
    if (_controller.text.isNotEmpty) {
      List<String> numbers = _controller.text.split(operation!);
      double firstNumber = double.tryParse(numbers[0]) ?? 0;
      double secondNumber = double.tryParse(numbers[1]) ?? 0;
      double result;

      print("first number: $firstNumber, second number: $secondNumber");

      if (operation == '+') {
        result = firstNumber + secondNumber;
      } else if (operation == '-') {
        result = firstNumber - secondNumber;
      } else {
        return;
      }

      _controller.text = result.toString();
      operation = null;
    }
  }

  Widget submitOrCalculateButton({required void Function() onSubmit}) {
    if (operation != null) {
      return _buildButton('=', onPressed: _calculate);
    } else {
      return ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6200EE), // Background color
          foregroundColor: Colors.white, // Text color
        ),
        child: Text('Submit'),
      );
    }
  }
}