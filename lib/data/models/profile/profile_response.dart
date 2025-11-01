/// Data models for profile API response
library;

class ProfileResponse {
  final bool hasMoreInfo;
  final bool hasIdInfo;
  final GeneralInfo generalInfo;
  final BasicInfo basicInfo;
  final MoreInfo? moreInfo;
  final List<Relative>? relatives;

  ProfileResponse({
    required this.hasMoreInfo,
    required this.hasIdInfo,
    required this.generalInfo,
    required this.basicInfo,
    this.moreInfo,
    this.relatives,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      hasMoreInfo: json['has_more_info'] ?? false,
      hasIdInfo: json['has_id_info'] ?? false,
      generalInfo: GeneralInfo.fromJson(
        json['general_info'] as Map<String, dynamic>,
      ),
      basicInfo: BasicInfo.fromJson(json['basic_info'] as Map<String, dynamic>),
      moreInfo: json['more_info'] != null
          ? MoreInfo.fromJson(json['more_info'] as Map<String, dynamic>)
          : null,
      relatives: json['relatives'] != null
          ? (json['relatives'] as List<dynamic>)
                .map((item) => Relative.fromJson(item as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

class GeneralInfo {
  final int id;
  final String name;
  final String enName;
  final String fullName;
  final String formGroup;
  final String photo;
  final int status;
  final String dormitory;
  final String dormitoryKind;

  GeneralInfo({
    required this.id,
    required this.name,
    required this.enName,
    required this.fullName,
    required this.formGroup,
    required this.photo,
    required this.status,
    required this.dormitory,
    required this.dormitoryKind,
  });

  factory GeneralInfo.fromJson(Map<String, dynamic> json) {
    return GeneralInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      enName: json['en_name'] ?? '',
      fullName: json['full_name'] ?? '',
      formGroup: json['form_group'] ?? '',
      photo: json['photo'] ?? '',
      status: json['status'] ?? 0,
      dormitory: json['dormitory'] ?? '',
      dormitoryKind: json['dormitory_kind'] ?? '',
    );
  }

  /// Check if student is active
  bool get isActive => status == 0;

  /// Get display name (prefer English name if available)
  String get displayName => enName.isNotEmpty ? enName : name;

  /// Get full display name
  String get fullDisplayName => fullName.isNotEmpty ? fullName : displayName;
}

class BasicInfo {
  final String gender;
  final String grade;
  final String house;
  final String dormitory;
  final String dormitoryKind;
  final String enrollment;
  final String mobile;
  final String schoolEmail;
  final String studentEmail;

  BasicInfo({
    required this.gender,
    required this.grade,
    required this.house,
    required this.dormitory,
    required this.dormitoryKind,
    required this.enrollment,
    required this.mobile,
    required this.schoolEmail,
    required this.studentEmail,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      gender: json['gender'] ?? '',
      grade: json['grade'] ?? '',
      house: json['house'] ?? '',
      dormitory: json['dormitory'] ?? '',
      dormitoryKind: json['dormitory_kind'] ?? '',
      enrollment: json['enrollment'] ?? '',
      mobile: json['mobile'] ?? '',
      schoolEmail: json['school_email'] ?? '',
      studentEmail: json['student_email'] ?? '',
    );
  }

  /// Check if student is boarding
  bool get isBoarding => dormitoryKind.toLowerCase().contains('boarding');

  /// Check if student is day student
  bool get isDayStudent => dormitoryKind.toLowerCase().contains('day');

  /// Get enrollment year
  int? get enrollmentYear {
    try {
      final parts = enrollment.split('.');
      if (parts.length >= 2) {
        return int.tryParse(parts[0]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get enrollment month
  int? get enrollmentMonth {
    try {
      final parts = enrollment.split('.');
      if (parts.length >= 2) {
        return int.tryParse(parts[1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class MoreInfo {
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? passportNumber;
  final String? visaStatus;
  final String? medicalInfo;
  final String? allergies;
  final String? medications;

  MoreInfo({
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.passportNumber,
    this.visaStatus,
    this.medicalInfo,
    this.allergies,
    this.medications,
  });

  factory MoreInfo.fromJson(Map<String, dynamic> json) {
    return MoreInfo(
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      passportNumber: json['passport_number'],
      visaStatus: json['visa_status'],
      medicalInfo: json['medical_info'],
      allergies: json['allergies'],
      medications: json['medications'],
    );
  }
}

class Relative {
  final int id;
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final String address;
  final bool isEmergencyContact;

  Relative({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.address,
    required this.isEmergencyContact,
  });

  factory Relative.fromJson(Map<String, dynamic> json) {
    return Relative(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      isEmergencyContact: json['is_emergency_contact'] ?? false,
    );
  }
}
