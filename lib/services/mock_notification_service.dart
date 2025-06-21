import 'package:get/get.dart';

class MockNotificationService extends GetxService {
  Future<void> initialize() async {
    // Mock implementation - does nothing
    print('Mock NotificationService initialized');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Mock implementation - just print
    print('Mock notification scheduled: $title at $scheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    // Mock implementation - just print
    print('Mock notification cancelled: $id');
  }

  Future<void> cancelAllNotifications() async {
    // Mock implementation - just print
    print('All mock notifications cancelled');
  }

  void onNotificationTap(String? payload) {
    // Mock implementation - just print
    print('Mock notification tapped with payload: $payload');
  }
}
