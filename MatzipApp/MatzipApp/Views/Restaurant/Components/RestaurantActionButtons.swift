import SwiftUI

// MARK: - 액션 버튼들
struct RestaurantActionButtons: View {
    let restaurant: Restaurant
    let onCall: () -> Void
    let onMap: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            if restaurant.phoneNumber != nil {
                ActionButton(
                    icon: "phone.fill",
                    title: "전화",
                    color: .green,
                    action: onCall
                )
            }
            
            ActionButton(
                icon: "map.fill",
                title: "지도",
                color: .blue,
                action: onMap
            )
            
            ActionButton(
                icon: "square.and.arrow.up",
                title: "공유",
                color: .orange,
                action: onShare
            )
            
            Spacer()
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
