/// Model for free classroom response from the legacy CMS
library;

import 'package:json_annotation/json_annotation.dart';

part 'free_classroom_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FreeClassroomResponse {
  final String rooms;
  final String date;
  final String period;

  const FreeClassroomResponse({
    required this.rooms,
    required this.date,
    required this.period,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> get freeClassrooms => 
    rooms.trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();

  factory FreeClassroomResponse.empty() {
    return FreeClassroomResponse(rooms: '', date: '', period: '');
  }

  factory FreeClassroomResponse.fromJson(Map<String, dynamic> json) =>
    _$FreeClassroomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FreeClassroomResponseToJson(this);
}
