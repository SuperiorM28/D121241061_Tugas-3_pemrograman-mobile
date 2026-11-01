import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../theme/app_theme.dart';

class HealthAdviceCard extends StatelessWidget {
  final AirQuality airQuality;

  const HealthAdviceCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Saran & Rekomendasi Kesehatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            airQuality.recommendation,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTipItem(
                isDark: isDark,
                icon: Icons.masks_rounded,
                label: airQuality.aqi > 100 ? 'Pakai Masker' : 'Masker Opsional',
                isWarning: airQuality.aqi > 100,
              ),
              _buildTipItem(
                isDark: isDark,
                icon: Icons.window_rounded,
                label: airQuality.aqi > 100 ? 'Tutup Jendela' : 'Buka Ventilasi',
                isWarning: airQuality.aqi > 100,
              ),
              _buildTipItem(
                isDark: isDark,
                icon: Icons.directions_run_rounded,
                label: airQuality.aqi > 150 ? 'Hindari Olahraga' : 'Aman Olahraga',
                isWarning: airQuality.aqi > 150,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required bool isDark,
    required IconData icon,
    required String label,
    required bool isWarning,
  }) {
    final color = isWarning
        ? (isDark ? Colors.orange.shade300 : Colors.orange.shade800)
        : (isDark ? Colors.teal.shade300 : Colors.teal.shade700);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
