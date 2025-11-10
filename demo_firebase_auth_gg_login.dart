import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final photoUrl = user.photoURL ?? 'https://via.placeholder.com/150';
    final displayName = user.displayName ?? 'Người dùng Google';
    final email = user.email ?? 'email@hidden.com';

    return Scaffold(
      appBar: AppBar(title: const Text("TRANG CHỦ"), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundImage: NetworkImage(photoUrl)),
            const SizedBox(height: 20),
            Text("$displayName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(fontSize: 18)),
            Text("UID: ${user.uid}", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text("ĐĂNG XUẤT"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);

    if (!mounted) return;

    try {
      final googleSignIn = GoogleSignIn(
        clientId: "1037305218991-6i0me3lpvo4dakajrf3ln1ljf2a6238q.apps.googleusercontent.com",
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();

      // Check mounted sau mỗi await
      if (!mounted) return;
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (!mounted) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Check mounted trước khi dùng context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    } finally {
      // Check mounted trước khi setState
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Đang đăng nhập..."),
                ],
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata, size: 40),
                label: const Text("ĐĂNG NHẬP GOOGLE", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _signIn,
              ),
      ),
    );
  }
}