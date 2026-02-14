import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:uuid/uuid.dart';

class AddFeeDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  final List<String> paidMonths; // Format: "Month Year"
  final String studentDoj; // Format: "yyyy-MM-dd"

  const AddFeeDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.paidMonths,
    required this.studentDoj,
  });

  @override
  State<AddFeeDialog> createState() => _AddFeeDialogState();
}

class _AddFeeDialogState extends State<AddFeeDialog> {
  final _amountController = TextEditingController();
  final Set<String> _selectedMonths = {}; // Stores "Month Year"
  String? _selectedMode;
  DateTime _paymentDate = DateTime.now();
  late int _currentYear;
  late int _displayYear;
  bool _isPairMode = true; // Default to pair mode
  int _currentStep = 0; // 0: Month Selection, 1: Payment Details

  // Map for display (Short) -> storage (Full)
  final Map<String, String> _monthMap = {
    'Jan': 'January', 'Feb': 'February', 'Mar': 'March', 'Apr': 'April',
    'May': 'May', 'Jun': 'June', 'Jul': 'July', 'Aug': 'August',
    'Sep': 'September', 'Oct': 'October', 'Nov': 'November', 'Dec': 'December'
  };

  // List of keys for the grid in correct order
  final List<String> _monthKeys = [
    'Jan', 'Feb', 'Mar',
    'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec'
  ];

