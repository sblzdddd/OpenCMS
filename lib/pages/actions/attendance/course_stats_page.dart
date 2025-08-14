import 'package:flutter/material.dart';

class CourseStatsPage extends StatefulWidget {
  const CourseStatsPage({
    super.key,
  });

  @override
  State<CourseStatsPage> createState() => _CourseStatsPageState();
}

class _CourseStatsPageState extends State<CourseStatsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Course Stats'),
      ],
    );
  }
}
