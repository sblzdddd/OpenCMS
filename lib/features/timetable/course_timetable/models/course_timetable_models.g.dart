// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_timetable_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimetableResponse _$TimetableResponseFromJson(Map<String, dynamic> json) =>
    TimetableResponse(
      weekType: json['week_type'] as String,
      weekNum: (json['week_num'] as num).toInt(),
      monday: json['monday'] as String,
      weekAPeriods: (json['week_a_periods'] as num).toInt(),
      weekBPeriods: (json['week_b_periods'] as num).toInt(),
      dutyPeriods: (json['duty_periods'] as num).toInt(),
      contractPeriods: (json['contract_periods'] as num).toInt(),
      weekdays: (json['weekdays'] as List<dynamic>)
          .map((e) => WeekDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TimetableResponseToJson(TimetableResponse instance) =>
    <String, dynamic>{
      'week_type': instance.weekType,
      'week_num': instance.weekNum,
      'monday': instance.monday,
      'week_a_periods': instance.weekAPeriods,
      'week_b_periods': instance.weekBPeriods,
      'duty_periods': instance.dutyPeriods,
      'contract_periods': instance.contractPeriods,
      'weekdays': instance.weekdays,
    };

WeekDay _$WeekDayFromJson(Map<String, dynamic> json) => WeekDay(
  periods: (json['periods'] as List<dynamic>)
      .map((e) => Period.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeekDayToJson(WeekDay instance) => <String, dynamic>{
  'periods': instance.periods,
};

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
  events: (json['events'] as List<dynamic>)
      .map((e) => TimetableEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
  'events': instance.events,
};

TimetableEvent _$TimetableEventFromJson(Map<String, dynamic> json) =>
    TimetableEvent(
      type: (json['type'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      room: json['room'] as String,
      teacher: json['teacher'] as String,
      weekType: json['week_type'] as String,
      newRoom: json['new_room'] as String,
    );

Map<String, dynamic> _$TimetableEventToJson(TimetableEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'name': instance.name,
      'room': instance.room,
      'teacher': instance.teacher,
      'week_type': instance.weekType,
      'new_room': instance.newRoom,
    };
