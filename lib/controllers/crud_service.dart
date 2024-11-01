import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService {
  // Making this static since it's accessing Firebase directly
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save FCM token to Firestore
  static Future<void> saveUserToken(String token) async {
    try {
      // Get current user within the method
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        Map<String, dynamic> data = {
          "email": currentUser.email,
          "token": token,
        };

        await _firestore.collection("user_data").doc(currentUser.uid).set(data);

        print("Document Added to ${currentUser.uid}");
      } else {
        print("No user is currently signed in");
      }
    } catch (e) {
      print("Error in saving to Firestore: ${e.toString()}");
    }
  }
}
