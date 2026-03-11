// Firebase Authentication Service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Send email verification
      await credential.user?.sendEmailVerification();

      // Save user to Firestore
      await _saveUserToFirestore(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getHardcodedError(e.code);
    } on FirebaseException catch (e) {
      throw _getHardcodedError(e.code);
    } catch (e) {
      // Check if error message contains known patterns
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('email-already-in-use')) {
        throw 'An account already exists with this email. Try signing in instead.';
      } else if (errorStr.contains('weak-password')) {
        throw 'Password is too weak. Use at least 6 characters.';
      } else if (errorStr.contains('invalid-email')) {
        throw 'Please enter a valid email address.';
      }
      throw 'Signup failed. Please check your details and try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getHardcodedError(e.code);
    } on FirebaseException catch (e) {
      throw _getHardcodedError(e.code);
    } catch (e) {
      // Check if error message contains known patterns
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user-not-found') || errorStr.contains('no user record')) {
        throw 'No account found with this email. Please sign up first.';
      } else if (errorStr.contains('wrong-password') || errorStr.contains('invalid-credential')) {
        throw 'Incorrect email or password. Please try again.';
      } else if (errorStr.contains('invalid-email')) {
        throw 'Please enter a valid email address.';
      } else if (errorStr.contains('user-disabled')) {
        throw 'This account has been disabled. Contact support.';
      } else if (errorStr.contains('too-many-requests')) {
        throw 'Too many failed attempts. Please try again later.';
      }
      throw 'Login failed. Please check your email and password.';
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger Google sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Save user to Firestore if new
      if (isNewUser) {
        await _saveUserToFirestore(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'User',
        );
      }

      return {
        'userCredential': userCredential,
        'isNewUser': isNewUser,
      };
    } catch (e) {
      throw 'Google sign in failed. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getHardcodedError(e.code);
    } on FirebaseException catch (e) {
      throw _getHardcodedError(e.code);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user-not-found')) {
        throw 'No account found with this email address.';
      } else if (errorStr.contains('invalid-email')) {
        throw 'Please enter a valid email address.';
      }
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Failed to send verification email. Please try again.';
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user to check verification status
  Future<bool> reloadAndCheckVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'onboardingComplete': false,
    }, SetOptions(merge: true));
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      // If document doesn't exist, create it
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    }
  }

  // Hardcoded error messages that don't rely on Firebase
  String _getHardcodedError(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Try signing in instead.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password. Please check and try again.';
      case 'operation-not-allowed':
        return 'This login method is not enabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// Singleton instance
final firebaseAuthService = FirebaseAuthService();
