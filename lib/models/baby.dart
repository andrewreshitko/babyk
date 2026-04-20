class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;

  const Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
      };

  factory Baby.fromJson(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        gender: json['gender'] as String,
      );
}
