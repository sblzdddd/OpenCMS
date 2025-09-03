/// Model for free classroom response from the legacy CMS
library;

class FreeClassroomResponse {
  final List<String> freeClassrooms;
  final String date;
  final String period;

  const FreeClassroomResponse({
    required this.freeClassrooms,
    required this.date,
    required this.period,
  });

  factory FreeClassroomResponse.empty() {
    return FreeClassroomResponse(
      freeClassrooms: [],
      date: '',
      period: '',
    );
  }

  factory FreeClassroomResponse.fromJson(Map<String, dynamic> json) {
    // Parse the rooms string to extract individual classroom names
    final String roomsString = json['rooms'] ?? '';
    final List<String> classrooms = _parseRoomsString(roomsString);
    
    print('FreeClassroomResponse.fromJson:');
    print('  Raw JSON: $json');
    print('  Rooms string: "$roomsString"');
    print('  Parsed classrooms: $classrooms');
    
    return FreeClassroomResponse(
      freeClassrooms: classrooms,
      date: json['date'] ?? '',
      period: json['period'] ?? '',
    );
  }

  /// Parse the rooms string from the API response
  /// Example: "(1006) (1008) (1010) A205 A216 A301 A310 A311 A318 A406 A505 A510 A606 (A704) B221 B320 B326 B327 B332 B333 (B629) (B631) (B722) (B724) (B726) (B731) (B819) (G019) G031 (G117) (G119B) "
  static List<String> _parseRoomsString(String roomsString) {
    if (roomsString.isEmpty) return [];
    
    final List<String> classrooms = roomsString.trim().split(' ').where((part) => part.isNotEmpty).toList();
    
    print(classrooms);
    
    return classrooms;
  }

  Map<String, dynamic> toJson() {
    return {
      'classrooms': freeClassrooms,
      'date': date,
      'period': period,
    };
  }
}
