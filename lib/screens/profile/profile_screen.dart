import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      setState(() {
        _profileFuture = AuthService().fetchProfile(token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final isHapticsEnabled = authProvider.hapticsEnabled;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color contrastColor = isDark ? Colors.white : Colors.black;
    final Color bgColor = highContrast 
        ? (isDark ? Colors.black : Colors.white) 
        : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: highContrast ? contrastColor : theme.colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isHapticsEnabled) HapticFeedback.lightImpact();
          _loadProfile();
          await _profileFuture;
        },
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString(), highContrast, contrastColor);
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No data found"));
            }

            final profile = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: highContrast ? contrastColor : theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person, 
                          size: 60, 
                          color: highContrast ? (isDark ? Colors.black : Colors.white) : theme.colorScheme.primary
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.username,
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: highContrast ? contrastColor : null
                        ),
                      ),
                      Text(
                        profile.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                _buildInfoCard(
                  context,
                  title: "Account Information",
                  highContrast: highContrast,
                  isDark: isDark,
                  items: [
                    _InfoRow(
                      label: "Household Code", 
                      value: profile.householdCode,
                      icon: Icons.home_work_rounded,
                    ),
                    _InfoRow(
                      label: "Member Since", 
                      value: profile.memberSince,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildInfoCard(
                  context,
                  title: "Your ResQ Impact",
                  highContrast: highContrast,
                  isDark: isDark,
                  items: [
                    _InfoRow(
                      label: "Items Rescued", 
                      value: "${profile.itemsRescued}", 
                      icon: Icons.eco_rounded, 
                      iconColor: Colors.green
                    ),
                    _InfoRow(
                      label: "Currently Expired", 
                      value: "${profile.itemsExpired}", 
                      icon: Icons.warning_amber_rounded, 
                      iconColor: Colors.red
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                TextButton.icon(
                  onPressed: () => _handleLogout(context, authProvider),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("Logout of ResQFood", style: TextStyle(color: Colors.red)),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required String title, 
    required List<_InfoRow> items, 
    required bool highContrast,
    required bool isDark,
  }) {
    final Color textColor = highContrast ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white70 : Colors.black87);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highContrast ? (isDark ? Colors.black : Colors.white) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highContrast ? (isDark ? Colors.white : Colors.black) : Colors.grey.withValues(alpha: 0.2),
          width: highContrast ? 2.5 : 1,
        ),
        boxShadow: highContrast ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)
          ),
          const Divider(height: 24),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(item.icon, color: item.iconColor ?? (isDark ? Colors.white70 : Colors.black54), size: 22),
                const SizedBox(width: 12),
                Text(item.label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                const Spacer(),
                Text(
                  item.value, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool highContrast, Color contrastColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text("Failed to load profile", style: TextStyle(fontWeight: FontWeight.bold, color: highContrast ? contrastColor : null)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _loadProfile, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final isHapticsEnabled = authProvider.hapticsEnabled;
    if (isHapticsEnabled) HapticFeedback.mediumImpact();
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  _InfoRow({required this.label, required this.value, required this.icon, this.iconColor});
}