import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relógio Analógico Bonito',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: AnalogClock(),
    );
  }
}

class AnalogClock extends StatefulWidget {
  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  bool isDarkMode = false;
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 10,
                    color: Colors.black38,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: ClockPainter(_now, isDarkMode),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => setState(() {
                    isDarkMode = false;
                  }),
                  child: Text('Tema Light'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => setState(() {
                    isDarkMode = true;
                  }),
                  child: Text('Tema Dark'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;
  final bool isDarkMode;

  ClockPainter(this.dateTime, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    // Draw the outer circle
    Paint outerCircle = Paint()
      ..color = isDarkMode ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, size.width / 2, outerCircle);

    // Hour hand
    final hourHandLength = size.width / 3;
    final hourAngle = 2 * pi * (dateTime.hour + dateTime.minute / 60) / 12;
    final hourHandX = centerX + hourHandLength * sin(hourAngle);
    final hourHandY = centerY - hourHandLength * cos(hourAngle);
    canvas.drawLine(
        center,
        Offset(hourHandX, hourHandY),
        Paint()
          ..color = isDarkMode ? Colors.white : Colors.black
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);

    // Minute hand
    final minuteHandLength = size.width / 2.3;
    final minuteAngle = 2 * pi * dateTime.minute / 60;
    final minuteHandX = centerX + minuteHandLength * sin(minuteAngle);
    final minuteHandY = centerY - minuteHandLength * cos(minuteAngle);
    canvas.drawLine(
        center,
        Offset(minuteHandX, minuteHandY),
        Paint()
          ..color = isDarkMode ? Colors.white : Colors.grey
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);

    // Second hand
    final secondHandLength = size.width / 2.5;
    final secondAngle = 2 * pi * dateTime.second / 60;
    final secondHandX = centerX + secondHandLength * sin(secondAngle);
    final secondHandY = centerY - secondHandLength * cos(secondAngle);
    canvas.drawLine(
        center,
        Offset(secondHandX, secondHandY),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2);

    // Draw numbers for seconds at every 5-second interval
    final textStyle = TextStyle(
      color: isDarkMode ? Colors.white60 : Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 60; i += 5) {
      final angle = 2 * pi * i / 60;
      final numberDistance = size.width / 2.7;
      final numberX = centerX + numberDistance * sin(angle);
      final numberY = centerY - numberDistance * cos(angle);
      textPainter.text = TextSpan(text: '$i', style: textStyle);
      textPainter.layout();

      final offset = Offset(
        numberX - textPainter.width / 2,
        numberY - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
