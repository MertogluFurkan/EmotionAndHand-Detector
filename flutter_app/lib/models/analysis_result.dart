/// AuraScan analiz sonuçlarını temsil eden modeller

class EmotionData {
  final String dominant;
  final Map<String, double> scores;

  const EmotionData({required this.dominant, required this.scores});

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'] as Map<String, dynamic>? ?? {};
    return EmotionData(
      dominant: json['dominant'] as String? ?? 'neutral',
      scores: rawScores.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  String get emoji {
    switch (dominant.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'fear':
        return '😨';
      case 'surprise':
        return '😮';
      case 'disgust':
        return '🤢';
      default:
        return '😐';
    }
  }

  String get dominantTr {
    switch (dominant.toLowerCase()) {
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

  double get dominantScore => scores[dominant] ?? 0.0;

  /// En yüksek skordan küçüğe sıralı duygu listesi
  List<MapEntry<String, double>> get sortedScores {
    final entries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}

class Demographics {
  final int age;
  final String gender;

  const Demographics({required this.age, required this.gender});

  factory Demographics.fromJson(Map<String, dynamic> json) => Demographics(
        age: (json['age'] as num?)?.toInt() ?? 0,
        gender: json['gender'] as String? ?? 'Unknown',
      );

  String get genderTr {
    switch (gender.toLowerCase()) {
      case 'man':
      case 'male':
        return 'Erkek';
      case 'woman':
      case 'female':
        return 'Kadın';
      default:
        return gender;
    }
  }
}

class SkinData {
  final String type;
  final String tone;
  final String textureQuality;
  final String rednessLevel;
  final double brightness;
  final double rednessScore;
  final double textureScore;
  final int hydrationScore;
  final int uniformityScore;

  const SkinData({
    required this.type,
    required this.tone,
    required this.textureQuality,
    required this.rednessLevel,
    required this.brightness,
    required this.rednessScore,
    required this.textureScore,
    required this.hydrationScore,
    required this.uniformityScore,
  });

  factory SkinData.fromJson(Map<String, dynamic> json) => SkinData(
        type: json['type'] as String? ?? 'normal',
        tone: json['tone'] as String? ?? 'medium',
        textureQuality: json['texture_quality'] as String? ?? 'normal',
        rednessLevel: json['redness_level'] as String? ?? 'low',
        brightness: (json['brightness'] as num?)?.toDouble() ?? 128,
        rednessScore: (json['redness_score'] as num?)?.toDouble() ?? 0,
        textureScore: (json['texture_score'] as num?)?.toDouble() ?? 0,
        hydrationScore: (json['hydration_score'] as num?)?.toInt() ?? 50,
        uniformityScore: (json['uniformity_score'] as num?)?.toInt() ?? 50,
      );

  String get typeTr {
    switch (type.toLowerCase()) {
      case 'oily':
        return 'Yağlı';
      case 'dry':
        return 'Kuru';
      case 'combination':
        return 'Karma';
      default:
        return 'Normal';
    }
  }

  String get toneTr {
    switch (tone.toLowerCase()) {
      case 'fair':
        return 'Açık';
      case 'light':
        return 'Hafif Açık';
      case 'medium':
        return 'Orta';
      case 'tan':
        return 'Esmer';
      case 'deep':
        return 'Koyu';
      default:
        return tone;
    }
  }

  String get textureQualityTr {
    switch (textureQuality.toLowerCase()) {
      case 'very smooth':
        return 'Çok Pürüzsüz';
      case 'smooth':
        return 'Pürüzsüz';
      case 'slightly textured':
        return 'Hafif Dokulu';
      case 'textured':
        return 'Dokulu';
      default:
        return 'Normal';
    }
  }

  String get rednessLevelTr {
    switch (rednessLevel.toLowerCase()) {
      case 'high':
        return 'Yüksek';
      case 'medium':
        return 'Orta';
      default:
        return 'Düşük';
    }
  }
}

class Recommendations {
  final List<String> emotionTips;
  final List<String> skinTips;
  final List<String> lifestyleTips;

  const Recommendations({
    required this.emotionTips,
    required this.skinTips,
    required this.lifestyleTips,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) => Recommendations(
        emotionTips: _toStringList(json['emotion_tips']),
        skinTips: _toStringList(json['skin_tips']),
        lifestyleTips: _toStringList(json['lifestyle_tips']),
      );

  static List<String> _toStringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }
}

class AnalysisResult {
  final EmotionData? emotion;
  final Demographics? demographics;
  final SkinData? skin;
  final Recommendations recommendations;
  final DateTime timestamp;

  AnalysisResult({
    this.emotion,
    this.demographics,
    this.skin,
    required this.recommendations,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        emotion: json['emotion'] != null
            ? EmotionData.fromJson(json['emotion'] as Map<String, dynamic>)
            : null,
        demographics: json['demographics'] != null
            ? Demographics.fromJson(json['demographics'] as Map<String, dynamic>)
            : null,
        skin: json['skin'] != null
            ? SkinData.fromJson(json['skin'] as Map<String, dynamic>)
            : null,
        recommendations: Recommendations.fromJson(
          json['recommendations'] as Map<String, dynamic>? ?? {},
        ),
      );
}
