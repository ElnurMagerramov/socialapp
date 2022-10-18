import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String id;
  final String postPhotoURL;
  final String description;
  final String userID;
  final int likeNumber;
  final String location;

  Post({required this.id, required this.postPhotoURL, required this.description, required this.userID, required this.likeNumber, required this.location});
  factory Post.documentCreate(DocumentSnapshot doc) {
    return Post(
      id : doc.id,
      postPhotoURL: doc['postPhotoURL'],
      description: doc['description'],
      userID: doc['userID'],
      likeNumber: doc['likeNumber'],
      location:doc['location']
    );
  }
}