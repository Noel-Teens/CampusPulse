import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final isVerified = authController.isVerified;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Campus ID"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isVerified
            ? _buildVerifiedState()
            : _buildVerificationForm(authController),
      ),
    );
  }

  Widget _buildVerifiedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 16),
          Text(
            "Verified!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Proceeding to dashboard..."),
        ],
      ),
    );
  }

  Widget _buildVerificationForm(AuthController authController) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Enter your campus credentials to link your account and verify your identity.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Campus Email",
              hintText: "you@college.edu",
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return "Required";
              if (!value.contains("@")) return "Invalid email";
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Create Password",
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) return "Min 6 characters";
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (authController.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await authController.linkEmailCredentials(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Verification link sent! Check your email.",
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                }
              },
              child: const Text("Verify & Continue"),
            ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await authController.reloadUser();
              if (!mounted) return;

              if (authController.isVerified) {
                // Wrapper handles navigation
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Email not yet verified. Please check your inbox.",
                    ),
                  ),
                );
              }
            },
            child: const Text("I have verified my email (Refresh Status)"),
          ),
        ],
      ),
    );
  }
}
