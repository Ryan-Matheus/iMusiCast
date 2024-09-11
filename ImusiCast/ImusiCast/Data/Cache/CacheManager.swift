import Foundation

class CacheManager {
    static let shared = CacheManager()
    private let cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let audioCacheDirectory: URL
    
    private init() {
        let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        audioCacheDirectory = cacheDirectoryURL.appendingPathComponent("AudioCache")
        try? fileManager.createDirectory(at: audioCacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func setObject(_ object: AnyObject, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    func getObject(forKey key: String) -> AnyObject? {
        return cache.object(forKey: key as NSString)
    }
    
    func cacheAudioData(_ data: Data, forKey key: String) {
        let fileURL = audioCacheDirectory.appendingPathComponent(key)
        try? data.write(to: fileURL)
    }
    
    func getCachedAudioData(forKey key: String) -> Data? {
        let fileURL = audioCacheDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        let cachedFiles = try? fileManager.contentsOfDirectory(at: audioCacheDirectory, includingPropertiesForKeys: nil)
        cachedFiles?.forEach { file in
            try? fileManager.removeItem(at: file)
        }
    }
}
