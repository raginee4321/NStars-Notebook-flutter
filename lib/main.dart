import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart' as di;
import 'package:n_stars_notebook/core/router/app_router.dart';
import 'package:n_stars_notebook/core/theme/app_theme.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';

import 'package:n_stars_notebook/core/supabase/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
    await dotenv.load(fileName: "assets/.env");
    await SupabaseConfig.init();
    await Firebase.initializeApp();
    await di.init();
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StudentBloc>()..add(LoadStudents()),
      child: MaterialApp.router(
        title: 'N Stars',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
