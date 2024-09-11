import Foundation

extension DateFormatter {
    static let rfc2822: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension String {
    var stripHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
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
            currentEpisode = Episode(id: UUID(),
                                     title: "",
                                     description: "",
                                     audioUrl: URL(string: "...")!,
                                     duration: 0,
                                     publishDate: Date())
        }
        
        if elementName == "enclosure",
           let url = attributeDict["url"],
           let audioUrl = URL(string: url) {
            currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                          title: $0.title,
                                                          description: $0.description,
                                                          audioUrl: audioUrl,
                                                          duration: $0.duration,
                                                          publishDate: $0.publishDate)
            }
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
            if let episode = currentEpisode {
                currentEpisode = Episode(id: episode.id,
                                         title: currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines),
                                         description: episode.description,
                                         audioUrl: episode.audioUrl,
                                         duration: episode.duration,
                                         publishDate: episode.publishDate)
            } else {
                podcastTitle = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        case "description":
            if let episode = currentEpisode {
                currentEpisode = Episode(id: episode.id,
                                         title: episode.title,
                                         description: currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines).stripHTMLTags,
                                         audioUrl: episode.audioUrl,
                                         duration: episode.duration,
                                         publishDate: episode.publishDate)
            } else {
                podcastDescription = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines).stripHTMLTags
            }
        case "itunes:image":
            if podcastImageUrl == nil, let url = URL(string: currentCharacters) {
                podcastImageUrl = url
            }
        case "itunes:author":
            podcastAuthor = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        case "itunes:category":
            podcastGenre = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        case "itunes:duration":
            let durationString = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            if let duration = TimeInterval(durationString) {
                currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                              title: $0.title,
                                                              description: $0.description,
                                                              audioUrl: $0.audioUrl,
                                                              duration: duration,
                                                              publishDate: $0.publishDate)
                }
            } else if let duration = parseDurationString(durationString) {
                currentEpisode = currentEpisode.map { Episode(id: $0.id,
                                                              title: $0.title,
                                                              description: $0.description,
                                                              audioUrl: $0.audioUrl,
                                                              duration: duration,
                                                              publishDate: $0.publishDate)
                }
            }
        case "pubDate":
            if let date = DateFormatter.rfc2822.date(from: currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)),
               let episode = currentEpisode {
                currentEpisode = Episode(id: episode.id,
                                         title: episode.title,
                                         description: episode.description,
                                         audioUrl: episode.audioUrl,
                                         duration: episode.duration,
                                         publishDate: date)
            }
        case "channel":
            podcast = Podcast(id: UUID(),
                              title: podcastTitle,
                              description: podcastDescription,
                              imageUrl: podcastImageUrl ?? URL(string: "...")!,
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
    
    func parseDurationString(_ durationString: String) -> TimeInterval? {
        let components = durationString.components(separatedBy: ":")
        switch components.count {
        case 3:
            guard let hours = Double(components[0]),
                  let minutes = Double(components[1]),
                  let seconds = Double(components[2]) else { return nil }
            return hours * 3600 + minutes * 60 + seconds
        case 2:
            guard let minutes = Double(components[0]),
                  let seconds = Double(components[1]) else { return nil }
            return minutes * 60 + seconds
        default:
            return nil
        }
    }
}
