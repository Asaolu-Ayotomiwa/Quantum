import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quantum/Services/firestore_service.dart';

// Define the auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// StateNotifier for Auth
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._auth, this._firestoreService) : super(AuthState());

  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  Future<void> signOut() async {
    // Update user status to offline
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestoreService.updateUserStatus(userId, false);
    }

    await _auth.signOut();
    state = AuthState(); // reset state
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update user status to online
      if (userCredential.user != null) {
        await _firestoreService.updateUserStatus(userCredential.user!.uid, true);
      }

      state = state.copyWith(
        user: userCredential.user,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? e.code,
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUserProfile(
          uid: userCredential.user!.uid,
          email: email.trim(),
          username: username.trim(),
        );

        // Update user status to online
        await _firestoreService.updateUserStatus(userCredential.user!.uid, true);
      }

      state = state.copyWith(
        user: userCredential.user,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? e.code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final firestoreService = ref.read(firestoreServiceProvider);
  return AuthController(auth, firestoreService);
});

