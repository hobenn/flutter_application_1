import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;

  void register() async {
    setState(() {
      errorText = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ✅ 기본 유효성 검사
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = "이메일과 비밀번호를 모두 입력해주세요.";
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        errorText = "올바른 이메일 형식을 입력해주세요.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorText = "비밀번호는 6자 이상이어야 합니다.";
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pop(context); // 회원가입 성공 시 로그인 화면으로 복귀
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.message ?? "회원가입에 실패했습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "이메일"),
              keyboardType: TextInputType.emailAddress,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  "📧 이메일 형식: example@email.com",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "비밀번호"),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  "🔒 비밀번호는 최소 6자 이상 입력해주세요.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ElevatedButton(onPressed: register, child: const Text("회원가입")),
          ],
        ),
      ),
    );
  }
}
