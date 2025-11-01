import 'package:flutter/material.dart';

class AttendanceConstants {
  static const Map<int, String> kindText = {
    0: 'Present',
    1: 'Late',
    2: 'Unapproved',
    3: 'Unknown',
    4: 'Sick',
    5: 'Approved',
    6: 'School',
    7: 'Leave early',
  };

  // Background colors per kind (see design notes)
  static const Map<int, Color> kindBackgroundColor = {
    0: Color(0xFF4CAF50), // green for present
    1: Colors.black, // late
    2: Color(0xFF795548), // brown
    3: Colors.white, // unknown reason
    4: Color(0xFFFFF9C4), // light yellow
    5: Color(0xFF0D47A1), // dark blue
    6: Color(0xFFFFCDD2), // light pink
    7: Color(0xFF424242), // dark grey
  };

  // Text colors per kind (contrast with backgrounds)
  static const Map<int, Color> kindTextColor = {
    0: Colors.white, // on green
    1: Colors.white, // on black
    2: Colors.white, // on brown
    3: Colors.black, // on white
    4: Colors.black, // on light yellow
    5: Colors.white, // on dark blue
    6: Colors.black, // on light pink
    7: Colors.white, // on dark grey
  };
}
