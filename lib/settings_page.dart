import 'package:knotwork/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:knotwork/components/button.dart';
import 'package:knotwork/policies_page.dart';
import 'package:provider/provider.dart';
import 'package:knotwork/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool enableNotifications = true;
  bool incognitoMode = false;
  bool autoLogout = false;
  String notificationPosition = "Top-Right";

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Yeshaya!"),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Placeholder()));
          },
          icon: const Icon(Icons.person),
        )
      ]),
      body: ListView(
        children: [
          // General Settings
          _buildSectionHeader("General"),
          _buildDropdownTile(
            "Theme Mode",
            themeProvider.themeMode.toString().split('.').last,
            ["system", "light", "dark"],
            (value) {
              if (value != null) {
                themeProvider.setTheme(
                  AppThemeMode.values.firstWhere(
                    (e) => e.toString().split('.').last == value,
                    orElse: () => AppThemeMode.system,
                  ),
                );
              }
            },
          ),

          // Notifications & Alerts
          _buildSectionHeader("Notifications & Alerts"),
          _buildSwitchTile("Enable Notifications", enableNotifications,
              (value) {
            setState(() => enableNotifications = value);
          }),
          _buildDropdownTile(
            "Notification Position",
            notificationPosition,
            ["Top-Right", "Bottom-Left", "Center"],
            (value) => setState(() => notificationPosition = value!),
          ),

          // Security & Privacy
          _buildSectionHeader("Security & Privacy"),
          _buildSwitchTile("Incognito Mode", incognitoMode, (value) {
            setState(() => incognitoMode = value);
          }),

          _buildButtonTile(
              "Policies",
              () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PoliciesPage()))),

          _buildSwitchTile("Auto Logout", autoLogout, (value) {
            setState(() => autoLogout = value);
          }),

          // logout
          _buildButtonTile("Log out", () => logout(context)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> options,
      Function(String?) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildButtonTile(String value, VoidCallback action) {
    return SquircleButton(onTap: action, title: value);
  }
}
