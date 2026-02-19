import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/presentation/bloc/student_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';

class AddEditStudentPage extends StatefulWidget {
  final Student? student;

  const AddEditStudentPage({super.key, this.student});

  @override
  State<AddEditStudentPage> createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _uidController;
  late TextEditingController _phoneController;
  String? _selectedBelt;
  String? _selectedBatchDay;
  String? _selectedBatchTime;
  String? _selectedGender;
  late TextEditingController _dojController;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isUploading = false;
  final double _maxFileSizeMB = 2.0;

  final List<String> _belts = [
    'White', 'Yellow', 'Green', 'Green-1', 'Blue', 'Blue-1', 'Red', 'Red-1', 'Black'
  ];

  final Map<String, List<String>> _batchOptions = {
    'Mon-Wed-Fri': ['5pm', '6pm', '7pm', '8pm'],
    'Tue-Thurs-Sat': ['9 am', '5pm', '6pm', '7pm'],
    'Sat-Sun': ['9 am', '10 am'],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _uidController = TextEditingController(text: widget.student?.uid ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _selectedBelt = widget.student?.belt;
    
    // Parse batch if exists: "Day (Time)"
    if (widget.student?.batch != null && widget.student!.batch.contains('(')) {
      final parts = widget.student!.batch.split(' (');
      _selectedBatchDay = parts[0];
      _selectedBatchTime = parts[1].replaceAll(')', '');
    }

    _selectedGender = widget.student?.gender;
    _dojController = TextEditingController(text: widget.student?.doj ?? '');
    _currentImageUrl = widget.student?.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uidController.dispose();
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final File file = File(image.path);
      final int sizeInBytes = await file.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > _maxFileSizeMB) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size exceeds ${_maxFileSizeMB}MB. Please select a smaller image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImage = file;
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
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                        ? CachedNetworkImageProvider(_currentImageUrl!)
                                        : null) as ImageProvider?,
                                child: (_selectedImage == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Theme.of(context).primaryColor,
                                shape: const CircleBorder(),
                                elevation: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _uidController,
                        label: 'Student UID',
                        icon: Icons.fingerprint,
                        validator: (value) => value!.isEmpty ? 'Please enter a UID' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Phone number must contain only digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: (['Male', 'Female', 'Other'].contains(_selectedGender) ? _selectedGender : null),
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
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select gender' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _belts.contains(_selectedBelt) ? _selectedBelt : null,
                        decoration: InputDecoration(
                          labelText: 'Belt',
                          prefixIcon: const Icon(Icons.workspace_premium),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _belts.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBelt = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select belt' : null,
                      ),
                      const SizedBox(height: 16),
                      // Batch Days Dropdown
                      DropdownButtonFormField<String>(
                        value: _batchOptions.containsKey(_selectedBatchDay) ? _selectedBatchDay : null,
                        decoration: InputDecoration(
                          labelText: 'Batch Days',
                          prefixIcon: const Icon(Icons.calendar_view_week),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _batchOptions.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBatchDay = newValue;
                            _selectedBatchTime = null; // Reset time when day changes
                          });
                        },
                        validator: (value) => value == null ? 'Please select batch days' : null,
                      ),
                      const SizedBox(height: 16),
                      // Batch Time Dropdown
                      DropdownButtonFormField<String>(
                        value: (_selectedBatchDay != null && 
                                _batchOptions.containsKey(_selectedBatchDay) && 
                                _batchOptions[_selectedBatchDay]!.contains(_selectedBatchTime)) 
                                ? _selectedBatchTime : null,
                        decoration: InputDecoration(
                          labelText: 'Batch Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: (_selectedBatchDay != null && _batchOptions.containsKey(_selectedBatchDay)
                              ? _batchOptions[_selectedBatchDay]! 
                              : <String>[]).map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBatchTime = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select batch time' : null,
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
                        onPressed: _isUploading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isUploading = true);
                            
                            try {
                              String? imageUrl = _currentImageUrl;
                              final String studentId = widget.student?.id ?? const Uuid().v4();
                              final String studentUid = _uidController.text.trim();

                              if (_selectedImage != null) {
                                final bytes = await _selectedImage!.readAsBytes();
                                final ext = path.extension(_selectedImage!.path).replaceAll('.', '');
                                imageUrl = await context.read<StudentBloc>().uploadProfileImage(
                                  studentId, 
                                  bytes, 
                                  ext
                                );
                              }

                              final student = Student(
                                id: studentId,
                                uid: studentUid,
                                name: _nameController.text,
                                phone: _phoneController.text,
                                gender: _selectedGender ?? '',
                                doj: _dojController.text,
                                belt: _selectedBelt ?? '',
                                batch: '$_selectedBatchDay ($_selectedBatchTime)',
                                role: 'student', // Default role for added students
                                profileImageUrl: imageUrl,
                              );

                              if (widget.student == null) {
                                context.read<StudentBloc>().add(CreateStudent(student));
                              } else {
                                context.read<StudentBloc>().add(EditStudent(student));
                              }

                              if (context.mounted) context.pop();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isUploading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isUploading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.student == null ? 'Create Student' : 'Save Changes'),
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
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
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
