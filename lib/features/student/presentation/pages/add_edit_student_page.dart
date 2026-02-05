import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddEditStudentPage extends StatefulWidget {
  final Student? student;

  const AddEditStudentPage({super.key, this.student});

  @override
  State<AddEditStudentPage> createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  late TextEditingController _dojController;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _selectedGender = widget.student?.gender;
    _dojController = TextEditingController(text: widget.student?.doj ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dojController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_dojController.text.isNotEmpty) {
      try {
        initialDate = _dateFormat.parse(_dojController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dojController.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        // Handle state if needed
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.wc),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['Male', 'Female', 'Other'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          _selectedGender = newValue;
                        },
                        validator: (value) => value == null ? 'Please select gender' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dojController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Date of Admission',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please select date' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final student = Student(
                              id: widget.student?.id ?? const Uuid().v4(),
                              name: _nameController.text,
                              phone: _phoneController.text,
                              gender: _selectedGender ?? '',
                              doj: _dojController.text,
                            );

                            if (widget.student == null) {
                              context.read<StudentBloc>().add(CreateStudent(student));
                            } else {
                              context.read<StudentBloc>().add(EditStudent(student));
                            }

                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (context.mounted) context.pop();
                            });
                          }
                        },
                        child: Text(
                          widget.student == null ? 'Create Student' : 'Save Changes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
