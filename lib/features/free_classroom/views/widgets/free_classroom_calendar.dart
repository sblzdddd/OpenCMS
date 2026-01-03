
import 'package:flutter/material.dart';
import 'package:opencms/utils/sfcalendar_theme.dart';
import 'package:opencms/features/theme/services/theme_services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'classroom_calendar_data_source.dart';

class FreeClassroomCalendar extends StatelessWidget {
  final CalendarController controller;
  final ClassroomDataSource dataSource;
  final ViewChangedCallback onViewChanged;
  final Function(ClassroomAppointment) onAppointmentTap;
  final ThemeNotifier themeNotifier;
  final bool isLoading;

  const FreeClassroomCalendar({
    super.key,
    required this.controller,
    required this.dataSource,
    required this.onViewChanged,
    required this.onAppointmentTap,
    required this.themeNotifier,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final calendarWidth = screenWidth > 800 ? screenWidth : 800.0;

        return Center(
          child: SizedBox(
            width: calendarWidth,
            child: Stack(
              children: [
                SfCalendarTheme(
                  data: themeData(context),
                  child: SfCalendar(
                    controller: controller,
                    view: CalendarView.timelineDay,
                    dataSource: dataSource,
                    showCurrentTimeIndicator: true,
                    allowViewNavigation: true,
                    showDatePickerButton: true,
                    viewNavigationMode: ViewNavigationMode.snap,
                    onViewChanged: onViewChanged,
                    resourceViewSettings: const ResourceViewSettings(
                      showAvatar: false,
                      displayNameTextStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      size: 42,
                    ),
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeIntervalHeight: 40,
                      timeIntervalWidth: -1,
                      minimumAppointmentDuration: Duration(minutes: 30),
                      startHour: 8,
                      endHour: 17,
                    ),
                    appointmentBuilder: (
                      BuildContext context,
                      CalendarAppointmentDetails details,
                    ) {
                      final ClassroomAppointment appointment =
                          details.appointments.first as ClassroomAppointment;
                      return Container(
                        decoration: BoxDecoration(
                          color: appointment.color,
                          borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                        ),
                      );
                    },
                    onTap: (details) {
                      if (details.targetElement == CalendarElement.appointment &&
                          details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        final ClassroomAppointment tapped =
                            details.appointments!.first as ClassroomAppointment;
                        onAppointmentTap(tapped);
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
            ),
          ),
        );
      },
    );
  }
}
