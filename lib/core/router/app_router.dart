import 'package:n_stars_notebook/features/student/presentation/pages/student_list_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/add_edit_student_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/student_detail_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/fee_history_page.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:go_router/go_router.dart';
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
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
        ]
      ),
      // Add more routes here
    ],
  );
}
