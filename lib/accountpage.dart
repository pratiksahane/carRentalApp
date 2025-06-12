import 'package:carrentalapp/signuppage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Accountpage extends StatefulWidget {
  const Accountpage({super.key});

  @override
  State<Accountpage> createState() => _AccountpageState();
}

class _AccountpageState extends State<Accountpage> {
  bool _isLoading = false;

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Signuppage()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                  Navigator.of(context).pop();
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.email?.replaceAll("@gmail.com", "") ?? "Guest";

    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage("https://tse2.mm.bing.net/th/id/OIP.oWs7z9rWjcaLEdUW4_ddbQHaI8?rs=1&pid=ImgDetMain"),
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user?.email != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user!.email!,
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: user.email!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildProfileHeader(),
            ),
            const Divider(height: 1),
            _buildMenuButton(
              'My Bookings',
              Icons.calendar_today,
              () {
                // Navigate to bookings page
              },
            ),
            const Divider(height: 1),
            _buildMenuButton(
              'Payment Methods',
              Icons.payment,
              () {
                // Navigate to payment methods
              },
            ),
            const Divider(height: 1),
            _buildMenuButton(
              'Favorites',
              Icons.favorite_border,
              () {
                // Navigate to favorites
              },
            ),
            const Divider(height: 1),
            _buildMenuButton(
              'Help Center',
              Icons.help_outline,
              () {
                // Navigate to help center
              },
            ),
            const Divider(height: 1),
            _buildMenuButton(
              'Settings',
              Icons.settings,
              () {
                // Navigate to settings
              },
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Version',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}