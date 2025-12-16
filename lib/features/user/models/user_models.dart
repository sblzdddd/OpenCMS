import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

/// User information data model
@JsonSerializable(fieldRename: FieldRename.snake)
class UserInfo {
  @JsonKey(name: 'username')
  final String userName;
  final int userType;
  final int id;
  final String name;
  final String enName;
  final String language;
  final List<String> permissions;

  const UserInfo({
    required this.userName,
    required this.userType,
    required this.id,
    required this.name,
    required this.enName,
    required this.language,
    required this.permissions,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  @override
  String toString() {
    return 'UserInfo(userName: $userName, userType: $userType, id: $id, name: $name, enName: $enName, language: $language, permissions: $permissions)';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory GeneralInfo.fromJson(Map<String, dynamic> json) =>
      _$GeneralInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GeneralInfoToJson(this);

  /// Check if student is active
  bool get isActive => status == 0;

  /// Get display name (prefer English name if available)
  String get displayName => enName.isNotEmpty ? enName : name;

  /// Get full display name
  String get fullDisplayName => fullName.isNotEmpty ? fullName : displayName;
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory BasicInfo.fromJson(Map<String, dynamic> json) =>
      _$BasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicInfoToJson(this);

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

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory MoreInfo.fromJson(Map<String, dynamic> json) =>
      _$MoreInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MoreInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory Relative.fromJson(Map<String, dynamic> json) =>
      _$RelativeFromJson(json);
  Map<String, dynamic> toJson() => _$RelativeToJson(this);
}



@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
