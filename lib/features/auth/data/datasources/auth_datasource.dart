import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:life_task_manager/core/constants/app_constants.dart';
import 'package:life_task_manager/features/auth/data/models/user_profile_model.dart';

abstract class AuthDatasource {
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> authStateChanges();
  Future<UserProfileModel?> getUserProfile(String uid);
  Future<void> createUserProfile(String uid, UserProfileModel profile);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}

class AuthDatasourceImpl implements AuthDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthDatasourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// users/{uid} ドキュメントにプロフィールを格納
  /// スキーマ表記 users/{uid}/profile は users/{uid} ドキュメント直下のデータを指す
  DocumentReference<Map<String, dynamic>> _userProfileRef(String uid) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid);
  }

  /// Google Sign-In フロー
  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      throw Exception('Firebase sign-in failed: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on FirebaseException catch (e) {
      throw Exception('Sign-out failed: ${e.message}');
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _userProfileRef(uid).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to get user profile: ${e.message}');
    }
  }

  @override
  Future<void> createUserProfile(
    String uid,
    UserProfileModel profile,
  ) async {
    try {
      await _userProfileRef(uid).set(profile.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user profile: ${e.message}');
    }
  }

  @override
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userProfileRef(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    }
  }
}
