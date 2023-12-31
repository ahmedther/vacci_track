import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputField extends StatefulWidget {
  Icon fieldIcon;
  String hintText;
  Function dataCallback;
  bool obscureText = false;
  InputField(this.fieldIcon, this.hintText,
      {this.obscureText = false, required this.dataCallback, super.key});

  void sendDataToParent(text) {
    dataCallback(text); // Call the callback function and pass the data
  }

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final _text = TextEditingController();
  final bool _validate = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Material(
        elevation: 5.0,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        color: Colors.indigo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.fieldIcon,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
              ),
              width: 200,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: TextField(
                    obscureText: widget.obscureText,
                    //TestField
                    controller: _text,
                    onChanged: (text) => {widget.sendDataToParent(text)},
                    decoration: InputDecoration(
                      errorText: _validate ? "Username" : null,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
