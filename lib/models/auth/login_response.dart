class LoginResponse {
  final String token;
  final String username;
  String? householdCode;

  LoginResponse({
    required this.token,
    required this.username,
    this.householdCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      username: json['username'] ?? "",
      householdCode: json['householdCode'],
    );
  }
}