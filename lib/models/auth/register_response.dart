class RegisterResponse {
  final int id;
  final String username;
  final String email;

  RegisterResponse({
    required this.id,
    required this.username,
    required this.email,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}