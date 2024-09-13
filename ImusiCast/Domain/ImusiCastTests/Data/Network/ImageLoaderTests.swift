import XCTest
@testable import ImusiCast

class ImageLoaderTests: XCTestCase {
    var imageLoader: ImageLoader!
    var mockCacheManager: MockCacheManager!

    override func setUp() {
        super.setUp()
        mockCacheManager = MockCacheManager()
        let url = URL(string: "https://example.com/image.jpg")!
        imageLoader = ImageLoader(url: url, cacheManager: mockCacheManager)
    }

    override func tearDown() {
        imageLoader = nil
        mockCacheManager = nil
        super.tearDown()
    }

    func testLoadImageFromCache() {
        let expectedImage = UIImage(systemName: "star")!
        mockCacheManager.mockObject = expectedImage

        imageLoader.loadImage()

        XCTAssertEqual(imageLoader.image, expectedImage)
    }

    func testLoadImageFromURL() {
        let expectation = XCTestExpectation(description: "Image loaded from URL")
        let mockData = UIImage(systemName: "star")!.pngData()!

        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.mockData = mockData

        imageLoader.loadImage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.imageLoader.image)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }
}
