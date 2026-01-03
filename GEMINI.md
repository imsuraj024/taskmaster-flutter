# Architectural Principles

- **DRY (Don't Repeat Yourself)** – eliminate duplicated logic by extracting shared utilities and modules.

- **Separation of Concerns** – each module should handle one distinct responsibility.

- **Single Responsibility Principle (SRP)** – every class/module/function/file should have exactly one reason to change.

- **Clear Abstractions & Contracts** – expose intent through small, stable interfaces and hide implementation details.

- **Low Coupling, High Cohesion** – keep modules self-contained, minimize cross-dependencies.

- **Scalability & Statelessness** – design components to scale horizontally and prefer stateless services when possible.

- **Observability & Testability** – build in logging, metrics, tracing, and ensure components can be unit/integration tested.

- **KISS (Keep It Simple, Sir)** - keep solutions as simple as possible.

- **YAGNI (You're Not Gonna Need It)** – avoid speculative complexity or over-engineering.

- **TDD (Test-Driven Development)** - write the tests first; the implementation
  code isn't done until the tests pass.

# Coding Standards

## Linting

This project uses the standard set of lints provided by the flutter_lints package. Ensure that all code adheres to these rules to maintain code quality and consistency. Run flutter analyze frequently to check for linting issues.

## Naming Conventions
- **Files**: Use snake_case for file names.
- **Classes**: Use PascalCase for classes.
- **Methods and Variables**: Use camelCase for methods and variables.
- **Constants**: Use camelCase for constants.