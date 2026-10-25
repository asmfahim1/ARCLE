import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/templates/core/constants_templates.dart';
import 'package:arcle/src/templates/core/widgets_templates.dart';
import 'package:test/test.dart';

void main() {
  group('Widgets Templates & AppColors Integration', () {
    test('appColors template includes static tokens and adaptive theme helpers', () {
      final code = ConstantsTemplates.appColors();
      expect(code, contains('class AppColors'));
      expect(code, contains('brandPrimaryLight'));
      expect(code, contains('brandPrimaryDark'));
      expect(code, contains('lightSurface'));
      expect(code, contains('darkSurface'));
      expect(code, contains('lightBorder'));
      expect(code, contains('darkBorder'));
      expect(code, contains('lightTextPrimary'));
      expect(code, contains('darkTextPrimary'));
      expect(code, contains('static bool isDark(BuildContext context)'));
      expect(code, contains('static Color primary(BuildContext context)'));
      expect(code, contains('static Color accent(BuildContext context)'));
      expect(code, contains('static Color background(BuildContext context)'));
      expect(code, contains('static Color surface(BuildContext context)'));
      expect(code, contains('static Color border(BuildContext context)'));
      expect(code, contains('static Color textPrimary(BuildContext context)'));
      expect(code, contains('static Color textSecondary(BuildContext context)'));
    });

    test('svgIcon template imports app_colors and supports colorFilter', () {
      final code = WidgetsTemplates.svgIcon();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class SvgIcon extends StatelessWidget'));
      expect(code, contains('final Color? color;'));
      expect(code, contains('ColorFilter.mode'));
    });

    test('commonLoader template imports app_colors and provides circular and shimmer loaders', () {
      final code = WidgetsTemplates.commonLoader();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonLoader extends StatelessWidget'));
      expect(code, contains('const CommonLoader.shimmer('));
      expect(code, contains('const CommonLoader.circularShimmer('));
      expect(code, contains('class CommonShimmer extends StatefulWidget'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('CircularProgressIndicator'));
      expect(code, contains('defaultBase'));
      expect(code, contains('defaultHighlight'));
    });

    test('commonButton template imports app_colors and wires light/dark theme defaults', () {
      final code = WidgetsTemplates.commonButton();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonButton extends StatelessWidget'));
      expect(code, contains('AppColors.isDark(context)'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('AppColors.disabled'));
      expect(code, contains('disabledBackgroundColor'));
      expect(code, contains('disabledForegroundColor'));
    });

    test('commonTextField template imports app_colors and adapts colors dynamically', () {
      final code = WidgetsTemplates.commonTextField();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonTextField extends StatelessWidget'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.border(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
      expect(code, contains('AppColors.textSecondary(context)'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('AppColors.error'));
    });

    test('commonDropdown template imports app_colors and styles menu and items', () {
      final code = WidgetsTemplates.commonDropdown();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonDropdown<T> extends StatelessWidget'));
      expect(code, contains('dropdownColor: effectiveDropdownColor'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.border(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
      expect(code, contains('AppColors.textSecondary(context)'));
    });

    test('commonCheckbox template imports app_colors and styles active, border, and text', () {
      final code = WidgetsTemplates.commonCheckbox();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonCheckbox extends StatelessWidget'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('AppColors.border(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
    });

    test('commonSnackbar template imports app_colors and covers all semantic colors', () {
      final code = WidgetsTemplates.commonSnackbar();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonSnackbar'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('AppColors.error'));
      expect(code, contains('AppColors.success'));
      expect(code, contains('AppColors.warning'));
      expect(code, contains('AppColors.info'));
    });

    test('commonAppBar template imports app_colors and adapts background and text', () {
      final code = WidgetsTemplates.commonAppBar();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonAppBar extends StatelessWidget'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
    });

    test('commonBottomSheet template imports app_colors and adapts background and title', () {
      final code = WidgetsTemplates.commonBottomSheet();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonBottomSheet extends StatelessWidget'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
    });

    test('commonDialog template imports app_colors and adapts background, text, and actions', () {
      final code = WidgetsTemplates.commonDialog();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonDialog extends StatelessWidget'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.textPrimary(context)'));
      expect(code, contains('AppColors.textSecondary(context)'));
      expect(code, contains('AppColors.primary(context)'));
    });

    test('commonImageContainer template imports app_colors and adapts indicators', () {
      final code = WidgetsTemplates.commonImageContainer(StateManagement.bloc);
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class CommonImageContainer extends StatelessWidget'));
      expect(code, contains('AppColors.surface(context)'));
      expect(code, contains('AppColors.primary(context)'));
      expect(code, contains('AppColors.border(context)'));
    });

    test('paginatedListView template imports app_colors and adapts indicator', () {
      final code = WidgetsTemplates.paginatedListView();
      expect(code, contains("import '../theme_manager/app_colors.dart';"));
      expect(code, contains('class PaginatedListView<T> extends StatelessWidget'));
      expect(code, contains('AppColors.primary(context)'));
    });
  });
}
