class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  int? idAkun;
  String? username;
  String? email;

  void setUser({
    required int idAkun,
    required String? username,
    required String? email,
  }) {
    this.idAkun = idAkun;
    this.username = username;
    this.email = email;

    print("[UserSession] SET → idAkun=$idAkun username=$username");
  }

  void clear() {
    print("[UserSession] CLEARED");

    idAkun = null;
    username = null;
    email = null;
  }
}
