import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/recommendation_card.dart';
import 'camera_screen.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (result.emotion != null) ...[
                        _buildEmotionSection(context),
                        const SizedBox(height: 24),
                      ],
                      if (result.demographics != null) ...[
                        _buildDemographicsSection(context),
                        const SizedBox(height: 24),
                      ],
                      if (result.skin != null) ...[
                        _buildSkinSection(context),
                        const SizedBox(height: 24),
                      ],
                      _buildRecommendations(context),
                      const SizedBox(height: 24),
                      _buildScanAgainButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Analiz Sonuçları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Duygu Bölümü
  // ────────────────────────────────────────────
  Widget _buildEmotionSection(BuildContext context) {
    final emotion = result.emotion!;
    final color = AppColors.emotionColor(emotion.dominant);

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.mood,
            title: 'Duygu Durumu',
            iconColor: color,
          ),
          const SizedBox(height: 20),

          // ── Baskın duygu ──
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Center(
                  child: Text(emotion.emoji, style: const TextStyle(fontSize: 36)),
                ),
              ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emotion.dominantTr,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '%${emotion.dominantScore.toStringAsFixed(1)} güven',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // ── Duygu grafiği ──
          Text(
            'Tüm Duygular',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          ...emotion.sortedScores.map((e) => _EmotionBar(
                label: _emotionTr(e.key),
                value: e.value / 100,
                color: AppColors.emotionColor(e.key),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  // ────────────────────────────────────────────
  // Demografik Bölüm
  // ────────────────────────────────────────────
  Widget _buildDemographicsSection(BuildContext context) {
    final demo = result.demographics!;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.person_outline,
            title: 'Demografik Tahmin',
            iconColor: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Tahmini Yaş',
                  value: '${demo.age}',
                  icon: Icons.cake_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Cinsiyet',
                  value: demo.genderTr,
                  icon: Icons.wc_outlined,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.1, end: 0);
  }

  // ────────────────────────────────────────────
  // Cilt Analizi Bölümü
  // ────────────────────────────────────────────
  Widget _buildSkinSection(BuildContext context) {
    final skin = result.skin!;
    final typeColor = AppColors.skinTypeColor(skin.type);

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.face_retouching_natural,
            title: 'Cilt Analizi',
            iconColor: typeColor,
          ),
          const SizedBox(height: 20),

          // ── Cilt tipi + ton ──
          Row(
            children: [
              Expanded(
                child: _SkinTypeBadge(label: '${skin.typeTr} Cilt', color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SkinTypeBadge(label: '${skin.toneTr} Ton', color: AppColors.emotionSurprise),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Metrik gauge'lar ──
          Row(
            children: [
              Expanded(
                child: MetricGauge(
                  label: 'Nemlendirme',
                  value: skin.hydrationScore / 100,
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: MetricGauge(
                  label: 'Düzenlilik',
                  value: skin.uniformityScore / 100,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Detay satırları ──
          _SkinDetailRow(label: 'Doku Kalitesi', value: skin.textureQualityTr),
          _SkinDetailRow(label: 'Kızarıklık Seviyesi', value: skin.rednessLevelTr),
          _SkinDetailRow(label: 'Parlaklık', value: skin.brightness.toStringAsFixed(1)),

          const SizedBox(height: 16),

          // ── Küçük radar grafik ──
          SizedBox(
            height: 180,
            child: _buildRadarChart(skin),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRadarChart(SkinData skin) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        gridBorderData: BorderSide(color: Colors.white12, width: 1),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, _) {
          const titles = ['Nem', 'Düzenlilik', 'Doku', 'Parlaklık', 'Kızarıklık'];
          return RadarChartTitle(
            text: titles[index],
            angle: 0,
            positionPercentageOffset: 0.1,
          );
        },
        titleTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        dataSets: [
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: skin.hydrationScore.toDouble()),
              RadarEntry(value: skin.uniformityScore.toDouble()),
              RadarEntry(value: _textureToScore(skin.textureQuality)),
              RadarEntry(value: (skin.brightness / 255 * 100).clamp(0, 100)),
              RadarEntry(value: _rednessToScore(skin.rednessLevel)),
            ],
            fillColor: AppColors.primary.withOpacity(0.3),
            borderColor: AppColors.primary,
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
      ),
    );
  }

  double _textureToScore(String q) {
    switch (q) {
      case 'very smooth':
        return 90;
      case 'smooth':
        return 75;
      case 'normal':
        return 60;
      case 'slightly textured':
        return 40;
      default:
        return 20;
    }
  }

  double _rednessToScore(String r) {
    switch (r) {
      case 'low':
        return 85;
      case 'medium':
        return 55;
      default:
        return 25;
    }
  }

  // ────────────────────────────────────────────
  // Öneriler
  // ────────────────────────────────────────────
  Widget _buildRecommendations(BuildContext context) {
    final recs = result.recommendations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişisel Öneriler',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        if (recs.emotionTips.isNotEmpty)
          RecommendationCard(
            icon: Icons.mood,
            title: 'Duygu & Zihin',
            color: AppColors.emotionHappy,
            tips: recs.emotionTips,
          ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1, end: 0),
        if (recs.skinTips.isNotEmpty) ...[
          const SizedBox(height: 12),
          RecommendationCard(
            icon: Icons.face_retouching_natural,
            title: 'Cilt Bakımı',
            color: AppColors.accent,
            tips: recs.skinTips,
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
        ],
        if (recs.lifestyleTips.isNotEmpty) ...[
          const SizedBox(height: 12),
          RecommendationCard(
            icon: Icons.spa,
            title: 'Yaşam Tarzı',
            color: AppColors.secondary,
            tips: recs.lifestyleTips,
          ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.1, end: 0),
        ],
      ],
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        },
        icon: const Icon(Icons.camera_enhance),
        label: const Text('Yeniden Tara'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  static String _emotionTr(String e) {
    switch (e.toLowerCase()) {
      case 'happy':
        return 'Mutlu';
      case 'sad':
        return 'Üzgün';
      case 'angry':
        return 'Kızgın';
      case 'fear':
        return 'Korkmuş';
      case 'surprise':
        return 'Şaşkın';
      case 'disgust':
        return 'İğrenmiş';
      default:
        return 'Nötr';
    }
  }
}

// ────────────────────────────────────────────
// Alt widget'lar
// ────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgCardLight],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.15),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _EmotionBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ).animate().custom(
                  duration: 800.ms,
                  curve: Curves.easeOut,
                  builder: (_, v, child) => child!,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SkinTypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SkinTypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SkinDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _SkinDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
