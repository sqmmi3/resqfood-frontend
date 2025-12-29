import 'package:flutter/material.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:provider/provider.dart';

class ImpactStatsScreen extends StatelessWidget {
  const ImpactStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : null,
      appBar: AppBar(
        title: const Text("My ResQ Impact"),
        centerTitle: true,
      ),
      body: FutureBuilder<UserProfile>(
        future: AuthService().fetchProfile(authProvider.token ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading stats: ${snapshot.error}"));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStatHero(
                  "Items Rescued",
                  stats.itemsRescued.toString(),
                  Icons.eco,
                  Colors.green,
                  highContrast,
                  contrastColor,
                ),
                const SizedBox(height: 20),
                _buildStatHero(
                  "Expired Items",
                  stats.itemsExpired.toString(),
                  Icons.delete_outline,
                  Colors.redAccent,
                  highContrast,
                  contrastColor,
                ),
                const SizedBox(height: 30),
                _buildEnvironmentalImpactCard(stats.itemsRescued, highContrast, isDark, contrastColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatHero(String label, String value, IconData icon, Color color, bool hc, Color cc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: hc ? cc : color.withValues(alpha: 0.5), width: hc ? 3 : 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 40, color: hc ? cc : color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: hc ? cc : null)),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(int rescued, bool hc, bool isDark, Color cc) {
    double co2Saved = rescued * 2.1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hc ? (isDark ? Colors.black : Colors.white) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: hc ? Border.all(color: cc, width: 2) : null,
      ),
      child: Column(
        children: [
          Icon(Icons.language, color: hc ? cc : Colors.green, size: 30),
          const SizedBox(height: 10),
          Text(
            "By rescuing $rescued items, you've prevented approximately ${co2Saved.toStringAsFixed(1)}kg of CO2 emissions!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, 
              color: hc ? cc : Colors.green.shade900,
              fontWeight: hc ? FontWeight.bold : FontWeight.normal
            ),
          ),
        ],
      ),
    );
  }
}