import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';

/// 本地通知服务:为带「提前提醒」的自定义事件安排设备本地通知。
/// 仅在本机调度,不依赖任何服务器;孕期数据不出本机。
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// 在 main() 中调用一次。初始化时区与插件,并申请通知权限。
  Future<void> init() async {
    tzdata.initializeTimeZones();
    // 面向中国用户,统一使用东八区;失败则回退默认。
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (_) {/* 保持默认本地时区 */}

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    await _requestPermissions();
    _ready = true;
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      '孕期提醒',
      channelDescription: '产检与自定义事件的提前提醒',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// 为事件安排提醒(目标日 - 提前天数,当天 09:00)。已过期或无需提醒则跳过。
  Future<void> scheduleEvent(CustomEvent e) async {
    if (!_ready || e.id == null || e.remindDaysBefore <= 0) return;
    await cancel(e.id!); // 先清旧的,避免重复
    final t = e.targetDate;
    final when = DateTime(t.year, t.month, t.day - e.remindDaysBefore, 9);
    if (!when.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      e.id!,
      '孕期提醒 · ${e.title}',
      e.content.isEmpty ? '别忘了今天的安排哦' : e.content,
      tz.TZDateTime.from(when, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
  }

  /// 启动时按现存事件重建调度(系统重启或权限变化后保证提醒在册)。
  Future<void> rescheduleAll(List<CustomEvent> events) async {
    if (!_ready) return;
    for (final e in events) {
      if (!e.isCompleted) await scheduleEvent(e);
    }
  }
}
