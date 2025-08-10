#!/bin/bash

# Script de test avec émulateur Android pour Jarvis Mobile App

set -e

echo "🤖 Démarrage des tests avec émulateur Android..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier que Android SDK est installé
if ! command -v adb &> /dev/null; then
    echo "❌ ADB n'est pas installé. Veuillez installer Android SDK d'abord."
    exit 1
fi

# Lister les émulateurs disponibles
echo "📱 Émulateurs disponibles:"
emulator -list-avds

# Démarrer un émulateur (premier disponible)
EMULATOR_NAME=$(emulator -list-avds | head -n 1)

if [ -z "$EMULATOR_NAME" ]; then
    echo "❌ Aucun émulateur trouvé. Veuillez créer un émulateur Android d'abord."
    echo "💡 Pour créer un émulateur:"
    echo "  1. Ouvrez Android Studio"
    echo "  2. Allez dans Tools > AVD Manager"
    echo "  3. Créez un nouvel émulateur"
    exit 1
fi

echo "🚀 Démarrage de l'émulateur: $EMULATOR_NAME"
emulator -avd "$EMULATOR_NAME" &

# Attendre que l'émulateur soit prêt
echo "⏳ Attente du démarrage de l'émulateur..."
sleep 30

# Vérifier que l'émulateur est connecté
echo "🔍 Vérification de la connexion..."
adb devices

# Attendre que l'émulateur soit complètement prêt
echo "⏳ Attente que l'émulateur soit prêt..."
adb wait-for-device

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Générer les fichiers de code
echo "🔧 Génération des fichiers de code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build APK debug
echo "🔨 Build APK debug..."
flutter build apk --debug

# Installer l'APK sur l'émulateur
echo "📱 Installation de l'APK sur l'émulateur..."
adb install build/app/outputs/flutter-apk/app-debug.apk

# Lancer l'application
echo "🚀 Lancement de l'application..."
adb shell am start -n com.example.jarvis_mobile_app/com.example.jarvis_mobile_app.MainActivity

# Attendre un peu pour que l'app se lance
sleep 10

# Prendre une capture d'écran
echo "📸 Capture d'écran..."
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png test_screenshot.png

echo "✅ Test avec émulateur terminé!"
echo ""
echo "📱 Application installée et lancée sur l'émulateur"
echo "📸 Capture d'écran sauvegardée: test_screenshot.png"
echo ""
echo "💡 Pour arrêter l'émulateur:"
echo "  adb emu kill"
