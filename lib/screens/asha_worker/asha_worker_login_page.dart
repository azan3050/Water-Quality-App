import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sih_project/l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import 'asha_worker_home_page.dart';
import 'asha_worker_signup_page.dart';

class AshaWorkerLoginPage extends StatefulWidget {
  const AshaWorkerLoginPage({super.key});

  @override
  _AshaWorkerLoginPageState createState() => _AshaWorkerLoginPageState();
}

class _AshaWorkerLoginPageState extends State<AshaWorkerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = await _authService.signInWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          // For ASHA workers, we check the 'users' collection for their role
          bool isAshaWorker =
              await _authService.checkUserRole(user.uid, 'users');
          if (isAshaWorker) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const AshaWorkerHomePage()),
            );
          } else {
            await _authService.signOut();
            if (mounted) _showErrorDialog(AppLocalizations.of(context)!.accessDeniedNotAsha);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) _showErrorDialog(e.message ?? AppLocalizations.of(context)!.anUnknownErrorOccurred);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loginFailed),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.okay),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ashaWorkerLogin)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(l10n.ashaWorkerPortal,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return l10n.pleaseEnterAValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return l10n.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text(l10n.login),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AshaWorkerSignUpPage()),
                    );
                  },
                  child: Text(l10n.dontHaveAnAccountSignUp),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
