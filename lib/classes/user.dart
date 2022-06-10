class User {
  final String id;
  final String name;
  final String user_country;
  final String birth_date;
  final String gender;
  final String email;
  final String join_date;

  const User(
      {required this.id,
      required this.name,
      required this.user_country,
      required this.birth_date,
      required this.gender,
      required this.email,
      required this.join_date});

  static User fromJson(json) => User(
      id: json['id'],
      name: json['name'],
      user_country: json['user_country'],
      birth_date: json['birth_date'],
      gender: json['gender'],
      email: json['email'],
      join_date: json['join_date']);
}
