import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/items/manual_add_item_screen.dart';
import 'package:frontend/widgets/user_item/user_item_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuOpen = false;

  void toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserItemProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userItemProvider = context.watch<UserItemProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isLeftHanded = authProvider.isLeftHanded;
    final highContrast = authProvider.highContrast;
    final isHapticsEnabled = authProvider.hapticsEnabled;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          userItemProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : userItemProvider.items.isEmpty
              ? Center(child: Text('No items found.', style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black)))
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: userItemProvider.items.length,
                itemBuilder: (context, index) {
                  final groupedItem = userItemProvider.items[index];
                  return UserItemBar(groupedItem: groupedItem);
                },
              ),
          
          if (_isMenuOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black.withValues(alpha: highContrast ? 0.6 : 0.3),
              ),
            ),
        ],
      ),

      floatingActionButtonLocation: isLeftHanded
        ? FloatingActionButtonLocation.startFloat
        : FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isLeftHanded ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) _buildExpansionMenu(context, isLeftHanded, highContrast, isHapticsEnabled),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            width: 60,
            child: FloatingActionButton(
              backgroundColor: highContrast 
                ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
                : theme.colorScheme.primary,
              elevation: highContrast ? 0 : 6,
              shape: CircleBorder(
                side: highContrast ? BorderSide(color: theme.brightness == Brightness.dark ? Colors.black : Colors.white, width: 2) : BorderSide.none
              ),
              onPressed: () { toggleMenu(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.add,
                color: highContrast
                  ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                  : theme.colorScheme.onPrimary,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionMenu(BuildContext context, bool isLeftHanded, bool highContrast, bool isHapticsEnabled) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 200,
      margin: EdgeInsets.only(
        right: isLeftHanded ? 0 : 10,
        left: isLeftHanded ? 10 : 0,
      ),
      decoration: BoxDecoration(
        color: highContrast
          ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
          : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highContrast ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black) : colorScheme.outline,
          width: highContrast ? 3.0 : 1.5,
        ),
        boxShadow: highContrast ? null : [
          const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuItem("Barcode", () {
            // TODO
            isHapticsEnabled ? HapticFeedback.lightImpact() : null;
          }, highContrast),
          Divider(
            height: 1,
            color: highContrast ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black) : colorScheme.outline,
            thickness: highContrast ? 2.5 : 1.5,
          ),
          _menuItem("Add Manually", () {
            toggleMenu();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManualAddItemScreen()),
            );
            isHapticsEnabled ? HapticFeedback.lightImpact() : null;
          }, highContrast),
        ],
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap, bool highContrast) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(fontWeight: highContrast ? FontWeight.bold : FontWeight.w600, fontSize: highContrast ? 18 : 16),
        ),
      ),
    );
  }
}