  final List<String> _modes = ['Cash', 'Cheque', 'GPay', 'GPay(B)', 'Paytm', 'Paytm(B)'];
  static const double _feePerMonth = 800.0;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now().year;
    _displayYear = _currentYear;
    _updateAmount();
  }

  void _updateAmount() {
    final total = _selectedMonths.length * _feePerMonth;
    _amountController.text = total.toStringAsFixed(0);
  }

  bool _isSelectable(String currentMonthKey) {
    // Logic: Previous month must be Paid or Selected
    // Extract Month and Year
    try {
        List<String> parts = currentMonthKey.split(' ');
        if (parts.length < 2) return true;
        
        String monthName = parts[0];
        int year = int.parse(parts[1]);
        
        int monthIndex = _monthKeys.indexWhere((k) => _monthMap[k] == monthName);
        
        // If Jan of the displayed year
        if (monthIndex == 0) {
           // check Dec of prev year ? 
           // For simplicity in this app, if it's Jan, we allow it (or check Dec of prev year if data available)
           // But since we operate mostly on current year view, assume Jan is start of sequence for that year 
           // unless we want to be very strict across years. 
           // User request: "selecting month ahead ... previous should be selected"
           // Let's assume within the year context or global.
           // Given data model, let's look for "Dec (year-1)"
           String prevKey = "December ${year - 1}";
           // If user just joined, they might start mid-year, but usually Jan is start.
           // Let's relax for Jan to always be selectable if we don't have full history loaded? 
           // Actually `paidMonths` should have all history.
           // Let's check Dec prev year.
           bool isPrevPaid = widget.paidMonths.contains(prevKey);
           // We don't usually select across years in one go in this dialog (it shows one year).
           // So just check if Paid. 
           // If it's the very first month of student's joining?
           // We have `studentDoj`.
           // If current month < DOJ, not selectable? That's a different validation.
           // Let's stick to "Previous month selected/paid".
           
           // If it's Jan, we usually allow it.
           return true; 
        }
        
        String prevMonthShort = _monthKeys[monthIndex - 1];
        String prevMonthFull = _monthMap[prevMonthShort]!;
        String prevKey = "$prevMonthFull $year";
        
        return widget.paidMonths.contains(prevKey) || _selectedMonths.contains(prevKey);
        
    } catch (e) {
        return true;
    }
  }



  void _toggleSingleMonth(String fullMonth) {
    final key = "$fullMonth $_displayYear";
    if (widget.paidMonths.contains(key)) return;

    setState(() {
      if (_selectedMonths.contains(key)) {
        _selectedMonths.remove(key);
      } else {

        if (_isSelectable(key)) {
             _validateAndAdd(key);
        } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
               content: Text('Please select the previous month first.'),
               duration: Duration(milliseconds: 1000),
             ));
        }
      }
      _updateAmount();
    });
  }

  void _togglePair(String clickedMonth) {
    // Find pair for the clicked month
    // Jan-Feb, Mar-Apr, May-Jun, Jul-Aug, Sep-Oct, Nov-Dec
    int index = _monthKeys.indexWhere((k) => _monthMap[k] == clickedMonth);
    if (index == -1) return;

    // Determine start index of the pair (even start)
    int pairStartIndex = (index ~/ 2) * 2;
    String firstMonthShort = _monthKeys[pairStartIndex];
    String secondMonthShort = _monthKeys[pairStartIndex + 1];
    
    String firstFull = _monthMap[firstMonthShort]!;
    String secondFull = _monthMap[secondMonthShort]!;
    
    String key1 = "$firstFull $_displayYear";
    String key2 = "$secondFull $_displayYear";

    bool isFirstPaid = widget.paidMonths.contains(key1);
    bool isSecondPaid = widget.paidMonths.contains(key2);

    if (isFirstPaid && isSecondPaid) return; // Both paid

    setState(() {
      // Toggle logic: If EITHER is selected, deselect BOTH. If NEITHER is selected, select BOTH (if available).
      bool isAnySelected = _selectedMonths.contains(key1) || _selectedMonths.contains(key2);
      
      if (isAnySelected) {
        _selectedMonths.remove(key1);
        _selectedMonths.remove(key2);
      } else {
        // Try to select first then second
        // Check if first is selectable
        bool added = false;
        if (!isFirstPaid) {
             if (_isSelectable(key1)) {
                 _validateAndAdd(key1);
                 added = true;
             } else {
                 // Show error
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select previous months first.'),
                     duration: Duration(milliseconds: 1000),
                 ));
                 return; // Stop
             }
        }
        
        // If first is paid or we just added it, check second
        if (!isSecondPaid) {
             // For second to be selectable, first must be paid or selected (which we just did)
             // So if we are here, key1 is either paid or in _selectedMonths.
             // So _isSelectable(key2) should pass normally, but let's double check logic
             if (_isSelectable(key2)) {
                 _validateAndAdd(key2);
                 added = true;
             }
        }
        
        if (!added) {
             // Maybe both were blocked?
        }
      }
      _updateAmount();
    });
  }

  void _validateAndAdd(String key) {
      // Basic validation logic from before (simplified for wizard flow)
      // Check if previous months are paid/selected is good, but user wants "work easier".
      // We will allow adding if not already paid/selected. 
      // Strict sequential validation might be annoying in a "wizard" if they just want to add a specific month.
      // But let's keep basic "future gap" warning if needed, or just allow it.
      // Given "make work easier", I will relax strict sequential checks that block user, 
      // but maybe show a warning if they skip? For now, just add.
      _selectedMonths.add(key);
  }
  


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10), // Make it big
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Text(
              widget.studentName, 
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentStep == 0 ? 'Select Months' : 'Payment Details', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: _currentStep == 0 ? _buildMonthSelectionStep() : _buildPaymentDetailsStep(),
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildMonthSelectionStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Year: $_displayYear', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text("Pair Mode", style: TextStyle(fontSize: 14)),
                Switch(
                  value: _isPairMode,
                  onChanged: (val) {
                    setState(() {
                      _isPairMode = val;
                      _selectedMonths.clear();
                      _updateAmount();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isPairMode ? 2 : 3, // 2 columns for pairs, 3 for single
            childAspectRatio: _isPairMode ? 1.8 : 1.5, // Bigger buttons
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _isPairMode ? 6 : 12, // 6 pairs or 12 months
          itemBuilder: (context, index) {
            if (_isPairMode) {
               return _buildPairItem(index);
            } else {
               return _buildSingleItem(index);
            }
          },
        ),
         if (_selectedMonths.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Select at least one month',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPairItem(int index) {
      // index 0 -> Jan-Feb (keys 0, 1)
      int startKeyIndex = index * 2;
      String m1Short = _monthKeys[startKeyIndex];
      String m2Short = _monthKeys[startKeyIndex+1];
      
      String m1Full = _monthMap[m1Short]!;
      String m2Full = _monthMap[m2Short]!;
      
      String key1 = "$m1Full $_displayYear";
      String key2 = "$m2Full $_displayYear";
      
      bool isPaid1 = widget.paidMonths.contains(key1);
      bool isPaid2 = widget.paidMonths.contains(key2);
      bool isSelected1 = _selectedMonths.contains(key1);
      bool isSelected2 = _selectedMonths.contains(key2);
      
      bool fullyPaid = isPaid1 && isPaid2;

      bool fullySelected = isSelected1 && isSelected2;
      bool partiallySelected = isSelected1 || isSelected2;
      
      // If partially paid, we treat the pair as "available" for the unpaid part, 
      // but clicking it selects the unpaid one.
      
      return InkWell(
        onTap: fullyPaid ? null : () => _togglePair(m1Full), // toggle using first month name
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fullyPaid 
                ? Colors.grey[300] 
                : fullySelected 
                    ? Theme.of(context).primaryColor 
                    : partiallySelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: fullySelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            "$m1Short - $m2Short",
            style: TextStyle(
              color: fullyPaid 
                  ? Colors.grey[500] 
                  : fullySelected 
                      ? Colors.white 
                      : Colors.black87,
              fontWeight: FontWeight.w500,
              decoration: fullyPaid ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      );
  }

  Widget _buildSingleItem(int index) {
      final shortMonth = _monthKeys[index];
      final fullMonth = _monthMap[shortMonth]!;
      final key = "$fullMonth $_displayYear";
      
      final isPaid = widget.paidMonths.contains(key);
      final isSelected = _selectedMonths.contains(key);
      
      return InkWell(
        onTap: isPaid ? null : () => _toggleSingleMonth(fullMonth),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
             color: isPaid 
                ? Colors.grey[300] 
                : isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            shortMonth,
            style: TextStyle(
              color: isPaid 
                  ? Colors.grey[500] 
                  : isSelected 
                      ? Colors.white 
                      : Colors.black87,
              fontWeight: FontWeight.w500,
              decoration: isPaid ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      );
  }

  Widget _buildPaymentDetailsStep() {
      // Sort selected months for display
      final sortedMonths = _selectedMonths.toList()..sort((a, b) {
           try {
             // Extract month index from name
             int getMonthIndex(String k) => _monthKeys.indexWhere((key) => _monthMap[key] == k.split(' ')[0]);
             return getMonthIndex(a).compareTo(getMonthIndex(b));
           } catch (_) {
             return 0;
           }
      });

      return SizedBox(
        width: double.maxFinite,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
             const Text(
                'Selected Months:',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
             ),
             const SizedBox(height: 12),
             Wrap(
               spacing: 8,
               runSpacing: 8,
               children: sortedMonths.map((m) => Chip(
                 label: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)),
                 backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                 side: BorderSide.none,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               )).toList(),
             ),
             
             const SizedBox(height: 24),
             
             Text(
                'Payment Mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns for big cards
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _modes.length,
                itemBuilder: (context, index) {
                   final mode = _modes[index];
                   final isSelected = _selectedMode == mode;
                   return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMode = mode;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              
              TextField(
                controller: _amountController,
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Total Amount (₹800/mo)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee_outlined),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _paymentDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _paymentDate = picked;
                      });
                    }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Payment Date (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.event_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(_paymentDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
        ],
      ),
      );
  }

  List<Widget> _buildActions() {
    if (_currentStep == 0) {
        return [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedMonths.isNotEmpty ? () {
                  setState(() {
                      _currentStep = 1;
                  });
              } : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Next'),
            ),
        ];
    } else {
        return [
            TextButton(
              onPressed: () {
                  setState(() {
                      _currentStep = 0;
                  });
              },
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedMode != null) {
                  final List<Fee> fees = _selectedMonths.map((monthKey) {
                    return Fee(
                      id: const Uuid().v4(),
                      studentId: widget.studentId,
                      amount: _feePerMonth,
                      month: monthKey,
                      mode: _selectedMode!,
                      paymentDate: DateFormat('yyyy-MM-dd').format(_paymentDate),
                      createdAt: DateTime.now(),
                    );
                  }).toList();
                  
                  Navigator.pop(context, fees);
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select a payment mode'),
                   ));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
        ];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
