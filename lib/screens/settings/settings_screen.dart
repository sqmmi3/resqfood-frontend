import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/services/household/household_service.dart';
import 'package:frontend/widgets/message_dialog.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HouseholdService _householdService = HouseholdService();
  late TextEditingController _joinCodeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _joinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateHousehold() async {
    setState(() => _isLoading = true);
    try {
      final String code = await _householdService.createHousehold();
      if (mounted) {
        context.read<AuthProvider>().updateHouseholdCode(code);
        MessageDialog.show(context, message: "Household created! Item sharing is now active.");
        Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoinHousehold(String code) async {
    if (code.length < 6) return;

    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      await _householdService.joinHousehold(code);
      if (mounted) {
        context.read<AuthProvider>().updateHouseholdCode(code);
        MessageDialog.show(context, message: "Successfully joined household!");
        Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceAll("Exception: ", "")), backgroundColor: Colors.red),
    );
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String? householdCode = authProvider.user?.householdCode;
    final bool isInHousehold = householdCode != null;
    final bool highContrast = authProvider.highContrast;
    final bool isHapticsEnabled = authProvider.hapticsEnabled;
    final bool isLeft = authProvider.isLeftHanded;

    return Scaffold(
      backgroundColor: highContrast ? Colors.white : Colors.grey[50],
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader("Sharing & Household"),
              const SizedBox(height: 12),
              if (!isInHousehold) ...[
                _buildActionCard(
                  title: "Create Household",
                  subtitle: "Start a shared inventory with others",
                  icon: Icons.add_home_rounded,
                  color: Colors.green,
                  onTap: () { _handleCreateHousehold; isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
                  highContrast: highContrast,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  title: "Join Household",
                  subtitle: "Enter a code from a housemate",
                  icon: Icons.group_add_rounded,
                  color: Colors.blue,
                  onTap: () { _showJoinBottomSheet(context, isHapticsEnabled); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
                  highContrast: highContrast,
                ),
              ] else ...[
                _buildHouseholdActiveCard(householdCode, highContrast, isHapticsEnabled),
              ],

              const SizedBox(height: 32),
              _buildSectionHeader("Preferences"),
              SwitchListTile(
                secondary: Icon(Icons.back_hand_rounded, color: highContrast ? Colors.black : Colors.orange),
                title: Text("Left-Handed Mode", style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
                subtitle: const Text("Moves primary buttons to the left side"),
                value: isLeft,
                activeThumbColor: highContrast ? Colors.black : Colors.green,
                controlAffinity: isLeft
                  ? ListTileControlAffinity.leading
                  : ListTileControlAffinity.trailing,
                onChanged: (val) {
                  authProvider.setHandedness(isLeft: val);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),

              SwitchListTile(
                secondary: Icon(Icons.dark_mode, color: highContrast ? Colors.black : Colors.deepPurple),
                title: Text("Dark Mode", style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
                subtitle: const Text("Turns application to dark coloured environment"),
                value: authProvider.themeMode == ThemeMode.dark,
                activeThumbColor: highContrast ? Colors.black : Colors.green,
                controlAffinity: isLeft
                  ? ListTileControlAffinity.leading
                  : ListTileControlAffinity.trailing,
                onChanged: (val) { 
                  authProvider.setThemeMode(val);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),

              SwitchListTile(
                secondary: Icon(Icons.remove_red_eye_rounded, color: highContrast ? Colors.black : Colors.blue),
                title: Text("High Contrast Mode", style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
                subtitle: const Text("Adds icons for colorblind-friendly status"),
                value: authProvider.highContrast,
                activeThumbColor: highContrast ? Colors.black : Colors.green,
                controlAffinity: isLeft
                  ? ListTileControlAffinity.leading
                  : ListTileControlAffinity.trailing,
                onChanged: (val) {
                  authProvider.setHighContrast(val);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),

              SwitchListTile(
                secondary: Icon(Icons.vibration, color: highContrast ? Colors.black : Colors.blueGrey),
                title: Text("Touch Feedback", style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
                subtitle: const Text("Vibrate on actions"),
                value: authProvider.hapticsEnabled,
                activeThumbColor: highContrast ? Colors.black : Colors.green,
                controlAffinity: isLeft ? ListTileControlAffinity.leading : ListTileControlAffinity.trailing,
                onChanged: (val) { 
                  authProvider.setHaptics(val);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                }
              ),

              SwitchListTile(
                secondary: Icon(Icons.record_voice_over_rounded, color: highContrast ? Colors.black : Colors.purple),
                title: Text("Enhanced Screen Reader", style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
                subtitle: const Text("Optimizes descriptions for Talkback/VoiceOver"),
                value: authProvider.isHighVerbosity,
                activeThumbColor: highContrast ? Colors.black : Colors.green,
                controlAffinity: isLeft 
                    ? ListTileControlAffinity.leading 
                    : ListTileControlAffinity.trailing,
                onChanged: (val) {
                  authProvider.setHighVerbosity(val);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),

              ListTile(
                leading: isLeft ? const Icon(Icons.chevron_left) : const Icon(Icons.format_size),
                trailing: isLeft ? const Icon(Icons.format_size) : const Icon(Icons.chevron_right),
                title: Text("Font Size", textAlign: isLeft ? TextAlign.right : TextAlign.left),
                onTap: () {
                  _showFontSizePicker(context, authProvider);
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),

              const SizedBox(height: 32),
              _buildSectionHeader("Account"),
              ListTile(
                leading:Icon(Icons.logout, color: highContrast ? Colors.black : Colors.red),
                title: Text("Logout", style: TextStyle(color: highContrast ? Colors.black : Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  context.read<UserItemProvider>().reset();
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                  isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                },
              ),
            ],
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap, required bool highContrast}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highContrast ? Colors.white : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highContrast ? Colors.black : color.withValues(alpha: 0.2),
            width: highContrast ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: highContrast ? Colors.black : color, child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: highContrast ? Colors.black : Colors.grey[700])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: highContrast ? Colors.black : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdActiveCard(String code, bool highContrast, bool isHapticsEnabled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: highContrast ? Colors.black : Colors.green,
        borderRadius: BorderRadius.circular(24),
        border: highContrast ? Border.all(color: Colors.black, width: 3) : null,
        boxShadow: [BoxShadow(color: highContrast ? Colors.black : Colors.green.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Text("YOUR HOUSEHOLD CODE", style: TextStyle(color: highContrast ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 6),
          ),
          const SizedBox(height: 12),
          const Text("Share this with people you live with", style: TextStyle(color: Colors.white, fontSize: 12)),
          const Divider(height: 32, color: Colors.white24),
          TextButton(
            onPressed: () { _handleLeaveHousehold(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
            child: Text("Leave Household", style: TextStyle(color: highContrast ? Colors.white : Colors.white70, fontSize: 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
          )
        ],
      ),
    );
  }

  void _showJoinBottomSheet(BuildContext context, bool isHapticsEnabled) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24, right: 24, top: 12
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            const Text("Join Household", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _joinCodeController,
              autofocus: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: "ABC123",
                hintStyle: TextStyle(color: Colors.grey[300]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16))),
                onPressed: () { _handleJoinHousehold(_joinCodeController.text); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
                child: const Text("Join Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }

  Future<void> _handleLeaveHousehold() async {
    setState(() => _isLoading = true);
    try {
      await _householdService.leaveHousehold();
      if (mounted) {
        context.read<AuthProvider>().updateHouseholdCode(null);
        MessageDialog.show(context, message: "Successfully left the household!");
        Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFontSizePicker(BuildContext context, AuthProvider authProvider) {
    final bool highContrast = authProvider.highContrast;

    showModalBottomSheet(
      context: context,
      backgroundColor: highContrast ? Colors.white : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4, width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Adjust Font Size", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Reset to default",
                        onPressed: () {
                          authProvider.setFontSize(1.0);
                          setModalState(() {});
                          HapticFeedback.mediumImpact();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: highContrast ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                    child: Text(
                      "This is how your text will look.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16 * authProvider.fontSizeFactor,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Slider(
                    value: authProvider.fontSizeFactor,
                    min: 0.5,
                    max: 1.6,
                    divisions: 20,
                    activeColor: Colors.green,
                    inactiveColor: Colors.green.withValues(alpha: 0.2),
                    label: "${(authProvider.fontSizeFactor * 100).toInt()}%",
                    onChanged: (double value) {
                      authProvider.setFontSize(value);
                      setModalState(() {});
                      if (authProvider.hapticsEnabled) HapticFeedback.selectionClick();
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("A", style: TextStyle(fontSize: 12)),
                        Text("A", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}