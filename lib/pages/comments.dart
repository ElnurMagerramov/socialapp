import 'package:app/models/comment.dart';
import 'package:app/models/posts.dart';
import 'package:app/models/user.dart';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
class Comments extends StatefulWidget {
  final Post post;
  const Comments({super.key, required this.post});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('az', timeago.AzMessages());
  }
  TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(children: [_showComments(), _addComment()]),
    );
  }

  _showComments() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FireStoreService().getComment(widget.post.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    Comment comment =
                        Comment.documentCreate(snapshot.data!.docs[index]);
                    return _commentLine(comment);
                  });
            }
          }),
    );
  }

  _commentLine(Comment comment) {
    return FutureBuilder<Users>(
        future: FireStoreService().getUser(comment.userID),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            // return Center(child: CircularProgressIndicator());
            return SizedBox(height: 0,);
          }
          // Users user;
          // try {
          //   user = snapshot.data!;
          // } catch (error) {

          // }
          Users user=snapshot.data!;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: NetworkImage(user.photoURL),
            ),
            title: RichText(
                text: TextSpan(
                    text: "${user.name}: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: "${comment.content}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                          color: Colors.black))
                ])),
                subtitle: Text(timeago.format(comment.createdTime.toDate(),locale: "az")),
          );
        });
  }

  _addComment() {
    return ListTile(
      title: TextFormField(
        controller: _commentController,
        decoration: InputDecoration(hintText: "Enter your comment:"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: () {
          String? activeUserID =
              Provider.of<AdminService>(context, listen: false).activeUserID;
          FireStoreService().addComment(
              activeUserID: activeUserID,
              content: _commentController.text,
              post: widget.post);
          _commentController.clear();
        },
      ),
    );
  }
}
