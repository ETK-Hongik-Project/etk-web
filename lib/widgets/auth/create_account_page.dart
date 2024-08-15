import 'package:etk_web/api/user.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({
    super.key,
  });

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _join() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String name = _nameController.text;
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;

    try {
      await join(name, username, password, email);
    } catch (e) {
      logger.e(e);
      setState(() {
        if (e.toString().contains("Duplicated username")) {
          _errorMessage = "이미 사용중인 아이디입니다.";
        } else if (e.toString().contains("Duplicated email")) {
          _errorMessage = "이미 사용중인 이메일입니다.";
        } else {
          _errorMessage = "$e";
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
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '사용자 이름'),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _join,
                child: const Text('가입하기'),
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
