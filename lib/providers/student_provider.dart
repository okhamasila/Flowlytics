import 'package:flutter/foundation.dart';
import 'package:flowlytics/models/student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoaded = false;
  bool _isInitialized = false;
  
  List<Student> get students => _students;
  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadStudents();
    _isInitialized = true;
  }

  Future<void> loadStudents() async {
    if (_isLoaded) return; // Don't reload if already loaded
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = prefs.getString('students');
      if (studentsJson != null) {
        final List<dynamic> decoded = jsonDecode(studentsJson);
        _students = decoded.map((item) => Student.fromJson(item)).toList();
      } else {
        _students = StudentData.getStudents();
        await saveStudents();
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading students: $e');
      _students = StudentData.getStudents();
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = jsonEncode(_students.map((s) => s.toJson()).toList());
      await prefs.setString('students', studentsJson);
    } catch (e) {
      print('Error saving students: $e');
    }
  }

  Future<void> addStudent(Student student) async {
    // Check for duplicate name
    bool hasDuplicateName = _students.any((s) => 
      s.name.toLowerCase() == student.name.toLowerCase() && s.id != student.id
    );
    
    // Check for duplicate NIM
    bool hasDuplicateNim = _students.any((s) => 
      s.nim == student.nim && s.id != student.id
    );

    if (hasDuplicateName) {
      throw Exception('A student with this name already exists');
    }

    if (hasDuplicateNim) {
      throw Exception('A student with this NIM already exists');
    }

    _students.add(student);
    await saveStudents();
    notifyListeners();
  }

  Future<void> removeStudent(String id) async {
    _students.removeWhere((student) => student.id == id);
    await saveStudents();
    notifyListeners();
  }

  Future<void> updateStudent(Student updatedStudent) async {
    final index = _students.indexWhere((student) => student.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      await saveStudents();
      notifyListeners();
    }
  }
}