import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let category: RestaurantCategory
    let address: String
    let coordinate: CLLocationCoordinate2D
    let phoneNumber: String?
    let rating: Double
    let reviewCount: Int
    let priceRange: PriceRange
    let openingHours: OpeningHours?
    let description: String
    let imageURLs: [String]
    let isFavorite: Bool
    
    var distanceText: String? {
        didSet {
            // Will be set by location service
        }
    }
}

enum RestaurantCategory: String, CaseIterable, Codable {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case western = "양식"
    case cafe = "카페"
    case fastfood = "패스트푸드"
    case dessert = "디저트"
    case other = "기타"
    
    var systemImage: String {
        switch self {
        case .korean: return "bowl.fill"
        case .chinese: return "takeoutbag.and.cup.and.straw.fill"
        case .japanese: return "fish.fill"
        case .western: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .fastfood: return "hamburger.fill"
        case .dessert: return "birthday.cake.fill"
        case .other: return "utensils"
        }
    }
}

enum PriceRange: Int, CaseIterable, Codable {
    case low = 1
    case medium = 2
    case high = 3
    case luxury = 4
    
    var displayText: String {
        String(repeating: "₩", count: rawValue)
    }
    
    var description: String {
        switch self {
        case .low: return "1만원 미만"
        case .medium: return "1-2만원"
        case .high: return "2-5만원"
        case .luxury: return "5만원 이상"
        }
    }
}

struct OpeningHours: Codable {
    let monday: DayHours?
    let tuesday: DayHours?
    let wednesday: DayHours?
    let thursday: DayHours?
    let friday: DayHours?
    let saturday: DayHours?
    let sunday: DayHours?
    
    struct DayHours: Codable {
        let open: String
        let close: String
        let isOpen: Bool
    }
    
    func todayHours() -> DayHours? {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        switch today {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return nil
        }
    }
}

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}