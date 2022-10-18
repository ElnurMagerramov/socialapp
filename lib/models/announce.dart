import 'package:cloud_firestore/cloud_firestore.dart';

class Announce {
  final String id;
  final String activityUserID;
  final String activityType;
  final String postID;
  final String postPhoto;
  final String comment;
  final Timestamp createdTime;

  Announce({
    required this.id,
    required this.activityUserID,
    required this.activityType,
    required this.postID,
    this.postPhoto="",
    this.comment="",
    required this.createdTime,
  });

  factory Announce.documentCreate(DocumentSnapshot doc) {
    return Announce(
        id: doc.id,
        activityUserID: doc['activityUserID'],
        activityType: doc['activityType'],
        postID: doc['postID'],
        postPhoto: doc['postPhoto'],
        comment: doc['comment'],
        createdTime: doc["createdTime"]);
  }
}
