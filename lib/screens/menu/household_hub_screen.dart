import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/household_details.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/services/household/household_service.dart';
import 'package:frontend/widgets/message_dialog.dart';
import 'package:provider/provider.dart';

class HouseholdHubScreen extends StatefulWidget {
  const HouseholdHubScreen({super.key});

  @override
  State<HouseholdHubScreen> createState() => _HouseholdHubScreenState();
}

class _HouseholdHubScreenState extends State<HouseholdHubScreen> {
  late Future<HouseholdDetails> _householdFuture;
  final HouseholdService _householdService = HouseholdService();

  @override
  void initState() {
    super.initState();
    _loadHousehold();
  }

  void _loadHousehold() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      setState(() {
        _householdFuture = _householdService.fetchMyHousehold(token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : null,
      appBar: AppBar(
        backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : Theme.of(context).colorScheme.primary,
        title: Text("Household Hub", style: TextStyle(fontWeight: FontWeight.bold, color: highContrast ? (isDark ? Colors.white : Colors.black) : Colors.white70 )),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: highContrast 
              ? (isDark ? Colors.white : Colors.black) 
              : Colors.white70,
        ),
      ),
      body: FutureBuilder<HouseholdDetails>(
        future: _householdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError) {
            return _buildNoHouseholdState(highContrast, contrastColor);
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Invite Code", highContrast, contrastColor),
                const SizedBox(height: 12),
                _buildInviteCard(data.inviteCode, highContrast, isDark, contrastColor),
                const SizedBox(height: 40),
                _buildSectionHeader("Household Members (${data.members.length})", highContrast, contrastColor),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: data.members.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isDark ? Colors.grey[800] : Colors.green[100],
                        child: Icon(Icons.person, color: highContrast ? contrastColor : Colors.green),
                      ),
                      title: Text(
                        data.members[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: highContrast ? contrastColor : null,
                        ),
                      ),
                      trailing: data.members[index] == authProvider.user?.username 
                          ? const Text("(Me)", style: TextStyle(color: Colors.grey)) 
                          : null,
                    ),
                  ),
                ),
                _buildLeaveButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool highContrast, Color contrastColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: highContrast ? contrastColor : Colors.green[800]
      ),
    );
  }

  Widget _buildInviteCard(String code, bool highContrast, bool isDark, Color contrastColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highContrast ? (isDark ? Colors.black : Colors.white) : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highContrast ? contrastColor : Colors.green.shade200, 
          width: highContrast ? 2.5 : 1.5
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            code,
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 4, 
              color: highContrast ? contrastColor : Colors.green[700]
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded, color: highContrast ? contrastColor : Colors.green),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Code copied to clipboard!")),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildNoHouseholdState(bool highContrast, Color contrastColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              "Not in a Household",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: highContrast ? contrastColor : null),
            ),
            const SizedBox(height: 12),
            const Text(
              "Join a household using an invite code or create a new one to start sharing your fridge!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveButton(BuildContext context, AuthProvider authProvider) {
    final bool isHapticsEnabled = authProvider.hapticsEnabled;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {
            _handleLeaveHousehold();
            isHapticsEnabled ? HapticFeedback.lightImpact() : null;
          },
          icon: const Icon(Icons.exit_to_app),
          label: const Text("Leave Household", style: TextStyle(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLeaveHousehold() async {
    try {
      await _householdService.leaveHousehold();
      if (mounted) {
        context.read<AuthProvider>().updateHouseholdCode(null);
        MessageDialog.show(context, message: "Successfully left the household!");
        Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceAll("Exception: ", "")), backgroundColor: Colors.red),
    );
    debugPrint(message);
  }
}