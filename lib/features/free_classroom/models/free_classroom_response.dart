/// Model for free classroom response from the legacy CMS
library;

import 'package:json_annotation/json_annotation.dart';

part 'free_classroom_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FreeClassroomResponse {
  final String status;
  final String info;
  final String rooms;

  const FreeClassroomResponse({
    required this.status,
    required this.info,
    required this.rooms,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> get freeClassrooms => 
    rooms.trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();

  factory FreeClassroomResponse.empty() {
    return FreeClassroomResponse(rooms: '', status: '', info: '');
  }

  factory FreeClassroomResponse.fromJson(Map<String, dynamic> json) =>
    _$FreeClassroomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FreeClassroomResponseToJson(this);
}
