#!/bin/bash
# Rørkassa – gjør iPhone-prosjektet klart.
# Kjøres én gang etter "npx cap add ios" (gjøres automatisk av "npm run ios:lag", også i Codemagic).
set -e
cd "$(dirname "$0")"

APP="ios/App/App"
PLIST="$APP/Info.plist"
PBX="ios/App/App.xcodeproj/project.pbxproj"

if [ ! -f "$PLIST" ]; then
  echo "Fant ikke $PLIST. Kjør 'npx cap add ios' først."
  exit 1
fi

# 1. Tekstene Apple krever. Uten dem stopper appen når kamera, bilder eller mikrofon brukes.
plutil -replace NSCameraUsageDescription -string "Rørkassa bruker kameraet når du tar bilde av en del du vil finne, eller legger bilder til en jobb." "$PLIST"
plutil -replace NSPhotoLibraryUsageDescription -string "Rørkassa henter bilder fra biblioteket ditt når du søker etter en del eller legger bilder til en jobb." "$PLIST"
plutil -replace NSPhotoLibraryAddUsageDescription -string "Rørkassa kan lagre bilder fra jobbene dine i bildebiblioteket." "$PLIST"
plutil -replace NSMicrophoneUsageDescription -string "Rørkassa bruker mikrofonen når du snakker inn punkter i et notat." "$PLIST"
plutil -replace NSSpeechRecognitionUsageDescription -string "Rørkassa gjør om det du sier til tekst i notatene dine." "$PLIST"
# Svarer «nei» på krypteringsspørsmålet, så du slipper det ved hver opplasting.
plutil -replace ITSAppUsesNonExemptEncryption -bool NO "$PLIST"
echo "✓ Tillatelser lagt inn"

# 2. Bare iPhone (da trenger du ikke iPad-skjermbilder i App Store) og versjon 1.0.0.
if [ -f "$PBX" ]; then
  sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = 1;/g' "$PBX"
  sed -i '' 's/MARKETING_VERSION = 1.0;/MARKETING_VERSION = 1.0.0;/g' "$PBX"
  echo "✓ Bare iPhone, versjon 1.0.0"
fi

# 3. App-ikon og oppstartsbilde. Hver bildefil byttes ut med vårt bilde i samme størrelse.
bytt_bilder() {
  local kilde="$1" mappe="$2" navn="$3" antall=0
  if [ -d "$mappe" ]; then
    for fil in "$mappe"/*.png; do
      [ -e "$fil" ] || continue
      local b h
      b=$(sips -g pixelWidth "$fil" | awk '/pixelWidth/{print $2}')
      h=$(sips -g pixelHeight "$fil" | awk '/pixelHeight/{print $2}')
      cp "$kilde" "$fil"
      sips -z "$h" "$b" "$fil" >/dev/null
      antall=$((antall + 1))
    done
  fi
  if [ "$antall" -gt 0 ]; then
    echo "✓ $navn lagt inn"
  else
    echo "! Fant ikke $navn i prosjektet. Dra $kilde inn i Xcode for hånd (se LES-MEG.md)."
  fi
}
bytt_bilder app-ikon-1024.png "$APP/Assets.xcassets/AppIcon.appiconset" "App-ikon"
bytt_bilder oppstartsbilde-2732.png "$APP/Assets.xcassets/Splash.imageset" "Oppstartsbilde"

echo ""
echo "Ferdig. Kjør nå: npm run ios:apne"
