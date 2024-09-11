import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private let cacheManager: CacheManagerProtocol
    
    init(url: URL, cacheManager: CacheManagerProtocol = CacheManager.shared) {
        self.url = url
        self.cacheManager = cacheManager
        loadImage()
    }
    
    func loadImage() {
        let cacheKey = url.absoluteString
        if let cachedImage = cacheManager.getObject(forKey: cacheKey) as? UIImage {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let loadedImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = loadedImage
                self.cacheManager.setObject(loadedImage, forKey: cacheKey)
            }
        }.resume()
    }
}
