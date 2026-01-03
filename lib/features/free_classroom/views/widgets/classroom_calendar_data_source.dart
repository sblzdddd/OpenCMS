
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ClassroomAppointment {
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final List<Object> resourceIds;
  final Color color;
  final String classroom;
  final int period;

  ClassroomAppointment({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.resourceIds,
    required this.color,
    required this.classroom,
    required this.period,
  });
}

class ClassroomDataSource extends CalendarDataSource {
  ClassroomDataSource(
    List<ClassroomAppointment> source,
    List<CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }

  @override
  DateTime getStartTime(int index) =>
      (appointments![index] as ClassroomAppointment).startTime;

  @override
  DateTime getEndTime(int index) =>
      (appointments![index] as ClassroomAppointment).endTime;

  @override
  String getSubject(int index) =>
      (appointments![index] as ClassroomAppointment).subject;

  @override
  Color getColor(int index) =>
      (appointments![index] as ClassroomAppointment).color;

  @override
  List<Object> getResourceIds(int index) =>
      (appointments![index] as ClassroomAppointment).resourceIds;
}
