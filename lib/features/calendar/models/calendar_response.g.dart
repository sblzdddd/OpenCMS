// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarResponse _$CalendarResponseFromJson(Map<String, dynamic> json) =>
    CalendarResponse(
      rows: (json['rows'] as num).toInt(),
      days: (json['days'] as num).toInt(),
      userType: json['usertype'] as String,
      psid: json['psid'] as String,
      thisMonth: json['thismonth'] as String,
      thisYear: json['thisyear'] as String,
      preMonth: json['premonth'] as String,
      preYear: json['preyear'] as String,
      nextMonth: json['nextmonth'] as String,
      nextYear: json['nextyear'] as String,
      fromPeriod: json['fromperiod'] as String,
      todaySpanId: json['todayspanid'] as String?,
    );

Map<String, dynamic> _$CalendarResponseToJson(CalendarResponse instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'days': instance.days,
      'usertype': instance.userType,
      'psid': instance.psid,
      'thismonth': instance.thisMonth,
      'thisyear': instance.thisYear,
      'premonth': instance.preMonth,
      'preyear': instance.preYear,
      'nextmonth': instance.nextMonth,
      'nextyear': instance.nextYear,
      'fromperiod': instance.fromPeriod,
      'todayspanid': instance.todaySpanId,
    };
