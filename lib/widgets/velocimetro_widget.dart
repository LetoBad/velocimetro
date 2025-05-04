import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget principal do velocímetro
class VelocimetroWidget extends StatelessWidget {
  final double speed;      // Velocidade atual
  final double maxSpeed;   // Velocidade máxima do velocímetro

  const VelocimetroWidget({
    super.key,
    required this.speed,
    this.maxSpeed = 180.0, // Valor padrão se não for informado
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fundo circular do velocímetro
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient( // Pode usar cores diferentes aqui se quiser dar mais vida
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
              ),
            ),
          ),

          // Pintura personalizada das marcações do velocímetro
          CustomPaint(
            size: const Size(240, 240),
            painter: SpeedometerPainter(maxSpeed: maxSpeed),
          ),

          // Ponteiro de velocidade
          Transform.rotate(
            angle: _getAngleFromSpeed(speed, maxSpeed), // Calcula o ângulo baseado na velocidade
            child: Container(
              height: 160,
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red,
                    Colors.red.shade800,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Círculo central (onde o ponteiro "gira")
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),

          // Texto que mostra a velocidade numérica
          Positioned(
            bottom: 30,
            child: Column(
              children: [
                Text(
                  speed.toStringAsFixed(1), // Mostra velocidade com uma casa decimal
                  style: GoogleFonts.orbitron(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 61, 61, 61),
                  ),
                ),
                Text(
                  'km/h',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Converte a velocidade em um ângulo (em radianos) para girar o ponteiro corretamente
  double _getAngleFromSpeed(double speed, double maxSpeed) {
    double clampedSpeed = speed.clamp(0, maxSpeed); // Garante que não passe do limite

    // Define o ângulo de início e fim do arco (em radianos)
    double startAngle = -3 * pi / 4; // -135 graus
    double endAngle = 3 * pi / 4;    // 135 graus
    double totalAngleRange = endAngle - startAngle;

    // Calcula a posição do ponteiro com base na proporção da velocidade
    double speedRatio = clampedSpeed / maxSpeed;
    return startAngle + (speedRatio * totalAngleRange);
  }
}

// Pintor personalizado que desenha as marcações do velocímetro
class SpeedometerPainter extends CustomPainter {
  final double maxSpeed;

  SpeedometerPainter({required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Pincel básico para desenhar marcações
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Arco principal do velocímetro
    const startAngle = -3 * pi / 4;
    const endAngle = 3 * pi / 4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle,
      endAngle - startAngle,
      false,
      paint,
    );

    // Marcações principais (números grandes)
    const majorTickCount = 10;
    final angleStep = (endAngle - startAngle) / majorTickCount;
    final speedStep = maxSpeed / majorTickCount;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i <= majorTickCount; i++) {
      final angle = startAngle + (i * angleStep);
      final x1 = center.dx + (radius - 20) * cos(angle);
      final y1 = center.dy + (radius - 20) * sin(angle);
      final x2 = center.dx + (radius - 35) * cos(angle);
      final y2 = center.dy + (radius - 35) * sin(angle);

      // Linha da marcação
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

      // Texto de velocidade
      final speed = (i * speedStep).toStringAsFixed(0);
      textPainter.text = TextSpan(
        text: speed,
        style: const TextStyle(
          color: Color.fromARGB(179, 0, 0, 0),
          fontSize: 12,
        ),
      );

      textPainter.layout();

      // Posiciona o texto um pouco mais para dentro
      final textX = center.dx + (radius - 50) * cos(angle) - textPainter.width / 2;
      final textY = center.dy + (radius - 50) * sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // Marcações menores (traços finos entre as grandes)
    final minorTickCount = majorTickCount * 5;
    final minorAngleStep = (endAngle - startAngle) / minorTickCount;

    for (int i = 0; i <= minorTickCount; i++) {
      if (i % 5 != 0) { // Pula os que coincidem com as marcações grandes
        final angle = startAngle + (i * minorAngleStep);
        final x1 = center.dx + (radius - 20) * cos(angle);
        final y1 = center.dy + (radius - 20) * sin(angle);
        final x2 = center.dx + (radius - 28) * cos(angle);
        final y2 = center.dy + (radius - 28) * sin(angle);

        // Linha menor
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Sempre repinta quando atualizar
  }
}
