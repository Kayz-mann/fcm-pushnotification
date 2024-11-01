import 'package:fcm_pushnotification/controllers/auth_service.dart';
import 'package:fcm_pushnotification/controllers/crud_service.dart';
import 'package:fcm_pushnotification/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //request notification permission
  static Future init() async {
    await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);
  }

  static Future getDeviceToken() async {
    //get device token --- FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Device token: $token");
      bool isUserLoggedin = await AuthService.isLoggedIn();
      await CRUDService.saveUserToken(token!);
      print("saved to firestore");

      //save token oif token changes
      _firebaseMessaging.onTokenRefresh.listen((event) async {
        if (isUserLoggedin) {
          await CRUDService.saveUserToken(token!);
          print("new token saved to firestore");
        }
      });
    } else {
      print("Error: Unable to retrieve device token.");
    }
  }

  // initialize local notification
  static Future localNotifInit() async {
    // initialixe the plugin app_ion needs to be added as a drwable resource
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final DarwinInitializationSettings intializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: "Open notification");

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: intializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // request permissiond for android 13 and above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
        onDidReceiveNotificationResponse: onNotificationTap);
  }

  //ontap local notification foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed("/message", arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetatails =
        AndroidNotificationDetails("channnel id", "channelm name",
            channelDescription: "channel description",
            importance: Importance.max,
            priority: Priority.high,
            ticker: "ticker");

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetatails);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }
}
