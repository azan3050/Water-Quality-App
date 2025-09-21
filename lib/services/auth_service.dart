import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // Re-throw the exception to be caught in the UI
      rethrow;
    }
  }

  // Sign up for ASHA workers
  Future<User?> signUpAshaWorker(
      {required String email,
      required String password,
      required String name}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a new document for the user with the uid and set the role
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'asha_worker',
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Check user role from Firestore
  // It checks if a document with the given uid exists in the specified collection.
  Future<bool> checkUserRole(String uid, String collectionName) async {
    // --- THIS IS THE CRUCIAL DEBUGGING LINE ---
    print('Checking for role in collection "$collectionName" with UID: $uid');
    // ------------------------------------------
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return;
    }
  }
}

