import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Users{
  
  final String id;
  final String name;
  final String photoURL;
  final String email;
  final String about;

  Users({required this.id, required this.name, required this.photoURL, required this.email,  this.about=""});


  factory Users.firebaseCreate(User user) {
    return Users(id: user.uid, name: "${user.displayName}", email: "${user.email}", photoURL: "${user.photoURL}");
  }


  factory Users.documentCreate(DocumentSnapshot doc) {
    return Users(
      id : doc.id,
      name: doc['username'],
      email: doc['email'],
      photoURL: doc['photoURL'],
      about: doc['about'],
    );
  }
}
