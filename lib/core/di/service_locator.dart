import 'package:get_it/get_it.dart';
import 'package:n_stars_notebook/core/supabase/supabase_client.dart';
import 'package:n_stars_notebook/features/student/data/datasources/student_remote_data_source.dart';
import 'package:n_stars_notebook/features/student/data/repositories/student_repository_impl.dart';
import 'package:n_stars_notebook/features/student/domain/repositories/student_repository.dart';
import 'package:n_stars_notebook/features/student/domain/usecases/student_usecases.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Student
  // Bloc
  sl.registerFactory(
    () => StudentBloc(
      getStudents: sl(),
      watchStudents: sl(),
      addStudent: sl(),
      updateStudent: sl(),
      deleteStudent: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetStudents(sl()));
  sl.registerLazySingleton(() => WatchStudents(sl()));
  sl.registerLazySingleton(() => AddStudent(sl()));
  sl.registerLazySingleton(() => UpdateStudent(sl()));
  sl.registerLazySingleton(() => DeleteStudent(sl()));

  // Repository
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(supabase: sl()),
  );

  // External
  sl.registerLazySingleton(() => SupabaseConfig.client);
}
