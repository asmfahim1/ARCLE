import '../../state_management.dart';
import '../../templates/app_templates.dart';
import '../../templates/core/api_templates.dart';
import '../../templates/core/constants_templates.dart';
import '../../templates/core/core_templates.dart';
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

Map<String, String> buildCommonProjectFiles(StateManagement state) {
  final files = <String, String>{
    'lib/bootstrap.dart': AppTemplates.bootstrap(state),
    'lib/app/app.dart': AppTemplates.app(state),
    'lib/main.dart': AppTemplates.mainEntry(),
    'lib/core/README.md': ReadmeTemplates.coreReadme(),
    'lib/core/api_client/dio_client.dart': ApiTemplates.dioClient(state),
    'lib/core/api_client/api_service.dart': ApiTemplates.apiService(state),
    'lib/core/api_client/base_response.dart': ApiTemplates.apiResponse(),
    'lib/core/localization/app_strings.dart':
        LocalizationTemplates.appStrings(state),
    'assets/images/.gitkeep': '',
    'assets/icons/.gitkeep': '',
    'lib/core/utils/constants.dart': ConstantsTemplates.appConstants(),
    'lib/core/utils/endpoints.dart': ConstantsTemplates.apiEndpoints(),
    'lib/core/utils/enums.dart': ConstantsTemplates.appEnums(),
    'lib/core/utils/app_assets.dart': ConstantsTemplates.appAssets(),
    'lib/core/utils/app_colors.dart': ConstantsTemplates.appColors(),
    'lib/core/utils/dimensions.dart': DimensionsTemplates.dimensions(state),
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
    'lib/core/di/app_di.dart': DiTemplates.di(state),
    'lib/core/env/env.dart': EnvTemplates.envBase(),
    'lib/core/env/prod_env.dart': EnvTemplates.envProd(),
    'lib/core/env/stag_env.dart': EnvTemplates.envStag(),
    'lib/core/env/local_env.dart': EnvTemplates.envLocal(),
    'lib/core/env/env_factory.dart': EnvTemplates.envFactory(),
    'lib/core/session_manager/pref_manager.dart':
        ServicesTemplates.prefManager(state),
    'lib/core/session_manager/session_manager.dart':
        ServicesTemplates.sessionManager(state),
    'lib/core/response_handler/response_handler.dart':
        CoreTemplates.responseHandler(),
    'lib/core/error_handler/error_handler.dart': CoreTemplates.errorHandler(),
    'lib/core/route_handler/app_routes.dart': RouteTemplates.routes(),
    'lib/core/route_handler/app_route_observer.dart':
        RouteTemplates.observer(),
    'lib/core/route_handler/app_router.dart': RouteTemplates.router(state),
    'lib/core/theme_handler/app_theme.dart': ThemeTemplates.themeHandler(),
    'lib/core/notifications/notification_service.dart':
        ServicesTemplates.notificationService(state),
    'lib/core/permissions/permission_service.dart':
        ServicesTemplates.permissionService(state),
    'lib/core/utils/logger.dart': UtilsTemplates.utilsLogger(),
    'lib/core/utils/app_failure.dart': UtilsTemplates.utilsFailure(),
    'lib/core/utils/result.dart': UtilsTemplates.utilsResult(),
    'lib/core/utils/app_validators.dart': UtilsTemplates.appValidators(),
    'lib/core/utils/validators.dart': UtilsTemplates.utilsValidators(),
    'lib/features/README.md': ReadmeTemplates.featuresReadme(),
    'test/features/auth/login_screen_test.dart':
        TestsTemplates.loginScreenTest(state),
    'test/features/users/user_model_test.dart': TestsTemplates.userModelTest(),
    'test/widget_test.dart': TestsTemplates.widgetTest(state),
  };

  files.addAll(SettingsTemplates.files(state));
  files.addAll(DemoTemplates.files(state));
  files['test/features/settings/settings_screen_test.dart'] =
      TestsTemplates.settingsScreenTest(state);

  return files;
}
