import '../notifications/notification_service.dart';
import 'injection.dart';

Future<void> setupDependencies() async {
  await configureDependencies();
  await getIt.allReady();
  await getIt<NotificationService>().init();
}
