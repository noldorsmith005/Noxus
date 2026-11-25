import 'package:flutter/material.dart';



class NumSelector extends StatefulWidget {
  const NumSelector({super.key, required this.min, required this.max, required this.initial, required this.onChanged});
  final int min;
  final int max;
  final int initial;
  final Function onChanged;

  @override
  State<NumSelector> createState() => _NumSelectorState();
}

class _NumSelectorState extends State<NumSelector> {
  late int value;
  bool holding = false;

  @override
  void initState() {
    super.initState();
    value = widget.initial.clamp(widget.min, widget.max);
  }

  void Increase() {
    setState(() {
      if (value < widget.max) value++;
      widget.onChanged(value);
    });
  }

  void Decrease() {
    setState(() {
      if (value > widget.min) value--;
      widget.onChanged(value);
    });
  }

  void quickIncrease() async {
    while (holding) {
      await Future.delayed(Duration(milliseconds: 70));
      Increase();
    }
  }

  void quickDecrease() async {
    while (holding) {
      await Future.delayed(Duration(milliseconds: 70));
      Decrease();
    }
  }

  Widget buildButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(12),
        minimumSize: Size(40, 40),
      ),
      child: Icon(icon, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () {
            holding = true;
            quickDecrease();
          },
          onLongPressUp:() {
            holding = false;
          },
          child: ElevatedButton(
            onPressed: Decrease,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(12),
              minimumSize: Size(40, 40),
            ),
            child: Icon(Icons.remove, size: 20, color: Colors.grey),
          ),
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "$value",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onLongPress: () {
            holding = true;
            quickIncrease();
          },
          onLongPressUp:() {
            holding = false;
          },
          child: ElevatedButton(
            onPressed: Increase,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(12),
              minimumSize: Size(40, 40),
            ),
            child: Icon(Icons.add, size: 20, color: Colors.grey),
          ),
        )
      ],
    );
  }
}