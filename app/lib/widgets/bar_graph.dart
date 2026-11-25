import 'dart:math';
import 'package:flutter/material.dart';



class BarPoint {
  double x;
  double y;

  BarPoint(this.x, this.y);
}

String valConvert(int value) {
  String text;
  switch (value) {
    case 0:
      text = '12:00';
    case 1:
      text = '13:00';
    case 2:
      text = '14:00';
    case 3:
      text = '15:00';
    case 4:
      text = '16:00';
    case 5:
      text = '17:00';
    case 6:
      text = '18:00';
    case 7: 
      text = '19:00';
    case 8:
      text = '20:00';
    case 9:
      text = '21:00';
    case 10:
      text = '22:00';
    case 11:
      text = '23:00';
    case 12:
      text = '00:00';
    case 13:
      text = '01:00';
    case 14:
      text = '02:00';
    case 15:
      text = '03:00';
    case 16:
      text = '04:00';
    case 17:
      text = '05:00';
    case 18:
      text = '06:00';
    case 19:
      text = '07:00';
    case 20:
      text = '08:00';
    case 21:
      text = '09:00';
    case 22:
      text = '10:00';
    case 23:
      text = '11:00';

    default:
      return "";
  }

  return text;
}


class BarGraph extends StatefulWidget {
  const BarGraph({super.key, required this.points});
  final List<BarPoint> points;

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {

  @override
  Widget build(BuildContext context) {
    Map<double, BarPoint> data = {};
    for (var point in widget.points) {
      data[point.x] = point;
    }

    return CustomPaint(
      painter: BarChartPainter(data, 10),
      size: Size(double.infinity, 200),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<double, BarPoint> data;
  final double max;
  final int slots;

  BarChartPainter(this.data, this.max, {this.slots = 24});

  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dashWidth = 4, double gap = 8}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt((dx * dx + dy * dy));
    final angle = atan2(dy, dx);

    double current = 0;
    while (current < distance) {
      final x1 = start.dx + (current * cos(angle));
      final y1 = start.dy + (current * sin(angle));
      final x2 = start.dx + ((current + dashWidth).clamp(0, distance) * cos(angle));
      final y2 = start.dy + ((current + dashWidth).clamp(0, distance) * sin(angle));

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      current += dashWidth + gap;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const int offset = 20;
    const double width = 20.0;
    const double spacing = 60.0;
    double main_height = (size.height - offset - 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);


    final gridPaint = Paint() 
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = (main_height - (i * 35));
      drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 1; i <= slots; i++) {
      final x = (i * spacing);
      drawDashedLine(canvas, Offset(x, 0), Offset(x, main_height), gridPaint);
    }


    final barPaint = Paint()..style = PaintingStyle.fill;
    final chart = Rect.fromLTWH(0, 0, size.width, main_height);
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      stops: [0.0, 0.85],
      colors: [Colors.blue, Colors.purple],
    );

    final shader = gradient.createShader(chart);
    barPaint.shader = shader;
    for (double i = -1; i <= slots; i += 0.5) {
      final x = ((i * spacing) - (width / 2));
      final index = (i - 1);
      final point = data[index];

      if (point != null) {
        double height = (point.y / max) * size.height;
        final bar = Rect.fromLTWH(x, (main_height - height), width, height);
        canvas.drawRect(
          bar,
          barPaint,
        );
      }

      if ((index % 1) == 0) {
        final labelText = TextSpan(
          text: valConvert(index.toInt()),
          style: TextStyle(color: Colors.white, fontSize: 15),
        );
        textPainter.text = labelText;
        textPainter.layout(minWidth: 0, maxWidth: spacing);
        textPainter.paint(
          canvas,
          Offset((x - 10), size.height - offset),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}