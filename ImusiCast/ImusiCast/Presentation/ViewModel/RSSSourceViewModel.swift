import Foundation

class RSSSourceViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var podcast: Podcast?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var cacheStatus: String = ""
    @Published var urlHistory: [String] = []
    
    private let rssParser: RSSParser
    private let cacheManager: CacheManagerProtocol
    private let historyManager: RSSURLHistoryManager
    
    init(rssParser: RSSParser = RSSParser(), cacheManager: CacheManagerProtocol = CacheManager.shared, historyManager: RSSURLHistoryManager = RSSURLHistoryManager()) {
        self.rssParser = rssParser
        self.cacheManager = cacheManager
        self.historyManager = historyManager
        loadURLHistory()
    }
    
    func loadPodcast() {
        guard let url = URL(string: self.url) else {
            self.error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            return
        }
        
        isLoading = true
        error = nil
        cacheStatus = ""
        
        Task {
            do {
                let startTime = Date()
                let podcast = try await rssParser.parsePodcast(from: url)
                let endTime = Date()
                let loadTime = endTime.timeIntervalSince(startTime)
                
                DispatchQueue.main.async {
                    self.podcast = podcast
                    self.isLoading = false
                    self.cacheStatus = "Load time: \(String(format: "%.2f", loadTime)) seconds"
                    self.historyManager.saveURL(self.url)
                    self.loadURLHistory()
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearCache() {
        cacheManager.clearCache()
        cacheStatus = "Cache cleared"
    }
    
    func loadURLHistory() {
        urlHistory = historyManager.getHistory().urls
    }
}
