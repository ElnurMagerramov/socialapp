import 'package:app/models/user.dart';
import 'package:app/pages/homePage.dart';
import 'package:app/pages/loginPage.dart';
import 'package:app/services/adminService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class Direct extends StatelessWidget {
  const Direct({super.key});

  @override
  Widget build(BuildContext context) {
    final _adminService = Provider.of<AdminService>(context, listen: false);
    return StreamBuilder(
      stream: _adminService.followState,
      builder: (context,snapshot) {
        Users? activeUser = snapshot.data;
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(body: Center(child: CircularProgressIndicator(),));
        }else if(snapshot.hasData){
          print (activeUser?.email);
          _adminService.activeUserID=activeUser?.id;
          return HomePage();
        }else{
          print("log out is good");
          return LoginPage();
        }
      },
      );
  }
}