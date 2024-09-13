import XCTest
@testable import ImusiCast

class EpisodeTests: XCTestCase {
    func testEpisodeInitialization() {
        let date = Date()
        let episode = Episode(title: "Test Episode", description: "Test Description", audioUrl: URL(string: "https://example.com")!, duration: 3600, publishDate: date)
        
        XCTAssertNotNil(episode.id)
        XCTAssertEqual(episode.title, "Test Episode")
        XCTAssertEqual(episode.description, "Test Description")
        XCTAssertEqual(episode.audioUrl, URL(string: "https://example.com")!)
        XCTAssertEqual(episode.duration, 3600)
        XCTAssertEqual(episode.publishDate, date)
    }
    
    func testEpisodeCodable() throws {
        let date = Date()
        let episode = Episode(title: "Test Episode", description: "Test Description", audioUrl: URL(string: "https://example.com")!, duration: 3600, publishDate: date)
        
        let encodedData = try JSONEncoder().encode(episode)
        let decodedEpisode = try JSONDecoder().decode(Episode.self, from: encodedData)
        
        XCTAssertEqual(episode.id, decodedEpisode.id)
        XCTAssertEqual(episode.title, decodedEpisode.title)
        XCTAssertEqual(episode.description, decodedEpisode.description)
        XCTAssertEqual(episode.audioUrl, decodedEpisode.audioUrl)
        XCTAssertEqual(episode.duration, decodedEpisode.duration)
        XCTAssertEqual(episode.publishDate, decodedEpisode.publishDate)
    }
}
