import '../../data/constants/api_endpoints.dart';
import '../../data/models/notification/notification_response.dart';
import '../../services/auth/auth_service.dart';
import '../shared/http_service.dart';

/// Service for handling notifications from the CMS system
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  /// Get a list of all notifications
  /// 
  /// Returns a list of [Notification] objects
  Future<List<Notification>> getNotificationsList({bool refresh = false}) async {
    try {
      final response = await _httpService.get(ApiConstants.notificationUrl, refresh: refresh);
      
      if (response.data != null) {
        final List<dynamic> notificationsJson = response.data as List<dynamic>;
        return notificationsJson
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<String> getNotificationContentUrl(int notificationId) async {
    try {
      final username = await _authService.fetchCurrentUsername();
      if (username.isEmpty) {
        throw Exception('Missing username. Please login again.');
      }
      return '${ApiConstants.legacyCMSBaseUrl}${ApiConstants.notificationDetailUrl(username, notificationId)}';
    } catch (e) {
      throw Exception('Error fetching notification content: $e');
    }
  }

  /// Get notifications sorted by priority (pinned first) and date
  /// 
  /// Returns a sorted list of [Notification] objects
  Future<List<Notification>> getSortedNotifications({bool refresh = false}) async {
    final notifications = await getNotificationsList(refresh: refresh);
    
    // Sort by pinned status first, then by date (newest first)
    notifications.sort((a, b) {
      // First sort by pinned status
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then sort by date (newest first)
      try {
        final dateA = DateTime.parse(a.addDate);
        final dateB = DateTime.parse(b.addDate);
        return dateB.compareTo(dateA);
      } catch (e) {
        // If date parsing fails, keep original order
        return 0;
      }
    });
    
    return notifications;
  }
}
