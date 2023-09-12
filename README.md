# webwrapper

Turn your website to APK

## How to change project name

  1. install flutter rename `flutter pub global activate rename`
  2. change bundleId `flutter pub global run rename --bundleId com.companyname`
  3. change appname `flutter pub global run rename --appname "YourAppName"`


## Change app icon

  1. put your icon in `assets/icon/icon.png`
  2. run `flutter pub run flutter_launcher_icons`


## Build APK file

  1. run `flutter build apk --split-per-abi`
  2. the output file will be at `build/app/outputs/apk/release/app-arm64-v8a-release.apk`
  3. you can rename the file as you like

