import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  bool isRunning = false;
  int totalSeconds = 0;
  int remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void startTimer() {
    if (!isRunning) {
      int minutes = int.tryParse(_minutesController.text) ?? 0;
      int seconds = int.tryParse(_secondsController.text) ?? 0;
      totalSeconds = (minutes * 60) + seconds;
      remainingSeconds = totalSeconds;

      if (totalSeconds > 0) {
        setState(() {
          isRunning = true;
        });

        _controller.duration = Duration(seconds: totalSeconds);
        _controller.forward(from: 0);

        _controller.addListener(() {
          setState(() {
            remainingSeconds = totalSeconds - (totalSeconds * _controller.value).floor();
          });
        });

        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              isRunning = false;
            });
          }
        });
      }
    } else {
      _controller.stop();
      setState(() {
        isRunning = false;
        remainingSeconds = totalSeconds;
      });
    }
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TimerPainter(
                        progress: isRunning ? _controller.value : 0,
                        strokeWidth: 20,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isRunning) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _minutesController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Min',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _secondsController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Seg',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                formatTime(remainingSeconds),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: startTimer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(isRunning ? 'Cancelar' : 'Iniciar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  TimerPainter({
    required this.progress,
    required this.strokeWidth,
  });

  Color _getColorByProgress(double progress) {
    if (progress <= 0.6) {
      return Colors.green;
    } else if (progress <= 0.9) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min((size.width * 2) / 2, (size.height * 2) / 2) - strokeWidth / 2;

    // Desenha o círculo base (invisível quando progress = 0)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      backgroundPaint,
    );

    // Desenha o progresso com cor baseada no tempo restante
    final progressPaint = Paint()
      ..color = _getColorByProgress(progress)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      -pi / 2, // Começa do topo
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
