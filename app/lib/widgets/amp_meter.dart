import 'package:flutter/material.dart';



class AmpMeter extends StatelessWidget {
  const AmpMeter({super.key, required this.amps});
  final List<double> amps;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: CustomPaint(
          painter: AmpMeterPainter(amps: amps),
        ),
      ),
    );
  }
}

class AmpMeterPainter extends CustomPainter {
  final List<double> amps;
  AmpMeterPainter({required this.amps});


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < amps.length; i++) {
      final value = amps[i];
      final height = ((value * size.height) * 0.75);
      final x = (i * 10.0);
      final y = ((size.height / 2) - (height / 2));

      final rect = Rect.fromLTWH(x, y, 5, height);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AmpMeterPainter oldDelegate) => true;
}