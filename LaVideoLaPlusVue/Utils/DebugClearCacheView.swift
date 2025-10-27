//
//  DebugClearCacheView.swift
//  LaVideoLaPlusVue
//
//  Vue SwiftUI temporaire pour nettoyer tous les caches
//

#if DEBUG
import SwiftUI

struct DebugClearCacheView: View {
    @State private var showAlert = false
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🧹 Nettoyage des Caches")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Cela va supprimer :")
                    .font(.headline)
                
                Text("• Best Score")
                Text("• Nom du joueur")
                Text("• Queue hors ligne")
                Text("• Cache des images")
            }
            .padding()
            
            Button(action: clearAllCaches) {
                Label("Tout nettoyer", systemImage: "trash.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .alert("Cache nettoyé", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(message)
        }
    }
    
    private func clearAllCaches() {
        DebugUserDefaults.clearAllCaches()
        
        message = """
        ✅ Nettoyage terminé :
        - Best Score : 0
        - Nom du joueur : supprimé
        - Queue hors ligne : vidée
        - Cache images : nettoyé
        """
        
        showAlert = true
    }
}

#Preview {
    DebugClearCacheView()
}
#endif