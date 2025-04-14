import 'package:flutter/material.dart';
import 'package:flowlytics/models/student.dart';
import 'package:flowlytics/pages/detail_student.dart' as detail;
import 'dart:io';

class StudentCard extends StatelessWidget {
  final Student student;
  
  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to student detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detail.StudentDetailPage(student: student),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: student.imageUrl.startsWith('http') 
                  ? NetworkImage(student.imageUrl)
                  : FileImage(File(student.imageUrl)) as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading image: $exception');
              },
              child: student.imageUrl.isEmpty 
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'NIM: ${student.nim}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}