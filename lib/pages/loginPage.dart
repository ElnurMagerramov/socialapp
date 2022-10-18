import 'package:app/pages/createAccount.dart';
import 'package:app/pages/forgotPassword.dart';
import 'package:app/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/adminService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String email, password;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_pageItems(), _loadingAnimation()],
      ),
    );
  }

  Widget _loadingAnimation() {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _pageItems() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: [
          FlutterLogo(
            size: 90.0,
          ),
          SizedBox(
            height: 80.0,
          ),
          TextFormField(
            validator: (dynamic insertingValue) {
              if (insertingValue.isEmpty) {
                return "Fill this field";
              } else if (!insertingValue.contains('@')) {
                return "this is not mail";
              } else {
                return null;
              }
            },
            onSaved: ((dynamic insertingValue) => email = insertingValue),
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: "Enter email",
                errorStyle: TextStyle(fontSize: 16.0),
                prefixIcon: Icon(Icons.mail)),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
              validator: (insertingValue) {
                if (insertingValue == "") {
                  return "Fill this field";
                } else if (insertingValue?.trim().length == 3 ||
                    insertingValue?.trim().length == 2 ||
                    insertingValue?.trim().length == 1 ||
                    insertingValue?.trim().length == 0) {
                  return "enter more symbols than 4";
                } else {
                  return null;
                }
              },
              onSaved: ((dynamic insertingValue) => password = insertingValue),
              autocorrect: true,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Enter password",
                  errorStyle: TextStyle(fontSize: 16.0),
                  prefixIcon: Icon(Icons.lock))),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateAccount(),
                    ));
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor, // Text Color
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: TextButton(
                  onPressed: _login,
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColorDark, // Text Color
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(child: Text('or')),
          SizedBox(
            height: 20.0,
          ),
          Center(
              child: InkWell(
                  onTap: _loginWithGoogle,
                  child: Text(
                    'Log in with Google',
                    style: TextStyle(fontSize: 19.0, color: Colors.grey[600]),
                  ))),
          SizedBox(
            height: 20.0,
          ),
          Center(child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPassword())),child: Text('forget password'))),
        ],
      ),
    );
  }

  void _login() async {
    final _adminService = Provider.of<AdminService>(context, listen: false);
    // _formKey.currentState?.validate();
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      setState(() {
        loading = true;
      });
      try {
        await _adminService.loginWithMail(email, password);
      } catch (error) {
        setState(() {
          loading = false;
        });
        var snackBar = SnackBar(content: Text("email or password is wrong."));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    final _adminService = Provider.of<AdminService>(context, listen: false);
    setState(() {
      loading = true;
    });
    try {
      Users user = await _adminService.loginWithGoogle();
      if (user != null) {
        Users? firestoreUser = await FireStoreService().getUser(user.id);
        if (firestoreUser != null) {
          FireStoreService().createUser(
            id: user.id,
            email: user.email,
            username: user.name,
            photoURL: user.photoURL
          );
        }
      }
    } catch (error) {
      setState(() {
        loading = false;
      });
      var snackBar = SnackBar(content: Text("email or password is wrong."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
