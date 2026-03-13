# Fokus.

A beautifully minimal, offline-first note-taking application built with Flutter. Fokus is designed to remove distractions, offering a clean, monochrome interface that lets your thoughts take center stage.

## Features

* **Folder Organization:** Keep your ideas structured by grouping notes into custom folders.
* **Distraction-Free Editor:** A highly responsive, clean text editor.
* **Rich Media:** Seamlessly attach images to your notes directly from your device gallery.
* **Typography Control:** Toggle between clean sans-serif (Inter), classic serif, and monospace fonts to suit your writing mood.
* **Quick Formats:** Instantly insert markdown-style checklists into your notes.
* **Offline-First Storage:** Lightning-fast local data persistence powered by Hive—no internet required.
* **Search:** Instantly filter and find folders and notes by title or content.

## Tech Stack

* **Framework:** Flutter / Dart
* **State Management:** Provider
* **Local Database:** Hive (NoSQL)
* **Design:** Custom minimalist monochrome UI

## Getting Started

To run this project locally, ensure you have Flutter installed on your machine.

**1. Clone the repository**
```bash
git clone https://github.com/harsh136/fokus-app.git

cd fokus-app
```
**2. Install dependencies**
```bash
flutter pub get
```
**3. Run the app**
```bash
flutter run
```

## Build for Android (APK)
To generate a standalone APK file to install on your Android device:
```bash
flutter build apk --release
```

The compiled APK will be located at: build/app/outputs/flutter-apk/app-release.apk
