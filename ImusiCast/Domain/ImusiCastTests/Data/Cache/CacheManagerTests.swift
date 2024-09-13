import XCTest
@testable import ImusiCast

class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
    }
    
    override func tearDown() {
        cacheManager.clearCache()
        cacheManager = nil
        super.tearDown()
    }
    
    func testSetAndGetObject() {
        let podcastTitle = "The Daily Tech Update" as AnyObject
        let cacheKey = "podcast_title_001"
        
        cacheManager.setObject(podcastTitle, forKey: cacheKey)
        
        let retrievedTitle = cacheManager.getObject(forKey: cacheKey) as? String
        
        XCTAssertEqual(retrievedTitle, "The Daily Tech Update")
    }
    
    func testCacheAndRetrieveAudioData() {
        let mockAudioData = Data(repeating: 0, count: 1024)
        let episodeKey = "episode_20240601_001"
        
        cacheManager.cacheAudioData(mockAudioData, forKey: episodeKey)
        
        let retrievedAudioData = cacheManager.getCachedAudioData(forKey: episodeKey)
        
        XCTAssertEqual(retrievedAudioData, mockAudioData)
    }
    
    func testClearCache() {
        let episodeDescription = "In this episode, we discuss about technology." as AnyObject
        let descriptionKey = "episode_description_001"
        
        cacheManager.setObject(episodeDescription, forKey: descriptionKey)
        cacheManager.clearCache()
        
        let retrievedDescription = cacheManager.getObject(forKey: descriptionKey)
        
        XCTAssertNil(retrievedDescription)
    }
}
