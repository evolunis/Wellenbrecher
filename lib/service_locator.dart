import 'package:get_it/get_it.dart';
import 'package:wellenreiter/services/cloud_server_service.dart';

final serviceLocator = GetIt.instance; // GetIt.I is also valid
void setUp() async {
  serviceLocator.registerSingletonAsync<CloudServerService>(() async {
    final cloudServer = CloudServerService();
    await cloudServer.init();
    return cloudServer;
  });
}
