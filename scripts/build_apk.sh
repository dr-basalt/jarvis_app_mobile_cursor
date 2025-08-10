#!/bin/bash

# Script de build APK auto-signé pour Jarvis Mobile App

set -e

echo "🚀 Démarrage du build APK pour Jarvis Mobile App..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier la version de Flutter
echo "📱 Version Flutter:"
flutter --version

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Générer les fichiers de code
echo "🔧 Génération des fichiers de code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Vérifier que tout est OK
echo "✅ Vérification du projet..."
flutter doctor
flutter analyze

# Build APK debug
echo "🔨 Build APK debug..."
flutter build apk --debug

# Build APK release
echo "🔨 Build APK release..."
flutter build apk --release

# Vérifier que les APKs ont été créés
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✅ APK debug créé: build/app/outputs/flutter-apk/app-debug.apk"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
else
    echo "❌ APK debug non trouvé"
fi

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK release créé: build/app/outputs/flutter-apk/app-release.apk"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
else
    echo "❌ APK release non trouvé"
fi

echo "🎉 Build terminé avec succès!"
echo ""
echo "📱 APKs disponibles:"
echo "  - Debug: build/app/outputs/flutter-apk/app-debug.apk"
echo "  - Release: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "💡 Pour installer sur un appareil connecté:"
echo "  adb install build/app/outputs/flutter-apk/app-debug.apk"
