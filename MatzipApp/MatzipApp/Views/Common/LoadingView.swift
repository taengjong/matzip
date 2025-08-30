import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    let text: String
    
    init(text: String = "로딩 중...") {
        self.text = text
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.2).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(isAnimating ? 0.6 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PulsingLoadingView: View {
    @State private var isPulsing = false
    let color: Color
    let size: CGFloat
    
    init(color: Color = .orange, size: CGFloat = 60) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: size, height: size)
                    .scaleEffect(isPulsing ? 1.0 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isPulsing
                    )
            }
            
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundColor(color)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

struct SkeletonView: View {
    @State private var isAnimating = false
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray5),
                        Color(.systemGray4),
                        Color(.systemGray5)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .offset(x: isAnimating ? width : -width)
            .animation(
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .clipped()
            .onAppear {
                isAnimating = true
            }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingView()
            PulsingLoadingView()
            SkeletonView(width: 200, height: 20)
        }
        .padding()
    }
}