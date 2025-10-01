import '../models/skin/skin_image.dart';
import '../models/skin/skin_image_type.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// the shared preferences key for the list of skins
const String skinsKey = 'app_skins';
const String activeSkinKey = 'active_skin_id';

// the directory for the skins
Future<Directory> getSkinsDirectory() async {
  final appDir = await getApplicationSupportDirectory();
  return Directory('${appDir.path}${Platform.pathSeparator}skins');
}

const defaultImageData = {
  'global.app_icon': SkinImageData(type: SkinImageType.icon),
  'global.background': SkinImageData(type: SkinImageType.background),
  'global.foreground': SkinImageData(type: SkinImageType.foreground),
  'global.empty_icon': SkinImageData(type: SkinImageType.icon),
  'global.error_icon': SkinImageData(type: SkinImageType.icon),

  'actionIcons.unknown': SkinImageData(type: SkinImageType.icon),
  'actionIcons.webcms': SkinImageData(type: SkinImageType.icon),
  'actionIcons.timetable': SkinImageData(type: SkinImageType.icon),
  'actionIcons.exam': SkinImageData(type: SkinImageType.icon),
  'actionIcons.attendance': SkinImageData(type: SkinImageType.icon),
  'actionIcons.reports': SkinImageData(type: SkinImageType.icon),
  'actionIcons.assessment': SkinImageData(type: SkinImageType.icon),
  'actionIcons.comments': SkinImageData(type: SkinImageType.icon),
  'actionIcons.calendar': SkinImageData(type: SkinImageType.icon),
  'actionIcons.notice': SkinImageData(type: SkinImageType.icon),
  'actionIcons.homeworks': SkinImageData(type: SkinImageType.icon),
  'actionIcons.documents': SkinImageData(type: SkinImageType.icon),
  'actionIcons.available_classrooms': SkinImageData(type: SkinImageType.icon),
  'actionIcons.maintenance': SkinImageData(type: SkinImageType.icon),
  'actionIcons.leave_requests': SkinImageData(type: SkinImageType.icon),
  'actionIcons.student_profile': SkinImageData(type: SkinImageType.icon),
  'actionIcons.course_stats': SkinImageData(type: SkinImageType.icon),
  'actionIcons.eca': SkinImageData(type: SkinImageType.icon),
  'actionIcons.settings': SkinImageData(type: SkinImageType.icon),
  'actionIcons.more': SkinImageData(type: SkinImageType.icon),
  'actionIcons.trash_can': SkinImageData(type: SkinImageType.icon),

  'subjectIcons.unknown': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.physics': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.chemistry': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.biology': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.science': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.mathematics': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.further_math': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.literature': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.language': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.chinese': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.japanese': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.spanish': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.computer_science': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.economics': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.business': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.accounting': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.geography': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.history': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.psychology': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.sociology': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.art': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.music': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.pe': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.form_time': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.pastoral': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.tutor': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.rpq': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.evening_study': SkinImageData(type: SkinImageType.icon),
  'subjectIcons.mr': SkinImageData(type: SkinImageType.icon),

  'login.background': SkinImageData(type: SkinImageType.background),
  'login.foreground': SkinImageData(type: SkinImageType.foreground),

  'home.background': SkinImageData(type: SkinImageType.background),
  'home.foreground': SkinImageData(type: SkinImageType.foreground),

  'home.bannerBackground': SkinImageData(type: SkinImageType.background),
  'home.bannerForeground': SkinImageData(type: SkinImageType.foreground),

  'home.homeworksWidgetIcon': SkinImageData(type: SkinImageType.icon),

  'home.timetableWidgetIcon': SkinImageData(type: SkinImageType.icon),

  'home.noticeWidgetIcon': SkinImageData(type: SkinImageType.icon),

  'home.assessmentWidgetIcon': SkinImageData(type: SkinImageType.icon),

  'web_cms.background': SkinImageData(type: SkinImageType.background),
  'web_cms.foreground': SkinImageData(type: SkinImageType.foreground),

  'timetable.background': SkinImageData(type: SkinImageType.background),
  'timetable.foreground': SkinImageData(type: SkinImageType.foreground),

  'exam.background': SkinImageData(type: SkinImageType.background),
  'exam.foreground': SkinImageData(type: SkinImageType.foreground),

  'attendance.background': SkinImageData(type: SkinImageType.background),
  'attendance.foreground': SkinImageData(type: SkinImageType.foreground),

  'course_stats.background': SkinImageData(type: SkinImageType.background),
  'course_stats.foreground': SkinImageData(type: SkinImageType.foreground),

  'reports.background': SkinImageData(type: SkinImageType.background),
  'reports.foreground': SkinImageData(type: SkinImageType.foreground),

  'assessment.background': SkinImageData(type: SkinImageType.background),
  'assessment.foreground': SkinImageData(type: SkinImageType.foreground),

  'comments.background': SkinImageData(type: SkinImageType.background),
  'comments.foreground': SkinImageData(type: SkinImageType.foreground),

  'calendar.background': SkinImageData(type: SkinImageType.background),
  'calendar.foreground': SkinImageData(type: SkinImageType.foreground),

  'notice.background': SkinImageData(type: SkinImageType.background),
  'notice.foreground': SkinImageData(type: SkinImageType.foreground),

  'homeworks.background': SkinImageData(type: SkinImageType.background),
  'homeworks.foreground': SkinImageData(type: SkinImageType.foreground),

  'available_classrooms.background': SkinImageData(type: SkinImageType.background),
  'available_classrooms.foreground': SkinImageData(type: SkinImageType.foreground),

  'daily_bulletin.background': SkinImageData(type: SkinImageType.background),
  'daily_bulletin.foreground': SkinImageData(type: SkinImageType.foreground),

  'events.background': SkinImageData(type: SkinImageType.background),
  'events.foreground': SkinImageData(type: SkinImageType.foreground),

  'student_profile.background': SkinImageData(type: SkinImageType.background),
  'student_profile.foreground': SkinImageData(type: SkinImageType.foreground),

  'settings.background': SkinImageData(type: SkinImageType.background),
  'settings.foreground': SkinImageData(type: SkinImageType.foreground),

};