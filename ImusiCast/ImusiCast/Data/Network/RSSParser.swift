import Foundation

class RSSParser {
    func parsePodcast(from url: URL) async throws -> Podcast {
        let (data, _) = try await URLSession.shared.data(from: url)
        return Podcast(id: UUID(), title: "Mock Podcast", description: "mock podcast", imageUrl: URL(string: "nothingYet.jpg")!, author: "Ryan Matheus", genre: "Technology", episodes: [])
    }
}
