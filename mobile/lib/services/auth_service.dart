import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user document reference
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Get AppUser from Firestore
  Future<AppUser?> getAppUser(String uid) async {
    try {
      final doc = await _userDoc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create or update user in Firestore
  Future<AppUser> createOrUpdateUser(User firebaseUser) async {
    final existingUser = await getAppUser(firebaseUser.uid);

    if (existingUser != null) {
      // Check if daily credits need refresh
      if (existingUser.needsCreditRefresh && !existingUser.isPremium) {
        final updatedUser = existingUser.copyWith(
          credits: existingUser.credits + 5, // Daily free credits
          lastCreditRefresh: DateTime.now(),
        );
        await _userDoc(firebaseUser.uid).update(updatedUser.toJson());
        return updatedUser;
      }
      return existingUser;
    }

    // Create new user
    final newUser = AppUser.newUser(
      firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );

    await _userDoc(firebaseUser.uid).set(newUser.toJson());
    return newUser;
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) return null;

      return await createOrUpdateUser(userCredential.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) return null;

      return await createOrUpdateUser(userCredential.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AppUser?> signUpWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) return null;

      await userCredential.user!.updateDisplayName(name);

      return await createOrUpdateUser(userCredential.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in anonymously
  Future<AppUser?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user == null) return null;

      return await createOrUpdateUser(userCredential.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Use credit
  Future<bool> useCredit(String uid) async {
    try {
      final user = await getAppUser(uid);
      if (user == null) return false;

      if (user.isPremium) {
        // Premium users don't use credits, just increment total
        await _userDoc(uid).update({
          'totalAnalyses': FieldValue.increment(1),
        });
        return true;
      }

      if (user.credits <= 0) return false;

      await _userDoc(uid).update({
        'credits': FieldValue.increment(-1),
        'totalAnalyses': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add credits
  Future<bool> addCredits(String uid, int amount) async {
    try {
      await _userDoc(uid).update({
        'credits': FieldValue.increment(amount),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Set premium status
  Future<bool> setPremium(String uid, DateTime until) async {
    try {
      await _userDoc(uid).update({
        'isPremium': true,
        'premiumUntil': until.toIso8601String(),
        'credits': FieldValue.increment(50), // Bonus credits
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _userDoc(user.uid).delete();
      await user.delete();
    }
  }
}
