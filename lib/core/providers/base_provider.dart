import 'package:flutter/material.dart';

/// Base class for all providers. Adds [isLoading] and [error] state so
/// screens can react to async operations without local setState boilerplate.
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convenience wrapper: sets loading, runs [action], clears loading.
  /// If [action] throws, captures the error message.
  Future<T?> run<T>(Future<T> Function() action) async {
    setLoading(true);
    clearError();
    try {
      final result = await action();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }
}
