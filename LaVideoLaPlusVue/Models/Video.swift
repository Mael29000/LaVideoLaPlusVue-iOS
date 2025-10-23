import Foundation

struct Video: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let channelId: String
    let channelTitle: String
    let publishedAt: String
    let thumbnailUrl: String
    let viewCount: Int
    let channelAvatarUrl: String?
    
    var formattedViewCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: NSNumber(value: viewCount)) ?? "\(viewCount)"
    }
    
    var shortViewCount: String {
        if viewCount >= 1_000_000 {
            return String(format: "%.1fM", Double(viewCount) / 1_000_000)
        } else if viewCount >= 1_000 {
            return String(format: "%.0fK", Double(viewCount) / 1_000)
        } else {
            return "\(viewCount)"
        }
    }
    
    var thumbnailURL: URL? {
        return URL(string: thumbnailUrl)
    }
    
    var channelAvatarURL: URL? {
        guard let channelAvatarUrl = channelAvatarUrl else { return nil }
        return URL(string: channelAvatarUrl)
    }
}