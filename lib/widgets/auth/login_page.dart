import 'package:etk_web/api/auth/login.dart';
import 'package:etk_web/widgets/auth/create_account_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../keyboard/keyboard_main_page.dart';

bool isLoggedIn = false; // 유저의 로그인 여부 (로그인, 비회원 이용하기 구분)

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

  void _nonMemberLogin(){
    isLoggedIn = false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KeyboardMainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                '안녕하세요',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  prefixIcon:
                      const Icon(Icons.person, color: Colors.deepPurpleAccent),
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  prefixIcon:
                      const Icon(Icons.lock, color: Colors.deepPurpleAccent),
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5, // Shadow applied to the button
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nonMemberLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5, // Shadow applied to the button
                  ),
                  child: const Text(
                    '비회원 이용하기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                child: const Text(
                  "아직 계정이 없으신가요? 지금 계정 만들기",
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 16,
                  ),
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
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
