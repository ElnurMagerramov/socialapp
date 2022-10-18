import 'package:app/models/user.dart';
import 'package:app/services/firestoreService.dart';
import 'package:app/widgets/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../models/posts.dart';

class OnePost extends StatefulWidget {
  final String postID;
  final String postUserID;
  const OnePost({super.key, required this.postID, required this.postUserID});

  @override
  State<OnePost> createState() => _OnePostState();
}

class _OnePostState extends State<OnePost> {
  Post? _post;
  Users? _postOwner;
  bool _loading=true;
  getPost() async{
   Post post= await FireStoreService().getOnePost(widget.postID, widget.postUserID);
   if(post !=null){
    Users postOwner= await FireStoreService().getUser(post.userID);
    setState(() {
      _post=post;
      _postOwner=postOwner;
      _loading=false;
    });
   }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Announces",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: !_loading? PostCard(post: _post!, user: _postOwner!): Center(child: CircularProgressIndicator()),
    );
  }
}