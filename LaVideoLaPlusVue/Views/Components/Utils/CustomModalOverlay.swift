import SwiftUI

/**
 * Observable object pour gérer l'interaction scroll-to-dismiss
 */
class ScrollToDismissController: ObservableObject {
    @Published var isAtTop: Bool = true
    @Published var pullOffset: CGFloat = 0
    
    private let dismissThreshold: CGFloat = 30
    
    func updateScrollPosition(offset: CGFloat) {
        // On considère qu'on est en haut si offset est proche de 0 ou positif
        isAtTop = offset >= -5
        
        // Si on est en haut et qu'on tire vers le haut (offset positif = pull down)
        if isAtTop && offset > 0 {
            pullOffset = offset
        } else {
            pullOffset = 0
        }
        
        print("📍 Scroll offset: \(offset), isAtTop: \(isAtTop), pullOffset: \(pullOffset)")
    }
    
    func shouldDismiss() -> Bool {
        let should = isAtTop && pullOffset > dismissThreshold
        if should {
            print("🔥 Should dismiss! pullOffset: \(pullOffset)")
        }
        return should
    }
}

/**
 * Modal overlay personnalisé qui remplace les sheets iOS pour éviter le zoom out.
 *
 * Fonctionnalités:
 * - Geste de swipe down pour fermer (identique aux sheets iOS)
 * - Animations fluides d'ouverture/fermeture
 * - Background dim avec tap pour fermer
 * - Aucun zoom out de l'écran principal
 * - Drag indicator visuel
 */
struct CustomModalOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var contentOffset: CGFloat = 0
    @StateObject private var scrollController = ScrollToDismissController()
    
    // Configuration
    private let cornerRadius: CGFloat = 20
    private let dragThreshold: CGFloat = 100 // Distance pour déclencher la fermeture
    private let maxDragOffset: CGFloat = 300 // Distance max de drag
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.4 * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    closeModal()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Drag indicator
                dragIndicator
                
                // Contenu principal
                content
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .environmentObject(scrollController)
            }
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
            )
            .offset(y: contentOffset + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Permettre seulement le drag vers le bas
                        if value.translation.height > 0 {
                            dragOffset = min(value.translation.height, maxDragOffset)
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > dragThreshold {
                            // Fermer si drag suffisant
                            closeModal()
                        } else {
                            // Revenir en position avec animation
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .onAppear {
            openModal()
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                closeModalImmediately()
            }
        }
        .onChange(of: scrollController.pullOffset) { offset in
            if scrollController.shouldDismiss() {
                closeModal()
            }
        }
    }
    
    // MARK: - Drag Indicator
    
    @ViewBuilder
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.5))
            .frame(width: 40, height: 6)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
    
    // MARK: - Animations
    
    private func openModal() {
        // État initial
        contentOffset = UIScreen.main.bounds.height
        opacity = 0
        
        // Animation d'ouverture
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            contentOffset = 0
            opacity = 1
        }
    }
    
    private func closeModal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            contentOffset = UIScreen.main.bounds.height
            opacity = 0
            dragOffset = 0
        }
        
        // Fermer après l'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func closeModalImmediately() {
        contentOffset = UIScreen.main.bounds.height
        opacity = 0
        dragOffset = 0
    }
}

// MARK: - Convenience Views

/**
 * Version avec destination enum pour s'intégrer avec AppRouter
 */
struct CustomModalDestination: View {
    let destination: AppDestination
    @Binding var isPresented: Bool
    
    var body: some View {
        CustomModalOverlay(isPresented: $isPresented) {
            destinationContent
        }
    }
    
    @ViewBuilder
    private var destinationContent: some View {
        switch destination {
        case .hallOfFame:
            HallOfFameSheet()
        case .enterName:
            EnterNameSheet(gameViewModel: GameViewModel()) // Vous devrez passer le bon gameViewModel
        default:
            EmptyView()
        }
    }
}

/**
 * Modifier pour détecter le scroll et notifier le controller
 */
struct ScrollOffsetDetector: ViewModifier {
    @EnvironmentObject var scrollController: ScrollToDismissController
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    let globalFrame = proxy.frame(in: .global)
                    let namedFrame = proxy.frame(in: .named("scroll"))
                    // Utiliser la position globale par rapport au conteneur scroll
                    let offset = namedFrame.minY
                    Color.clear
                        .preference(key: CustomScrollOffsetPreferenceKey.self, value: offset)
                        .onAppear {
                            print("📋 Geometry - Global: \(globalFrame.minY), Named: \(namedFrame.minY)")
                        }
                }
            )
            .onPreferenceChange(CustomScrollOffsetPreferenceKey.self) { offset in
                scrollController.updateScrollPosition(offset: offset)
            }
    }
}

struct CustomScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func detectScrollOffset() -> some View {
        modifier(ScrollOffsetDetector())
    }
}

/**
 * Version avec un modifier pour faciliter l'utilisation
 */
extension View {
    func customModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                CustomModalOverlay(isPresented: isPresented, content: content)
                    .zIndex(999)
            }
        }
    }
}

#Preview {
    struct PreviewContent: View {
        @State private var showModal = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Button("Ouvrir Modal") {
                    showModal = true
                }
                .foregroundColor(.white)
            }
            .customModal(isPresented: $showModal) {
                VStack {
                    Text("Modal Content")
                        .foregroundColor(.white)
                        .padding()
                    
                    Button("Fermer") {
                        showModal = false
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
            }
        }
    }
    
    return PreviewContent()
}