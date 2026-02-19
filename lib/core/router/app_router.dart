import 'package:n_stars_notebook/features/student/presentation/pages/student_list_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/add_edit_student_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/student_detail_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/fee_history_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/student_profile_page.dart';
import 'package:n_stars_notebook/features/auth/presentation/pages/login_page.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_state.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final loggingIn = state.matchedLocation == '/login';

      if (authState is AuthInitial) {
        return null; // Stay where we are (showing splash) until state is resolved
      }

      if (authState is AuthUnauthenticated) {
        return loggingIn ? null : '/login';
      }

      if (authState is AuthAuthenticated) {
        if (loggingIn) {
          return authState.user.role == 'admin' ? '/' : '/profile';
        }
        
        // Prevent student from accessing admin routes
        final studentOnlyRoutes = ['/profile'];
        final isAdminRoute = !studentOnlyRoutes.contains(state.matchedLocation) && state.matchedLocation != '/login';
        
        if (authState.user.role == 'student' && isAdminRoute) {
          return '/profile';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            return StudentProfilePage(student: authState.user);
          }
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const StudentListPage(),
        routes: [
          GoRoute(
            path: 'add-student',
            builder: (context, state) {
              final student = state.extra as Student?;
              return AddEditStudentPage(student: student);
            },
          ),
          GoRoute(
            path: 'student/:id',
            builder: (context, state) {
              final student = state.extra as Student?;
              return StudentDetailPage(student: student, id: state.pathParameters['id']!);
            },
            routes: [
              GoRoute(
                path: 'fees',
                builder: (context, state) {
                  final student = state.extra as Student;
                  return FeeHistoryPage(student: student);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Helper class to convert Bloc stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
