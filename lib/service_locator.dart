import 'package:get_it/get_it.dart';
import 'package:wellenbrecher/services/cloud_server_service.dart';
import 'package:wellenbrecher/services/firebase_notifications.dart';

final serviceLocator = GetIt.instance; // GetIt.I is also valid
void setUp() async {
  serviceLocator.registerSingletonAsync<CloudServerService>(() async {
    final cloudServer = CloudServerService();
    await cloudServer.init();
    return cloudServer;
  });

  serviceLocator.registerSingletonAsync<FirebaseNotifications>(() async {
    final firebaseNotifications = FirebaseNotifications();
    await firebaseNotifications.init();
    return firebaseNotifications;
  });
}
