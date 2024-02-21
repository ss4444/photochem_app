class RegUser{
  String? last_name;
  String? name;
  String? username;
  String? password;
  bool? is_admin;

  RegUser({ required this.username, required this.password, required this.last_name, required this.is_admin, required this.name});
}