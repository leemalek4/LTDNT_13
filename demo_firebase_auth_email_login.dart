import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

// ==================== MÀN HÌNH CHÍNH ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("TRANG CHỦ"), backgroundColor: Colors.deepPurple),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text("Email: ${user.email}", style: const TextStyle(fontSize: 18)),
            Text("UID: ${user.uid}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
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

// ==================== MÀN HÌNH ĐĂNG NHẬP ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ĐĂNG NHẬP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: "Mật khẩu")),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async => await _login(),
                    child: const Text("ĐĂNG NHẬP"),
                  ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error(e))));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

// ==================== MÀN HÌNH ĐĂNG KÝ ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ĐĂNG KÝ")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: "Mật khẩu (>= 6 ký tự)")),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async => await _register(),
                    child: const Text("ĐĂNG KÝ"),
                  ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đã có tài khoản? Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error(e))));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

// ==================== XỬ LÝ LỖI ====================
String _error(dynamic e) {
  if (e.toString().contains("weak-password")) return "Mật khẩu phải >= 6 ký tự";
  if (e.toString().contains("email-already-in-use")) return "Email đã được dùng";
  if (e.toString().contains("invalid-email")) return "Email không hợp lệ";
  if (e.toString().contains("user-not-found") || e.toString().contains("wrong-password")) return "Sai email hoặc mật khẩu";
  return "Lỗi không xác định: ${e.toString()}";
}