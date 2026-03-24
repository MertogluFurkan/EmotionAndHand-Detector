import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

/// Yuvarlak ilerleme göstergeli metrik kartı (nemlendirme, düzenlilik vb.)
class MetricGauge extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0
  final Color color;

  const MetricGauge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan çemberi
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  color: color.withOpacity(0.12),
                ),
              ),
              // Değer çemberi
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: value.clamp(0, 1),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
                  .animate()
                  .custom(
                    duration: 1200.ms,
                    curve: Curves.easeOut,
                    builder: (_, v, child) => child!,
                  ),
              // Yüzde metni
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Basit satır metriği (etiket + değer + renk çubuğu)
class MetricRow extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0
  final Color color;
  final String? valueLabel;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(
              valueLabel ?? '${(value * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
