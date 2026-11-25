import 'dart:async';
import 'package:flutter/material.dart';




class HoldButton extends StatefulWidget {
  const HoldButton({super.key, required this.onComplete});
  final Function onComplete;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  Timer? holdTimer;
  double current = 0.0;
  static const duration = Duration(milliseconds: 1000);
  late AnimationController aniController;

  @override
  void initState() {
    super.initState();
    aniController = AnimationController(
      vsync: this,
      duration: duration,
    )..addListener(() {
        setState(() {
          current = aniController.value;
        });
      });
  }

  void onHolding(TapDownDetails details) {
    aniController.forward(from: 0.0);
      holdTimer = Timer(duration, () {
      aniController.reset();
      widget.onComplete();
    });
  }

  void cancelHold() {
    holdTimer?.cancel();
    aniController.duration = Duration(milliseconds: 400);
    aniController.reverse().whenComplete(() {
      aniController.duration = duration;
    });
    current = 0.0;
  }

  void onTapUp(TapUpDetails details) {
    cancelHold();
  }

  @override
  void dispose() {
    holdTimer?.cancel();
    aniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: onHolding,
        onTapUp: onTapUp,
        onTapCancel: cancelHold,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(130, 105, 60, 185),
                foregroundColor: Colors.white,
                elevation: 5,
                padding: EdgeInsets.all(50),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: CircleBorder()
              ),
              child: Text("   Log \nDream "),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: aniController.value,
                strokeWidth: 3,
                backgroundColor: Colors.black,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
