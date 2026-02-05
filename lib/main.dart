import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart' as di;
import 'package:n_stars_notebook/core/router/app_router.dart';
import 'package:n_stars_notebook/core/theme/app_theme.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';

import 'package:n_stars_notebook/core/supabase/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  await SupabaseConfig.init();

  await Firebase.initializeApp();
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StudentBloc>()..add(LoadStudents()),
      child: MaterialApp.router(
        title: 'N Stars TKD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
