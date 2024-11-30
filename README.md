# Timer Customizado em Flutter - Guia Detalhado

Este guia explica em detalhes a implementação de um Timer customizado em Flutter, com animações e mudança de cores baseada no progresso.

## 🎯 Visão Geral

O projeto implementa um timer circular animado com as seguintes características:
- Interface visual com círculo progressivo
- Mudança de cores baseada no tempo restante (verde → amarelo → vermelho)
- Campos para entrada de minutos e segundos
- Animação suave do progresso

## 📚 Estrutura do Código

### 1. Estrutura Base do App

```dart
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
```

**Explicação:**
- `main()`: Ponto de entrada do app Flutter
- `MyApp`: Widget raiz que configura o tema e estrutura básica
- `MaterialApp`: Fornece a estrutura material design do app

### 2. Tela Principal (StatefulWidget)

```dart
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}
```

**Explicação:**
- `StatefulWidget`: Usado porque precisamos manter estado (tempo, animação)
- O `createState()` retorna a classe que gerenciará o estado

### 3. Estado da Tela

```dart
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
```

**Explicação:**
- `TickerProviderStateMixin`: Necessário para animações
- `AnimationController`: Controla a animação do timer
- `TextEditingController`: Controla os campos de texto
- `initState()`: Inicializa os controladores
- `dispose()`: Libera recursos quando o widget é destruído

### 4. Painter Customizado

```dart
class TimerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  TimerPainter({
    required this.progress,
    required this.strokeWidth,
  });

  Color _getColorByProgress(double progress) {
    double remainingTime = 1 - progress;
    if (remainingTime > 0.4) {
      return Colors.green;
    } else if (remainingTime > 0.1) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min((size.width * 2) / 2, (size.height * 2) / 2) - strokeWidth / 2;

    // Círculo base
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      backgroundPaint,
    );

    // Progresso
    final progressPaint = Paint()
      ..color = _getColorByProgress(progress)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      -pi / 2,
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
```

**Explicação:**
- `CustomPainter`: Classe para desenho personalizado
- `paint()`: Método onde fazemos o desenho
- `_getColorByProgress()`: Define a cor baseada no progresso
- `canvas.drawOval()`: Desenha a forma oval base
- `canvas.drawArc()`: Desenha o arco de progresso

### 5. Lógica do Timer

```dart
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
    });
  }
}
```

**Explicação:**
- Converte minutos e segundos em total de segundos
- Configura a duração da animação
- Adiciona listeners para atualizar o UI
- Gerencia o estado de execução do timer

### 6. Interface do Usuário

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CustomPaint(
            painter: TimerPainter(
              progress: _controller.value,
              strokeWidth: 20,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Min'),
                    ),
                  ),
                  Text(':'),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Seg'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: startTimer,
            child: Text(isRunning ? 'Cancelar' : 'Iniciar'),
          ),
        ),
      ],
    ),
  );
}
```

## 🔑 Conceitos Importantes

### 1. Gerenciamento de Estado
- Uso de `setState()` para atualizar a UI
- Controladores para campos de texto
- Estado do timer (running/stopped)

### 2. Animação
- `AnimationController` para controlar o progresso
- Listeners para atualizar UI durante a animação
- Transições suaves de cores

### 3. Desenho Customizado
- `CustomPainter` para desenho manual
- Cálculos geométricos para o layout
- Gerenciamento de cores dinâmicas

### 4. Interface do Usuário
- Layout responsivo
- Campos de entrada formatados
- Botão com estado dinâmico

### 5. Ciclo de Vida
- Inicialização de recursos em `initState()`
- Limpeza de recursos em `dispose()`
- Gerenciamento de animações

## 📝 Conclusão

Este código demonstra vários conceitos importantes do Flutter:
- Widgets com e sem estado
- Animações
- Desenho customizado
- Gerenciamento de entrada do usuário
- Layout responsivo
- Ciclo de vida dos widgets

## 🤝 Contribuição

Sinta-se à vontade para contribuir com este projeto através de Pull Requests ou criando Issues para reportar problemas ou sugestões.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
