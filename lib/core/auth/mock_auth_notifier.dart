import 'package:flutter/foundation.dart';

class MockAuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _displayName = 'Owner';

  bool get isAuthenticated => _isAuthenticated;
  bool get isResolving => _isLoading;
  String? get accessError => _errorMessage;
  String get displayName => _displayName;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter your email and password.';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    _isAuthenticated = true;
    _displayName = email.contains('@') ? email.split('@').first : 'Owner';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}

MockAuthNotifier? _authInstance;

MockAuthNotifier get authNotifier => _authInstance ??= MockAuthNotifier();

void initializeAuth() {
  _authInstance ??= MockAuthNotifier();
}
