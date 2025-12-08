import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  final directory = Directory('assets/images');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final paint = Paint()..color = Colors.blue;
  const textStyle = TextStyle(color: Colors.white, fontSize: 24);

  for (int i = 1; i <= 3; i++) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(300, 300);

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        paint..color = Colors.blue[300 + (i * 100)]!,);

    // Draw text
    final text = TextPainter(
      text: TextSpan(text: 'Placeholder $i', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    text.paint(
      canvas,
      Offset(
        (size.width - text.width) / 2,
        (size.height - text.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('assets/images/placeholder$i.png');
    await file.writeAsBytes(buffer);
  }
}
