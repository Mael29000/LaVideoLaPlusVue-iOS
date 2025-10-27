# Intégration Supabase - LaVideoLaPlusVue

## Vue d'ensemble

L'intégration Supabase permet de gérer le Hall of Fame avec une base de données réelle, remplaçant les données mockées. Le système supporte le mode hors ligne avec synchronisation automatique.

## Configuration

### 1. Basculer entre Mock et Supabase

Dans `AppConfiguration.swift`:
```swift
static let useSupabase = true  // true pour Supabase, false pour mock
```

### 2. Credentials Supabase

Les credentials sont configurés dans `SupabaseConfig.swift`:
- URL: `https://libvlfsupgtpqmiaulzb.supabase.co`
- Clé API: Configurée

### 3. Structure de la base de données

Table `hall_of_fame`:
- `id` (UUID) - Clé primaire
- `user_name` (TEXT) - Nom du joueur
- `score` (INTEGER) - Score obtenu
- `created_at` (TIMESTAMP) - Date d'enregistrement
- `device_id` (TEXT) - Identifiant de l'appareil (optionnel)

## Fonctionnalités implémentées

### 1. Enregistrement automatique du nom
- Quand un joueur dépasse 20 points ET fait un nouveau record personnel
- L'EnterNameSheet s'affiche automatiquement après 2.5 secondes
- Le nom n'est demandé qu'une seule fois

### 2. Gestion du classement
- Top 100 mondial
- Classement personnel avec 50 joueurs au-dessus et 50 en dessous
- Mise en évidence du joueur dans la liste

### 3. Mode hors ligne
- Les scores sont sauvegardés localement si pas de connexion
- Synchronisation automatique au retour de la connexion
- Indicateur visuel de l'état de connexion

### 4. États de l'interface
- État de chargement avec indicateur
- État hors ligne avec message approprié
- État d'erreur avec possibilité de réessayer
- État vide pour les nouveaux utilisateurs

## Test de l'intégration

### Scénario 1: Premier score > 20 points
1. Jouer et obtenir un score > 20
2. L'EnterNameSheet devrait s'afficher automatiquement
3. Entrer un nom et confirmer
4. Le score est sauvegardé dans Supabase

### Scénario 2: Mode hors ligne
1. Couper la connexion Internet
2. Jouer et obtenir un score > 20
3. Le score est sauvegardé localement
4. Réactiver Internet
5. Le score est automatiquement synchronisé

### Scénario 3: Consultation du classement
1. Ouvrir le Hall of Fame depuis l'EndGameScreen
2. Voir le top 100 mondial
3. Si un nom est enregistré, possibilité de voir "Mon classement"

## Maintenance

### Pour désactiver temporairement Supabase
```swift
// Dans AppConfiguration.swift
static let useSupabase = false
```

### Pour changer le seuil d'entrée
```swift
// Dans AppConfiguration.swift
static let hallOfFameThreshold = 15  // Au lieu de 20
```

### Pour nettoyer les données locales
```swift
// Supprimer le nom enregistré
UserDefaults.standard.removeObject(forKey: "playerName")

// Supprimer l'ID de l'appareil
UserDefaults.standard.removeObject(forKey: "deviceId")

// Supprimer la queue offline
UserDefaults.standard.removeObject(forKey: "offlineHallOfFameQueue")
```

## Problèmes connus et solutions

### Problème: L'EnterNameSheet ne s'affiche pas
- Vérifier que le score >= 20
- Vérifier que c'est un nouveau record personnel
- Vérifier qu'aucun nom n'est déjà enregistré

### Problème: Erreur de connexion Supabase
- Vérifier les credentials dans `SupabaseConfig.swift`
- Vérifier la connexion Internet
- Vérifier que la table `hall_of_fame` existe dans Supabase

### Problème: Synchronisation offline ne fonctionne pas
- Les entrées sont limitées à 3 tentatives
- Vérifier les logs dans la console Xcode
- Supprimer manuellement la queue si nécessaire