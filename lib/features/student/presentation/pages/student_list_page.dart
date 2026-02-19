import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_event.dart';



class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('N Stars', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rocket Rinder')),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<StudentBloc>().add(LoadStudents());
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-student'),
          label: const Text('Add Student'),
          icon: const Icon(Icons.add),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4, // Reduce width to 40% of screen
                  child: Opacity(
                    opacity: 0.1, 
                    child: Image.asset(
                      'assets/images/home_bg.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, state) {
                      if (state is StudentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is StudentLoaded) {
                        final students = state.students;
                        final query = state.searchQuery;

                        if (query.isEmpty) {
                          // Return empty widget to show background image
                          return const SizedBox.shrink();
                        }
    
                        if (students.isEmpty) {
                          return const Center(child: Text('No students found.'));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: students.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withValues(alpha: 0.9), // Slightly transparent card to show bg? Or keep opaque? User didn't specify, standard is opaque card.
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  context.push('/student/${student.id}', extra: student);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: 'avatar_${student.id}',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 2),
                                          ),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                            backgroundImage: student.profileImageUrl != null && student.profileImageUrl!.isNotEmpty
                                                ? CachedNetworkImageProvider(student.profileImageUrl!)
                                                : null,
                                            child: (student.profileImageUrl == null || student.profileImageUrl!.isEmpty)
                                                ? Text(
                                                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.primary, 
                                                      fontSize: 24, 
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  student.phone,
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'DOJ: ${student.doj}',
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is StudentError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: Text('Start adding students!'));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: TextField(
        onChanged: (value) {
          context.read<StudentBloc>().add(SearchStudents(value));
        },
        decoration: InputDecoration(
          hintText: 'Search students...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
