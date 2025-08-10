#!/bin/bash

# Script de test pour Jarvis Mobile App

set -e

echo "🧪 Démarrage des tests pour Jarvis Mobile App..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Générer les fichiers de code
echo "🔧 Génération des fichiers de code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Tests unitaires
echo "🔬 Exécution des tests unitaires..."
flutter test

# Tests d'intégration
echo "🔬 Exécution des tests d'intégration..."
flutter test integration_test

# Analyse du code
echo "🔍 Analyse du code..."
flutter analyze

# Vérification de la qualité du code
echo "📊 Vérification de la qualité du code..."
flutter pub run flutter_lints:lint

echo "🎉 Tous les tests sont passés avec succès!"
echo ""
echo "📈 Résumé:"
echo "  ✅ Tests unitaires: OK"
echo "  ✅ Tests d'intégration: OK"
echo "  ✅ Analyse du code: OK"
echo "  ✅ Qualité du code: OK"
