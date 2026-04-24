import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  Timer? _pollingTimer;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchNotifications(isSilent: true);
    });
  }

  Future<void> fetchNotifications({bool isSilent = false}) async {
    try {
      if (!isSilent) isLoading.value = true;

      String? token = GetStorage().read('token');
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        notifications.value =
            data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error ambil notif: $e");
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notifId) async {
    try {
      String? token = GetStorage().read('token');

      int index = notifications.indexWhere((n) => n.id == notifId);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
      }

      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notifId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      debugPrint("Gagal tandai dibaca: $e");
    }
  }
}
