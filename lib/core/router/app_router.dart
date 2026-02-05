import 'package:n_stars_notebook/features/student/presentation/pages/student_list_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/add_edit_student_page.dart';
import 'package:n_stars_notebook/features/student/presentation/pages/student_detail_page.dart';
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
               // If logic requires fetching by ID if extra is null, we can do that.
               // For now assume extra is passed or handle null in page (not this one, but a Detail page if we create it)
               // Re-using AddEdit for detail/edit flow or creating separate Detail page?
               // Creating separate Detail page next.
               // For this route let's point to a DetailPage which I will create next.
               return StudentDetailPage(student: student, id: state.pathParameters['id']!);
            },
          ),
        ]
      ),
      // Add more routes here
    ],
  );
}
