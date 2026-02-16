class CoreTemplates {
  static String coreReadme() => '''
# Core

This folder is shared across all features.

- Keep logic here framework-agnostic.
- Keep third-party packages at the edge.
- Each file includes guidance comments to reduce boilerplate.

## Structure

- `api_client/` - HTTP client, API service, base response models
- `di/` - Dependency injection setup
- `env/` - Environment configuration (dev/staging/prod)
- `error_handler/` - Centralized error handling and recovery
- `localization/` - i18n and l10n support
- `notifications/` - Push and local notifications
- `permissions/` - Runtime permission handling
- `response_handler/` - API response parsing and transformation
- `route_handler/` - Navigation and routing
- `session_manager/` - Auth tokens and user session
- `theme_handler/` - App theming (light/dark mode)
- `utils/` - Validators, constants, helpers
- `common_widgets/` - Shared UI components
''';

  static String responseHandler() => '''
import 'package:dio/dio.dart';

import '../response_handler/api_failure.dart';
import '../utils/result.dart';

/// Centralized response handler for API calls.
/// 
/// Provides consistent parsing, error handling, and logging across all API calls.
/// 
/// Usage:
/// ```dart
/// final result = await ResponseHandler.handle(
///   () => apiService.get('/users'),
///   fromJson: (json) => User.fromJson(json),
/// );
/// 
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
class ResponseHandler {
  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static List<Map<String, dynamic>> _toMapList(List<dynamic> source) {
    return source
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static bool _isSuccessStatus(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  /// Handle a single object response
  static Future<Result<T>> handle<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null) {
        return Results.failure(const ServerFailure('Empty response'));
      }

      final mapData = _asMap(data);
      if (mapData == null) {
        return Results.failure(const ServerFailure('Invalid response format'));
      }

      if (mapData.containsKey('success') && mapData['success'] == false) {
        return Results.failure(AppFailure.fromResponse(response));
      }

      final payload = mapData['data'] ?? mapData['result'] ?? mapData['payload'];
      final payloadMap = _asMap(payload) ?? mapData;
      return Results.success(fromJson(payloadMap));
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle a list response
  static Future<Result<List<T>>> handleList<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null) {
        return Results.success([]);
      }
      
      List<Map<String, dynamic>> items;
      
      if (data is List) {
        items = _toMapList(data);
      } else if (data is Map<String, dynamic>) {
        // Handle BaseResponse wrapper
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(AppFailure.fromResponse(response));
        }
        final payload = data['data'] ?? data['result'] ?? data['payload'] ?? data;
        if (payload is List) {
          items = _toMapList(payload);
        } else if (payload is Map<String, dynamic>) {
          final nestedList =
              payload['items'] ?? payload['results'] ?? payload['data'];
          items = nestedList is List ? _toMapList(nestedList) : [];
        } else {
          items = [];
        }
      } else {
        return Results.success([]);
      }
      
      return Results.success(
        items.map(fromJson).toList(),
      );
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle paginated response
  static Future<Result<PaginatedResponse<T>>> handlePaginated<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null || data is! Map<String, dynamic>) {
        return Results.success(PaginatedResponse.empty());
      }
      
      if (data.containsKey('success') && data['success'] == false) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      
      return Results.success(PaginatedResponse.fromJson(data, fromJson));
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle void response (no data expected)
  static Future<Result<void>> handleVoid({
    required Future<Response<dynamic>> Function() request,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(AppFailure.fromResponse(response));
        }
      }
      
      return Results.success(null);
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
}

/// Model for paginated API responses
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
  
  factory PaginatedResponse.empty() => const PaginatedResponse(
    items: [],
    page: 1,
    totalPages: 1,
    totalItems: 0,
    hasMore: false,
  );
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = _asMap(json['data']) ?? json;
    final rawItemsDynamic = data['items'] ?? data['results'] ?? data['data'];
    final rawItems = rawItemsDynamic is List ? rawItemsDynamic : <dynamic>[];
    final meta = _asMap(json['meta']) ?? _asMap(json['pagination']) ?? json;

    final page = _asInt(meta['page']) ?? _asInt(meta['current_page']) ?? 1;
    final totalPages =
        _asInt(meta['total_pages']) ?? _asInt(meta['last_page']) ?? 1;
    final totalItems =
        _asInt(meta['total']) ?? _asInt(meta['total_items']) ?? rawItems.length;
    
    return PaginatedResponse(
      items: rawItems
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      page: page,
      totalPages: totalPages,
      totalItems: totalItems,
      hasMore: page < totalPages,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
''';

  static String errorHandler() => '''
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../response_handler/api_failure.dart';
import '../utils/logger.dart';

/// Centralized error handler for the application.
/// 
/// Features:
/// - Converts failures to user-friendly messages
/// - Provides UI helpers for showing errors
/// - Supports error recovery actions
/// - Logs errors for debugging
/// 
/// Usage:
/// ```dart
/// // In repository/usecase:
/// result.fold(
///   (failure) => ErrorHandler.handle(context, failure),
///   (data) => showData(data),
/// );
/// 
/// // Or with recovery action:
/// ErrorHandler.handleWithRecovery(
///   context,
///   failure,
///   onRetry: () => fetchData(),
/// );
/// ```
class ErrorHandler {
  /// Global error callback for custom handling
  static void Function(AppFailure failure)? onError;
  
  /// Handle failure and show appropriate UI feedback
  static void handle(BuildContext context, AppFailure failure) {
    AppLogger.error('Error handled', tag: 'ERROR', error: failure.message);
    onError?.call(failure);
    
    final message = _getUserMessage(failure);
    showErrorSnackBar(context, message);
  }
  
  /// Handle failure with retry option
  static void handleWithRecovery(
    BuildContext context,
    AppFailure failure, {
    required VoidCallback onRetry,
    String? retryLabel,
  }) {
    final message = _getUserMessage(failure);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: retryLabel ?? 'Retry',
          onPressed: onRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    AppFailure failure, {
    String? title,
    VoidCallback? onDismiss,
  }) async {
    final message = _getUserMessage(failure);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show simple error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  
  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
  
  /// Convert failure to user-friendly message
  static String _getUserMessage(AppFailure failure) {
    if (failure is ValidationFailure) {
      return failure.displayMessage;
    }
    return failure.when(
      network: (msg) => 'No internet connection. Please check your network and try again.',
      server: (msg, code) => msg.isNotEmpty ? msg : 'Server error occurred. Please try again later.',
      timeout: (msg) => 'Request timed out. Please check your connection and try again.',
      unauthorized: (msg) => 'Session expired. Please login again.',
      notFound: (msg) => msg.isNotEmpty ? msg : 'The requested resource was not found.',
      validation: (msg) => msg.isNotEmpty ? msg : 'Please correct the highlighted fields.',
      cache: (msg) => 'Unable to load cached data.',
      unknown: (msg, error) => kDebugMode ? msg : 'Something went wrong. Please try again.',
    );
  }
  
  /// Check if failure requires re-authentication
  static bool requiresReAuth(AppFailure failure) {
    return failure is UnauthorizedFailure;
  }
  
  /// Check if failure is recoverable (user can retry)
  static bool isRecoverable(AppFailure failure) {
    return failure is NetworkFailure || 
           failure is TimeoutFailure || 
           failure is ServerFailure;
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  void handleError(AppFailure failure) {
    ErrorHandler.handle(context, failure);
  }
  
  void handleErrorWithRetry(AppFailure failure, VoidCallback onRetry) {
    ErrorHandler.handleWithRecovery(context, failure, onRetry: onRetry);
  }
}
''';

  static String routeHandler() => '''
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // TODO: Add your feature routes here.
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}
''';

  static String themeHandler() => '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // All app-wide colors live here.
  static const _brand = Color(0xFF2C3E50);
  static const _accent = Color(0xFF18BC9C);
  static const _surface = Color(0xFFF5F7FA);
  static const _error = Color(0xFFE74C3C);
  static const _darkSurface = Color(0xFF12161C);
  static const _darkBackground = Color(0xFF0E1116);

  // Update typography here to affect all text in the app.
  static final _textTheme = GoogleFonts.poppinsTextTheme(
    const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 15),
    ),
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      // Backgrounds and main brand palette.
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brand,
        primary: _brand,
        secondary: _accent,
        surface: _surface,
        error: _error,
      ),
      // Text across the entire app (titles, body, captions).
      textTheme: _textTheme,
      // App-wide background (Scaffold).
      scaffoldBackgroundColor: _surface,
      // App bar styling (top navigation).
      appBarTheme: const AppBarTheme(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // Bottom navigation bar (legacy).
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _brand,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
      ),
      // Navigation bar (Material 3).
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0x1A2C3E50),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Drawer panel styling.
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        scrimColor: Color(0x662C3E50),
      ),
      // Text fields and input boxes.
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _brand, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      // Dropdowns using Material 3 dropdown menu.
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      // Chips (filters, tags).
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFE8EEF3),
        selectedColor: _brand,
        labelStyle: TextStyle(color: Colors.black87),
        secondaryLabelStyle: TextStyle(color: Colors.white),
      ),
      // Snackbars / lightweight feedback.
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _brand,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.dark,
        primary: _accent,
        secondary: _brand,
        surface: _darkSurface,
        error: _error,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1B2028),
        selectedItemColor: _accent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF1B2028),
        indicatorColor: Color(0x332C3E50),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1B2028),
        scrimColor: Color(0x662C3E50),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1B2028),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1B2028),
          border: OutlineInputBorder(),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF202631),
        selectedColor: _accent,
        labelStyle: TextStyle(color: Colors.white70),
        secondaryLabelStyle: TextStyle(color: Colors.black),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _accent,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
