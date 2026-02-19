import 'package:n_stars_notebook/features/auth/domain/repositories/auth_repository.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/data/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n_stars_notebook/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabase;
  final SharedPreferences prefs;

  AuthRepositoryImpl({required this.supabase, required this.prefs});

  static const String _userUidKey = 'user_uid';

  @override
  Future<Student?> signIn(String uid, String password) async {
    // Check if it's the Admin first
    if (uid == 'admin') {
      try {
        final response = await supabase.auth.signInWithPassword(
          email: 'nstarstaekwondo@gmail.com',
          password: password,
        );
        if (response.user != null) {
          return const Student(
            id: 'admin',
            uid: 'admin',
            name: 'Administrator',
            doj: '',
            gender: '',
            phone: '',
            belt: '',
            batch: '',
            role: 'admin',
          );
        }
      } catch (e) {
        // Handle admin login failure
      }
    }

    // Check students table for UID and password
    final response = await supabase
        .from(AppConstants.studentsCollection)
        .select()
        .eq('uid', uid)
        .eq('phone', password)
        .maybeSingle();

    if (response != null) {
      final student = StudentModel.fromJson(response);
      // Save student UID and role for persistence
      await prefs.setString(_userUidKey, uid);
      await prefs.setString('user_role', student.role);
      return student;
    }
    
    return null;
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
    await prefs.remove(_userUidKey);
    await prefs.remove('user_role');
  }

  @override
  Future<Student?> getCurrentUser() async {
    // 1. Check if it's the Admin (Supabase session)
    final session = supabase.auth.currentSession;
    if (session != null && session.user.email == 'nstarstaekwondo@gmail.com') {
      return const Student(
        id: 'admin',
        uid: 'admin',
        name: 'Administrator',
        doj: '',
        gender: '',
        phone: '',
        belt: '',
        batch: '',
        role: 'admin',
      );
    }
    
    // 2. Check if it's a student (Local persistence)
    final savedUid = prefs.getString(_userUidKey);
    if (savedUid != null) {
      final response = await supabase
          .from(AppConstants.studentsCollection)
          .select()
          .eq('uid', savedUid)
          .maybeSingle();
          
      if (response != null) {
        return StudentModel.fromJson(response);
      }
    }
    
    return null;
  }
}
