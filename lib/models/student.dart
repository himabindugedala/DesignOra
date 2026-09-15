enum Gender {
  male,
  female,
}

enum StudentType {
  hosteller,
  dayScholar,
}

class Student {
  final String id;
  final String name;
  final String regNumber;
  final String branch;
  final String phone;
  final String mentorName;
  final String mentorPhone;
  final Gender gender;
  final StudentType studentType;
  final bool isApproved;

  const Student({
    required this.id,
    required this.name,
    required this.regNumber,
    required this.branch,
    required this.phone,
    required this.mentorName,
    required this.mentorPhone,
    required this.gender,
    required this.studentType,
    this.isApproved = false,
  });

  String get genderDisplay => gender == Gender.male ? 'Male' : 'Female';
  String get studentTypeDisplay =>
      studentType == StudentType.hosteller ? 'Hosteller' : 'Day Scholar';

  String get assignedRoomName => gender == Gender.male
      ? 'Male Celebration Room'
      : 'Female Celebration Room';

  String get assignedRoomLocation => gender == Gender.male
      ? 'Block A - Ground Floor, Room 102'
      : 'Block B - Ground Floor, Room 104';

  Student copyWith({
    String? id,
    String? name,
    String? regNumber,
    String? branch,
    String? phone,
    String? mentorName,
    String? mentorPhone,
    Gender? gender,
    StudentType? studentType,
    bool? isApproved,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      regNumber: regNumber ?? this.regNumber,
      branch: branch ?? this.branch,
      phone: phone ?? this.phone,
      mentorName: mentorName ?? this.mentorName,
      mentorPhone: mentorPhone ?? this.mentorPhone,
      gender: gender ?? this.gender,
      studentType: studentType ?? this.studentType,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'regNumber': regNumber,
        'branch': branch,
        'phone': phone,
        'mentorName': mentorName,
        'mentorPhone': mentorPhone,
        'gender': gender.name,
        'studentType': studentType.name,
        'isApproved': isApproved,
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      regNumber: json['regNumber'] as String,
      branch: json['branch'] as String,
      phone: json['phone'] as String,
      mentorName: json['mentorName'] as String,
      mentorPhone: json['mentorPhone'] as String? ?? '',
      gender: Gender.values.firstWhere(
        (value) => value.name == json['gender'],
        orElse: () => Gender.male,
      ),
      studentType: StudentType.values.firstWhere(
        (value) => value.name == json['studentType'],
        orElse: () => StudentType.dayScholar,
      ),
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }
}
