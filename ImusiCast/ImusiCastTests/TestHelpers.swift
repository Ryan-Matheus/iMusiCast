import Foundation
@testable import ImusiCast

class MockCacheManager: CacheManagerProtocol {
    var mockObject: AnyObject?
    var mockAudioData: Data?

    func setObject(_ object: AnyObject, forKey key: String) {
        mockObject = object
    }

    func getObject(forKey key: String) -> AnyObject? {
        return mockObject
    }

    func cacheAudioData(_ data: Data, forKey key: String) {
        mockAudioData = data
    }

    func getCachedAudioData(forKey key: String) -> Data? {
        return mockAudioData
    }

    func clearCache() {
        mockObject = nil
        mockAudioData = nil
    }
}

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
