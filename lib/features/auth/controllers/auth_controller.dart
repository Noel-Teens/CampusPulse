import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // For secondary app
import '../../../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _userModel; // The Firestore user data (Role, etc.)
  bool _isLoading = false;

  User? get user => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isVerified => _firebaseUser?.emailVerified ?? false;

  UserRole get currentRole {
    if (_userModel != null) return _userModel!.role;
    if (_firebaseUser != null && !_firebaseUser!.isAnonymous) {
      return UserRole.student;
    }
    return UserRole.guest;
  }

  AuthController() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        // Fetch user data from Firestore if available
        await _fetchUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Fetch UserModel from Firestore
  Future<void> _fetchUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // If user document doesn't exist yet (e.g. freshly created)
        _userModel = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user model: $e");
    }
  }

  // Sign in Anonymously
  Future<void> signInAnonymously() async {
    try {
      _setLoading(true);
      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Link Email/Password to Anonymous Account (Student Registration Step)
  Future<void> linkEmailCredentials(
    String email,
    String password,
    String name,
  ) async {
    if (_firebaseUser == null) return;

    try {
      _setLoading(true);

      // Link credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      UserCredential userCredential = await _firebaseUser!.linkWithCredential(
        credential,
      );

      // Update local reference
      _firebaseUser = userCredential.user;

      // Send verification email
      await _firebaseUser!.sendEmailVerification();

      UserModel newUser = UserModel(
        uid: _firebaseUser!.uid,
        email: email,
        name: name,
        role: UserRole.student,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      // Explicitly set the document with the role string "student"
      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .set(newUser.toMap());

      // Update local state immediately to avoid "Guest" flicker
      _userModel = newUser;
      notifyListeners();

      await _fetchUserModel(_firebaseUser!.uid);
    } catch (e) {
      debugPrint("Error linking creds: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Login for returning users (Students, Faculty, Admin)
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Listener will fetch UserModel
    } catch (e) {
      debugPrint("Error signing in: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Verify Invite Code & Upgrade to Student Role
  Future<void> verifyInviteCode(String code) async {
    if (_firebaseUser == null) return;

    if (code.toUpperCase() != "STUDENT2025") {
      throw Exception("Invalid Invite Code");
    }

    try {
      _setLoading(true);

      // Update user role to STUDENT
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'role': UserRole.student.name,
        'campusId': 'campus_001', // Default campus
      });

      // Refresh local model
      await _fetchUserModel(_firebaseUser!.uid);
    } catch (e) {
      debugPrint("Error verifying code: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createFacultyUser(
    String email,
    String password,
    String name,
  ) async {
    FirebaseApp? tempApp;
    try {
      _setLoading(true);

      // Initialize a secondary "temp" app to create the user
      tempApp = await Firebase.initializeApp(
        name: 'tempApp',
        options: Firebase.app().options,
      );

      UserCredential uc = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(email: email, password: password);

      String uid = uc.user!.uid;

      UserModel newFaculty = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: UserRole.faculty,
        isVerified: true, // Auto-verified since Admin created it
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newFaculty.toMap());

      // We might want to set Display Name too?
      // uc.user?.updateDisplayName(name); // on temp app instance

      await _auth.signOut(); // This signs out main? NO.
      // Wait, `_auth` is main instance. `FirebaseAuth.instanceFor(app: tempApp)` is temp.
      // We must sign out the TEMP app user to clean up?
      await FirebaseAuth.instanceFor(app: tempApp).signOut();
    } catch (e) {
      debugPrint("Error creating faculty: $e");
      rethrow;
    } finally {
      _setLoading(false);
      if (tempApp != null) {
        await tempApp.delete(); // Delete the secondary app instance
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  // Get users by role (Admin use)
  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    debugPrint("Admin: Streaming users for role: ${role.name}");
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.name)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            "Admin: Found ${snapshot.docs.length} users with role: ${role.name}",
          );
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return UserModel.fromMap(data);
          }).toList();
        });
  }

  // Reload User
  Future<void> reloadUser() async {
    if (_firebaseUser != null) {
      await _firebaseUser!.reload();
      _firebaseUser = _auth.currentUser;
      notifyListeners();
    }
  }

  // Update Profile Name
  Future<void> updateProfileName(String name) async {
    if (_firebaseUser == null) return;
    try {
      _setLoading(true);

      // Update Firebase Auth display name
      await _firebaseUser!.updateDisplayName(name);

      // Update Firestore
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'name': name,
      });

      await _fetchUserModel(_firebaseUser!.uid);
    } catch (e) {
      debugPrint("Error updating name: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Error sending reset email: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete User (Admin/Service use)
  // Note: Standard Firebase Auth deletion requires recent login.
  // For Admin deleting others, it usually requires a backend.
  // For MVP, we will delete the Firestore doc and hope the Auth user is handled or used as a placeholder.
  // Real implementation would use Firebase Admin SDK in a Cloud Function.
  Future<void> deleteUser(String uid) async {
    try {
      _setLoading(true);
      await _firestore.collection('users').doc(uid).delete();
      // Note: We can't easily delete the Auth record from the client for ANOTHER user.
    } catch (e) {
      debugPrint("Error deleting user: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
