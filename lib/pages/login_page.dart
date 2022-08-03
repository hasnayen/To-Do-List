import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/model/user_model.dart';
import 'package:todo_list/pages/home_page.dart';
import 'package:todo_list/provider/user_provider.dart';

import '../auth_pref.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isObscure = true;
  bool isNewUser = false;

  final form_key = GlobalKey<FormState>();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/background.png',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
                Form(
                  key: form_key,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/app_image.png',
                            height: 150,
                            width: 90,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                            controller: userNameController,
                            decoration: InputDecoration(
                              labelText: 'User Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'This field cannot be empty';
                              } else if (val.length < 6) {
                                return 'Password is too short';
                              }
                              return null;
                            },
                            controller: passwordController,
                            obscureText: isObscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: (isObscure
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility)),
                                onPressed: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: isNewUser ? _regUser : _loginUser,
                            child: isNewUser
                                ? const Text('Register')
                                : const Text('Login'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('New user?'),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isNewUser = !isNewUser;
                                    });
                                  },
                                  child: const Text('Click here!'))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _regUser() async {
    if (form_key.currentState!.validate()) {
      final user = UserModel(
          userName: userNameController.text,
          userPassword: passwordController.text);

      final status = await Provider.of<UserProvider>(context, listen: false)
          .addNewUser(user);

      if (status) {
        String userName = userNameController.text;
        setUser(userName);
        SnackBar snackBar = SnackBar(content: Text('Welcome $userName!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setLoginStat(true).then((value) =>
            Navigator.pushReplacementNamed(context, HomePage.routeName));
      } else {
        SnackBar snackBar = SnackBar(content: Text('User already exists!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void _loginUser() async {
    if (form_key.currentState!.validate()) {
      final user = UserModel(
          userName: userNameController.text,
          userPassword: passwordController.text);

      final status =
          Provider.of<UserProvider>(context, listen: false).loginUser(user);

      if (status) {
        String userName = userNameController.text;
        setUser(userName);
        SnackBar snackBar = SnackBar(content: Text('Welcome back $userName!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setLoginStat(true).then((value) =>
            Navigator.pushReplacementNamed(context, HomePage.routeName));
      } else {
        SnackBar snackBar =
            SnackBar(content: Text('Username or password Incorrect!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
