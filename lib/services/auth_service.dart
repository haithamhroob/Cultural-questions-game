import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? _userName;
  bool _isLoggedIn = false;
  List<String> _allUsers = [];

  String? get userName => _userName;
  bool get isAuthenticated => _isLoggedIn;
  List<String> get allUsers => _allUsers;

  AuthService() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');
    _allUsers = prefs.getStringList('all_users') ?? [];
    _isLoggedIn = _userName != null;
    notifyListeners();
  }

  Future<void> signIn(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    
    if (!_allUsers.contains(name)) {
      _allUsers.add(name);
      await prefs.setStringList('all_users', _allUsers);
    }
    
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> deleteUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _allUsers.remove(name);
    await prefs.setStringList('all_users', _allUsers);
    if (_userName == name) {
      await signOut();
    }
    notifyListeners();
  }
}
