import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../theme/app_theme.dart';

class PollutantGrid extends StatelessWidget {
  final AirQuality airQuality;

  const PollutantGrid({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> items = [
      {
        'title': 'PM 2.5',
        'value': airQuality.pm25 != null ? '${airQuality.pm25!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Partikel Halus',
        'icon': Icons.grain_rounded,
        'color': Colors.indigo,
      },
      {
        'title': 'PM 10',
        'value': airQuality.pm10 != null ? '${airQuality.pm10!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Partikel Kasar',
        'icon': Icons.blur_on_rounded,
        'color': Colors.teal,
      },
      {
        'title': 'O3 (Ozon)',
        'value': airQuality.o3 != null ? '${airQuality.o3!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Ozon Permukaan',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.amber.shade800,
      },
      {
        'title': 'NO2',
        'value': airQuality.no2 != null ? '${airQuality.no2!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Nitrogen Dioksida',
        'icon': Icons.electric_bolt_rounded,
        'color': Colors.deepOrange,
      },
      {
        'title': 'SO2',
        'value': airQuality.so2 != null ? '${airQuality.so2!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Belerang Dioksida',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.purple,
      },
      {
        'title': 'CO',
        'value': airQuality.co != null ? '${airQuality.co!.toStringAsFixed(1)} µg/m³' : '-',
        'desc': 'Karbon Monoksida',
        'icon': Icons.directions_car_rounded,
        'color': Colors.blueGrey,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Parameter Polutan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final Color baseColor = item['color'] as Color;
            // Warna dicerahkan di dark mode agar kontras tetap baik
            final Color itemColor = isDark
                ? Color.lerp(baseColor, Colors.white, 0.35)!
                : baseColor;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(
                    color: c.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: c.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: itemColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item['value'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: itemColor,
                    ),
                  ),
                  Text(
                    item['desc'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
