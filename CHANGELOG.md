## 1.0.0

### 🎉 Initial Release

**ARCLE** is a production-ready Flutter CLI for Clean Architecture scaffolding.

#### Features

- **Project Creation** - Create new Flutter projects with Clean Architecture structure
- **Multiple State Management** - Support for BLoC, GetX, and Riverpod
- **Feature Generation** - Generate complete feature modules with data/domain/presentation layers
- **Dependency Injection** - Auto-configured DI setup for each state management solution
- **Routing** - Pre-configured routing with route observer and deep linking support
- **Localization** - Multi-language support with JSON translation files
- **Theme Management** - Light/Dark theme switching built-in
- **API Client** - Dio-based HTTP client with interceptors and error handling
- **Session Management** - Secure token storage and authentication management
- **Common Widgets** - Reusable UI components library
- **APK Builds** - Debug/Release builds with smart renaming
- **Documentation** - Generate project documentation

#### State Management Support

- **BLoC** - Full pattern with Events, States, Blocs, GetIt + Injectable DI
- **GetX** - Controllers with reactive observables and Bindings
- **Riverpod** - StateNotifier pattern with Provider-based DI and ProviderLogger

#### Commands

- `arcle create <name>` - Create a new Flutter project
- `arcle init` - Scaffold Clean Architecture in existing project
- `arcle feature <name>` - Generate a feature module
- `arcle auto-gen-di` - Regenerate DI and refresh dependencies
- `arcle gen-di` - Regenerate DI files only
- `arcle build` - Build APK (debug or release)
- `arcle gen-doc` - Generate project documentation
