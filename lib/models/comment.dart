import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  String id,content,userID;
  Timestamp createdTime;
  Comment({required this.id,required this.content,required this.userID,required this.createdTime});
  factory Comment.documentCreate(DocumentSnapshot doc) {
    return Comment(
      id : doc.id,
      content: doc['content'],
      userID: doc['userID'],
      createdTime: doc['createdTime'],
    );
  }
}