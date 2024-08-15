import 'package:etk_web/api/user.dart';
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

    const String NoUsernameEnteredError = "[username](은)는 아이디가 입력되지 않았습니다";
    const String NoPasswordEnteredError = "[password](은)는 비밀번호가 입력되지 않았습니다";
    const String NoNameEnteredError = "[name](은)는 이름이 입력되지 않았습니다";
    const String NoEmailEnteredError = "[email](은)는 이메일이 입력되지 않았습니다";
    const String InvalidEmailFormatError = "[email](은)는 올바른 형식이 아닙니다";
    const String DuplicatedUsernameError = "이미 사용중인 아이디입니다";
    const String DuplicatedEmailError = "이미 사용중인 이메일입니다";

    try {
      await join(name, username, password, email);
    } catch (e) {
      setState(() {
        _errorMessage = "회원가입 실패:";
      });
      setState(() {
        if (e.toString().contains(NoNameEnteredError)) {
          _errorMessage = "$_errorMessage\n이름을 입력해주세요.";
        } else if (e.toString().contains(NoUsernameEnteredError)) {
          _errorMessage = "$_errorMessage\n아이디를 입력해주세요.";
        } else if (e.toString().contains(NoPasswordEnteredError)) {
          _errorMessage = "$_errorMessage\n비밀번호를 입력해주세요.";
        } else if (e.toString().contains(NoEmailEnteredError)) {
          _errorMessage = "$_errorMessage\n이메일을 입력해주세요.";
        } else if (e.toString().contains(InvalidEmailFormatError)) {
          _errorMessage = "$_errorMessage\n잘못된 이메일 형식입니다. 이메일 형식을 확인해주세요.";
        } else if (e.toString().contains(DuplicatedUsernameError)) {
          _errorMessage = "$_errorMessage\n이미 사용중인 아이디입니다.";
        } else if (e.toString().contains(DuplicatedEmailError)) {
          _errorMessage = "$_errorMessage\n이미 사용중인 이메일입니다.";
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
