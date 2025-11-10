import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final displayNameCtrl = TextEditingController();
  final photoUrlCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final curPassCtrl = TextEditingController();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> updateProfile() async {
    final user = currentUser;
    if (user == null) {
      showSnackBar("Chưa đăng nhập");
      return;
    }
    await user.updateDisplayName(displayNameCtrl.text.trim());
    await user.updatePhotoURL(photoUrlCtrl.text.trim());
    await user.reload();
    setState(() {});
    showSnackBar("Cập nhật hồ sơ thành công");
  }

  Future<void> reauthenticate() async {
    final user = currentUser;
    final email = user?.email;
    final password = curPassCtrl.text.trim();

    if (email == null || password.isEmpty) {
      throw Exception("Chưa nhập email hoặc mật khẩu hiện tại");
    }

    final xacthuc = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user!.reauthenticateWithCredential(xacthuc);
  }

  Future<void> updateEmail() async {
    final user = currentUser;
    if (user == null) return;
    await reauthenticate();
    await user.verifyBeforeUpdateEmail(emailCtrl.text.trim());
    showSnackBar("Email xác minh đã được gửi.");
  }

  Future<void> updatePassword() async {
    final user = currentUser;
    if (user == null) return;
    final newPassword = newPassCtrl.text.trim();
    if (newPassword.length < 6) {
      showSnackBar("Mật khẩu mới phải có ít nhất 6 ký tự");
      return;
    }
    await reauthenticate();
    await user.updatePassword(newPassword);
    showSnackBar("Cập nhật mật khẩu thành công");
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    showSnackBar("Đã đăng xuất");
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ người dùng"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "UID: ${user.uid}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text("Email: ${user.email ?? 'Unknown'}"),
                      Text("Tên: ${user.displayName ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Image.network(
                  user.photoURL ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, size: 100),
                ),
              ),

              const SizedBox(height: 20),
            ],

            const Divider(),
            const Text(
              "Cập nhật hồ sơ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: displayNameCtrl,
              decoration: const InputDecoration(labelText: 'Tên hiển thị'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: photoUrlCtrl,
              decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: updateProfile,
              icon: const Icon(Icons.save),
              label: const Text("Cập nhật hồ sơ"),
            ),

            const Divider(height: 30),
            const Text(
              "Đổi Email",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Mới'),
            ),

            const Divider(height: 30),
            const Text(
              "Đổi Mật khẩu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassCtrl,
              decoration: const InputDecoration(labelText: 'Mật khẩu Mới'),
              obscureText: true,
            ),

            const Divider(height: 30),
            const Text(
              "Mật khẩu Hiện tại",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: curPassCtrl,
              decoration: const InputDecoration(labelText: 'Mật khẩu Hiện tại'),
              obscureText: true,
            ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: updateEmail,
              icon: const Icon(Icons.email),
              label: const Text("Đổi Email"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: updatePassword,
              icon: const Icon(Icons.lock),
              label: const Text("Đổi Mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
