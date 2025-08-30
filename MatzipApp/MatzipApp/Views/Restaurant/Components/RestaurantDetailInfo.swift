import SwiftUI

// MARK: - 상세 정보
struct RestaurantDetailInfo: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("상세 정보")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "location.fill",
                    title: "주소",
                    content: restaurant.address
                )
                
                if let phoneNumber = restaurant.phoneNumber {
                    InfoRow(
                        icon: "phone.fill",
                        title: "전화번호",
                        content: phoneNumber
                    )
                }
                
                if let openingHours = restaurant.openingHours {
                    InfoRow(
                        icon: "clock.fill",
                        title: "운영시간",
                        content: todayOpeningHours(openingHours)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func todayOpeningHours(_ hours: OpeningHours) -> String {
        guard let todayHours = hours.todayHours() else {
            return "운영시간 정보 없음"
        }
        
        if todayHours.isOpen {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let openTime = formatter.string(from: todayHours.open)
            let closeTime = formatter.string(from: todayHours.close)
            return "\(openTime) - \(closeTime)"
        } else {
            return "휴무"
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}
