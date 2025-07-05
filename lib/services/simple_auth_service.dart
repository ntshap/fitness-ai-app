// Removed crypto import to avoid database issues
import 'package:fitness_ai_app/services/database_helper.dart';
import 'package:fitness_ai_app/services/image_service.dart';
import 'dart:io';

class SimpleAuthService {
  static final SimpleAuthService _instance = SimpleAuthService._internal();

  SimpleAuthService._internal() {
    print('=== SimpleAuthService._internal() called ===');
    _initializeTestUser();
  }

  void _initializeTestUser() {
    // Always ensure test user exists
    try {
      print('Initializing SimpleAuthService with test user');

      // Check if test user already exists
      bool testUserExists = _users.any((user) => user['email'] == 'test@test.com');

      if (!testUserExists) {
        _users.add({
          'id': 1,
          'email': 'test@test.com',
          'password': _hashPassword('test123'), // Use the hash function to properly hash the password
          'name': 'Test User',
          'gender': 'Wanita',
          'age': 25,
          'height': 170.0,
          'weight': 65.0,
          'fitness_goal': 'Turunkan Berat Badan',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Test user added. Total users: ${_users.length}');
      } else {
        print('Test user already exists. Total users: ${_users.length}');
      }

      print('Test user email: test@test.com');
      print('Test user password: test123');
    } catch (e) {
      print('Error adding test user: $e');
    }
  }

  factory SimpleAuthService() {
    print('=== SimpleAuthService() factory called ===');
    print('Instance users count: ${_instance._users.length}');

    // Ensure test user is always available
    if (_instance._users.isEmpty) {
      print('No users found, reinitializing test user...');
      _instance._initializeTestUser();
    }

    return _instance;
  }

  // In-memory storage for testing - using a different approach
  final List<Map<String, dynamic>> _users = <Map<String, dynamic>>[];
  Map<String, dynamic>? _currentUser;
  
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Simple password "hashing" for testing (not secure, just for demo)
  String _hashPassword(String password) {
    try {
      // For testing purposes, just add a simple prefix
      // In production, use proper hashing like bcrypt or argon2
      return 'hashed_$password';
    } catch (e) {
      print('Error in _hashPassword: $e');
      throw e;
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('=== REGISTRATION DEBUG START ==='); // Debug
      print('Registration attempt for email: $email'); // Debug
      print('Current users in memory: ${_users.length}'); // Debug

      // Check if user already exists using simple loop
      bool userExists = false;
      for (var user in _users) {
        print('Checking existing user: ${user['email']}'); // Debug
        if (user['email'] == email) {
          userExists = true;
          break;
        }
      }

      if (userExists) {
        print('User already exists'); // Debug
        return {
          'success': false,
          'message': 'Email sudah terdaftar',
        };
      }

      // Hash password
      final hashedPassword = _hashPassword(password);
      print('Password hashed: $hashedPassword'); // Debug
      
      // Create user data
      final userData = {
        'id': _users.length + 1,
        'email': email,
        'password': hashedPassword,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Adding user data: $userData'); // Debug

      // Add user to in-memory storage
      _users.add(userData);
      print('User added. Total users: ${_users.length}'); // Debug
      
      // Create user data without password for current user
      _currentUser = {
        'id': userData['id'],
        'email': userData['email'],
        'name': userData['name'],
        'created_at': userData['created_at'],
        'updated_at': userData['updated_at'],
      };
      
      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user': _currentUser,
      };
    } catch (e) {
      print('Registration error: $e'); // Debug
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('=== LOGIN DEBUG START ==='); // Debug
      print('Login attempt for email: $email'); // Debug
      print('Current users in memory: ${_users.length}'); // Debug

      // Find user in memory using a simple loop to avoid any read-only issues
      Map<String, dynamic>? foundUser;
      print('Starting user search...'); // Debug
      for (int i = 0; i < _users.length; i++) {
        print('Checking user $i: ${_users[i]['email']}'); // Debug
        if (_users[i]['email'] == email) {
          print('Found matching user at index $i'); // Debug
          foundUser = _users[i];
          break;
        }
      }

      print('User found: ${foundUser != null}'); // Debug

      if (foundUser == null) {
        print('User not found in memory'); // Debug
        return {
          'success': false,
          'message': 'Email tidak ditemukan',
        };
      }

      print('Verifying password...'); // Debug
      // Verify password
      final hashedPassword = _hashPassword(password);
      final storedPassword = foundUser['password'];
      print('Hashed input password: $hashedPassword'); // Debug
      print('Stored password: $storedPassword'); // Debug

      if (storedPassword != hashedPassword) {
        print('Password mismatch'); // Debug
        return {
          'success': false,
          'message': 'Password salah',
        };
      }

      print('Password verified, creating user session...'); // Debug
      // Create a new map without password for security
      try {
        _currentUser = <String, dynamic>{
          'id': foundUser['id'],
          'email': foundUser['email'],
          'name': foundUser['name'],
          'gender': foundUser['gender'],
          'age': foundUser['age'],
          'height': foundUser['height'],
          'weight': foundUser['weight'],
          'fitness_goal': foundUser['fitness_goal'],
          'created_at': foundUser['created_at'],
          'updated_at': foundUser['updated_at'],
        };
        print('User session created successfully'); // Debug
      } catch (e) {
        print('Error creating user session: $e'); // Debug
        throw e;
      }

      print('Login successful, returning result...'); // Debug
      return {
        'success': true,
        'message': 'Login berhasil',
        'user': _currentUser,
      };
    } catch (e) {
      print('Login error: $e'); // Debug logging
      print('Error type: ${e.runtimeType}'); // Debug
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update user profile (name only)
  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      // Find user in memory and update name
      final userIndex = _users.indexWhere((user) => user['id'] == _currentUser!['id']);
      if (userIndex != -1) {
        _users[userIndex]['name'] = name;
        _users[userIndex]['updated_at'] = DateTime.now().toIso8601String();

        // Update current user
        _currentUser!['name'] = name;

        return {
          'success': true,
          'message': 'Profil berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      // Find user in memory and update
      final userIndex = _users.indexWhere((user) => user['id'] == _currentUser!['id']);
      if (userIndex != -1) {
        _users[userIndex].addAll(profileData);
        _users[userIndex]['updated_at'] = DateTime.now().toIso8601String();

        // Update current user
        _currentUser!.addAll(profileData);

        return {
          'success': true,
          'message': 'Profil berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update profile picture
  Future<Map<String, dynamic>> updateProfilePicture(File imageFile) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      final ImageService imageService = ImageService();
      final int userId = _currentUser!['id'];

      // Save the new profile picture
      final String? savedPath = await imageService.saveProfilePicture(imageFile, userId);

      if (savedPath == null) {
        return {
          'success': false,
          'message': 'Gagal menyimpan foto profil',
        };
      }

      // Delete old profile picture if exists
      final String? oldProfilePicture = _currentUser!['profile_picture'];
      if (oldProfilePicture != null && oldProfilePicture.isNotEmpty) {
        await imageService.deleteProfilePicture(oldProfilePicture);
      }

      // Update profile data
      final profileData = {'profile_picture': savedPath};
      final result = await updateUserProfile(profileData);

      if (result['success']) {
        // Clean up old profile pictures
        await imageService.cleanupOldProfilePictures(userId, savedPath);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get profile picture path
  String? getProfilePicturePath() {
    return _currentUser?['profile_picture'];
  }

  // Check if profile picture exists
  Future<bool> hasValidProfilePicture() async {
    final String? profilePicturePath = getProfilePicturePath();
    if (profilePicturePath == null || profilePicturePath.isEmpty) {
      return false;
    }

    final ImageService imageService = ImageService();
    return await imageService.profilePictureExists(profilePicturePath);
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      // Calculate real statistics from database
      final userId = _currentUser!['id'];
      if (userId == null) {
        // For new users without database ID, return zeros
        return {
          'success': true,
          'stats': {
            'workoutCount': 0,
            'totalCalories': 0,
            'progressCount': 0,
            'analysisCount': 0,
          },
        };
      }

      // Get real data from database
      final DatabaseHelper dbHelper = DatabaseHelper();

      // Get workout count and total calories
      final workouts = await dbHelper.getWorkouts(userId);
      final workoutCount = workouts.length;
      final totalCalories = workouts.fold<int>(0, (sum, workout) =>
          sum + (workout['calories_burned'] as int? ?? 0));

      // Get progress count
      final progress = await dbHelper.getProgress(userId);
      final progressCount = progress.length;

      // Get AI analysis count
      final analyses = await dbHelper.getAIAnalysis(userId);
      final analysisCount = analyses.length;

      return {
        'success': true,
        'stats': {
          'workoutCount': workoutCount,
          'totalCalories': totalCalories,
          'progressCount': progressCount,
          'analysisCount': analysisCount,
        },
      };
    } catch (e) {
      print('Error getting user stats: $e');
      // Return zeros on error instead of dummy data
      return {
        'success': true,
        'stats': {
          'workoutCount': 0,
          'totalCalories': 0,
          'progressCount': 0,
          'analysisCount': 0,
        },
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
  }

  // Initialize auth (simplified)
  Future<void> initializeAuth() async {
    // Simple initialization
  }

  // Reset authentication state (for debugging)
  void resetAuth() {
    print('=== RESETTING AUTH STATE ===');
    _currentUser = null;
    _users.clear();
    _initializeTestUser();
    print('Auth state reset. Users count: ${_users.length}');
  }

  // Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'users_count': _users.length,
      'current_user': _currentUser != null ? _currentUser!['email'] : null,
      'users_list': _users.map((u) => u['email']).toList(),
    };
  }
}
