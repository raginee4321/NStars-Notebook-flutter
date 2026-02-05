import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';



class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('N Stars TKD', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-student'),
          label: const Text('Add Student'),
          icon: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) {
                  if (state is StudentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentLoaded) {
                    final students = state.students;
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.push('/student/${student.id}', extra: student);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'avatar_${student.id}',
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      child: Text(
                                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary, 
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold
                                        ),
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
                                        Text(
                                          student.phone,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
