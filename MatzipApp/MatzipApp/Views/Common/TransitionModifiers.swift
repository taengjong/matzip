import SwiftUI

// MARK: - 커스텀 화면 전환 애니메이션

struct SlideTransition: ViewModifier {
    let isActive: Bool
    let direction: Edge
    
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction).combined(with: .opacity),
                    removal: .move(edge: direction.opposite).combined(with: .opacity)
                )
            )
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct ScaleTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isActive)
    }
}

struct FadeSlideTransition: ViewModifier {
    let isActive: Bool
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isActive ? 0 : offset)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4), value: isActive)
    }
}

// MARK: - 리스트 아이템 애니메이션

struct ListItemAppearance: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(x: isVisible ? 0 : -20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct CardFlipTransition: ViewModifier {
    let isFlipped: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .animation(.easeInOut(duration: 0.6), value: isFlipped)
    }
}

// MARK: - View Extensions

extension View {
    func slideTransition(isActive: Bool, from direction: Edge = .trailing) -> some View {
        modifier(SlideTransition(isActive: isActive, direction: direction))
    }
    
    func scaleTransition(isActive: Bool) -> some View {
        modifier(ScaleTransition(isActive: isActive))
    }
    
    func fadeSlideTransition(isActive: Bool, offset: CGFloat = 30) -> some View {
        modifier(FadeSlideTransition(isActive: isActive, offset: offset))
    }
    
    func listItemAppearance(delay: Double = 0.0) -> some View {
        modifier(ListItemAppearance(delay: delay))
    }
    
    func cardFlip(isFlipped: Bool) -> some View {
        modifier(CardFlipTransition(isFlipped: isFlipped))
    }
    
    // 햅틱 피드백 추가
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }
}

// MARK: - Edge Extension

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// MARK: - 카드 애니메이션 컴포넌트

struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    @State private var isVisible = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .animation(.easeOut(duration: 0.6), value: isVisible)
            .onAppear {
                isVisible = true
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - 맛집 카드 전용 애니메이션

struct RestaurantCardTransition: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 50)
            .scaleEffect(isVisible ? 1.0 : 0.9)
            .animation(
                .easeOut(duration: 0.5)
                .delay(Double(index) * 0.1),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func restaurantCardTransition(index: Int) -> some View {
        modifier(RestaurantCardTransition(index: index))
    }
}