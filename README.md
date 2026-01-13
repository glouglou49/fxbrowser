# 🎛️ FX Browser & Tagger pour Reaper

Un navigateur d'effets (FX) moderne et avancé pour Reaper, conçu pour remplacer la fenêtre native par une interface fluide, puissante et entièrement personnalisable via ReaImGui.

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Reaper](https://img.shields.io/badge/Reaper-v6%2B-green.svg) ![Lua](https://img.shields.io/badge/Lua-5.3-blue.svg)

## ✨ Fonctionnalités Principales

### 🔍 Recherche Intelligente & Filtrée
- **Recherche Instantanée** : Filtrez par nom, alias ou tags.
- **Filtres Avancés** : Sélectionnez des **Tags** (Type d'effet) et des **Éditeurs** (Manufacturers).
- **Navigation par "Chips"** : Les filtres sélectionnés apparaissent sous forme d'étiquettes amovibles au-dessus de la barre de recherche (Sticky Header).
- **Interface Fluide** : La zone de recherche reste fixée en haut lors du défilement des résultats.

### 🏷️ Système de Tagging Puissant (Onglet Éditeur)
- **Tags Colorés** : Assignez des couleurs uniques à vos tags pour une identification visuelle rapide.
- **Ajout Rapide** : Ajoutez des tags existants via une liste déroulante ou créez-en de nouveaux à la volée.
- **Auto-Complétion** : Gestion intelligente des éditeurs (Manufacturers) avec saisie semi-automatique.

### 🛠️ Gestion & Organisation
- **Renommage (Alias)** : Donnez des noms personnalisés à vos plugins sans toucher aux fichiers DLL/VST.
- **Corbeille (Soft Delete) ♻️** : Supprimez des plugins de la liste sans risque. Ils sont envoyés, peuvent être consultés et restaurés à tout moment.
- **Suppression Automatique** : Les plugins qui échouent au chargement sont automatiquement déplacés vers la corbeille pour garder votre liste propre.

### 💾 Robustesse
- **Sauvegarde Automatique** : Toutes vos modifications sont sauvegardées à la fermeture du script.
- **Scan Intelligent** : Mettez à jour votre liste de plugins (`Scannez les nouveaux VST`) sans jamais perdre vos tags et alias existants.
- **Persistance** : La taille et la position de la fenêtre sont mémorisées.

## ⚙️ Prérequis

- **Reaper** (v6.0 ou supérieur recommandé)
- **ReaImGui** : Extension indispensable pour l'interface graphique. (Disponible via ReaPack).
- **JS_ReaScriptAPI** (Recommandé pour certaines fonctions avancées).

## 🚀 Installation

1. Assurez-vous d'avoir installé **ReaPack** et **ReaImGui** dans Reaper.
2. Copiez le dossier `fxbrowser` dans votre dossier de scripts Reaper :
   - `Options` -> `Show REAPER resource path in explorer/finder`
   - Allez dans `Scripts`.
3. Dans Reaper, ouvrez l'Action List (`?`).
4. Cliquez sur `New Action` -> `Load ReaScript...`.
5. Sélectionnez `fxbrowser_reaper.lua`.
6. (Optionnel) Assignez un raccourci clavier ou ajoutez-le à une barre d'outils.

## 📖 Utilisation

### Onglet "Rechercher"
- Tapez dans la barre pour chercher.
- Cliquez sur les tags (colonne gauche) ou les éditeurs (colonne milieu) pour filtrer.
- Les filtres actifs s'affichent en haut. Cliquez dessus pour les retirer.
- Cliquez sur un plugin dans la liste de droite pour l'ajouter à la piste sélectionnée.
- **Ctrl + Clic** sur un plugin ferme la fenêtre après l'ajout.

### Onglet "Éditeur"
- C'est ici que vous organisez votre collection.
- **Nom Réel** : Nom original du VST.
- **Alias** : Changez le nom affiché (cliquez pour éditer).
- **Éditeur** : Sélectionnez ou tapez le nom du fabricant.
- **Tags** : 
    - Cliquez sur `+` pour ajouter un tag.
    - Cliquez sur les "kapsules" colorées pour supprimer un tag.
- **Suppression** : Cliquez sur le **X rouge** pour envoyer à la corbeille.

## 🆕 Mises à jour & Maintenance

- **Bouton "Mettre à jour"** : Scanne Reaper pour détecter de nouveaux plugins installés. Vos tags actuels sont préservés.
- **Bouton "Reset"** : (Attention) Efface toute la base de données et rescanne à zéro. Un avertissement vous protège.
- **Bouton Corbeille** : Affiche les éléments supprimés pour restauration.

---
*Développé avec ❤️ pour la communauté Reaper.*
