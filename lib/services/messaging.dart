import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  static final fbm = FirebaseMessaging();

  static Future<String> getToken() async => await fbm.getToken();

  static void config(String from) {
    fbm.configure(
      onMessage: (message) async {
        print('$from onMessage: ' + message.toString());
      },
      onResume: (message) async {
        print('$from onResume: ' + message.toString());
      },
      onLaunch: (message) async {
        print('$from onLaunch: ' + message.toString());
      },
    );
  }
}
