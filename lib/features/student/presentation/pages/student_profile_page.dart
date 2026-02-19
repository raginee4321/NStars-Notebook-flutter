import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/fee_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_event.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentProfilePage extends StatelessWidget {
  final Student student;

  const StudentProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeeBloc>()..add(LoadFees(student.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    _buildFeeStatus(context),
                    const SizedBox(height: 24),
                    _buildFeeHistory(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: student.profileImageUrl != null && student.profileImageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(student.profileImageUrl!)
                : null,
            child: student.profileImageUrl == null || student.profileImageUrl!.isEmpty
                ? Text(
                    student.name[0].toUpperCase(),
                    style: TextStyle(
                        fontSize: 48,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'UID: ${student.uid}',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(context, Icons.phone, 'Phone', student.phone),
            const Divider(),
            _buildInfoRow(context, Icons.workspace_premium, 'Belt', student.belt),
            const Divider(),
            _buildInfoRow(context, Icons.group, 'Batch', student.batch),
            const Divider(),
            _buildInfoRow(context, Icons.calendar_today, 'Admission Date', student.doj),
            const Divider(),
            _buildInfoRow(context, Icons.wc, 'Gender', student.gender),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeStatus(BuildContext context) {
    return BlocBuilder<FeeBloc, FeeState>(
      builder: (context, state) {
        if (state is FeeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FeeLoaded) {
          final now = DateTime.now();
          final currentMonth = DateFormat('MMMM', 'en_US').format(now);
          final currentYear = now.year.toString();
          
          final isPaid = state.fees.any((f) {
            // Case 1: "Month Year" format (e.g. "February 2026")
            if (f.month.contains(currentYear)) {
              return f.month.startsWith(currentMonth);
            }
            
            // Case 2: "Month" format without year (check paymentDate year)
            if (!f.month.contains(RegExp(r'\d{4}'))) {
              try {
                final paymentDate = DateTime.parse(f.paymentDate);
                return f.month == currentMonth && paymentDate.year == now.year;
              } catch (_) {}
            }
            return false;
          });

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isPaid ? Icons.check_circle : Icons.error_outline,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Status: ${isPaid ? "Paid" : "Pending"}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPaid ? Colors.green[800] : Colors.orange[800],
                        ),
                      ),
                      Text(
                        isPaid 
                          ? 'You are all set for $currentMonth!' 
                          : 'Please clear your $currentMonth fees.',
                        style: GoogleFonts.outfit(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeeHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<FeeBloc, FeeState>(
          builder: (context, state) {
            if (state is FeeLoaded && state.fees.isNotEmpty) {
              final sortedFees = List.from(state.fees)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedFees.length > 5 ? 5 : sortedFees.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final fee = sortedFees[index];
                  String displayMonth = fee.month;
                  if (!displayMonth.contains(RegExp(r'\d{4}'))) {
                    try {
                      final date = DateTime.parse(fee.paymentDate);
                      displayMonth = "$displayMonth ${date.year}";
                    } catch (_) {}
                  }
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                      title: Text(displayMonth, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      subtitle: Text('${fee.mode} • ${DateFormat('dd MMM yy').format(DateTime.parse(fee.paymentDate))}'),
                      trailing: Text('₹${fee.amount.toStringAsFixed(0)}', 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ),
                  );
                },
              );
            }
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No recent payments found'),
            );
          },
        ),
      ],
    );
  }
}
