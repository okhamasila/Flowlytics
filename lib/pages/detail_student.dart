import 'package:flutter/material.dart';
import 'package:flowlytics/models/student.dart';
import 'package:flowlytics/asset/delete_confirmation.dart';
import 'package:provider/provider.dart';
import 'package:flowlytics/providers/student_provider.dart';
import 'package:flowlytics/pages/edit_student.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;

  const StudentDetailPage({
    Key? key,
    required this.student,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        onDelete: () {
          Provider.of<StudentProvider>(context, listen: false)
              .removeStudent(student.id)
              .then((_) {
            if (context.mounted) {
              // Pop both the dialog and the detail page
              Navigator.of(context).pop(); // Pop dialog
              Navigator.of(context).pop(); // Pop detail page
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Student deleted successfully',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: Color(0xFFEF4444),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Profile Header
              Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: student.imageUrl.startsWith('http')
                        ? NetworkImage(student.imageUrl)
                        : FileImage(File(student.imageUrl)) as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Error loading image: $exception');
                    },
                    child: student.imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              
              // Student Information
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Full Name',
                      value: student.name
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.badge,
                      label: 'Student ID (NIM)',
                      value: student.nim
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.school,
                      label: 'Program Studi',
                      value: student.major
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.grade,
                      label: 'Grade Level',
                      value: student.gradeLevel
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date of Birth',
                      value: DateFormat('MMMM d, yyyy').format(student.dateOfBirth)
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: student.phone
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email Address',
                      value: student.email
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Student'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _navigateToEdit(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Student'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Example usage:
// final student = Student(
//   fullName: 'Sarah Johnson',
//   studentId: '2025140001',
//   programStudi: 'Computer Science',
//   email: 'sarah.j@university.edu',
//   imageUrl: 'https://placehold.co/120x120',
// );
// 
// StudentDetailPage(
//   student: student,
//   onEdit: () {
//     // handle edit
//   },
// )
