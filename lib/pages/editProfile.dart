import 'dart:io';
import 'package:app/models/user.dart';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:app/services/storageService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final Users? profile;
  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _username;
  String? _about;
  File? _choosenPhoto;
  bool _loading=false;
  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: (() => Navigator.pop(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: (() => _save()),
          )
        ],
      ),
      body: ListView(children: [
        _loading? LinearProgressIndicator():SizedBox(height: 0,),
        _profilePhoto(),
         _userDetails()
         ]),
    );
  }
 _save() async {
  if(mounted){
    if(_formKey.currentState!.validate()){
      setState(() {
        _loading=true;
      });
    _formKey.currentState!.save();

    String? profilePhotoURL;
    if(_choosenPhoto==null){
      profilePhotoURL=widget.profile!.photoURL;
    }else{
      profilePhotoURL= await StorageService().profilePhotoUpload(_choosenPhoto!);
    }
    String? activeUserID= Provider.of<AdminService>(context, listen: false).activeUserID;
    FireStoreService().updateUser(userID: activeUserID,username: _username,about: _about,photoURL: profilePhotoURL!);
    setState(() {
      _loading=false;
    });
    Navigator.pop(context);
  }
  }
 }
 _uploadFromGalery() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800.0,
        maxHeight: 600.0,
        imageQuality: 80);
    setState(() {
      _choosenPhoto = File("${image?.path}");
    });
  }
  _profilePhoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: _uploadFromGalery,
          child: _choosenPhoto==null ? 
          CircleAvatar(
            backgroundColor: Colors.blue[800],
            radius: 55,
            backgroundImage: NetworkImage("${widget.profile?.photoURL}"),
          )
          : 
          CircleAvatar(
            backgroundColor: Colors.blue[800],
            radius: 55,
            backgroundImage: FileImage(_choosenPhoto!),
        )
        ),
      ),
    );
  }

  _userDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.profile?.name,
              validator: (value) {
                if (value!.trim().length <= 3) {
                  return "enter more than 4 characters for user name";
                } else {
                  return null;
                }
              },
              onSaved: (insertingValue) {
                _username=insertingValue;
              },
              decoration: InputDecoration(
                  hintText: "Enter user name", labelText: "Username:"),
            ),
            TextFormField(
              initialValue: widget.profile?.about,
               validator: (value) {
                if (value!.trim().length>=100 ) {
                  return "enter less than 100 characters for about";
                } else {
                  return null;
                }
              },
              onSaved: (insertingValue) {
                _about=insertingValue;
              },
              decoration: InputDecoration(
                  hintText: "Enter about", labelText: "About:"),
            )
          ],
        ),
      ),
    );
  }
}
