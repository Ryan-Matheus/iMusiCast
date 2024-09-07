import Foundation

class RSSSourceViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var podcast: Podcast?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let rssParser = RSSParser()
    
    func loadPodcast() {
        guard let url = URL(string: self.url) else {
            error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let podcast = try await rssParser.parsePodcast(from: url)
                DispatchQueue.main.async {
                    self.podcast = podcast
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}
