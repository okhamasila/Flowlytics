class Student {
  final String id;
  final String name;
  final String nim;
  final String major;
  final String email;
  final String imageUrl;
  final DateTime dateOfBirth;
  final String gradeLevel;
  final String phone;

  Student({
    required this.id,
    required this.name,
    required this.nim,
    required this.major,
    required this.email,
    required this.imageUrl,
    required this.dateOfBirth,
    required this.gradeLevel,
    required this.phone,
  });

  // Convert Student to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nim': nim,
    'major': major,
    'email': email,
    'imageUrl': imageUrl,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'gradeLevel': gradeLevel,
    'phone': phone,
  };

  // Create Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    name: json['name'] as String,
    nim: json['nim'] as String,
    major: json['major'] as String,
    email: json['email'] as String,
    imageUrl: json['imageUrl'] as String,
    dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
    gradeLevel: json['gradeLevel'] as String,
    phone: json['phone'] as String,
  );

  // Create a copy of Student with optional field updates
  Student copyWith({
    String? id,
    String? name,
    String? nim,
    String? major,
    String? email,
    String? imageUrl,
    DateTime? dateOfBirth,
    String? gradeLevel,
    String? phone,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      phone: phone ?? this.phone,
    );
  }
}

class StudentData {
  static List<Student> getStudents() {
    return [
      Student(
        id: '1',
        name: 'John Doe',
        nim: '12345678',
        major: 'Information Technology (S1)',
        email: 'john.doe@example.com',
        imageUrl: '',
        dateOfBirth: DateTime(2000, 1, 1),
        gradeLevel: '1',
        phone: '+62 812-3456-7890',
      ),
      Student(
        id: '2',
        name: 'Jane Smith',
        nim: '87654321',
        major: 'Business Management (S1)',
        email: 'jane.smith@example.com',
        imageUrl: '',
        dateOfBirth: DateTime(2001, 5, 15),
        gradeLevel: '2',
        phone: '+62 813-9876-5432',
      ),
    ];
  }

  static List<String> getMajors() => [
    // Bachelor's Degree (S1)
    'Architecture (S1)',
    'Urban and Regional Planning (S1)',
    'Civil Engineering (S1)',
    'Interior Design (S1)',
    'Visual Communication Design (S1)',
    'Accounting (S1)',
    'Food & Beverage Retail Management (S1)',
    'Business Management (S1)',
    'Information Technology (S1)',
    'Business Information Systems (S1)',
    'Tourism and Hospitality (S1)',
    
    // Diploma (D3)
    'Culinary Arts (D3)',
    
    // Master's Degree (S2)
    'Information Technology (S2)',
  ];

  static List<String> getEducationLevels() => [
    'D3 (Diploma)',
    'S1 (Bachelor\'s Degree)',
    'S2 (Master\'s Degree)',
  ];
} 