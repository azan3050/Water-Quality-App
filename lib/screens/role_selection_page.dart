import 'package:flutter/material.dart';
import 'package:sih_project/screens/admin/admin_login_page.dart';
import 'package:sih_project/l10n/app_localizations.dart';
import 'package:sih_project/screens/alerts/alerts_page.dart';
import 'package:sih_project/screens/asha_worker/asha_worker_login_page.dart';
import 'package:sih_project/screens/clinic/clinic_login_page.dart';
import 'package:sih_project/main.dart';


class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectYourRole),
        // --- ACTION ICONS ---
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.viewAlerts,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AlertsPage()),
              );
            },
          ),
          // --- NEW: LANGUAGE SELECTION MENU ---
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            //tooltip: l10n.changeLanguage,
            onSelected: (Locale locale) {
              MyApp.setLocale(context, locale);
            },
            itemBuilder: (BuildContext context) {
              return AppLocalizations.supportedLocales.map((Locale locale) {
                final String languageName;
                switch (locale.languageCode) {
                  case 'en':
                    languageName = 'English';
                    break;
                  case 'hi':
                    languageName = 'हिन्दी';
                    break;
                  case 'as':
                    languageName = 'অসমীয়া';
                    break;
                  default:
                    languageName = locale.languageCode;
                }
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Text(languageName),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
              
                  Icons.health_and_safety_outlined,
                  size: 80,
                  color: Colors.teal,
                
              ),
              const SizedBox(height: 20),
              Text(
                l10n.welcome,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildRoleButton(
                context,
                icon: Icons.admin_panel_settings_outlined,
                label: l10n.loginAsAdmin,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminLoginPage())),
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context,
                icon: Icons.health_and_safety_outlined,
                label: l10n.loginAsAshaWorker,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AshaWorkerLoginPage())),
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context,
                icon: Icons.local_hospital_outlined,
                label: l10n.loginAsClinic,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder:(context) => ClinicLoginPage(),)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
