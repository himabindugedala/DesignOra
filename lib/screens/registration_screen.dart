import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../data/college_config.dart';
import '../services/app_state.dart';
import 'registration_approval_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final bool isEditing;

  const RegistrationScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _regNoController;
  late TextEditingController _phoneController;
  late TextEditingController _mentorNameController;
  late TextEditingController _mentorPhoneController;

  String? _selectedBranch;
  Gender _gender = Gender.male;
  StudentType _studentType = StudentType.hosteller;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final student = appState.currentStudent;

    if (student != null) {
      _nameController = TextEditingController(text: student.name);
      _regNoController = TextEditingController(text: student.regNumber);
      _phoneController = TextEditingController(text: student.phone);
      _mentorNameController = TextEditingController(text: student.mentorName);
      _mentorPhoneController = TextEditingController(text: student.mentorPhone);
      _selectedBranch = student.branch;
      _gender = student.gender;
      _studentType = student.studentType;
    } else {
      _nameController = TextEditingController();
      _regNoController = TextEditingController();
      _phoneController = TextEditingController();
      _mentorNameController = TextEditingController();
      _mentorPhoneController = TextEditingController();
      _selectedBranch = CollegeConfig.branches.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    _mentorNameController.dispose();
    _mentorPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final student = Student(
      id: appState.currentStudent?.id ?? 'std_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      regNumber: _regNoController.text.trim().toUpperCase(),
      branch: _selectedBranch ?? CollegeConfig.branches.first,
      phone: _phoneController.text.trim(),
      mentorName: _mentorNameController.text.trim(),
      mentorPhone: _mentorPhoneController.text.trim().isEmpty
          ? '9845012345'
          : _mentorPhoneController.text.trim(),
      gender: _gender,
      studentType: _studentType,
    );

    if (widget.isEditing) {
      await appState.updateProfile(student);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop();
    } else {
      await appState.registerStudent(student);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RegistrationApprovalScreen(student: student),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Student Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(50),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isEditing
                            ? 'Update your student information and mentor contact details below.'
                            : 'Enter your official college details. Gender determines your celebration hall room assignment.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Academic details
              Text(
                'Personal & Academic Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g. Rahul Sharma',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reg Number
              TextFormField(
                controller: _regNoController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration Number *',
                  hintText: 'e.g. 22BCE1084',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your registration number';
                  }
                  if (value.trim().length < 5) {
                    return 'Please enter a valid registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Branch dropdown
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedBranch),
                initialValue: _selectedBranch,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Branch *',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: CollegeConfig.branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch,
                    child: Text(branch, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBranch = val;
                  });
                },
                validator: (val) => val == null ? 'Please select your branch' : null,
              ),
              const SizedBox(height: 16),

              // Phone number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Student Phone Number *',
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                    return 'Enter a valid 10-digit Indian phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Section 2: Gender & Student Type
              Text(
                'Campus Classification',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Gender Selector
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Gender (Room Assignment) *',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.male_rounded, size: 18),
                                  SizedBox(width: 4),
                                  Text('Male'),
                                ],
                              ),
                            ),
                            selected: _gender == Gender.male,
                            onSelected: (selected) {
                              if (selected) setState(() => _gender = Gender.male);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.female_rounded, size: 18),
                                  SizedBox(width: 4),
                                  Text('Female'),
                                ],
                              ),
                            ),
                            selected: _gender == Gender.female,
                            onSelected: (selected) {
                              if (selected) setState(() => _gender = Gender.female);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 15,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _gender == Gender.male
                                  ? 'Assigned: Male Celebration Room (Block A - 102)'
                                  : 'Assigned: Female Celebration Room (Block B - 104)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Student Type Selector
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Student Type *',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.hotel_rounded, size: 18),
                                  SizedBox(width: 4),
                                  Text('Hosteller'),
                                ],
                              ),
                            ),
                            selected: _studentType == StudentType.hosteller,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _studentType = StudentType.hosteller);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_bus_rounded, size: 18),
                                  SizedBox(width: 4),
                                  Text('Day Scholar'),
                                ],
                              ),
                            ),
                            selected: _studentType == StudentType.dayScholar,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _studentType = StudentType.dayScholar);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _studentType == StudentType.hosteller
                          ? '✨ Hostellers get full-day booking privileges on college holidays.'
                          : 'ℹ️ Day Scholars follow normal college break & evening hours.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Mentor / Class Teacher details
              Text(
                'Class Teacher / Mentor Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Required for digital sign-off of all celebration requests.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Mentor Name
              TextFormField(
                controller: _mentorNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Mentor / Class Teacher Name *',
                  hintText: 'e.g. Dr. K. Ramesh',
                  prefixIcon: Icon(Icons.supervisor_account_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Mentor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mentor Phone
              TextFormField(
                controller: _mentorPhoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mentor Phone Number *',
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone_in_talk_outlined),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Mentor phone number';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  widget.isEditing ? 'Save Changes' : 'Register & Enter Campus Hall',
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
