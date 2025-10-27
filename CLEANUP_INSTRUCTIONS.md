# Instructions de nettoyage du projet

## 1. FICHIERS À SUPPRIMER

### Services (fichiers mock)
- `/LaVideoLaPlusVue/Services/HallOfFameService.swift`
- `/LaVideoLaPlusVue/Services/SupabaseHallOfFameService.swift`

### ViewModels (fichiers mock)
- `/LaVideoLaPlusVue/ViewModels/HallOfFameViewModel.swift`
- `/LaVideoLaPlusVue/ViewModels/HallOfFameViewModel+Supabase.swift`

### Views (fichiers mock)
- `/LaVideoLaPlusVue/Views/Screens/HallOfFameSheet.swift`
- `/LaVideoLaPlusVue/Views/Screens/HallOfFameSheetSupabase.swift`

### Models (non utilisés)
- `/LaVideoLaPlusVue/Models/HighScore.swift`

### Utils (code mort)
- `/LaVideoLaPlusVue/Views/Components/Utils/SlideTransition.swift`
- `/LaVideoLaPlusVue/Views/Components/Utils/ColorConversion.swift`

## 2. FICHIERS À RENOMMER

### Services
- `HallOfFameService_New.swift` → `HallOfFameService.swift`

### ViewModels
- `HallOfFameViewModel_New.swift` → `HallOfFameViewModel.swift`

### Views
- `HallOfFameSheet_New.swift` → `HallOfFameSheet.swift`

## 3. FICHIERS À MODIFIER

### MainAppView.swift
- Ligne 19: Changer `HallOfFameViewModelSupabase` → `HallOfFameViewModel`
- Lignes 122, 140: Changer `HallOfFameSheetSupabase` → `HallOfFameSheet`

### EnterNameSheet.swift
- Ligne 26: Changer `HallOfFameViewModelSupabase` → `HallOfFameViewModel`

### AppConfiguration.swift
- Supprimer la ligne `static let useSupabase = true`

## 4. ORDRE DES OPÉRATIONS

1. Supprimer tous les fichiers listés en section 1
2. Renommer les fichiers listés en section 2
3. Effectuer les modifications listées en section 3
4. Compiler et tester

## 5. RÉSULTAT ATTENDU

Après le nettoyage :
- Un seul `HallOfFameService.swift` (avec Supabase intégré)
- Un seul `HallOfFameViewModel.swift` 
- Un seul `HallOfFameSheet.swift`
- Plus de références à "Supabase" dans les noms de fichiers
- Code plus propre et maintenable