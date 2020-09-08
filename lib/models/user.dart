enum UserType { student, facult, guest }

class UserData {
  final String name, password, email;
  String uid, phone;
  final UserType type;

  UserData(
      {this.name, this.password, this.email, this.phone, this.type, this.uid});
}
