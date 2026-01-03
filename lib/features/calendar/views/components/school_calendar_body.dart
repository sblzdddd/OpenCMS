import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:provider/provider.dart';
import '../../../../utils/sfcalendar_theme.dart';
import '../../../theme/services/theme_services.dart';
import '../../models/calendar.dart';
import '../../../shared/views/error/error_placeholder.dart';

class SchoolCalendarBody extends StatelessWidget {
  final CalendarController calendarController;
  final List<SchoolCalendarAppointment> events;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(SchoolCalendarAppointment) onEventTap;

  const SchoolCalendarBody({
    super.key,
    required this.calendarController,
    required this.events,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onViewChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ErrorPlaceholder(
        title: 'Failed to load calendar',
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);

    return Stack(
      children: [
        SfCalendarTheme(
          data: themeData(context),
          child: SfCalendar(
            controller: calendarController,
            allowedViews: const [
              CalendarView.month,
              CalendarView.schedule,
              CalendarView.week,
              CalendarView.day,
            ],
            view: CalendarView.week,
            firstDayOfWeek: 7, // Sunday
            dataSource: SchoolCalendarDataSource(events),
            showCurrentTimeIndicator: true,
            allowViewNavigation: true,
            showDatePickerButton: true,
            viewNavigationMode: ViewNavigationMode.snap,
            showWeekNumber: false,
            onViewChanged: onViewChanged,
            monthViewSettings: const MonthViewSettings(
              showAgenda: false,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showTrailingAndLeadingDates: true,
            ),
            timeSlotViewSettings: const TimeSlotViewSettings(
              nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
              timeIntervalHeight: 60,
              timeRulerSize: 50,
              minimumAppointmentDuration: Duration(minutes: 30),
              startHour: 0,
              endHour: 8,
            ),
            appointmentBuilder:
                (BuildContext context, CalendarAppointmentDetails details) {
              final SchoolCalendarAppointment event =
                  details.appointments.first as SchoolCalendarAppointment;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment &&
                  details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final SchoolCalendarAppointment tapped =
                    details.appointments!.first as SchoolCalendarAppointment;
                onEventTap(tapped);
              } else if (details.targetElement ==
                  CalendarElement.calendarCell) {
                // Navigate to day view when tapping on a month cell
                final DateTime tappedDate = details.date!;
                calendarController.view = CalendarView.week;
                calendarController.displayDate = tappedDate;
              }
            },
          ),
        ),
        if (isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
