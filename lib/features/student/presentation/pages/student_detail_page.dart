import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

class StudentDetailPage extends StatelessWidget {
  final Student? student;
  final String id;

  const StudentDetailPage({super.key, this.student, required this.id});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StudentBloc>().add(RemoveStudent(id));
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Hero(
                      tag: 'avatar_${student!.id}',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          student!.name.isNotEmpty ? student!.name[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student!.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       IconButton.filledTonal(
                        onPressed: () => context.push('/add-student', extra: student),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Profile',
                       ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Personal Info"),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(context, Icons.phone, "Phone", student!.phone),
                          const Divider(),
                          _buildDetailRow(context, Icons.calendar_today, "Admission Date", student!.doj),
                          const Divider(),
                          _buildDetailRow(context, Icons.person, "Gender", student!.gender),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(context, "Fees History"),
                      FilledButton.icon(
                        onPressed: () {}, // TODO
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add"),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                         Icon(Icons.receipt_long_outlined, size: 48, color: Theme.of(context).disabledColor),
                         const SizedBox(height: 8),
                         Text("No transactions yet", style: TextStyle(color: Theme.of(context).disabledColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
