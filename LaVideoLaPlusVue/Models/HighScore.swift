
import Foundation

struct HighScore: Codable, Identifiable {
    var id = UUID()
    
    let userName: String
    let score: Int
    let rank: Int
    let date: Date

    
    init(userName: String, score: Int, rank: Int = 0, date: Date = Date()) {
        self.userName = userName
        self.score = score
        self.rank = rank
        self.date = date
    }
}
