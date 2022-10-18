import 'package:app/models/announce.dart';
import 'package:app/models/posts.dart';
import 'package:app/models/user.dart';
import 'package:app/services/storageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final DateTime time = DateTime.now();
  Future<void> createUser(
      {id, email, username, photoURL = "", about = ""}) async {
    await _fireStore.collection('users').doc(id).set({
      'username': username,
      'email': email,
      'photoURL': photoURL,
      'about': about,
      'createdTime': time
    });
  }

  Future<Users> getUser(id) async {
    DocumentSnapshot doc = await _fireStore.collection("users").doc(id).get();
    if (doc.exists) {
      Users user = Users.documentCreate(doc);
      return user;
    } else {
      return null!;
    }
  }

  void updateUser(
      {String? userID, String? username, String photoURL = "", String? about}) {
    _fireStore
        .collection("users")
        .doc(userID)
        .update({"username": username, "about": about, "photoURL": photoURL});
  }

  Future<List<Users>> searchUser(word) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: word)
        .get();
    List<Users> users =
        snapshot.docs.map((doc) => Users.documentCreate(doc)).toList();
    return users;
  }

  void follow(String? activeUserID, String? profileOwnerID) {
    _fireStore
        .collection('followers')
        .doc(profileOwnerID)
        .collection('userFollowers')
        .doc(activeUserID)
        .set({});
    _fireStore
        .collection('followings')
        .doc(activeUserID)
        .collection('userFollowings')
        .doc(profileOwnerID)
        .set({});

        addAnnounce(activityType: "follow", activityUserID: activeUserID,profileOwnerID: profileOwnerID);
  }

  void followOut(String? activeUserID, String? profileOwnerID) {
    _fireStore
        .collection('followers')
        .doc(profileOwnerID)
        .collection('userFollowers')
        .doc(activeUserID)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    _fireStore
        .collection('followings')
        .doc(activeUserID)
        .collection('userFollowings')
        .doc(profileOwnerID)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> followControl(
      String? activeUserID, String? profileOwnerID) async {
    DocumentSnapshot doc = await _fireStore
        .collection('followings')
        .doc(activeUserID)
        .collection('userFollowings')
        .doc(profileOwnerID)
        .get();
    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> followerNumber(id) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('followers')
        .doc(id)
        .collection('userFollowers')
        .get();
    return snapshot.docs.length;
  }

  Future<int> followingNumber(id) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('followings')
        .doc(id)
        .collection('userFollowings')
        .get();
    return snapshot.docs.length;
  }

  void addAnnounce(
      {String? activityUserID,
      String? profileOwnerID,
      String? activityType,
      String? comment=" ",
      Post? post}) {
        String id;
        String postPhotoURL;
        if(post!=null){
          id=post.id;
          postPhotoURL=post.postPhotoURL;
        }else{
          id=" ";
          postPhotoURL=" ";
        }
    if(activityUserID==profileOwnerID){
      return;
    }
    else{_fireStore
        .collection('announces')
        .doc(profileOwnerID)
        .collection('userAnnounces')
        .add({
      'activityUserID': activityUserID,
      'activityType': activityType,
      'postID': id,
      'postPhoto': postPhotoURL,
      'comment': comment,//yaddan cixmasin
      'createdTime': time
    });}
  }

  getAnnounces(String? profileOwnerID) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('announces')
        .doc(profileOwnerID)
        .collection('userAnnounces')
        .orderBy('createdTime', descending: true)
        .limit(20)
        .get();
    List<Announce> announces = [];
    snapshot.docs.forEach((DocumentSnapshot doc) {
      Announce announce = Announce.documentCreate(doc);
      announces.add(announce);
    });
    return announces;
  }

  Future<void> createPost(
      {postPhotoURL, description, userID, location, likeNumber}) async {
    await _fireStore
        .collection("posts")
        .doc(userID)
        .collection('userPosts')
        .add({
      'postPhotoURL': postPhotoURL,
      'description': description,
      'userID': userID,
      'likeNumber': 0,
      'location': location,
      'createdTime': time
    });
  }

  Future<List<Post>> getPosts(userID) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('posts')
        .doc(userID)
        .collection('userPosts')
        .orderBy('createdTime', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.documentCreate(doc)).toList();
    return posts;
  }
  Future<List<Post>> getFlows(userID) async {
    QuerySnapshot snapshot = await _fireStore
        .collection('flows')
        .doc(userID)
        .collection('userFlowPosts')
        .orderBy('createdTime', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.documentCreate(doc)).toList();
    return posts;
  }
  Future<Post> getOnePost(String postID,String postUserID) async {
  DocumentSnapshot doc=await _fireStore.collection('posts').doc(postUserID).collection('userPosts').doc(postID).get();
  Post post=Post.documentCreate(doc);
  return post;
  }
  Future<void> removePost(String activeUserID,Post post) async {
  _fireStore.collection('posts').doc(activeUserID).collection('userPosts').doc(post.id).get().then((doc){
    if(doc.exists){
      doc.reference.delete();
    }
  });

  QuerySnapshot commentSnapshot= await _fireStore.collection("comments").doc(post.id).collection('postComments').get();
  commentSnapshot.docs.forEach((DocumentSnapshot doc) {
    if(doc.exists){
      doc.reference.delete();
    }
  });


  QuerySnapshot announcesSnapshot = await _fireStore.collection('announces').doc(post.userID).collection('userAnnounces').where("postID",isEqualTo: post.id).get();
   announcesSnapshot.docs.forEach((DocumentSnapshot doc) {
    if(doc.exists){
      doc.reference.delete();
    }
  });

  StorageService().removePostPhoto(post.postPhotoURL);
  }
  Future<void> likePost(Post post, String activeUserID) async {
    DocumentReference docRef = _fireStore
        .collection('posts')
        .doc(post.userID)
        .collection('userPosts')
        .doc(post.id);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Post post = Post.documentCreate(doc);
      int updateLikeNumber = post.likeNumber + 1;
      docRef.update({"likeNumber": updateLikeNumber});
      _fireStore
          .collection("likes")
          .doc(post.id)
          .collection('postLikes')
          .doc(activeUserID)
          .set({});
    }
    addAnnounce(
      activityType: "like",
      activityUserID: activeUserID,
      profileOwnerID: post.userID,
      post: post,
    );
  }

  Future<void> dislikePost(Post post, String activeUserID) async {
    DocumentReference docRef = _fireStore
        .collection('posts')
        .doc(post.userID)
        .collection('userPosts')
        .doc(post.id);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Post post = Post.documentCreate(doc);
      int updateLikeNumber = post.likeNumber - 1;
      docRef.update({"likeNumber": updateLikeNumber});
      DocumentSnapshot docLike = await _fireStore
          .collection("likes")
          .doc(post.id)
          .collection('postLikes')
          .doc(activeUserID)
          .get();
      if (docLike.exists) {
        docLike.reference.delete();
      }
    }
  }

  Future<bool> isLike(Post post, String activeUserID) async {
    DocumentSnapshot docLike = await _fireStore
        .collection("likes")
        .doc(post.id)
        .collection('postLikes')
        .doc(activeUserID)
        .get();
    if (docLike.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> getComment(String postID) {
    return _fireStore
        .collection("comments")
        .doc(postID)
        .collection('postComments')
        .orderBy("createdTime", descending: true)
        .snapshots();
  }

  void addComment({String? activeUserID, Post? post, String? content}) {
    _fireStore
        .collection("comments")
        .doc(post?.id)
        .collection('postComments')
        .add({"content": content, "userID": activeUserID, "createdTime": time});

        addAnnounce(
          activityType: "comment",
          activityUserID: activeUserID,
          comment: content,
          post: post,
          profileOwnerID: post?.userID
          );
  }
}
