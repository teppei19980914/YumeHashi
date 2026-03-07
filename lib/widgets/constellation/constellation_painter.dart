/// 星座描画ウィジェット.
///
/// CustomPainterを使って星座の星と接続線を描画する.
library;

import 'package:flutter/material.dart';

import '../../models/constellation.dart';

/// 星座を描画するウィジェット.
class ConstellationWidget extends StatelessWidget {
  /// ConstellationWidgetを作成する.
  const ConstellationWidget({
    required this.progress,
    super.key,
    this.compact = false,
  });

  /// 星座の進捗データ.
  final ConstellationProgress progress;

  /// コンパクト表示（ダッシュボード用）.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConstellationPainter(
        progress: progress,
        compact: compact,
        brightness: Theme.of(context).brightness,
      ),
      size: Size.infinite,
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({
    required this.progress,
    required this.compact,
    required this.brightness,
  });

  final ConstellationProgress progress;
  final bool compact;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final constellation = progress.constellation;
    final litCount = progress.litStarCount;
    final isComplete = progress.isComplete;

    // パディング
    final pad = compact ? 8.0 : 16.0;
    final drawArea = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );

    // 星の実座標を計算
    final positions = constellation.stars.map((s) {
      return Offset(
        drawArea.left + s.x * drawArea.width,
        drawArea.top + s.y * drawArea.height,
      );
    }).toList();

    final isDark = brightness == Brightness.dark;

    // --- 接続線の描画 ---
    for (final conn in constellation.connections) {
      final fromLit = conn.fromIndex < litCount;
      final toLit = conn.toIndex < litCount;

      final Paint linePaint;
      if (fromLit && toLit) {
        // 両端が点灯: 明るい線
        linePaint = Paint()
          ..color = isComplete
              ? const Color(0xFFFFD700).withAlpha(180) // ゴールド
              : (isDark
                  ? const Color(0xFF7EB8DA).withAlpha(120)
                  : const Color(0xFF4A8FC2).withAlpha(100))
          ..strokeWidth = compact ? 1.0 : 1.5
          ..style = PaintingStyle.stroke;
      } else {
        // 未点灯: 暗い線
        linePaint = Paint()
          ..color = isDark
              ? Colors.white.withAlpha(15)
              : Colors.black.withAlpha(10)
          ..strokeWidth = compact ? 0.5 : 0.8
          ..style = PaintingStyle.stroke;
      }

      canvas.drawLine(
        positions[conn.fromIndex],
        positions[conn.toIndex],
        linePaint,
      );
    }

    // --- 星の描画 ---
    final litStarRadius = compact ? 3.0 : 5.0;
    final dimStarRadius = compact ? 1.5 : 2.5;

    for (var i = 0; i < constellation.stars.length; i++) {
      final pos = positions[i];
      final isLit = i < litCount;

      if (isLit) {
        // グロー効果
        final glowRadius = litStarRadius * (isComplete ? 4.0 : 3.0);
        final glowColor = isComplete
            ? const Color(0xFFFFD700) // ゴールド
            : const Color(0xFFB0D4F1); // 淡い青白

        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              glowColor.withAlpha(isComplete ? 100 : 60),
              glowColor.withAlpha(0),
            ],
          ).createShader(
            Rect.fromCircle(center: pos, radius: glowRadius),
          );
        canvas.drawCircle(pos, glowRadius, glowPaint);

        // 星本体
        final starPaint = Paint()
          ..color = isComplete
              ? const Color(0xFFFFD700)
              : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, litStarRadius, starPaint);
      } else {
        // 未点灯の星（かすかに見える）
        final dimPaint = Paint()
          ..color = isDark
              ? Colors.white.withAlpha(30)
              : Colors.black.withAlpha(20)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, dimStarRadius, dimPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter oldDelegate) {
    return progress.litStarCount != oldDelegate.progress.litStarCount ||
        progress.constellation.id != oldDelegate.progress.constellation.id ||
        brightness != oldDelegate.brightness;
  }
}
