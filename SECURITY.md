# Configuration des Secrets

## 🔐 Sécurité

Ce projet utilise des clés d'API et des secrets qui ne doivent JAMAIS être committés dans le repository Git.

## Configuration initiale

1. **Copier le template des secrets**
   ```bash
   cp LaVideoLaPlusVue/Config/Secrets.swift.template LaVideoLaPlusVue/Config/Secrets.swift
   ```

2. **Modifier le fichier `Secrets.swift`** avec vos vraies valeurs :
   - `supabaseURL` : L'URL de votre projet Supabase
   - `supabaseAnonKey` : La clé anonyme de votre projet Supabase

3. **Vérifier que le fichier est bien ignoré par Git** :
   ```bash
   git status
   ```
   Le fichier `Secrets.swift` ne doit PAS apparaître dans la liste des fichiers à committer.

## ⚠️ Important

- **NE JAMAIS** committer le fichier `Secrets.swift`
- **NE JAMAIS** committer de clés d'API directement dans le code
- Si vous avez accidentellement commité des secrets :
  1. Changez immédiatement les clés dans votre dashboard Supabase
  2. Utilisez `git filter-branch` ou BFG Repo-Cleaner pour nettoyer l'historique Git

## Fichiers ignorés

Les fichiers suivants sont automatiquement ignorés par Git :
- `Secrets.swift`
- `Config-Secrets.xcconfig`
- `*.xcconfig`
- `.env` et `.env.*`
- `LaVideoLaPlusVue/Config/Secrets/`

## Rotation des clés

Si vos clés ont été compromises :
1. Allez sur votre dashboard Supabase
2. Générez de nouvelles clés d'API
3. Mettez à jour le fichier `Secrets.swift`
4. Redéployez l'application