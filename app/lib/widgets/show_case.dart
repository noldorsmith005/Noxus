import 'dart:async';
import 'package:flutter/material.dart';


Future<void> showSpotlight(BuildContext context, GlobalKey currKey, String tutMessage) async {
  final RenderBox renderBox = currKey.currentContext!.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  final completer = Completer<void>();
  double offset;
  if (context.size != null) {
    if ((position.dy + size.height) > (context.size!.height - 50)) {
      offset = (position.dy - size.height - 50);
    } else {
      offset = (position.dy + size.height + 10);
    }
  } else {
    offset = (position.dy + size.height + 10);
  }

  final overlay = Overlay.of(context);
  late OverlayEntry spot;
  spot = OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: () {
          spot.remove();
          completer.complete();
        },
        child: Stack(
          children: [
            ShowCase(
              position: position,
              size: size,
            ),
            Positioned(
              left: position.dx,
              top: offset,
              child: Container(
                width: 350,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.transparent,
                child: Text(
                  tutMessage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, decoration: TextDecoration.none, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(spot);

  return completer.future;
}


class ShowCase extends StatelessWidget {
  final Offset position;
  final Size size;

  const ShowCase({
    required this.position,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ShowCasePainter(position: position, size: size),
      ),
    );
  }
}

class ShowCasePainter extends CustomPainter {
  final Offset position;
  final Size size;

  ShowCasePainter({required this.position, required this.size});

  @override
  void paint(Canvas canvas, Size screenSize) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.9);
    final spotlightPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height)),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH((position.dx - 8), (position.dy - 8), (size.width + 16), (size.height + 16)),
            Radius.circular(12),
          ),
        )
        ..close(),
    );
    canvas.drawPath(spotlightPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}