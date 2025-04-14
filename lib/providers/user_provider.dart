import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flowlytics/providers/student_provider.dart';
import 'package:flowlytics/models/student.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;
  String? _username;
  String? _profileImagePath;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  String? get username => _username;
  String? get profileImagePath => _profileImagePath;

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('isLoggedIn', false);
      
      _username = username;
      _email = email;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('email');
      final storedPassword = prefs.getString('password');

      if (storedEmail == null || storedPassword == null) {
        throw Exception('No account found. Please sign up first.');
      }

      if (storedEmail.toLowerCase() == email.toLowerCase() && storedPassword == password) {
        _isLoggedIn = true;
        _email = email;
        _username = prefs.getString('username');
        _profileImagePath = prefs.getString('profileImagePath');
        await prefs.setBool('isLoggedIn', true);
        
        // Load student data immediately after successful login
        await Provider.of<StudentProvider>(context, listen: false).loadStudents();
        
        notifyListeners();
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      _isLoggedIn = false;
      _email = null;
      _username = null;
      _profileImagePath = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<bool> checkLoginStatus(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (_isLoggedIn) {
        _email = prefs.getString('email');
        _username = prefs.getString('username');
        _profileImagePath = prefs.getString('profileImagePath');
        
        // Load student data if user is logged in
        await Provider.of<StudentProvider>(context, listen: false).loadStudents();
      }
      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    required String username,
    required String email,
    File? profileImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update username and email
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      
      // Handle profile image
      if (profileImage != null) {
        // Delete old profile image if exists
        if (_profileImagePath != null) {
          try {
            final oldFile = File(_profileImagePath!);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (e) {
            print('Error deleting old profile image: $e');
          }
        }

        // Create a directory for profile images if it doesn't exist
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profile_images');
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        // Generate unique filename
        final filename = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await profileImage.copy('${profileDir.path}/$filename');
        
        // Save the path to SharedPreferences
        await prefs.setString('profileImagePath', savedImage.path);
        _profileImagePath = savedImage.path;
      }
      
      _username = username;
      _email = email;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('password');
      
      if (storedPassword == null) {
        throw Exception('No password found');
      }
      
      if (storedPassword != currentPassword) {
        throw Exception('Current password is incorrect');
      }
      
      // Save the new password
      await prefs.setString('password', newPassword);
      
      // Ensure student data is saved
      await Provider.of<StudentProvider>(context, listen: false).saveStudents();
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
} 