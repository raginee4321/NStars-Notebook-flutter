import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/domain/usecases/student_usecases.dart';

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentEvent {}

class UpdateStudentsList extends StudentEvent {
  final List<Student> students;
  const UpdateStudentsList(this.students);
  @override
  List<Object?> get props => [students];
}

class CreateStudent extends StudentEvent {
  final Student student;
  const CreateStudent(this.student);
  @override
  List<Object?> get props => [student];
}

class SearchStudents extends StudentEvent {
  final String query;
  const SearchStudents(this.query);
  @override
  List<Object?> get props => [query];
}

class EditStudent extends StudentEvent {
  final Student student;
  const EditStudent(this.student);
  @override
  List<Object?> get props => [student];
}

class RemoveStudent extends StudentEvent {
  final String id;
  const RemoveStudent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students; // Displayed students (filtered)
  final List<Student> allStudents; // All students (cache)
  final String searchQuery;
  
  const StudentLoaded(this.students, {List<Student>? allStudents, this.searchQuery = ''}) 
      : allStudents = allStudents ?? students;
      
  @override
  List<Object?> get props => [students, allStudents, searchQuery];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);
  @override
  List<Object?> get props => [message];
}

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudents getStudents;
  final WatchStudents watchStudents;
  final AddStudent addStudent;
  final UpdateStudent updateStudent;
  final DeleteStudent deleteStudent;
  final UploadProfileImage uploadProfileImageUseCase;
  StreamSubscription? _studentSubscription;

  StudentBloc({
    required this.getStudents,
    required this.watchStudents,
    required this.addStudent,
    required this.updateStudent,
    required this.deleteStudent,
    required this.uploadProfileImageUseCase,
  }) : super(StudentInitial()) {
    
    // Listen to real-time changes
    _studentSubscription = watchStudents().listen((students) {
      add(UpdateStudentsList(students));
    });

    on<LoadStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        final students = await getStudents();
        emit(StudentLoaded(students, allStudents: students));
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<UpdateStudentsList>((event, emit) {
      final query = state is StudentLoaded ? (state as StudentLoaded).searchQuery : '';
      _applyFilter(event.students, query, emit);
    });

    on<SearchStudents>((event, emit) {
      if (state is StudentLoaded) {
        final currentState = state as StudentLoaded;
        _applyFilter(currentState.allStudents, event.query, emit);
      }
    });

    on<CreateStudent>((event, emit) async {
      try {
        await addStudent(event.student);
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<EditStudent>((event, emit) async {
      try {
        await updateStudent(event.student);
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<RemoveStudent>((event, emit) async {
      try {
        await deleteStudent(event.id);
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });
  }

  Future<String> uploadProfileImage(String studentId, List<int> imageBytes, String extension) {
    return uploadProfileImageUseCase.call(studentId, imageBytes, extension);
  }

  void _applyFilter(List<Student> allStudents, String query, Emitter<StudentState> emit) {
    final lowercaseQuery = query.toLowerCase();
    if (lowercaseQuery.isEmpty) {
      emit(StudentLoaded(allStudents, allStudents: allStudents, searchQuery: ''));
    } else {
      final filtered = allStudents.where((s) {
        return s.name.toLowerCase().contains(lowercaseQuery) || 
               s.phone.contains(lowercaseQuery);
      }).toList();
      emit(StudentLoaded(filtered, allStudents: allStudents, searchQuery: query));
    }
  }

  @override
  Future<void> close() {
    _studentSubscription?.cancel();
    return super.close();
  }
}
