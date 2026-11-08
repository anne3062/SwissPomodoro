# AGENTS.md

## Commands
- **Build**: `swift build`
- **Run**: `swift run`
- **Bundle app**: `Scripts/bundle.sh` (builds `SwissPomodoro.app`)
- **Test all**: `swift test`
- **Test single**: `swift test --filter <TestSuite>.<testMethod>`
- **Lint**: No linter configured
- **Format**: No formatter configured

## Code Style Guidelines

### Swift/SwiftUI
- **Indentation**: 2 spaces
- **Imports**: One per line, grouped by framework then alphabetically
- **Types**: Use structs over classes, prefer value types
- **Naming**: camelCase for variables/functions, PascalCase for types
- **Error Handling**: Use guard statements for early returns, avoid force unwraps
- **Concurrency**: StrictConcurrency enabled - use async/await patterns
- **Comments**: Minimal, only for complex logic
- **Properties**: Group @State/@ObservedObject first, then computed properties
- **Functions**: Group logically, actions separate from computed values
- **Formatting**: Use String(format:) for time/display strings
- **Previews**: Include PreviewProvider for all Views

### Testing
- Use Swift Testing framework
- Test files in Tests/ directory with @testable import
- Use `@Suite` for test containers and `@Test` for individual tests
- Follow naming: `<SuiteName>Tests` and descriptive test names

### Architecture
- SwiftUI declarative UI with MVVM pattern
- State management via @State and computed properties
- Timer-based updates with DispatchQueue.main.async
