import SwiftUI

struct AnimatedButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary, secondary, outline, danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .orange
            case .secondary: return Color(.systemGray5)
            case .outline: return .clear
            case .danger: return .red
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .danger: return .white
            case .secondary: return .primary
            case .outline: return .orange
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline: return .orange
            default: return .clear
            }
        }
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
    }
    
    init(
        _ title: String,
        systemImage: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: size == .small ? 12 : size == .medium ? 14 : 16))
                }
                
                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.foregroundColor)
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style.borderColor, lineWidth: style == .outline ? 1.5 : 0)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .buttonStyle(PlainButtonStyle())
    }
}

struct FloatingActionButton: View {
    let systemImage: String
    let action: () -> Void
    let color: Color
    
    @State private var isPressed = false
    @State private var isRotated = false
    
    init(
        systemImage: String,
        color: Color = .orange,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // 햅틱 피드백 추가
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            Image(systemName: systemImage)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .rotationEffect(.degrees(isRotated ? 360 : 0))
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .animation(.easeInOut(duration: 0.3), value: isRotated)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onTapGesture {
            isRotated.toggle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PulsingButton: View {
    let title: String
    let action: () -> Void
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .shadow(color: .orange.opacity(0.3), radius: isPulsing ? 12 : 8, x: 0, y: isPulsing ? 6 : 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct AnimatedButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnimatedButton("Primary Button", systemImage: "heart.fill") {}
            AnimatedButton("Secondary", style: .secondary, size: .small) {}
            AnimatedButton("Outline Button", style: .outline) {}
            AnimatedButton("Danger", style: .danger) {}
            
            FloatingActionButton(systemImage: "plus") {}
            
            PulsingButton(title: "지금 시작하기") {}
        }
        .padding()
    }
}