<p align="center">
  <img src="web/icons/Icon-192.png" alt="PictoTap" width="96" height="96">
</p>

<h1 align="center">PictoTap</h1>

<p align="center">
  A communication app for accessibility using pictograms.<br>
  Built with Flutter for web, installable as a PWA.
</p>

<p align="center">
  <a href="https://endika.github.io/pictotap"><strong>Live Demo</strong></a> ·
  <a href="#features">Features</a> ·
  <a href="#getting-started">Getting Started</a>
</p>

---

## Features

- **Pictogram keyboard** with categorized icons (descriptive, people, prepositions, determiners, nouns, verbs)
- **Visual board** to compose messages by selecting pictograms
- **Share** the board as an image with text description
- **Installable PWA** — add to home screen on Android and iOS
- **Multi-language support**: English, Spanish, Catalan, Basque, French, Galician, Portuguese, Valencian
- **Accessibility-focused** design with semantic labels for screen readers

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0

### Installation

```bash
flutter pub get
flutter gen-l10n
```

### Running

```bash
flutter run
```

### Testing

```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── data/
│   └── pictogram_data.dart       # Pictogram categories and icon data
├── utils/
│   └── pictogram_utils.dart      # Icon utility functions
├── screens/
│   └── pictotap_screen.dart      # Main screen with board and state
├── widgets/
│   ├── pictogram_icon.dart       # Pictogram icon widget
│   ├── pictogram_keyboard.dart   # Keyboard widget with categories
│   └── board_empty_hint.dart     # Empty board hint animation
├── image_saver.dart              # Platform export selector
├── image_saver_native.dart       # Native image sharing
├── image_saver_web.dart          # Web image download
├── image_saver_stub.dart         # Stub for unsupported platforms
└── l10n/                         # Localization (ARB files)
```

## License

This project is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) — free to use, modify and share, but **not for commercial purposes**.
