# Contributing to Zypay Flutter SDK

First off, thank you for considering contributing to Zypay Flutter SDK! It's people like you that make this SDK better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@zypay.app.

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members
- Accept constructive criticism gracefully

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a new branch for your contribution
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the behavior
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Flutter version and device information
- SDK version
- Any relevant error messages or logs

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- A clear and descriptive title
- A detailed description of the proposed enhancement
- Explanation of why this enhancement would be useful
- Possible implementation approach (optional)

### Pull Requests

- Fill in the pull request template
- Follow the Dart style guide
- Include tests for new functionality
- Update documentation as needed
- Ensure all tests pass
- Keep pull requests focused on a single concern

## Development Setup

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Git
- A code editor (VS Code, Android Studio, IntelliJ IDEA)

### Setup Instructions

1. Clone your fork:
```bash
git clone https://github.com/your-username/flutter-sdk.git
cd flutter-sdk
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the example app:
```bash
cd example
flutter run
```

4. Run tests:
```bash
flutter test
```

5. Run analyzer:
```bash
flutter analyze
```

## Coding Guidelines

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

### Code Structure

```
lib/
├── src/
│   ├── core/              # Core business logic
│   │   ├── config/        # Configuration classes
│   │   ├── types/         # Type definitions
│   │   └── payment_client.dart
│   ├── provider/          # State management
│   ├── widgets/           # UI components
│   └── utils/             # Utility functions
└── zypay_flutter_sdk.dart # Public API
```

### Best Practices

1. **Type Safety**: Use strong typing and avoid dynamic types where possible
2. **Null Safety**: Leverage Dart's null safety features
3. **Immutability**: Prefer immutable data structures
4. **Documentation**: Add dartdoc comments for public APIs
5. **Error Handling**: Use proper error handling and validation
6. **Performance**: Optimize for performance and minimize rebuilds
7. **Testing**: Write tests for new functionality
8. **Naming**: Use clear, descriptive names for variables and functions

### Widget Guidelines

- Keep widgets small and focused
- Use const constructors where possible
- Implement proper lifecycle methods
- Handle dispose properly
- Use keys appropriately

### State Management

- Use Provider pattern for state management
- Keep business logic separate from UI
- Use ChangeNotifier for state updates
- Implement proper disposal of resources

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(payment): add support for Ethereum blockchain

Implement Ethereum blockchain integration with Web3 support.
Includes wallet connection and transaction processing.

Closes #123
```

```
fix(ui): resolve QR code rendering issue on iOS

The QR code was not displaying correctly on iOS devices due to
incorrect size constraints. Updated the widget to use proper
sizing.

Fixes #456
```

## Pull Request Process

1. **Update Documentation**: Update README.md and other docs if needed
2. **Add Tests**: Include tests for new functionality
3. **Update Changelog**: Add entry to CHANGELOG.md
4. **Run Checks**: Ensure all tests and linting pass
5. **Request Review**: Request review from maintainers
6. **Address Feedback**: Make requested changes promptly
7. **Merge**: Maintainers will merge when approved

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests added
- [ ] All tests passing
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] No breaking changes (or documented)
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/payment_client_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for complete flows
- Aim for high test coverage
- Use mocks and fixtures appropriately

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

void main() {
  group('PaymentClient', () {
    test('should initialize successfully', () {
      // Arrange
      final config = ZypayConfig(token: 'test-token');
      
      // Act
      final client = PaymentClient(config: config);
      
      // Assert
      expect(client, isNotNull);
    });
  });
}
```

## Documentation

### Dartdoc Comments

Use dartdoc comments for public APIs:

```dart
/// Processes a payment transaction for the specified blockchain.
///
/// The [blockchain] parameter specifies which blockchain to use.
/// The optional [packageName] parameter selects a specific package.
///
/// Returns a [Future] that resolves to the created [Transaction].
///
/// Throws [Exception] if the transaction fails to process.
///
/// Example:
/// ```dart
/// final transaction = await client.processTransaction(
///   blockchain: BlockchainType.ton,
///   packageName: PackageName.basic,
/// );
/// ```
Future<Transaction> processTransaction({
  required BlockchainType blockchain,
  PackageName? packageName,
}) async {
  // Implementation
}
```

### README Updates

When adding new features, update:
- Feature list
- Usage examples
- API reference
- Configuration options

## Questions?

Feel free to reach out:
- 📧 Email: support@zypay.app
- 💬 Discord: [Join our community](https://discord.gg/zypay)
- 📖 Documentation: [docs.zypay.app](https://docs.zypay.app)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Zypay Flutter SDK! 🚀

