# SmartSweep

**SmartSweep** is a privacy-first, AI-powered iOS app for cleaning duplicate, temporary, and one-time-use images from your iPhone or iPad. Designed for the Indonesian market with global scalability, SmartSweep helps users optimize storage, clean up their photo gallery, and upgrade to a premium experience with a one-time purchase.

## Features

- **Smart Scan**: Central animated button to scan your gallery for duplicate and temporary images
- **Storage Dashboard**: Visual progress, cleanable space stats, and usage breakdown
- **Suggested Actions**: Card-based, swipe-dismissible cleaning suggestions
- **Freemium Model**: Free tier with watermarked results, scan limits, and premium unlock for unlimited use
- **On-Device Processing**: No data ever leaves your device—privacy guaranteed
- **Localization**: Full Bahasa Indonesia and English support
- **App Store Compliance**: Follows Apple and Indonesian PDPI 2022 privacy guidelines

## Screenshots

![SmartSweep Home](assets/screenshots/home.png)
![SmartSweep Scan](assets/screenshots/scan.png)

## Getting Started

### Requirements
- Xcode 15+
- iOS 16.0+
- Swift 5.7+

### Build & Run
1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/SmartSweep.git
   cd SmartSweep
   ```
2. Open `SmartSweep.xcodeproj` in Xcode.
3. Build and run on a simulator or device (Photo Library access required).

## Architecture

- **Clean Architecture**: Domain, Data, and Presentation layers
- **MVVM**: SwiftUI Views and ViewModels
- **Combine**: Reactive data flow
- **Apple Vision**: AI-powered duplicate detection
- **StoreKit 2**: In-app purchase for premium unlock

## Folder Structure
```
SmartSweep/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   └── Repositories/
├── Presentation/
│   ├── Views/
│   └── ViewModels/
├── Core/
├── Assets.xcassets/
├── Info.plist
├── SmartSweepApp.swift
├── ContentView.swift
└── ...
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Credits
- Developed by Rizky Hasibuan
- Special thanks to the Indonesian iOS community

## ASO Keywords
See [ASO_KEYWORDS.md](ASO_KEYWORDS.md) for App Store keyword strategy.

## Development Calendar
See [DEVELOPMENT_CALENDAR.md](DEVELOPMENT_CALENDAR.md) for the 8-week MVP plan.
