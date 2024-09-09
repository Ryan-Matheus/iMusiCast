import Foundation

extension String {
    var xmlEscaped: String {
        return self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "'", with: "&apos;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

extension DateFormatter {
    static let rfc2822: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var podcast: Podcast?
    private var currentElement = ""
    private var currentEpisode: Episode?
    private var currentCharacters = ""
    
    private var podcastTitle = ""
    private var podcastDescription = ""
    private var podcastImageUrl: URL?
    private var podcastAuthor = ""
    private var podcastGenre = ""
    private var episodes: [Episode] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentCharacters = ""
        
        if elementName == "item" {
            currentEpisode = nil
        }
        
        if elementName == "enclosure",
           let url = attributeDict["url"],
           let audioUrl = URL(string: url) {
            currentEpisode = Episode(id: UUID(),
                                     title: "",
                                     description: "",
                                     audioUrl: audioUrl,
                                     duration: 0,
                                     publishDate: Date())
        }
        
        if elementName == "itunes:image", let href = attributeDict["href"], let url = URL(string: href) {
            podcastImageUrl = url
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "item":
            if let episode = currentEpisode {
                episodes.append(episode)
            }
            currentEpisode = nil
        case "title":
            if currentEpisode == nil {
                podcastTitle = currentCharacters.xmlEscaped
            } else {
                currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                              title: currentCharacters.xmlEscaped,
                                                              description: $0.description,
                                                              audioUrl: $0.audioUrl,
                                                              duration: $0.duration,
                                                              publishDate: $0.publishDate) }
            }
        case "description":
            if currentEpisode == nil {
                podcastDescription = currentCharacters.xmlEscaped
            } else {
                currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                              title: $0.title,
                                                              description: currentCharacters.xmlEscaped,
                                                              audioUrl: $0.audioUrl,
                                                              duration: $0.duration,
                                                              publishDate: $0.publishDate) }
            }
        case "itunes:image":
            if podcastImageUrl == nil, let url = URL(string: currentCharacters) {
                podcastImageUrl = url
            }
        case "itunes:author":
            podcastAuthor = currentCharacters.xmlEscaped
        case "itunes:duration":
            let durationString = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            let duration = parseDuration(durationString)
            currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                          title: $0.title,
                                                          description: $0.description,
                                                          audioUrl: $0.audioUrl,
                                                          duration: duration,
                                                          publishDate: $0.publishDate) }
        case "pubDate":
            if let date = DateFormatter.rfc2822.date(from: currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)) {
                currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                              title: $0.title,
                                                              description: $0.description,
                                                              audioUrl: $0.audioUrl,
                                                              duration: $0.duration,
                                                              publishDate: date) }
            }
        case "channel":
            podcast = Podcast(id: UUID(),
                              title: podcastTitle,
                              description: podcastDescription,
                              imageUrl: podcastImageUrl ?? URL(string: "none")!,
                              author: podcastAuthor,
                              genre: podcastGenre,
                              episodes: episodes)
        default:
            break
        }
        
        currentCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters += string
    }
    
    private func parseDuration(_ durationString: String) -> TimeInterval {
        let components = durationString.components(separatedBy: ":")
        switch components.count {
        case 1:
            return TimeInterval(durationString) ?? 0
        case 2:
            let minutes = TimeInterval(components[0]) ?? 0
            let seconds = TimeInterval(components[1]) ?? 0
            return minutes * 60 + seconds
        case 3:
            let hours = TimeInterval(components[0]) ?? 0
            let minutes = TimeInterval(components[1]) ?? 0
            let seconds = TimeInterval(components[2]) ?? 0
            return hours * 3600 + minutes * 60 + seconds
        default:
            return 0
        }
    }
}
