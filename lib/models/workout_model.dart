class Workout {
  final int? id;
  final int userId;
  final String name;
  final String type;
  final int duration; // in minutes
  final int? caloriesBurned;
  final DateTime date;
  final DateTime createdAt;

  Workout({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    this.caloriesBurned,
    required this.date,
    required this.createdAt,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      type: map['type'],
      duration: map['duration'],
      caloriesBurned: map['calories_burned'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Workout copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    int? duration,
    int? caloriesBurned,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
