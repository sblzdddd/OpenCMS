/// Data models for timetable API response
library;

class TimetableResponse {
  final String weekType;
  final int weekNum;
  final String monday;
  final int weekAPeriods;
  final int weekBPeriods;
  final int dutyPeriods;
  final int contractPeriods;
  final List<WeekDay> weekdays;

  TimetableResponse({
    required this.weekType,
    required this.weekNum,
    required this.monday,
    required this.weekAPeriods,
    required this.weekBPeriods,
    required this.dutyPeriods,
    required this.contractPeriods,
    required this.weekdays,
  });

  factory TimetableResponse.fromJson(Map<String, dynamic> json) {
    return TimetableResponse(
      weekType: json['week_type'] ?? '',
      weekNum: json['week_num'] ?? 0,
      monday: json['monday'] ?? '',
      weekAPeriods: json['week_a_periods'] ?? 0,
      weekBPeriods: json['week_b_periods'] ?? 0,
      dutyPeriods: json['duty_periods'] ?? 0,
      contractPeriods: json['contract_periods'] ?? 0,
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((item) => WeekDay.fromJson(item))
          .toList() ?? [],
    );
  }
}

class WeekDay {
  final List<Period> periods;

  WeekDay({required this.periods});

  factory WeekDay.fromJson(Map<String, dynamic> json) {
    return WeekDay(
      periods: (json['periods'] as List<dynamic>?)
          ?.map((item) => Period.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Period {
  final List<TimetableEvent> events;

  Period({required this.events});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      events: (json['events'] as List<dynamic>?)
          ?.map((item) => TimetableEvent.fromJson(item))
          .toList() ?? [],
    );
  }
}

class TimetableEvent {
  final int type;
  final int id;
  final String name;
  final String room;
  final String teacher;
  final String weekType;
  final String newRoom;

  TimetableEvent({
    required this.type,
    required this.id,
    required this.name,
    required this.room,
    required this.teacher,
    required this.weekType,
    required this.newRoom,
  });

  factory TimetableEvent.fromJson(Map<String, dynamic> json) {
    return TimetableEvent(
      type: json['type'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      room: json['room'] ?? '',
      teacher: json['teacher'] ?? '',
      weekType: json['week_type'] ?? '',
      newRoom: json['new_room'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimetableEvent &&
        other.id == id &&
        other.name == name &&
        other.room == room &&
        other.teacher == teacher;
  }

  String get subject {
    if (name.contains('-')) {
      return name.split('-').first.trim();
    }
    return name;
  }

  String get code {
    if (name.contains('-')) {
      return name.split('-')[1].trim();
    }
    return 'ECA';
  }

  @override
  int get hashCode {
    return Object.hash(id, name, room, teacher);
  }
}
