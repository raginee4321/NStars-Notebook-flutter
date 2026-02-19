import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:n_stars_notebook/core/services/notification_service.dart';
import 'package:n_stars_notebook/core/supabase/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackgroundService {
  static const String feeCheckTask = "com.raginee.n_stars_notebook.feeCheckTask";

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        // 1. Initialize dependencies
        await dotenv.load(fileName: "assets/.env");
        await SupabaseConfig.init();
        final prefs = await SharedPreferences.getInstance();
        await NotificationService.init();

        // 2. Get saved student UID
        final studentUid = prefs.getString('user_uid');
        if (studentUid == null || studentUid == 'admin') {
          return true; // No student logged in or it's admin
        }

        // 3. Get Student ID (technical) for the UID
        final studentResponse = await SupabaseConfig.client
            .from('students')
            .select('id')
            .eq('uid', studentUid)
            .maybeSingle();

        if (studentResponse == null) return true;
        final studentId = studentResponse['id'];

        // 4. Check Fee Status for current month
        final now = DateTime.now();
        final currentMonth = DateFormat('MMMM', 'en_US').format(now);
        final currentYear = now.year.toString();

        final feesResponse = await SupabaseConfig.client
            .from('fees')
            .select()
            .eq('studentId', studentId);

        final fees = feesResponse as List;
        
        final isPaid = fees.any((f) {
          final m = f['month'] as String;
          final pDate = f['paymentDate'] as String;
          
          // Case 1: "Month Year" format
          if (m.contains(currentYear)) {
            return m.startsWith(currentMonth);
          }
          
          // Case 2: "Month" format without year (check paymentDate year)
          if (!m.contains(RegExp(r'\d{4}'))) {
            try {
              final paymentDate = DateTime.parse(pDate);
              return m == currentMonth && paymentDate.year == now.year;
            } catch (_) {}
          }
          return false;
        });

        // 5. If not paid, show notification
        if (!isPaid) {
          await NotificationService.showNotification(
            id: 1,
            title: 'Fee Reminder 🥋',
            body: 'Your fee for $currentMonth is still pending. Please clear it soon!',
          );
        }

        return true;
      } catch (e) {
        print("Background task error: $e");
        return false;
      }
    });
  }

  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleDailyCheck() async {
    await Workmanager().registerPeriodicTask(
      "1",
      feeCheckTask,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
