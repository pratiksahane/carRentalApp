import 'package:carrentalapp/mainlayout.dart';
import 'package:carrentalapp/signuppage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Title
              Text(
                'Zymo',
                style: GoogleFonts.dancingScript(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 40),

              // Username Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword 
                        ? Icons.visibility_off 
                        : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 30),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleSignIn,
                  child: const Text("SIGN IN"),
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Signuppage(),
                        ),
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
   Future<void> _handleSignIn() async {
  final username = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Validate input fields
  if (username.isEmpty || password.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter both email and password')),
    );
    return;
  }

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Attempt sign in
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: username,
      password: password,
    );

    // Dismiss loading indicator
    if (mounted) Navigator.of(context).pop();

    // Check if email is verified (optional)
    if (userCredential.user?.emailVerified ?? false) {
      if (!mounted) return;
      
      // Navigate to home page on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout())
      );
    } else {
      if (!mounted) return;
      
      // Optional: Handle unverified email case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first')),
      );
      await FirebaseAuth.instance.signOut();
    }

  } on FirebaseAuthException catch (e) {
    // Dismiss loading indicator if still mounted
    if (mounted) Navigator.of(context).pop();

    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      case 'invalid-email':
        errorMessage = 'Please enter a valid email address';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again later';
        break;
      default:
        errorMessage = 'Login failed. Please try again';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    // Dismiss loading indicator if still mounted
    if (mounted) Navigator.of(context).pop();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }
    debugPrint('Sign in error: $e');
  }
}

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: const Text("Enter your username to receive a password reset link"),
        actions: [
          TextField(
            decoration: InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add password reset logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset link sent (demo)')),
                  );
                },
                child: const Text("Send Link"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}