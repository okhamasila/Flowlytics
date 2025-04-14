import 'package:flutter/material.dart';
import 'package:flowlytics/models/student.dart';
import 'package:flowlytics/pages/add_student.dart';
import 'package:flowlytics/asset/card.dart';
import 'package:provider/provider.dart';
import 'package:flowlytics/providers/student_provider.dart';
import 'package:flowlytics/pages/settings.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    await provider.initialize();
    setState(() {
      _filteredStudents = provider.students;
    });
  }

  void _filterStudents(String query, List<Student> students) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = students;
      } else {
        _filteredStudents = students.where((student) {
          final searchLower = query.toLowerCase();
          
          switch (_selectedFilter) {
            case 'name':
              return student.name.toLowerCase().contains(searchLower);
            case 'nim':
              return student.nim.toLowerCase().contains(searchLower);
            case 'major':
              return student.major.toLowerCase().contains(searchLower);
            case 'all':
            default:
              return student.name.toLowerCase().contains(searchLower) ||
                     student.nim.toLowerCase().contains(searchLower) ||
                     student.major.toLowerCase().contains(searchLower) ||
                     student.email.toLowerCase().contains(searchLower);
          }
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: _selectedFilter == value ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
      selected: _selectedFilter == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
          _filterStudents(_searchController.text, Provider.of<StudentProvider>(context, listen: false).students);
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD), // Light blue color
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Flowlytics',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Mahasiswa',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<StudentProvider>(
                          builder: (context, provider, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Total: ${provider.students.length} mahasiswa',
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddStudentPage()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Student'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari mahasiswa...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterStudents('', Provider.of<StudentProvider>(context, listen: false).students);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      _filterStudents(value, Provider.of<StudentProvider>(context, listen: false).students);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nama', 'name'),
                      const SizedBox(width: 8),
                      _buildFilterChip('NIM', 'nim'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Jurusan', 'major'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (!provider.isLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (_filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada hasil pencarian',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    return StudentCard(student: _filteredStudents[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}