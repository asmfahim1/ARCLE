import '../state_management.dart';
import '../utils/string_helpers.dart';

class FeatureTemplates {
  static Map<String, String> files(StateManagement state, String name) {
    final snake = StringHelpers.snakeCase(name);
    final className = StringHelpers.pascalCase(name);

    final files = <String, String>{
      'lib/features/$snake/README.md': _readme(name),
      'lib/features/$snake/data/README.md': _layerReadme('Data'),
      'lib/features/$snake/data/model/${snake}_model.dart':
          _model(snake, className),
      'lib/features/$snake/data/source/${snake}_remote_source.dart':
          _remoteSource(state, snake, className),
      'lib/features/$snake/data/repository/${snake}_repository_impl.dart':
          _repositoryImpl(state, snake, className),
      'lib/features/$snake/domain/README.md': _layerReadme('Domain'),
      'lib/features/$snake/domain/entity/${snake}_entity.dart':
          _entity(snake, className),
      'lib/features/$snake/domain/repository/${snake}_repository.dart':
          _repositoryContract(snake, className),
      'lib/features/$snake/domain/usecase/${snake}_usecase.dart':
          _usecase(state, snake, className),
      'lib/features/$snake/presentation/README.md':
          _layerReadme('Presentation'),
      'lib/features/$snake/presentation/widgets/${snake}_card.dart':
          _cardWidget(snake, className),
    };

    switch (state) {
      case StateManagement.bloc:
        files.addAll(_blocPresentation(snake, className));
      case StateManagement.getx:
        files.addAll(_getxPresentation(snake, className));
      case StateManagement.riverpod:
        files.addAll(_riverpodPresentation(snake, className));
    }

    return files;
  }

  static Map<String, String> _blocPresentation(String snake, String className) {
    return {
      'lib/features/$snake/presentation/pages/${snake}_screen.dart':
          _blocScreen(snake, className),
      'lib/features/$snake/presentation/bloc/${snake}_bloc.dart':
          _blocBloc(snake, className),
      'lib/features/$snake/presentation/bloc/${snake}_event.dart':
          _blocEvent(snake, className),
      'lib/features/$snake/presentation/bloc/${snake}_state.dart':
          _blocState(snake, className),
    };
  }

  static Map<String, String> _getxPresentation(String snake, String className) {
    return {
      'lib/features/$snake/presentation/pages/${snake}_screen.dart':
          _getxScreen(snake, className),
      'lib/features/$snake/presentation/controller/${snake}_controller.dart':
          _getxController(snake, className),
      'lib/features/$snake/presentation/bindings/${snake}_binding.dart':
          _getxBinding(snake, className),
    };
  }

  static Map<String, String> _riverpodPresentation(
      String snake, String className) {
    return {
      'lib/features/$snake/presentation/pages/${snake}_screen.dart':
          _riverpodScreen(snake, className),
      'lib/features/$snake/presentation/providers/${snake}_providers.dart':
          _riverpodProviders(snake, className),
      'lib/features/$snake/presentation/state/${snake}_state.dart':
          _riverpodState(snake, className),
    };
  }

  static String _readme(String name) => '''
# $name

Describe the feature, responsibilities, and flows here.
''';

  static String _layerReadme(String title) => '''
# $title Layer

Add $title layer files here.
''';

  static String _model(String snake, String className) => '''
import '../../domain/entity/${snake}_entity.dart';

class ${className}Model {
  ${className}Model({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ${className}Model.fromJson(Map<String, dynamic> json) {
    return ${className}Model(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ${className}Entity toEntity() {
    return ${className}Entity(id: id, title: title);
  }
}
''';

  static String _entity(String snake, String className) => '''
class ${className}Entity {
  ${className}Entity({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
''';

  static String _repositoryContract(String snake, String className) => '''
import '../../../../core/utils/result.dart';
import '../entity/${snake}_entity.dart';

abstract class ${className}Repository {
  Future<Result<List<${className}Entity>>> get${className}Data();
}
''';

