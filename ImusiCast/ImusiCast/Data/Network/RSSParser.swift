import Foundation

class RSSParser {
    private let cacheManager: CacheManager
    
    init(cacheManager: CacheManager = .shared) {
        self.cacheManager = cacheManager
    }
    
    func parsePodcast(from url: URL) async throws -> Podcast {
        if let cachedPodcast = cacheManager.getObject(forKey: url.absoluteString) as? Podcast {
            return cachedPodcast
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let podcast = try parseRSSData(data)
        cacheManager.setObject(podcast as AnyObject, forKey: url.absoluteString)
        return podcast
    }
    
    private func parseRSSData(_ data: Data) throws -> Podcast {
        // TODO: Insert real parse here later...
        // TODO: For now, just a mock test...
        return Podcast(
            title: "Podcast Plane",
            description: "This is a podcast about planes and aviation.",
            imageUrl: URL(string: "...")!,
            author: "Lito planes",
            genre: "Aviation",
            episodes: [
                Episode(
                    title: "Episode 1",
                    description: "Talking about planes, today...",
                    audioUrl: URL(string: "...")!,
                    duration: 1800,
                    publishDate: Date()
                )
            ]
        )
    }
}
