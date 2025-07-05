class UserProfileData {
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String goal;

  UserProfileData({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
  });

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
    };
  }

  factory UserProfileData.fromMap(Map<String, dynamic> map) {
    return UserProfileData(
      gender: map['gender'],
      age: map['age'],
      height: map['height'],
      weight: map['weight'],
      goal: map['goal'],
    );
  }
}
