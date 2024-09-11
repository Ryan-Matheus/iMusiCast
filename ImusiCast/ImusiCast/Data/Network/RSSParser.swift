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
        let parser = XMLParser(data: data)
        let parserDelegate = RSSParserDelegate()
        parser.delegate = parserDelegate
        
        if parser.parse() {
            if let podcast = parserDelegate.podcast {
                return podcast
            } else {
                throw NSError(domain: "RSSParserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create podcast object"])
            }
        } else {
            throw NSError(domain: "RSSParserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse RSS feed"])
        }
    }
}
