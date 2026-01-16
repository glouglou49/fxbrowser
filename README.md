# 🎛️ FX Browser & Tagger pour Reaper

Un navigateur d'effets (FX) moderne et avancé pour Reaper, conçu pour remplacer la fenêtre native par une interface fluide, puissante et entièrement personnalisable via ReaImGui.

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Reaper](https://img.shields.io/badge/Reaper-v6%2B-green.svg) ![Lua](https://img.shields.io/badge/Lua-5.3-blue.svg)

## 🌍 Nouveau : Support Multilingue / Multilingual Support
L'interface est désormais **traduite en Anglais par défaut**.
- 🇫🇷 **Français** / 🇺🇸 **English** : Changez la langue instantanément via le sélecteur en haut à droite.

## ✨ Fonctionnalités Principales

### 🔍 Recherche Intelligente & Filtrée
- **Interface à 3 Colonnes** : 
  1. **Type** (Tags)
  2. **Résultats** (Liste des Plugins, au centre)
  3. **Éditeur** (Fabricant)
- **Recherche Instantanée** : Filtrez par nom, alias ou tags.
- **Nettoyage Automatique** : Les préfixes inutiles (`VST:`, `JS:`) et les extensions (`.vst3`, `.dll`) sont masqués automatiquement pour une lecture plus claire.
- **Navigation par "Chips"** : Les filtres sélectionnés apparaissent au-dessus de la barre de recherche.

### 🎨 Personnalisation Avancée
- **Palette de Couleurs** : **Clic-droit** sur un tag dans la colonne de gauche pour lui assigner une couleur personnalisée (sauvegardée).
- **Auto-Coloration** : Les tags ont des couleurs générées automatiquement par défaut pour une distinction rapide.
- **Thème Moderne** : Interface sombre, boutons colorés et style épuré.

### 🛠️ Mode Paramètres (Settings)
Cliquez sur le bouton **Settings / Paramètres** pour accéder à l'édition :
- **Renommage (Alias)** : Donnez des noms personnalisés à vos plugins.
- **Tags Intelligents** : 
  - Détection automatique (EQ, Comp, Reverb, Delay...).
  - Ajout/Suppression facile via les boutons.
- **Éditeur (Manufacturer)** : Liste déroulante ou saisie libre.
- **Corbeille (Trash) ♻️** : "Soft Delete" pour masquer les plugins sans les supprimer définitivement.

### 💾 Robustesse & Maintenance
- **Sauvegarde Automatique** : Base de données et préférences (taille fenêtre, langue) sauvegardées à la sortie.
- **Mises à Jour Safe** :
  - **Update** : Scanne les nouveaux plugins sans toucher à vos tags existants.
  - **Reset** : Réinitialisation complète (avec avertissement).
- **Import Piste** : Importez tous les FX d'une piste existante en un clic (utile pour les plugins Waves/Shell).

## ⚙️ Prérequis

- **Reaper** (v6.0 ou supérieur recommandé)
- **ReaImGui** : Extension indispensable. (Installer via ReaPack).

## 🚀 Installation

1. Installez **ReaImGui** via ReaPack.
2. Copiez le dossier `fxbrowser` dans votre dossier de scripts Reaper (`Options` -> `Show REAPER resource path` -> `Scripts`).
3. Dans l'Action List de Reaper, chargez `fxbrowser_reaper.lua`.

## 📖 Utilisation

### Mode Recherche
- **Clic Gauche** sur un FX : Ajoute le FX à la piste sélectionnée.
- **Ctrl + Clic** : Ajoute et ferme la fenêtre.
- **Clic Droit sur un Tag** : Ouvre le sélecteur de couleur.

### Mode Settings
- **Bouton Import** : Scanne la piste sélectionnée pour ajouter ses FX à la base.
- **Bouton Update** : Ajoute les nouveaux plugins installés.
- **Corbeille** : Restaurez les plugins supprimés par erreur.

---
*Développé pour la communauté Reaper.*
