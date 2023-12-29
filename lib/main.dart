import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static double percentage = 100.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CustomRadialProgress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RadialProgressWidget(
        percentage: percentage,
      ),
    );
  }
}

const double radialSize = 100.0;
const double thickness = 10.0;

class Particle {
  late double orbit;
  late double originalOrbit;
  late double theta;
  late double opacity;
  late Color color;

  Particle(this.orbit) {
    originalOrbit = orbit;
    theta = getRandomRange(0.0, 360.0) * pi / 180.0;
    opacity = getRandomRange(0.3, 1.0);
    color = Colors.white;
  }

  void update() {
    orbit += 1.0;
    opacity -= 0.0025;
    if (opacity <= 0.0) {
      orbit = originalOrbit;
      opacity = getRandomRange(0.1, 1.0);
    }
  }
}

final rnd = Random();

double getRandomRange(double min, double max) {
  return rnd.nextDouble() * (max - min) + min;
}

Offset polarToCartesian(double r, double theta) {
  final dx = r * cos(theta);
  final dy = r * sin(theta);
  return Offset(dx, dy);
}

class RadialProgressWidget extends StatefulWidget {
  final double percentage;

  const RadialProgressWidget({super.key, required this.percentage});

  @override
  State<RadialProgressWidget> createState() => _RadialProgressWidgetState();
}

class _RadialProgressWidgetState extends State<RadialProgressWidget> {
  var value = 0.0;
  late Timer timer;
  final speed = 0.5;

  final List<Particle> particles = List<Particle>.generate(
      200, (index) => Particle(radialSize + thickness / 2.0));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      var v = value;
      if (v <= widget.percentage) {
        v += speed;
      } else {
        setState(() {
          for (var element in particles) {
            element.update();
          }
        });
      }

      setState(() {
        value = v;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgressPainter(value, particles),
      child: Container(),
    );
  }
}

const Color col1 = Color(0Xff110f14);
const Color col2 = Color(0Xff2a2732);
const Color col3 = Color(0Xff3c393f);
const Color col4 = Color(0Xff6047f5);
const Color col5 = Color(0Xffa3b0ef);

const TextStyle textStyle =
    TextStyle(color: Colors.red, fontSize: 50.0, fontWeight: FontWeight.bold);

class RadialProgressPainter extends CustomPainter {
  final double percentage;
  final List<Particle> particles;

  RadialProgressPainter(this.percentage, this.particles);

  @override
  void paint(Canvas canvas, Size size) {

    final c = Offset(size.width / 2.0, size.height / 2.0);
    drawBackground(canvas, c, size.height / 2.0);
    final rect = Rect.fromCenter(
        center: c, width: 2.0 * radialSize, height: 2.0 * radialSize);

    drawCircle(canvas, c, radialSize);
    drawArc(canvas, rect);
    drawTextCentered(
        canvas, c, "${percentage.toInt()}", textStyle, radialSize * 2 * 0.8);

    if (percentage >= 100.0) {
      drawParticles(canvas, c);
    }
  }

  void drawBackground(Canvas canvas, Offset c, double extend) {
    final rect = Rect.fromCenter(center: c, width: extend, height: extend);
    final bgPaint = Paint()
      ..shader = const RadialGradient(colors: [col1, col2]).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPaint(bgPaint);
  }

  void drawParticles(Canvas canvas, Offset c) {
    for (var p in particles) {
      final cc = polarToCartesian(p.orbit, p.theta) + c;
      final paint = Paint()..color = p.color.withOpacity(p.opacity);
      canvas.drawCircle(cc, 1.0, paint);
    }
  }

  Size drawTextCentered(Canvas canvas, Offset position, String text,
      TextStyle style, double maxWidth) {
    final tp = measureText(text, style, maxWidth, TextAlign.center);
    tp.paint(canvas, position + Offset(-tp.width / 2.0, -tp.height / 2.0));
    return tp.size;
  }

  TextPainter measureText(
      String text, TextStyle style, double maxWidth, TextAlign alignment) {
    final span = TextSpan(
      text: text,
      style: style,
    );
    final tp = TextPainter(
        text: span, textAlign: alignment, textDirection: TextDirection.ltr);
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    return tp;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawArc(Canvas canvas, Rect rect) {
    final fgPaint = Paint()
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [col4, col5],
          tileMode: TileMode.mirror).createShader(rect);
    const startAngle = -90.0 * pi / 180;

    ///SweepAngle is the progress angle
    final sweepAngle = 360.0 * percentage / 100.0 * pi / 180;

    ///draw an arc
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void drawCircle(
    Canvas canvas,
    Offset c,
    double radius,
  ) {
    Paint paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400;
    canvas.drawCircle(c, radius, paint);
  }
}
