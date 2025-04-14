import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flowlytics/providers/student_provider.dart';
import 'package:flowlytics/models/student.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _gradeLevelController = TextEditingController();
  String? _selectedProgram;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();
  DateTime? _selectedDate;
  final _dateFormat = DateFormat('d MMMM yyyy');

  final List<String> programs = StudentData.getMajors();
  final List<String> gradeLevels = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _formatDateInput(String value) {
    // Remove any non-digit characters
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numbers.length > 8) {
      numbers = numbers.substring(0, 8);
    }

    String formatted = '';
    
    // Add slashes automatically
    for (int i = 0; i < numbers.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += numbers[i];
    }

    // Update text field with formatted value
    _dateOfBirthController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // Try to parse the date if we have full 8 digits
    if (numbers.length == 8) {
      try {
        final day = int.parse(numbers.substring(0, 2));
        final month = int.parse(numbers.substring(2, 4));
        final year = int.parse(numbers.substring(4));
        
        final date = DateTime(year, month, day);
        
        if (date.year >= 1900 && date.isBefore(DateTime.now())) {
          setState(() {
            _selectedDate = date;
          });
        }
      } catch (e) {
        // Invalid date
        setState(() {
          _selectedDate = null;
        });
      }
    } else {
      setState(() {
        _selectedDate = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime minimumDate = DateTime(1900, 1, 1);
    final DateTime initialDate = _selectedDate ?? DateTime(currentDate.year - 18, currentDate.month, currentDate.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minimumDate,
      lastDate: currentDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      keyboardType: TextInputType.none,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: Color(0xFF2563EB),
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse the date from DD/MM/YYYY format
        final dateParts = _dateOfBirthController.text.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        final dateOfBirth = DateTime(year, month, day);

        final newStudent = Student(
          id: _uuid.v4(),
          name: _nameController.text.trim(),
          nim: _nimController.text.trim(),
          major: _selectedProgram!,
          email: _emailController.text.trim(),
          imageUrl: _imageFile?.path ?? '',
          dateOfBirth: dateOfBirth,
          gradeLevel: _gradeLevelController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        
        await Provider.of<StudentProvider>(context, listen: false)
            .addStudent(newStudent);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Student data saved successfully',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              backgroundColor: Color(0xFF2563EB),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Add Student',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.person, size: 64, color: Colors.white)
                      : null,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                ),
                child: const Text(
                  'Upload Photo',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter a student ID' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                value: _selectedProgram,
                items: programs.map((program) => 
                  DropdownMenuItem(
                    value: program,
                    child: Text(program, style: const TextStyle(fontFamily: 'Poppins')),
                  )
                ).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedProgram = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select a program' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeLevelController,
                decoration: InputDecoration(
                  labelText: 'Grade Level (1-8)',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (String value) {
                      setState(() {
                        _gradeLevelController.text = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return gradeLevels.map((String level) {
                        return PopupMenuItem<String>(
                          value: level,
                          child: Text(level, style: const TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList();
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter a grade level';
                  final grade = int.tryParse(value!);
                  if (grade == null || grade < 1 || grade > 8) {
                    return 'Please enter a valid grade level (1-8)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'DD/MM/YYYY',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF2563EB),
                  ),
                  suffixIcon: _dateOfBirthController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dateOfBirthController.clear();
                            _selectedDate = null;
                          });
                        },
                      )
                    : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: _formatDateInput,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter your date of birth';
                  }
                  if (_selectedDate == null) {
                    return 'Please enter a valid date (DD/MM/YYYY)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter an email';
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