''';

  static String utilsLogger() => '''
class Logger {
  void info(String message) {
    // Replace with your preferred logger.
    // ignore: avoid_print
    print('[INFO] \$message');
  }

  void error(String message) {
    // ignore: avoid_print
    print('[ERROR] \$message');
  }
}
''';

  static String utilsValidators() => '''
class Validators {
  static bool isEmail(String value) {
    return value.contains('@');
  }
}
''';

  static String utilsFailure() => '''
class AppFailure {
  AppFailure(this.message);

  final String message;
}
''';

  static String utilsResult() => '''
import 'package:dartz/dartz.dart';

import '../response_handler/api_failure.dart';

typedef Result<T> = Either<AppFailure, T>;
''';

  static String featuresReadme() => '''
# Features

Create each feature with `data`, `domain`, and `presentation` layers.

Example:
- features/demo/data
- features/demo/domain
- features/demo/presentation
''';

  static String commonWidgetsReadme() => '''
# Common Widgets

Place shared widgets here (buttons, loaders, error views).
Keep them dumb and reusable.
''';

  static String svgIcon() => '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size = 24});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
    );
  }
}
''';

  static String permissionService() => '''
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
''';

  static String notificationService() => '''
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  Future<void> showSimple({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'default',
        'General',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final scheduled = tz.TZDateTime.from(time, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('scheduled', 'Scheduled'),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}
''';

  static String riverpodProviders() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client/api_service.dart';
import '../env/env.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/session_manager.dart';

final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('Env is not initialized');
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  throw UnimplementedError('SessionManager is not initialized');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError('ApiService is not initialized');
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  throw UnimplementedError('PermissionService is not initialized');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService is not initialized');
});
''';

  static String blocInjection() => '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
)
void configureDependencies() {
  init(getIt);
}
''';

  static String blocInjectableModule() => '''
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AppModule {
  @lazySingleton
  FlutterLocalNotificationsPlugin get notificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}
''';

  static String blocInjectionConfig() => '''
// GENERATED CODE - This is a stub. Run build_runner to regenerate.
// ignore_for_file: unused_import
import 'package:get_it/get_it.dart';

import '../api_client/api_service.dart';
import '../api_client/dio_client.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/session_manager.dart';
import 'injectable_module.dart';

GetIt init(GetIt getIt) {
  final module = AppModule();
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<SessionManager>()),
  );
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(module.notificationsPlugin),
  );
  return getIt;
}
''';
}
