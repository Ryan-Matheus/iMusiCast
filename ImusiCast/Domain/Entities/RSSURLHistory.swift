import Foundation

struct RSSURLHistory: Codable {
    var urls: [String]
    
    init(urls: [String] = []) {
        self.urls = urls
    }
}
