class HouseholdDetails {
  final String inviteCode;
  final List<String> members;

  HouseholdDetails({
    required this.inviteCode,
    required this.members,
  });

  factory HouseholdDetails.fromJson(Map<String, dynamic> json) {
    return HouseholdDetails(
      inviteCode: json['inviteCode'],
      members: List<String>.from(json['members']),
    );
  }
}