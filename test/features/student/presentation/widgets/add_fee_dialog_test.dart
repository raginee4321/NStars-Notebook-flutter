
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_stars_notebook/features/student/presentation/widgets/add_fee_dialog.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';

void main() {
  testWidgets('AddFeeDialog shows month selection step initially with pair mode enabled', (WidgetTester tester) async {
    const studentId = 'student-123';
    const paidMonths = <String>[];
    const studentDoj = '2025-01-01';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AddFeeDialog(
            studentId: studentId,
            studentName: 'Test Student',
            paidMonths: paidMonths,
            studentDoj: studentDoj,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Select Months'), findsOneWidget);
    expect(find.text('Pair Mode'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    
    // Verify grid shows pairs (e.g., Jan - Feb)
    expect(find.textContaining('Jan - Feb'), findsOneWidget);
    expect(find.textContaining('Mar - Apr'), findsOneWidget);
    
    // Verify current year is displayed
    final currentYear = DateTime.now().year;
    expect(find.text('Year: $currentYear'), findsOneWidget);
  });

  testWidgets('Selecting a pair in AddFeeDialog adds both months', (WidgetTester tester) async {
    const studentId = 'student-123';
    const paidMonths = <String>[];
    const studentDoj = '2025-01-01';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AddFeeDialog(
            studentId: studentId,
            studentName: 'Test Student',
            paidMonths: paidMonths,
            studentDoj: studentDoj,
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.textContaining('Jan - Feb'));
    await tester.pump();

    // Assert
    // Check if "Next" button is enabled
    final nextButton = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(nextButton).enabled, isTrue);

    // Tap Next to see summary
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Verify step 2
    expect(find.text('Payment Details'), findsOneWidget);
    expect(find.text('Selected: 2 Month(s)'), findsOneWidget);
    
    // Verify amount (800 * 2 = 1600)
    expect(find.text('1600'), findsOneWidget);
  });

  testWidgets('Switching off Pair Mode shows single months', (WidgetTester tester) async {
    const studentId = 'student-123';
    const paidMonths = <String>[];
    const studentDoj = '2025-01-01';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AddFeeDialog(
            studentId: studentId,
            studentName: 'Test Student',
            paidMonths: paidMonths,
            studentDoj: studentDoj,
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Assert
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text('Jan'), findsOneWidget); // Single month
    // Ensure "Jan - Feb" text is not present as a single widget text
    expect(find.text('Jan - Feb'), findsNothing);
  });

  testWidgets('Completing the wizard returns correct fee objects', (WidgetTester tester) async {
    const studentId = 'student-123';
    const paidMonths = <String>[];
    const studentDoj = '2025-01-01';
    List<Fee>? returnedFees;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  returnedFees = await showDialog<List<Fee>>(
                    context: context,
                    builder: (context) => const AddFeeDialog(
                      studentId: studentId,
                      studentName: 'Test Student',
                      paidMonths: paidMonths,
                      studentDoj: studentDoj,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Select Jan-Feb pair
    await tester.tap(find.textContaining('Jan - Feb'));
    await tester.pump();

    // Go to Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Select Payment Mode (Clicking the 'Cash' card directly)
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Assert
    expect(returnedFees, isNotNull);
    expect(returnedFees!.length, 2);
    expect(returnedFees![0].month, contains('January'));
    expect(returnedFees![1].month, contains('February'));
    expect(returnedFees![0].amount, 800.0);
    expect(returnedFees![0].mode, 'Cash');
  });
}
