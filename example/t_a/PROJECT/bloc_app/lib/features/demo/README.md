# Demo Feature

This demo shows how to structure a feature using Clean Architecture:

- **data**: Remote data sources and repository implementations
- **domain**: Entities, repository contracts, and use cases
- **presentation**: UI screens, widgets, and state management
  - **pages**: Screen widgets (StatelessWidget)
  - **widgets**: Reusable UI components
  - **bloc/controller/notifiers**: State management classes
