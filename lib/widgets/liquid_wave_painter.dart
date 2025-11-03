import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final Color color1;
  final Color color2;

  LiquidWavePainter({
    required this.animationValue,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Wave now sweeps entire screen (goes beyond 100%)
    final waveProgress = animationValue * 1.2; // 120% to fully cover screen
    
    // Triple layered waves for epic effect
    _drawWaveLayer(canvas, size, waveProgress, color1, 0);
    _drawWaveLayer(canvas, size, waveProgress, color2, 0.3);
    _drawWaveLayer(
      canvas,
      size,
      waveProgress,
      color2.withOpacity(0.6),
      0.6,
    );
  }

  void _drawWaveLayer(
    Canvas canvas,
    Size size,
    double progress,
    Color color,
    double phaseShift,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * progress;

    path.moveTo(0, size.height);

    // Multiple wave frequencies for complex motion
    for (double i = 0; i <= size.width; i += 2) {
      final normalizedX = i / size.width;
      
      // Combine multiple sine waves for organic movement
      final wave1 = math.sin((normalizedX * 2 * math.pi) + (progress * 2 * math.pi) + phaseShift);
      final wave2 = math.sin((normalizedX * 4 * math.pi) + (progress * 3 * math.pi) - phaseShift) * 0.5;
      final wave3 = math.sin((normalizedX * 6 * math.pi) + (progress * 4 * math.pi) + phaseShift) * 0.3;
      
      final combinedWave = wave1 + wave2 + wave3;
      final amplitude = 40 + (progress * 20); // Increase amplitude as it rises
      
      final y = size.height - waveHeight + (combinedWave * amplitude);
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}