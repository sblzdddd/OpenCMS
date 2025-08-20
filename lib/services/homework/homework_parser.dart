import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../../data/models/homework/homework_response.dart';

/// Parse homework HTML response from legacy CMS
HomeworkResponse parseHomeworkHtml(String html) {
  final document = html_parser.parse(html);
  final List<HomeworkItem> homeworkItems = [];
  
  // Find the homework table
  final table = document.querySelector('table.mark_tabl.a12');
  if (table == null) {
    return HomeworkResponse(
      homeworkItems: [],
      currentPage: 1,
      totalPages: 1,
      totalRecords: 0,
    );
  }
  
  // Get all table rows (skip header row)
  final rows = table.querySelectorAll('tr');
  if (rows.length <= 1) {
    return HomeworkResponse(
      homeworkItems: [],
      currentPage: 1,
      totalPages: 1,
      totalRecords: 0,
    );
  }
  
  // Process homework rows (skip header, process in pairs)
  for (int i = 1; i < rows.length; i += 2) {
    if (i + 1 >= rows.length) break; // Need both rows for complete homework entry
    
    final firstRow = rows[i];
    final secondRow = rows[i + 1];
    
    try {
      final homeworkItem = _parseHomeworkRows(firstRow, secondRow);
      if (homeworkItem != null) {
        homeworkItems.add(homeworkItem);
      }
    } catch (e) {
      print('HomeworkParser: Error parsing homework row $i: $e');
      // Continue processing other rows
    }
  }
  
  // Parse pagination info
  final paginationInfo = _parsePaginationInfo(document);
  
  return HomeworkResponse(
    homeworkItems: homeworkItems,
    currentPage: paginationInfo['currentPage'] ?? 1,
    totalPages: paginationInfo['totalPages'] ?? 1,
    totalRecords: paginationInfo['totalRecords'] ?? homeworkItems.length,
  );
}

/// Parse a pair of homework rows into a HomeworkItem
HomeworkItem? _parseHomeworkRows(Element element1, Element element2) {
  final cells1 = element1.querySelectorAll('td');
  final cells2 = element2.querySelectorAll('td');
  
  if (cells1.length < 6 || cells2.length < 2) {
    return null; // Not enough cells
  }
  
  try {
    // Extract homework ID from status link
    String homeworkId = '';
    final statusCell = cells1.length > 6 ? cells1[6] : null;
    final statusLink = statusCell?.querySelector('a[href*="change_homework_to_done"]');
    if (statusLink != null) {
      final href = statusLink.attributes['href'] ?? '';
      // Extract ID from: javascript:change_homework_to_done('475005');
      final match = RegExp(r"change_homework_to_done\('([^']+)'\)").firstMatch(href);
      homeworkId = match?.group(1) ?? '';
    }
    
    // Parse dates safely
    final assignedDateText = cells1[1].text.trim();
    final dueDateText = cells1.length > 5 ? cells1[5].text.trim() : '';
    
    final assignedDate = DateTime.tryParse(assignedDateText) ?? DateTime.now();
    final dueDate = DateTime.tryParse(dueDateText) ?? DateTime.now();
    
    // Extract other fields
    final teacher = cells1[2].text.trim();
    final title = cells1[3].text.trim();
    
    // Extract category from the div inside the cell
    final categoryCell = cells1.length > 4 ? cells1[4] : null;
    final categoryDiv = categoryCell?.querySelector('div');
    final category = categoryDiv?.text.trim() ?? '';
    
    // Extract course code from second row
    final courseCode = cells2[0].text.trim();
    
    // Determine completion status (assume pending since status link exists)
    final isCompleted = statusLink == null; // If no status link, might be completed
    
    return HomeworkItem(
      id: homeworkId,
      assignedDate: assignedDate,
      teacher: teacher,
      title: title,
      category: category,
      dueDate: dueDate,
      courseCode: courseCode,
      isCompleted: isCompleted,
    );
  } catch (e) {
    print('HomeworkParser: Error parsing homework item: $e');
    return null;
  }
}

/// Parse pagination information from the HTML
Map<String, int> _parsePaginationInfo(Document document) {
  final paginationDiv = document.querySelectorAll('div.top10')[1];
  
  final text = paginationDiv.text;
  
  // Parse "Current Page：1/11"
  int currentPage = 1;
  int totalPages = 1;
  final pageMatch = RegExp(r'Current Page：(\d+)\/(\d+)').firstMatch(text);
  if (pageMatch != null) {
    currentPage = int.tryParse(pageMatch.group(1) ?? '1') ?? 1;
    totalPages = int.tryParse(pageMatch.group(2) ?? '1') ?? 1;
  }
  
  // Parse "Total:105 records"
  int totalRecords = 0;
  final recordsMatch = RegExp(r'Total:(\d+) records').firstMatch(text);
  if (recordsMatch != null) {
    totalRecords = int.tryParse(recordsMatch.group(1) ?? '0') ?? 0;
  }
  
  return {
    'currentPage': currentPage,
    'totalPages': totalPages,
    'totalRecords': totalRecords,
  };
}
