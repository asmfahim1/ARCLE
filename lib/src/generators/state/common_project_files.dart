import '../../state_management.dart';
import '../../templates/app_templates.dart';
import '../../templates/core/analysis_templates.dart';
import '../../templates/core/api_templates.dart';
import '../../templates/core/constants_templates.dart';
import '../../templates/core/dialogs_templates.dart';
import '../../templates/core/dimensions_templates.dart';
import '../../templates/core/di_templates.dart';
import '../../templates/core/env_templates.dart';
import '../../templates/core/localization_templates.dart';
import '../../templates/core/readme_templates.dart';
import '../../templates/core/route_templates.dart';
import '../../templates/core/services_templates.dart';
import '../../templates/core/theme_templates.dart';
import '../../templates/core/utils_templates.dart';
import '../../templates/core/widgets_templates.dart';
import '../../templates/features/demo_templates.dart';
import '../../templates/features/settings_templates.dart';
import '../../templates/tests_templates.dart';

Map<String, String> buildCommonProjectFiles(
  StateManagement state, {
  String projectName = 'my_app',
  NetworkClient network = NetworkClient.dio,
}) {
  final files = <String, String>{
    'analysis_options.yaml': AnalysisTemplates.analysisOptions(),
    'lib/bootstrap.dart': AppTemplates.bootstrap(state),
    'lib/app/app.dart': AppTemplates.app(state, projectName: projectName),
    'lib/main.dart': AppTemplates.mainEntry(),
    'lib/core/README.md': ReadmeTemplates.coreReadme(),
    if (network.isHttp)
      'lib/core/network/http_client.dart': ApiTemplates.httpClient(state)
    else
      'lib/core/network/dio_client.dart': ApiTemplates.dioClient(state),
    'lib/core/network/api_service.dart': ApiTemplates.apiService(
      state,
      network,
    ),
    'lib/core/network/base_response.dart': ApiTemplates.apiResponse(network),
    'lib/core/localization/app_strings.dart': LocalizationTemplates.appStrings(
      state,
    ),
    'assets/images/.gitkeep': '',
    'assets/icons/.gitkeep': '',
    'lib/core/utils/constants.dart': ConstantsTemplates.appConstants(
      projectName: projectName,
    ),
    'lib/core/utils/endpoints.dart': ConstantsTemplates.apiEndpoints(),
    'lib/core/utils/enums.dart': ConstantsTemplates.appEnums(),
    'lib/core/utils/app_assets.dart': ConstantsTemplates.appAssets(),
    'lib/core/theme_manager/app_colors.dart': ConstantsTemplates.appColors(),
    'lib/core/theme_manager/dimensions.dart': DimensionsTemplates.dimensions(),
    'lib/core/utils/dialogs.dart': DialogsTemplates.dialogs(state),
    'lib/core/common_widgets/README.md': ReadmeTemplates.commonWidgetsReadme(),
    'lib/core/common_widgets/svg_icon.dart': WidgetsTemplates.svgIcon(),
    'lib/core/common_widgets/common_loader.dart':
        WidgetsTemplates.commonLoader(),
    'lib/core/common_widgets/common_button.dart':
        WidgetsTemplates.commonButton(),
    'lib/core/common_widgets/common_text_field.dart':
        WidgetsTemplates.commonTextField(),
    'lib/core/common_widgets/common_dropdown.dart':
        WidgetsTemplates.commonDropdown(),
    'lib/core/common_widgets/common_checkbox.dart':
        WidgetsTemplates.commonCheckbox(),
    'lib/core/common_widgets/common_snackbar.dart':
        WidgetsTemplates.commonSnackbar(),
    'lib/core/common_widgets/common_app_bar.dart':
        WidgetsTemplates.commonAppBar(),
    'lib/core/common_widgets/common_bottom_sheet.dart':
        WidgetsTemplates.commonBottomSheet(),
    'lib/core/common_widgets/common_dialog.dart':
        WidgetsTemplates.commonDialog(),
    'lib/core/common_widgets/common_image_container.dart':
        WidgetsTemplates.commonImageContainer(state),
    'lib/core/common_widgets/paginated_list_view.dart':
        WidgetsTemplates.paginatedListView(),
    'lib/core/di/app_di.dart': DiTemplates.di(state, network),
    'lib/core/env/env.dart': EnvTemplates.envBase(),
    'lib/core/env/prod_env.dart': EnvTemplates.envProd(),
    'lib/core/env/stag_env.dart': EnvTemplates.envStag(),
    'lib/core/env/local_env.dart': EnvTemplates.envLocal(),
    'lib/core/env/env_factory.dart': EnvTemplates.envFactory(),
    'lib/core/services/pref_manager.dart': ServicesTemplates.prefManager(
      state,
    ),
    'lib/core/services/session_manager.dart': ServicesTemplates.sessionManager(
      state,
    ),
    'lib/core/route_handler/app_routes.dart': RouteTemplates.routes(),
    'lib/core/route_handler/app_route_observer.dart': RouteTemplates.observer(),
    'lib/core/route_handler/app_router.dart': RouteTemplates.router(state),
    'lib/core/theme_manager/app_theme.dart': ThemeTemplates.themeHandler(),
    'lib/core/services/notification_service.dart':
        ServicesTemplates.notificationService(state),
    'lib/core/services/permission_service.dart':
        ServicesTemplates.permissionService(state),
    'lib/core/utils/logger.dart': UtilsTemplates.utilsLogger(),
    'lib/core/utils/date_formatter.dart': UtilsTemplates.utilsDateFormatter(),
    'lib/core/network/api_failure.dart': UtilsTemplates.utilsFailure(network),
    'lib/core/network/result.dart': UtilsTemplates.utilsResult(),
    'lib/core/utils/app_validators.dart': UtilsTemplates.appValidators(),
    'lib/core/utils/validators.dart': UtilsTemplates.utilsValidators(),
    'test/features/auth/login_screen_test.dart': TestsTemplates.loginScreenTest(
      state,
    ),
    'test/features/users/user_model_test.dart': TestsTemplates.userModelTest(),
    'test/widget_test.dart': TestsTemplates.widgetTest(state),
  };

  files.addAll(SettingsTemplates.files(state));
  files.addAll(DemoTemplates.files(state, network));
  files['test/features/settings/settings_screen_test.dart'] =
      TestsTemplates.settingsScreenTest(state);

  return files;
}
