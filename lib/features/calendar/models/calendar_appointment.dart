import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import './calendar_response.dart';

class SchoolCalendarAppointment {
  final String title;
  // final String eventType;
  final DateTime from;
  final DateTime to;
  final Color color;
  final bool isAllDay;
  final CalendarEvent sourceEvent;
  final CalendarDay sourceDay;

  SchoolCalendarAppointment({
    required this.title,
    // required this.eventType,
    required this.from,
    required this.to,
    required this.color,
    required this.isAllDay,
    required this.sourceEvent,
    required this.sourceDay,
  });
}

class SchoolCalendarDataSource extends CalendarDataSource {
  SchoolCalendarDataSource(List<SchoolCalendarAppointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from as DateTime;

  @override
  DateTime getEndTime(int index) => appointments![index].to as DateTime;

  @override
  String getSubject(int index) => appointments![index].title as String;

  @override
  Color getColor(int index) => appointments![index].color as Color;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay as bool;
}
