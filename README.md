# Flowlytics - Student Management System

Aplikasi manajemen data mahasiswa berbasis Flutter dengan penyimpanan lokal menggunakan SharedPreferences.

## Fitur Utama

### 1. Model Data Mahasiswa
```dart
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
}
```

### 2. Operasi CRUD

#### Create (Tambah Data)
```dart
// Menambah mahasiswa baru
await studentProvider.addStudent(Student(
  id: 'unique_id',
  name: 'Nama Mahasiswa',
  nim: '12345678',
  major: 'Jurusan',
  email: 'email@example.com',
  imageUrl: 'url_gambar',
  dateOfBirth: DateTime(2000, 1, 1),
  gradeLevel: '1',
  phone: '081234567890'
));
```

#### Read (Baca Data)
```dart
// Mengambil semua data mahasiswa
List<Student> students = studentProvider.students;

// Mengambil data mahasiswa spesifik
Student student = students.firstWhere((s) => s.id == 'id_yang_dicari');
```

#### Update (Update Data)
```dart
// Update data mahasiswa
await studentProvider.updateStudent(updatedStudent);
```

#### Delete (Hapus Data)
```dart
// Menghapus mahasiswa berdasarkan ID
await studentProvider.removeStudent('id_yang_dihapus');
```

### 3. State Management
```dart
// Mengakses provider di widget
final studentProvider = Provider.of<StudentProvider>(context);

// Mendengarkan perubahan
Consumer<StudentProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.students.length,
      itemBuilder: (context, index) {
        return StudentCard(student: provider.students[index]);
      },
    );
  },
);
```

### 4. Penyimpanan Lokal
- Data disimpan otomatis menggunakan SharedPreferences
- Format penyimpanan: JSON
- Auto-load saat aplikasi dimulai
- Fallback ke data default jika terjadi error

### 5. Navigasi
```dart
// Setup routes di MaterialApp
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomePage(),
    '/students': (context) => StudentListPage(),
    '/student/add': (context) => AddStudentPage(),
    '/student/edit': (context) => EditStudentPage(),
    '/student/detail': (context) => StudentDetailPage(),
  },
);

// Navigasi antar halaman
// Push ke halaman baru
Navigator.pushNamed(context, '/students');

// Push dengan data
Navigator.pushNamed(
  context, 
  '/student/detail',
  arguments: student,
);

// Pop kembali ke halaman sebelumnya
Navigator.pop(context);

// Pop dengan data
Navigator.pop(context, result);

// Mengambil data dari navigasi
final student = ModalRoute.of(context)!.settings.arguments as Student;
```

## Penggunaan Provider

1. Setup Provider di `main.dart`:
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StudentProvider(),
      child: MyApp(),
    ),
  );
}
```

2. Akses Data di Widget:
```dart
// Read-only access
final students = Provider.of<StudentProvider>(context).students;

// Dengan akses untuk modifikasi
final provider = Provider.of<StudentProvider>(context, listen: false);
```

## Error Handling
- Semua operasi CRUD memiliki error handling
- Data akan tetap tersimpan meskipun aplikasi ditutup
- Fallback ke data default jika terjadi error saat loading

## Best Practices
1. Selalu gunakan `await` untuk operasi async
2. Gunakan `notifyListeners()` setelah modifikasi data
3. Implementasikan error handling untuk operasi database
4. Gunakan `Consumer` untuk widget yang perlu update otomatis
5. Gunakan named routes untuk navigasi yang lebih terstruktur
6. Selalu validasi data sebelum melakukan operasi CRUD
7. Implementasikan loading state saat melakukan operasi async
8. Selalu kompres gambar sebelum disimpan untuk menghemat ruang
9. Implementasikan loading indicator saat mengambil/menyimpan foto
10. Berikan feedback ke user saat operasi foto berhasil/gagal

### 6. Pengelolaan Foto Profil
```dart
// 1. Tambahkan dependencies di pubspec.yaml
dependencies:
  image_picker: ^1.0.7
  path_provider: ^2.1.2

// 2. Implementasi di Provider
class ProfileProvider with ChangeNotifier {
  String? _profileImage;
  
  String? get profileImage => _profileImage;

  Future<void> updateProfileImage(String imagePath) async {
    try {
      // Konversi gambar ke base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64Image);
      
      _profileImage = base64Image;
      notifyListeners();
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

  Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _profileImage = prefs.getString('profile_image');
      notifyListeners();
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }
}

// 3. Penggunaan di Widget
class ProfileSettingsPage extends StatelessWidget {
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await Provider.of<ProfileProvider>(context, listen: false)
          .updateProfileImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Tampilkan foto profil
            if (provider.profileImage != null)
              Image.memory(
                base64Decode(provider.profileImage!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            
            // Tombol untuk memilih foto
            ElevatedButton(
              onPressed: () => _pickImage(context),
              child: Text('Pilih Foto'),
            ),
          ],
        );
      },
    );
  }
}
```
