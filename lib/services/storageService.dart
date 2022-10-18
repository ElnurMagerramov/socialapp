import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
// bunu deyisdirmek lazimdi firebasde storage rulesde
// rules_version = '2';
// service firebase.storage {
//   match /b/{bucket}/o {
//     match /{allPaths=**} {
//       allow read, write: if true;
//     }
//   }
// }
class StorageService {
  Reference _storage = FirebaseStorage.instance.ref();
  String? photoId;
  Future<String?> postPhotoUpload(File file) async {
    photoId=Uuid().v4();
    // UploadTask uploadAdmin = _storage.child('images').child('posts').child('post.jpg').putFile(file);
    UploadTask uploadAdmin = _storage.child('images/posts/post_$photoId.jpg').putFile(file);
    try {
      TaskSnapshot sanpshot = await uploadAdmin;
      String uploadPhotoUrl = await sanpshot.ref.getDownloadURL();
      return uploadPhotoUrl;
    } catch (error) {
      print(error);
    }
  }
  Future<String?> profilePhotoUpload(File file) async {
    photoId=Uuid().v4();
    // UploadTask uploadAdmin = _storage.child('images').child('posts').child('post.jpg').putFile(file);
    UploadTask uploadAdmin = _storage.child('images/profile/profile_$photoId.jpg').putFile(file);
    try {
      TaskSnapshot sanpshot = await uploadAdmin;
      String uploadPhotoUrl = await sanpshot.ref.getDownloadURL();
      return uploadPhotoUrl;
    } catch (error) {
      print(error);
    }
  }
  void removePostPhoto(String postPhotoURL){
    RegExp pattern = RegExp(r'post_.{36}\.jpg');
    // RegExp pattern = RegExp(r'.{36}\.jpg');
    var equality = pattern.firstMatch(postPhotoURL);
    String? fileName=equality?[0];
    if(fileName!.isNotEmpty){
      _storage.child('images/posts/$fileName').delete();
    }
  }
}
