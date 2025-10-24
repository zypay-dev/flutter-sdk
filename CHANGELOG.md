# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-10-08

### Added

- Initial release of Zypay Flutter SDK
- Multi-blockchain support (TON, BSC)
- Flutter Provider API for state management
- Payment processing with Socket.IO real-time communication
- Comprehensive debug logging system
- QR code generation for payments
- Beautiful, responsive UI widgets:
  - PaymentWidget - Main payment interface
  - OptionSelectionWidget - Blockchain and package selection
  - PaymentDetailsWidget - Transaction details with QR code
  - LoadingWidget - Loading states
  - ErrorWidget - Error handling
- Real-time payment status updates via WebSocket
- Transaction history display
- Payment timer with expiry tracking
- Clipboard support for wallet addresses
- TypeScript-like type safety with Dart
- Comprehensive error handling with retry logic
- Configuration management with debug modes
- Example application with complete integration
- Full documentation and API reference

### Features

- **Payment Processing**: Secure blockchain payment handling
- **Multi-blockchain**: Support for TON and BSC networks
- **Real-time Updates**: Live payment status monitoring via WebSocket
- **Type Safety**: Full Dart type safety with Equatable
- **Security**: Encrypted API communications and secure token handling
- **Mobile First**: Responsive design for all device sizes
- **Easy Integration**: Simple Provider-based API
- **Debug Tools**: Comprehensive logging for development
- **QR Payments**: Generate scannable QR codes for easy payment
- **Transaction History**: View recent payment transactions

### Security

- All API communications are encrypted via HTTPS
- Tokens are securely handled and never stored locally
- Sensitive data is sanitized in debug logs
- No local storage of payment information
- Socket.IO secure connection with authentication

### Architecture

- Clean architecture with separation of concerns
- Provider pattern for state management
- Socket.IO for real-time communication
- Modular widget system
- Extensible configuration system
- Performance-optimized with minimal rebuilds

### Documentation

- Comprehensive README with examples
- API reference documentation
- Example application with best practices
- Inline code documentation
- Security guidelines
- Contributing guidelines

## [Unreleased]

### Planned Features

- Additional blockchain support (Ethereum, Polygon, Solana)
- Payment analytics and reporting
- Custom UI themes and styling
- Webhook support for backend integration
- Payment history management with pagination
- Multi-language support
- Offline mode with queue
- Enhanced error recovery
- Payment receipt generation
- Biometric authentication support
- Deep linking support
- Push notification integration
- Advanced transaction filtering
- Payment scheduling
- Recurring payments support

### Known Issues

None at this time.

### Migration Guide

N/A - Initial release

---

## Release Notes

### Version 1.0.0

This is the initial public release of the Zypay Flutter SDK. It provides a complete solution for integrating blockchain payments into Flutter applications with support for multiple blockchains, real-time updates, and a beautiful UI.

**Key Highlights:**

- ✅ Production-ready for TON and BSC blockchains
- ✅ Real-time payment tracking
- ✅ Beautiful, responsive UI out of the box
- ✅ Comprehensive error handling
- ✅ Developer-friendly debug tools
- ✅ Type-safe API
- ✅ Example app included

**Getting Started:**

```dart
ZypayProvider(
  config: ZypayConfig(
    token: 'your-api-token',
    hostUrl: 'https://api.zypay.app',
  ),
  child: MyApp(),
)
```

For detailed documentation, visit [docs.zypay.app](https://docs.zypay.app)

---

Made with ❤️ by the Zypay Team
