import 'package:etk_web/api/auth/login.dart';
import 'package:etk_web/widgets/auth/create_account_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final logger = Logger();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;
    const String NoUsernameEnteredError = "[username](은)는 아이디를 입력해 주세요";
    const String NoPasswordEnteredError = "[password](은)는 비밀번호를 입력해주세요";
    const String NoUserExistsError = "존재하지 않는 유저입니다";

    try {
      await login(context, username, password);
    } catch (e) {
      setState(() {
        _errorMessage = "로그인 실패:";
      });
      setState(() {
        if (e.toString().contains(NoUsernameEnteredError)) {
          _errorMessage = "$_errorMessage\n아이디를 입력해주세요.";
        } else if (e.toString().contains(NoPasswordEnteredError)) {
          _errorMessage = "$_errorMessage\n비밀번호를 입력해주세요.";
        } else if (e.toString().contains(NoUserExistsError)) {
          _errorMessage = "$_errorMessage\n잘못된 아이디 혹은 비밀번호입니다.";
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _login,
                child: const Text('로그인'),
              ),
            TextButton(
              child: const Text(
                "아직 계정이 없으신가요? 지금 계정 만들기",
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAccountPage(),
                  ),
                );
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
