import XCTest
@testable import ImusiCast

class PodcastTests: XCTestCase {
    func testPodcastInitialization() {
        let podcast = Podcast(title: "Test Podcast", description: "Test Description", imageUrl: URL(string: "https://example.com")!, author: "Test Author", genre: "Test Genre")
        
        XCTAssertNotNil(podcast.id)
        XCTAssertEqual(podcast.title, "Test Podcast")
        XCTAssertEqual(podcast.description, "Test Description")
        XCTAssertEqual(podcast.imageUrl, URL(string: "https://example.com")!)
        XCTAssertEqual(podcast.author, "Test Author")
        XCTAssertEqual(podcast.genre, "Test Genre")
        XCTAssertTrue(podcast.episodes.isEmpty)
    }
    
    func testPodcastCodable() throws {
        let podcast = Podcast(title: "Test Podcast", description: "Test Description", imageUrl: URL(string: "https://example.com")!, author: "Test Author", genre: "Test Genre")
        
        let encodedData = try JSONEncoder().encode(podcast)
        let decodedPodcast = try JSONDecoder().decode(Podcast.self, from: encodedData)
        
        XCTAssertEqual(podcast.id, decodedPodcast.id)
        XCTAssertEqual(podcast.title, decodedPodcast.title)
        XCTAssertEqual(podcast.description, decodedPodcast.description)
        XCTAssertEqual(podcast.imageUrl, decodedPodcast.imageUrl)
        XCTAssertEqual(podcast.author, decodedPodcast.author)
        XCTAssertEqual(podcast.genre, decodedPodcast.genre)
    }
}
