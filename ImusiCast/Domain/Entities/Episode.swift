import Foundation

struct Episode: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let audioUrl: URL
    let duration: TimeInterval
    let publishDate: Date
    
    init(id: UUID = UUID(), title: String, description: String, audioUrl: URL, duration: TimeInterval, publishDate: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.audioUrl = audioUrl
        self.duration = duration
        self.publishDate = publishDate
    }
}
