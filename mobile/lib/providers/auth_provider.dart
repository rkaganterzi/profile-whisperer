import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../main.dart' show firebaseInitialized;

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthService? _authService;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Credit shortcuts
  int get credits => _user?.credits ?? 0;
  bool get isPremium => _user?.isPremium ?? false;
  bool get canAnalyze => _user?.canAnalyze ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    if (!firebaseInitialized) {
      // Firebase not configured - use mock user for development
      _useMockUser();
      return;
    }

    try {
      _authService = AuthService();
      _authSubscription = _authService!.authStateChanges.listen(_onAuthStateChanged);
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
      _useMockUser();
    }
  }

  void _useMockUser() {
    _status = AuthStatus.authenticated;
    _user = AppUser(
      uid: 'dev_user',
      email: 'dev@test.com',
      displayName: 'Test User',
      credits: 10,
      isPremium: false,
      createdAt: DateTime.now(),
      lastCreditRefresh: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.loading;
      notifyListeners();

      _user = await _authService?.createOrUpdateUser(firebaseUser);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    debugPrint('AuthProvider: signInWithGoogle started');
    if (_authService == null) {
      debugPrint('AuthProvider: _authService is null');
      return false;
    }
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      debugPrint('AuthProvider: calling _authService.signInWithGoogle()');
      _user = await _authService!.signInWithGoogle();
      debugPrint('AuthProvider: signInWithGoogle returned, user: $_user');
      if (_user != null) {
        debugPrint('AuthProvider: user is not null, setting authenticated');
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        debugPrint('AuthProvider: user is null, setting unauthenticated');
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthProvider: FirebaseAuthException: ${e.code}');
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Generic error: $e');
      _status = AuthStatus.error;
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      notifyListeners();
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail(String email, String password) async {
    if (_authService == null) return false;
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService!.signInWithEmail(email, password);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      notifyListeners();
      return false;
    }
  }

  // Sign up with email
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    if (_authService == null) return false;
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService!.signUpWithEmail(email, password, name);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      notifyListeners();
      return false;
    }
  }

  // Continue as guest
  Future<bool> continueAsGuest() async {
    if (_authService == null) {
      _useMockUser();
      return true;
    }
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService!.signInAnonymously();
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService?.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Use credit
  Future<bool> useCredit() async {
    if (_user == null) return false;

    // Always update locally first to ensure UI responsiveness
    _user = _user!.copyWith(credits: _user!.credits - 1);
    notifyListeners();

    // Try to sync with Firestore in background, but don't block
    if (_authService != null) {
      try {
        await _authService!.useCredit(_user!.uid);
      } catch (e) {
        debugPrint('AuthProvider: useCredit Firestore sync failed: $e');
      }
    }
    return true;
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_user == null || _authService == null) return;
    _user = await _authService!.getAppUser(_user!.uid);
    notifyListeners();
  }

  // Add credits (after purchase)
  Future<bool> addCredits(int amount) async {
    if (_user == null) return false;
    if (_authService == null) {
      _user = _user!.copyWith(credits: _user!.credits + amount);
      notifyListeners();
      return true;
    }

    final success = await _authService!.addCredits(_user!.uid, amount);
    if (success) {
      _user = await _authService!.getAppUser(_user!.uid);
      notifyListeners();
    }
    return success;
  }

  // Set premium (after subscription)
  Future<bool> setPremium(DateTime until) async {
    if (_user == null) return false;
    if (_authService == null) {
      _user = _user!.copyWith(isPremium: true, premiumUntil: until);
      notifyListeners();
      return true;
    }

    final success = await _authService!.setPremium(_user!.uid, until);
    if (success) {
      _user = await _authService!.getAppUser(_user!.uid);
      notifyListeners();
    }
    return success;
  }

  // Password reset
  Future<bool> sendPasswordResetEmail(String email) async {
    if (_authService == null) return false;
    try {
      await _authService!.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Error message helper
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen bekleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
