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

class Patient extends User {
  final String? request_doctor_id;
  final String? doctor_id;

  const Patient(
      {required this.request_doctor_id,
      required this.doctor_id,
      required id,
      required name,
      required user_country,
      required birth_date,
      required gender,
      required email,
      required join_date})
      : super(
          id: id,
          name: name,
          user_country: user_country,
          birth_date: birth_date,
          gender: gender,
          email: email,
          join_date: join_date,
        );

  static Patient fromJson(json) => Patient(
        id: json['id'],
        name: json['name'],
        user_country: json['user_country'],
        birth_date: json['birth_date'],
        gender: json['gender'],
        email: json['email'],
        join_date: json['join_date'],
        doctor_id: json['doctor_id'],
        request_doctor_id: json['request_doctor_id'],
      );
}
