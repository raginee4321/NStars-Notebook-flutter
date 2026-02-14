import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:n_stars_notebook/core/utils/error_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/fee_bloc.dart';
import 'package:n_stars_notebook/features/student/presentation/widgets/add_fee_dialog.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart';
import 'package:intl/intl.dart';

class StudentDetailPage extends StatefulWidget {
  final Student? student;
  final String id;

  const StudentDetailPage({super.key, this.student, required this.id});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  bool _isPersonalInfoExpanded = false;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text(
            'Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StudentBloc>().add(RemoveStudent(widget.id));
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
    if (widget.student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Student not found')),
      );
    }

    final student = widget.student!;

    return BlocProvider(
      create: (context) => sl<FeeBloc>()..add(LoadFees(student.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'avatar_${student.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            backgroundImage: student.profileImageUrl != null &&
                                    student.profileImageUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    student.profileImageUrl!)
                                : null,
                            child: student.profileImageUrl == null ||
                                    student.profileImageUrl!.isEmpty
                                ? Text(
                                    student.name.isNotEmpty
                                        ? student.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                        fontSize: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Removed the top Edit button as per request to have edit icon on personal info
                    // Instead, we can keep a general edit button if desired, but user focused on "personal info... edit icon(pencil)"
                    // I will leave the top edit button as it edits the *student details* (name, image etc) which is different from just viewing personal info.
                    // But maybe the user meant "edit visibility".
                    // "there should be edit icon(pencil) on which when I click then only the personal detail should be extended"
                    // This implies the pencil is for *viewing* the details.
                    // The existing edit button was:
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
                    
                    // Personal Info Header with Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader(context, "Personal Info"),
                        IconButton(
                          icon: Icon(
                            _isPersonalInfoExpanded ? Icons.visibility_off : Icons.visibility,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPersonalInfoExpanded = !_isPersonalInfoExpanded;
                            });
                          },
                          tooltip: _isPersonalInfoExpanded ? 'Hide Details' : 'Show Details',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isPersonalInfoExpanded)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildDetailRow(context, Icons.phone_outlined,
                                  "Phone", student.phone),
                              const Divider(height: 24),
                              _buildDetailRow(
                                  context,
                                  Icons.calendar_today_outlined,
                                  "Admission Date",
                                  student.doj),
                              const Divider(height: 24),
                              _buildDetailRow(context, Icons.person_outline,
                                  "Gender", student.gender),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Financials Section
                    _buildFinancialsSection(context, student),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialsSection(BuildContext context, Student student) {
    return BlocBuilder<FeeBloc, FeeState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, "Financials"),
                // Add Entry Button
                FilledButton.tonalIcon(
                  onPressed: () => _showAddFeeDialog(context, student),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Entry"),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state is FeeLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is FeeLoaded) ...[
              if (state.fees.isNotEmpty) ...[
                 _buildFeesSummary(context, state.fees),
                 const SizedBox(height: 20),
                 Builder(
                   builder: (context) {
                     // Sort fees by date ascending (Oldest first: Jan -> Feb)
                     final sortedFees = List<Fee>.from(state.fees)..sort((a, b) {
                        try {
                           // Try to parse using stored paymentDate which might just be when it was paid, 
                           // but ideally we want to sort by the *Month* of the fee.
                           // However, Fee entity stores "Month Year" in `month` field usually.
                           // Let's rely on paymentDate as a proxy if it matches the month, 
                           // or better, parse the `month` string.
                           
                           // Helper to get date from "Month Year" string
                           DateTime getDate(String m, String fallbackDate) {
                             try {
                               // Assuming format "Month Year" e.g. "January 2025"
                               return DateFormat('MMMM yyyy').parse(m);
                             } catch (_) {
                               // Fallback to paymentDate if parsing fails
                               return DateTime.parse(fallbackDate); 
                             }
                           }
                           
                           final dateA = getDate(a.month.contains(RegExp(r'\d{4}')) ? a.month : '${a.month} ${DateTime.parse(a.paymentDate).year}', a.paymentDate);
                           final dateB = getDate(b.month.contains(RegExp(r'\d{4}')) ? b.month : '${b.month} ${DateTime.parse(b.paymentDate).year}', b.paymentDate);
                           
                           return dateA.compareTo(dateB);
                        } catch (_) {
                           return 0;
                        }
                     });

                     return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedFees.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final fee = sortedFees[index];
                          return _buildFeeItem(context, fee);
                        },
                      );
                   }
                 ),
              ] else
                _buildEmptyFees(context),
            ] else if (state is FeeError)
              Center(child: Text(state.message))
            else
              _buildEmptyFees(context),
          ],
        );
      },
    );
  }

  Future<void> _showAddFeeDialog(BuildContext context, Student student) async {
    final state = context.read<FeeBloc>().state;
                  List<String> paidMonths = [];
                  if (state is FeeLoaded) {
                    paidMonths = state.fees.map((f) {
                      // If month already has year (e.g. "January 2025"), use it.
                      // Otherwise append year from paymentDate
                      if (f.month.contains(RegExp(r'\d{4}'))) {
                        return f.month;
                      }
                      final date = DateTime.parse(f.paymentDate);
                      return '${f.month} ${date.year}';
                    }).toList();
                  }

                  final fees = await showDialog<List<Fee>>(
                    context: context,
                    builder: (ctx) => AddFeeDialog(
                      studentId: student.id,
                      studentName: student.name,
                      paidMonths: paidMonths,
                      studentDoj: student.doj,
                    ),
                  );

                  if (fees != null && fees.isNotEmpty && context.mounted) {
                    try {
                      // Submit each fee sequentially
                      for (final fee in fees) {
                        await context.read<FeeBloc>().submitFee(fee);
                      }
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${fees.map((f) => f.month).join(', ')} fees added successfully 🎉'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHelper.getErrorMessage(e)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
  }

  Widget _buildFeesSummary(BuildContext context, List<Fee> fees) {
    final totalAmount = fees.fold<double>(0, (sum, item) => sum + item.amount);
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM').format(now);
    final currentYear = now.year.toString();
    
    final paidThisMonth = fees.any((f) {
        if (f.month.contains(currentYear)) {
            return f.month.startsWith(currentMonth);
        }
        if (!f.month.contains(RegExp(r'\d{4}'))) {
            final paymentDate = DateTime.parse(f.paymentDate);
            return f.month == currentMonth && paymentDate.year == now.year;
        }
        return false;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Paid',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: paidThisMonth ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      paidThisMonth ? Icons.check_circle : Icons.pending_actions,
                      size: 16,
                      color: paidThisMonth ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      paidThisMonth ? 'Paid This Month' : 'Pending',
                      style: TextStyle(
                        color: paidThisMonth ? Colors.green.shade700 : Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFees(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            "No fee records yet",
            style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(BuildContext context, Fee fee) {
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onLongPress: () {
             showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Fee Record'),
                    content: Text('Are you sure you want to delete this ${fee.month} fee record of ₹${fee.amount.toStringAsFixed(0)}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Close dialog
                          try {
                            await context.read<FeeBloc>().deleteFee(fee.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fee record deleted successfully'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ErrorHelper.getErrorMessage(e)),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayMonth,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.payment,
                          size: 14, color: Theme.of(context).disabledColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${fee.mode} • ',
                          style: TextStyle(
                              color: Theme.of(context).disabledColor,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.event,
                          size: 14, color: Theme.of(context).disabledColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          DateFormat('dd MMM yy')
                              .format(DateTime.parse(fee.paymentDate)),
                          style: TextStyle(
                              color: Theme.of(context).disabledColor,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹${fee.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
