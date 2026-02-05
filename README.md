# lunalist
Lunalist is a music-based party game inspired by timeline guessing mechanics. 
Use it with Spotify or your own mp3 files!

# Why?
This project was created to offer a song guessing game where players are free to choose their own music, without being limited by a large corporation’s curated song selection.
Lunalist was developed as a project for our 12th grade informatics class, where each student is required to design and implement an independent software project.

## Installing
### Android
- ensure your device is running android 10 or newer
- download latest apk file on [releases](https://github.com/Lmntrixpy/Lunalist/releases/latest) page.
- install apk by clicking on it (you may need to allow the installation of unknown sources)

### iOS / iPadOS
- ensure your device is running iOS 15.0 or newer
- download latest ipa file on [releases](https://github.com/Lmntrixpy/Lunalist/releases/latest) page.
- install it ...
  - ... via [Trollstore](https://github.com/opa334/TrollStore) (iOS 15.X or any other supported iOS Version)
  - ... via [Impactor](https://github.com/khcrysalis/Impactor), [AltServer](https://faq.altstore.io/altstore-classic/altserver), [Sideloadly](https://sideloadly.io) or any other Sideloading Software (iOS 16+)

## App Building
### android
```
gh repo clone Lmntrixpy/lunalist # pull repo via github-cli
cd lunalist

flutter pub get # get dependencies

flutter clean # clean build cache
flutter build apk --relase # build apk for android
```

### iOS / iPadOS
```
gh repo clone Lmntrixpy/lunalist # pull repo via github-cli
cd lunalist

flutter pub get # get dependencies

flutter clean # clean build cache
flutter build ipa --relase --no-codesign # build xcarchive
``` 
- drag & drop generated `runner.xcarchive` into [IOS App Signer](https://dantheman827.github.io/ios-app-signer/)

### MacOS
```
gh repo clone Lmntrixpy/lunalist # pull repo via github-cli
cd lunalist

flutter pub get # get dependencies

flutter clean # clean build cache
flutter build mac --relase  # build app for MacOS
```

### Windows

## Disclaimer
This project was created with the help of Ai while debugging. Not for code generation. 

