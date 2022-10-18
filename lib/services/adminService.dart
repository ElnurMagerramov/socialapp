import 'package:firebase_auth/firebase_auth.dart' hide Users;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
class AdminService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? activeUserID;
  Users? _createUser(user) {
    return user == null ? null : Users.firebaseCreate(user);
  }

  Stream<Users?> get followState {
    print(_firebaseAuth.authStateChanges().map(_createUser));
    return _firebaseAuth.authStateChanges().map(_createUser);
  }
  Future<Users?> loginWithMail(String email, String password) async {
    var loginCard=await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return _createUser(loginCard.user);
  }
  Future<Users?> registerWithMail(String email, String password) async {
    var loginCard=await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _createUser(loginCard.user);
  }
  Future<dynamic> logout(){
    return _firebaseAuth.signOut();
  }
  Future<void> resetPassword(String email) async{
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  loginWithGoogle() async {
    GoogleSignInAccount? googleAccount=await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAdminCard= await googleAccount?.authentication;
    AuthCredential passwordless= GoogleAuthProvider.credential(idToken: googleAdminCard?.idToken, accessToken: googleAdminCard?.accessToken);
    UserCredential loginCard= await _firebaseAuth.signInWithCredential(passwordless);

    return _createUser(loginCard.user);

    // print(loginCard.user?.uid);
    // print(loginCard.user?.displayName);
    // print(loginCard.user?.photoURL);
    // print(loginCard.user?.email);

    // print(googleAccount?.id);
    // print(googleAccount?.displayName);
    
  }
}
