class AssessmentData {
  final String label;
  final int percentage;
  final String title;
  final String date;
  final int weight;

  AssessmentData({
    required this.label,
    required this.percentage,
    required this.title,
    required this.date,
    this.weight = 0,
  });
}
