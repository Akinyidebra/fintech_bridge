# FinTech Bridge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Overview

FinTech Bridge is a mobile application designed to connect Kabarak University students with short-term loan providers. The application serves as an intermediary platform addressing urgent financial needs caused by delays in traditional financial aid systems like HELB.

**Research Insight:** 75% of students at Kenyan universities experience financial aid delays

**Key Benefits:**
- Alleviate financial stress
- Improve academic performance
- Enhance student well-being

## Key Features

- 🔒 University Credential Authentication
- 📄 Streamlined Loan Application
- 🤖 Automated Risk Assessment
- 🤝 Financial Provider Matching
- 💸 M-Pesa Integration
- 🔔 Repayment Reminders
- 📊 Financial Analytics

## Technology Stack

| Component       | Technology                          |
|-----------------|-------------------------------------|
| Frontend        | Flutter (iOS & Android)             |
| Backend         | Firebase (Auth, Firestore, Cloud Functions) |
| Payment Gateway | Safaricom M-Pesa API                |
| Notifications   | Africa's Talking SMS API            |

## Project Structure

```
fintech_bridge/
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── lib/                   # Core application code
│   ├── config/            # App configuration
│   ├── models/            # Data models
│   ├── screens/           # UI components
│   ├── services/          # Business logic
│   └── ...                # Other directories
├── functions/             # Firebase Cloud Functions
├── test/                  # Test suites
├── CONTRIBUTING.md        # Contribution guidelines
├── LICENSE.md             # MIT License
└── pubspec.yaml           # Dependency management
```

## Getting Started

### Prerequisites
- Flutter 3.0+
- Firebase CLI
- Dart 2.17+

### Installation
```bash
git clone https://github.com/Akinyidebra/fintech_bridge.git
cd fintech_bridge
flutter pub get
```

### Firebase Configuration
1. Create Firebase project
2. Add iOS/Android apps
3. Download config files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

### Run the App
```bash
flutter run
```

## Contributing

We welcome contributions! Please read our [Contribution Guidelines](CONTRIBUTING.md) before making any changes.

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

## Contact

**Project Lead**: Dee  
**Email**: dee@fintechbridge.com  
**University Partner**: Kabarak University