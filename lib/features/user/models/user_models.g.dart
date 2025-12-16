// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  userName: json['username'] as String,
  userType: (json['user_type'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  enName: json['en_name'] as String,
  language: json['language'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'username': instance.userName,
  'user_type': instance.userType,
  'id': instance.id,
  'name': instance.name,
  'en_name': instance.enName,
  'language': instance.language,
  'permissions': instance.permissions,
};

GeneralInfo _$GeneralInfoFromJson(Map<String, dynamic> json) => GeneralInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  enName: json['en_name'] as String,
  fullName: json['full_name'] as String,
  formGroup: json['form_group'] as String,
  photo: json['photo'] as String,
  status: (json['status'] as num).toInt(),
  dormitory: json['dormitory'] as String,
  dormitoryKind: json['dormitory_kind'] as String,
);

Map<String, dynamic> _$GeneralInfoToJson(GeneralInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'en_name': instance.enName,
      'full_name': instance.fullName,
      'form_group': instance.formGroup,
      'photo': instance.photo,
      'status': instance.status,
      'dormitory': instance.dormitory,
      'dormitory_kind': instance.dormitoryKind,
    };

BasicInfo _$BasicInfoFromJson(Map<String, dynamic> json) => BasicInfo(
  gender: json['gender'] as String,
  grade: json['grade'] as String,
  house: json['house'] as String,
  dormitory: json['dormitory'] as String,
  dormitoryKind: json['dormitory_kind'] as String,
  enrollment: json['enrollment'] as String,
  mobile: json['mobile'] as String,
  schoolEmail: json['school_email'] as String,
  studentEmail: json['student_email'] as String,
);

Map<String, dynamic> _$BasicInfoToJson(BasicInfo instance) => <String, dynamic>{
  'gender': instance.gender,
  'grade': instance.grade,
  'house': instance.house,
  'dormitory': instance.dormitory,
  'dormitory_kind': instance.dormitoryKind,
  'enrollment': instance.enrollment,
  'mobile': instance.mobile,
  'school_email': instance.schoolEmail,
  'student_email': instance.studentEmail,
};

MoreInfo _$MoreInfoFromJson(Map<String, dynamic> json) => MoreInfo(
  address: json['address'] as String?,
  emergencyContact: json['emergency_contact'] as String?,
  emergencyPhone: json['emergency_phone'] as String?,
  passportNumber: json['passport_number'] as String?,
  visaStatus: json['visa_status'] as String?,
  medicalInfo: json['medical_info'] as String?,
  allergies: json['allergies'] as String?,
  medications: json['medications'] as String?,
);

Map<String, dynamic> _$MoreInfoToJson(MoreInfo instance) => <String, dynamic>{
  'address': instance.address,
  'emergency_contact': instance.emergencyContact,
  'emergency_phone': instance.emergencyPhone,
  'passport_number': instance.passportNumber,
  'visa_status': instance.visaStatus,
  'medical_info': instance.medicalInfo,
  'allergies': instance.allergies,
  'medications': instance.medications,
};

Relative _$RelativeFromJson(Map<String, dynamic> json) => Relative(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  relationship: json['relationship'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  address: json['address'] as String,
  isEmergencyContact: json['is_emergency_contact'] as bool,
);

Map<String, dynamic> _$RelativeToJson(Relative instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'relationship': instance.relationship,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'is_emergency_contact': instance.isEmergencyContact,
};

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      hasMoreInfo: json['has_more_info'] as bool,
      hasIdInfo: json['has_id_info'] as bool,
      generalInfo: GeneralInfo.fromJson(
        json['general_info'] as Map<String, dynamic>,
      ),
      basicInfo: BasicInfo.fromJson(json['basic_info'] as Map<String, dynamic>),
      moreInfo: json['more_info'] == null
          ? null
          : MoreInfo.fromJson(json['more_info'] as Map<String, dynamic>),
      relatives: (json['relatives'] as List<dynamic>?)
          ?.map((e) => Relative.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'has_more_info': instance.hasMoreInfo,
      'has_id_info': instance.hasIdInfo,
      'general_info': instance.generalInfo,
      'basic_info': instance.basicInfo,
      'more_info': instance.moreInfo,
      'relatives': instance.relatives,
    };
