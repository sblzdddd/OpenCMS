// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_timetable_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamTimetableEntry _$ExamTimetableEntryFromJson(Map<String, dynamic> json) =>
    ExamTimetableEntry(
      id: (json['id'] as num).toInt(),
      examId: (json['exam_id'] as num).toInt(),
      examName: json['exam_name'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      paper: json['paper'] as String,
      code: json['code'] as String,
      room: json['room'] as String,
      seat: json['seat'] as String,
      isTaken: json['is_taken'] as int,
    );

Map<String, dynamic> _$ExamTimetableEntryToJson(ExamTimetableEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'exam_name': instance.examName,
      'code': instance.code,
      'paper': instance.paper,
      'date': instance.date,
      'time': instance.time,
      'room': instance.room,
      'seat': instance.seat,
      'is_taken': instance.isTaken,
    };
