import 'package:flutter/material.dart';
import '../models/calendar.dart';

class CalendarUtils {
  static List<SchoolCalendarAppointment> buildCalendarEvents(
    CalendarResponse? currentCalendar,
    Map<String, Color> eventColors,
    Color Function(CalendarEvent) getColorForEvent,
  ) {
    final List<SchoolCalendarAppointment> events =
        <SchoolCalendarAppointment>[];

    if (currentCalendar == null) return events;

    // Group source events by day to assign pseudo time slots
    final Map<DateTime, List<MapEntry<CalendarDay, CalendarEvent>>>
    eventsByDay = {};

    for (final dayEntry in currentCalendar.calendarDays.values) {
      if (!dayEntry.hasEvents) continue;

      final DateTime? eventDate = dayEntry.dateTime;
      if (eventDate == null) continue;

      for (final event in dayEntry.events) {
        eventsByDay.putIfAbsent(
          DateTime(eventDate.year, eventDate.month, eventDate.day),
          () => <MapEntry<CalendarDay, CalendarEvent>>[],
        );
        eventsByDay[DateTime(eventDate.year, eventDate.month, eventDate.day)]!
            .add(MapEntry<CalendarDay, CalendarEvent>(dayEntry, event));
      }
    }

    // Assign sequential 1-hour slots starting from 09:00 for each day
    const int startHour = 0;
    const int slotMinutes = 60;

    for (final entry in eventsByDay.entries) {
      final DateTime day = entry.key;
      final List<MapEntry<CalendarDay, CalendarEvent>> dayEvents = entry.value;

      // Stable ordering: by kind then title then id
      dayEvents.sort((a, b) {
        final int kindCmp = a.value.kind.compareTo(b.value.kind);
        if (kindCmp != 0) return kindCmp;
        final int titleCmp = a.value.title.compareTo(b.value.title);
        if (titleCmp != 0) return titleCmp;
        return a.value.id.compareTo(b.value.id);
      });

      for (int i = 0; i < dayEvents.length; i++) {
        final CalendarEvent event = dayEvents[i].value;
        final CalendarDay srcDay = dayEvents[i].key;
        final DateTime from = DateTime(
          day.year,
          day.month,
          day.day,
          startHour + i,
          0,
        );
        final DateTime to = from.add(const Duration(minutes: slotMinutes));
        final Color color = getColorForEvent(event);

        events.add(
          SchoolCalendarAppointment(
            title: event.title,
            from: from,
            to: to,
            color: color,
            isAllDay: false,
            sourceEvent: event,
            sourceDay: srcDay,
          ),
        );
      }
    }

    return events;
  }
}
