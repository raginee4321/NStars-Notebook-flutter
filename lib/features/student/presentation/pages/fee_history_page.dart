import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/fee_bloc.dart';
import 'package:n_stars_notebook/features/student/presentation/widgets/add_fee_dialog.dart';
import 'package:n_stars_notebook/core/utils/error_helpers.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart';
import 'package:intl/intl.dart';

class FeeHistoryPage extends StatelessWidget {
  final Student student;

  const FeeHistoryPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeeBloc>()..add(LoadFees(student.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${student.name}\'s Fees'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
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
              child: BlocBuilder<FeeBloc, FeeState>(
                builder: (context, state) {
                  if (state is FeeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FeeLoaded) {
                    if (state.fees.isEmpty) {
                      return _buildEmptyFees(context);
                    }

                    final totalAmount = state.fees.fold<double>(0, (sum, item) => sum + item.amount);
                    final now = DateTime.now();
                    final currentMonth = DateFormat('MMMM').format(now);
                    final currentYear = now.year.toString();
                    
                    final paidThisMonth = state.fees.any((f) {
                        if (f.month.contains(currentYear)) {
                            return f.month.startsWith(currentMonth);
                        }
                        // Fallback for legacy data (assuming current year if no year in string?)
                        // actually, legacy data is just "Month". If we are in Feb 2026, and legacy data is "February", 
                        // it might be Feb 2025. We should check paymentDate year.
                        if (!f.month.contains(RegExp(r'\d{4}'))) {
                            final paymentDate = DateTime.parse(f.paymentDate);
                            return f.month == currentMonth && paymentDate.year == now.year;
                        }
                        return false;
                    });

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildFeesSummary(context, totalAmount, paidThisMonth),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Payment Records",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${state.fees.length} Total",
                              style: TextStyle(color: Theme.of(context).disabledColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.fees.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final fee = state.fees[index];
                            return _buildFeeItem(context, fee);
                          },
                        ),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    );
                  } else if (state is FeeError) {
                    return Center(child: Text(state.message));
                  }
                  return _buildEmptyFees(context);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton.extended(
                onPressed: () async {
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
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Fee Record'),
              );
            }
        ),
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

  Widget _buildFeesSummary(BuildContext context, double total, bool paidThisMonth) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Paid', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
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
                      Icon(Icons.payment, size: 14, color: Theme.of(context).disabledColor),
                      const SizedBox(width: 4),
                      Text(
                        '${fee.mode} • ',
                        style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 13),
                      ),
                      Icon(Icons.event, size: 14, color: Theme.of(context).disabledColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yy').format(DateTime.parse(fee.paymentDate)),
                        style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 13),
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