import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';

class VibeCard extends StatelessWidget {
  final AnalysisResult result;

  const VibeCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Emoji
                Text(
                  result.vibeEmoji,
                  style: const TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 16),
                // Vibe Type
                Text(
                  result.vibeType,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Energy badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.energy,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  result.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Roast section
                if (result.roast.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                Colors.orange.shade900.withOpacity(0.3),
                                Colors.pink.shade900.withOpacity(0.3),
                              ]
                            : [
                                Colors.orange.shade50,
                                Colors.pink.shade50,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryPink.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🔥 ROAST 🔥',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.roast,
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Red & Green Flags
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Red Flags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('🚩', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Text(
                                'Red Flags',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...result.redFlags.map((flag) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $flag',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                height: 1.4,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Green Flags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('💚', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Text(
                                'Green Flags',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...result.greenFlags.map((flag) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $flag',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                                height: 1.4,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Traits
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: result.traits.map((trait) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryPink.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          trait,
                          style: const TextStyle(
                            color: AppTheme.primaryPink,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Compatibility
                if (result.compatibility.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.purple.shade900.withOpacity(0.3)
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? Border.all(color: Colors.purple.shade700.withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Text('💕', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.compatibility,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Branding
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Profile Whisperer',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
