import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/core/di/service_locator.dart' as di;
import 'package:n_stars_notebook/core/router/app_router.dart';
import 'package:n_stars_notebook/core/theme/app_theme.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_event.dart';
import 'package:n_stars_notebook/features/auth/presentation/bloc/auth_state.dart';

import 'package:n_stars_notebook/core/supabase/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:n_stars_notebook/core/services/notification_service.dart';
import 'package:n_stars_notebook/core/services/background_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
    await dotenv.load(fileName: "assets/.env");
    await SupabaseConfig.init();
    await Firebase.initializeApp();
    await di.init();
    await NotificationService.init();
    await BackgroundService.init();
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  // FlutterNativeSplash.remove() removed from here; will be removed in MyApp
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule splash removal for after the first frame where state is resolved
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (context) => di.sl<StudentBloc>()..add(LoadStudents())),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthError) {
            FlutterNativeSplash.remove();
          }
        },
        child: MaterialApp.router(
          title: 'N Stars',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
