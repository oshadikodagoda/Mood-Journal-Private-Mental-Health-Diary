class Emotion {
  final int? id;
  final String name;

  Emotion({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'emotion_id': id,
      'name': name,
    };
  }

  factory Emotion.fromMap(Map<String, dynamic> map) {
    return Emotion(
      id: map['emotion_id'],
      name: map['name'],
    );
  }
}