import Foundation

struct Podcast: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageUrl: URL
    let author: String
    let genre: String
    var episodes: [Episode]
    
    init(id: UUID = UUID(), title: String, description: String, imageUrl: URL, author: String, genre: String, episodes: [Episode] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.author = author
        self.genre = genre
        self.episodes = episodes
    }
}

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
