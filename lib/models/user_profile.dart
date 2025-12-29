class UserProfile {
  final String username;
  final String email;
  final String householdCode;
  final String memberSince;
  final int itemsRescued;
  final int itemsExpired;

  UserProfile({
    required this.username,
    required this.email,
    required this.householdCode,
    required this.memberSince,
    required this.itemsRescued,
    required this.itemsExpired,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      householdCode: json['householdCode'],
      memberSince: json['memberSince'],
      itemsRescued: json['itemsRescued'],
      itemsExpired: json['itemsExpired'],
    );
  }
}