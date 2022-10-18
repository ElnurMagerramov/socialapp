import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String username, email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Create account')),
      body: ListView(children: [
        loading
            ? LinearProgressIndicator()
            : SizedBox(
                height: 0.0,
              ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (dynamic insertingValue) {
                      if (insertingValue == "") {
                        return "Fill this field";
                      } else if (insertingValue?.trim().length < 4 ||
                          insertingValue?.trim().length > 10) {
                        return "enter more symbols than 3 and less than 11";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (dynamic insertingValue) =>username = insertingValue,
                    autocorrect: true,
                    decoration: InputDecoration(
                        hintText: "Enter username",
                        labelText: "Username: ",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.person)),
                  ),
                  SizedBox(
                    height: 10.0,
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
                    onSaved: (dynamic insertingValue) {
                      email = insertingValue;
                    },
                    autocorrect: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: "Enter email",
                        labelText: "Email: ",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.mail)),
                  ),
                  SizedBox(
                    height: 10.0,
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
                      onSaved: (dynamic insertingValue) {
                        password = insertingValue;
                      },
                      autocorrect: true,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Enter password",
                          labelText: "Password: ",
                          errorStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.lock))),
                  SizedBox(
                    height: 50.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _createUser,
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
                ],
              )),
        )
      ]),
    );
  }

  Future<void> _createUser() async {
    final _adminService = Provider.of<AdminService>(context, listen: false);
    var _formState = _formKey.currentState;
    if (_formState?.validate() == true) {
      _formState?.save();
      setState(() {
        loading = true;
      });
      try {
        Users? user= await _adminService.registerWithMail(email, password);
        if(user != null){
          FireStoreService().createUser(id: user.id, email: email, username: username);
        }
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          loading = false;
        });
        showWarning(error);
        // var snackBar = SnackBar(content: Text("${error.toString()}"));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print("it is not okay.");
    }
  }

  showWarning(dynamic error) {
    late String errorMessage;

    if ("${error}".contains("invalid-email")) {
      errorMessage = "The email address is not valid.";
    } else if ("${error}".contains("email-already-in-use")) {
      errorMessage =
          "There already exists an account with the given email address";
    } else if ("${error}".contains("weak-password")) {
      errorMessage = "the password is not strong enough";
    }

    var snackBar = SnackBar(content: Text('${errorMessage}'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