  static String _remoteSource(
    StateManagement state,
    String snake,
    String className,
  ) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    // Use the snake name to preserve word boundaries for endpoints.
    final camelName = StringHelpers.camelCase(snake);
    return '''
import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/endpoints.dart';
$injectableImport
import '../model/${snake}_model.dart';

$injectableAnno
class ${className}RemoteSource {
  ${className}RemoteSource(this._api, this._session);

  final ApiService _api;
  final SessionManager _session;

  Future<List<${className}Model>> fetchData() async {
    final token = await _session.getToken();
    final response = await _api.get(ApiEndpoints.${camelName}List, query: {
      'token': token ?? '',
    });

    final data = (response.data as List<dynamic>? ?? []);
    return data
        .map((item) => ${className}Model.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
''';
  }

  static String _repositoryImpl(
      StateManagement state, String snake, String className) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc
        ? '@LazySingleton(as: ${className}Repository)\n'
        : '';
    return '''
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/${snake}_entity.dart';
import '../../domain/repository/${snake}_repository.dart';
// import '../model/${snake}_model.dart';
import '../source/${snake}_remote_source.dart';
$injectableImport

$injectableAnno
class ${className}RepositoryImpl implements ${className}Repository {
  ${className}RepositoryImpl(this._remote);

  final ${className}RemoteSource _remote;

  @override
  Future<Result<List<${className}Entity>>> get${className}Data() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(AppFailure.fromException(e));
    }
  }
}
''';
  }

  static String _usecase(
      StateManagement state, String snake, String className) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno = state == StateManagement.bloc ? '@injectable\n' : '';
    return '''
import '../../../../core/utils/result.dart';
import '../entity/${snake}_entity.dart';
import '../repository/${snake}_repository.dart';
$injectableImport

$injectableAnno
class ${className}UseCase {
  ${className}UseCase(this._repo);

  final ${className}Repository _repo;

  Future<Result<List<${className}Entity>>> call() {
    return _repo.get${className}Data();
  }
}
''';
  }

  static String _blocEvent(String snake, String className) => '''
import 'package:equatable/equatable.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object?> get props => [];
}

class Load${className} extends ${className}Event {
  const Load${className}();
}
''';

  static String _blocState(String snake, String className) => '''
import 'package:equatable/equatable.dart';
import '../../domain/entity/${snake}_entity.dart';

enum ${className}Status { initial, loading, success, failure }

class ${className}State extends Equatable {
  const ${className}State({
    this.status = ${className}Status.initial,
    this.items = const [],
    this.message,
  });

  final ${className}Status status;
  final List<${className}Entity> items;
  final String? message;

  ${className}State copyWith({
    ${className}Status? status,
    List<${className}Entity>? items,
    String? message,
  }) {
    return ${className}State(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
''';

  static String _blocBloc(String snake, String className) => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/${snake}_usecase.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc(this._useCase) : super(const ${className}State()) {
    on<Load${className}>(_onLoad);
    add(const Load${className}());
  }

  final ${className}UseCase _useCase;

  Future<void> _onLoad(
    Load${className} event,
    Emitter<${className}State> emit,
  ) async {
    emit(state.copyWith(status: ${className}Status.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ${className}Status.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ${className}Status.success,
          items: data,
        ),
      ),
    );
  }
}
''';

  static String _blocScreen(String snake, String className) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/${snake}_bloc.dart';
import '../bloc/${snake}_state.dart';
import '../widgets/${snake}_card.dart';

class ${className}Screen extends StatelessWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('${snake}_title'))),
      body: BlocBuilder<${className}Bloc, ${className}State>(
        builder: (context, state) {
          switch (state.status) {
            case ${className}Status.loading:
              return const Center(child: CircularProgressIndicator());
            case ${className}Status.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ${className}Status.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ${className}Card(entity: state.items[index]),
              );
            case ${className}Status.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
''';

  static String _getxController(String snake, String className) => '''
import 'package:get/get.dart';

import '../../domain/entity/${snake}_entity.dart';
import '../../domain/usecase/${snake}_usecase.dart';

class ${className}Controller extends GetxController {
  ${className}Controller(this._useCase);

  final ${className}UseCase _useCase;

  final items = <${className}Entity>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load${className}Data();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> load${className}Data() async {
    loading.value = true;
    error.value = null;
    final result = await _useCase();
    result.fold(
      (failure) => error.value = failure.message,
      (data) => items.assignAll(data),
    );
    loading.value = false;
  }
}
''';

  static String _getxBinding(String snake, String className) => '''
import 'package:get/get.dart';

import '../../domain/usecase/${snake}_usecase.dart';
import '../../domain/repository/${snake}_repository.dart';
import '../../data/repository/${snake}_repository_impl.dart';
import '../../data/source/${snake}_remote_source.dart';
import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../controller/${snake}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ${className}RemoteSource(
        Get.find<ApiService>(),
        Get.find<SessionManager>(),
      ),
    );
    Get.lazyPut<${className}Repository>(
      () => ${className}RepositoryImpl(Get.find<${className}RemoteSource>()),
    );
    Get.lazyPut(() => ${className}UseCase(Get.find<${className}Repository>()));
    Get.lazyPut(() => ${className}Controller(Get.find<${className}UseCase>()));
  }
}
''';

  static String _getxScreen(String snake, String className) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/${snake}_controller.dart';
