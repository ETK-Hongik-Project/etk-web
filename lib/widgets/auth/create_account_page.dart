import 'package:etk_web/api/user.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
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

      // 예외가 발생하지 않았을 경우
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('환영합니다!'),
            content: const Text('가입이 성공적으로 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginPage(), // LoginPage 위젯으로 이동
                    ),
                  );
                },
                child: const Text('로그인 페이지로 이동'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = "회원가입 실패:";
        if (e.toString().contains(NoNameEnteredError)) {
          _errorMessage = "$_errorMessage\n사용자 이름을 입력해주세요.";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                '환영해요!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '사용자 이름',
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
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Colors.deepPurpleAccent),
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
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  prefixIcon:
                      const Icon(Icons.email, color: Colors.deepPurpleAccent),
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
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _join,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
