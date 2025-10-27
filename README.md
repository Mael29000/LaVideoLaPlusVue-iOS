# LaVideoLaPlusVue-iOS

## 🎮 À propos

LaVideoLaPlusVue est un jeu iOS où vous devez deviner quelle vidéo YouTube a le plus de vues entre deux options.

## 🚀 Installation

### Prérequis
- Xcode 15.0+
- iOS 18.4+
- Un compte Supabase (pour le Hall of Fame)

### Configuration

1. **Cloner le repository**
   ```bash
   git clone https://github.com/yourusername/LaVideoLaPlusVue.git
   cd LaVideoLaPlusVue
   ```

2. **Configurer les secrets** (IMPORTANT!)
   ```bash
   cp LaVideoLaPlusVue/Config/Secrets.swift.template LaVideoLaPlusVue/Config/Secrets.swift
   ```
   Puis éditez `Secrets.swift` avec vos clés Supabase. Voir [SECURITY.md](SECURITY.md) pour plus de détails.

3. **Ouvrir dans Xcode**
   ```bash
   open LaVideoLaPlusVue.xcodeproj
   ```

4. **Build and Run**
   - Sélectionnez votre simulateur ou device
   - Appuyez sur Cmd+R

## 🔐 Sécurité

Ce projet utilise des clés d'API qui ne doivent PAS être committées. Consultez [SECURITY.md](SECURITY.md) pour la configuration des secrets.