import '../widgets/${snake}_card.dart';

class ${className}Screen extends StatelessWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<${className}Controller>();
    return Scaffold(
      appBar: AppBar(title: Text('${snake}_title'.tr)),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value ?? 'Error'));
        }
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, index) =>
              ${className}Card(entity: controller.items[index]),
        );
      }),
    );
  }
}
''';

  static String _riverpodState(String snake, String className) => '''
import '../../domain/entity/${snake}_entity.dart';

class ${className}State {
  const ${className}State({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  final bool loading;
  final List<${className}Entity> items;
  final String? error;

  ${className}State copyWith({
    bool? loading,
    List<${className}Entity>? items,
    String? error,
  }) {
    return ${className}State(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}
''';

  static String _riverpodProviders(String snake, String className) => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/${snake}_repository.dart';
import '../../domain/usecase/${snake}_usecase.dart';
import '../../data/repository/${snake}_repository_impl.dart';
import '../../data/source/${snake}_remote_source.dart';
import '../../../core/api_client/api_service.dart';
import '../../../core/di/providers.dart';
import '../../../core/session_manager/session_manager.dart';
import '../state/${snake}_state.dart';

final ${snake}RemoteSourceProvider = Provider<${className}RemoteSource>((ref) {
  return ${className}RemoteSource(
    ref.watch(apiServiceProvider),
    ref.watch(sessionManagerProvider),
  );
});

final ${snake}RepositoryProvider = Provider<${className}Repository>((ref) {
  return ${className}RepositoryImpl(ref.watch(${snake}RemoteSourceProvider));
});

final ${snake}UseCaseProvider = Provider<${className}UseCase>((ref) {
  return ${className}UseCase(ref.watch(${snake}RepositoryProvider));
});

final ${snake}NotifierProvider =
    StateNotifierProvider<${className}Notifier, ${className}State>(
  (ref) => ${className}Notifier(ref.watch(${snake}UseCaseProvider)),
);

class ${className}Notifier extends StateNotifier<${className}State> {
  ${className}Notifier(this._useCase) : super(const ${className}State()) {
    load();
  }

  final ${className}UseCase _useCase;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    final result = await _useCase();
    result.fold(
      (failure) =>
          state = state.copyWith(loading: false, error: failure.message),
      (data) => state = state.copyWith(loading: false, items: data),
    );
  }
}
''';

  static String _riverpodScreen(String snake, String className) => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../providers/${snake}_providers.dart';
import '../widgets/${snake}_card.dart';

class ${className}Screen extends ConsumerWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${snake}NotifierProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('${snake}_title'))),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (_, index) =>
                      ${className}Card(entity: state.items[index]),
                ),
    );
  }
}
''';

  static String _cardWidget(String snake, String className) => '''
import 'package:flutter/material.dart';
import '../../domain/entity/${snake}_entity.dart';

class ${className}Card extends StatelessWidget {
  const ${className}Card({super.key, required this.entity});

  final ${className}Entity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
''';
}
