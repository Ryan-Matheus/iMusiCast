import Foundation

class RSSSourceViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var podcast: Podcast?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let rssParser = RSSParser()
    
    // MARK: TEST PLAYER
    
    init() {
        let exampleEpisodes = [
            Episode(title: "Ep 1", description: "episode 1", audioUrl: URL(string: "...")!, duration: 1800, publishDate: Date()),
            Episode(title: "Ep 2", description: "episode 2", audioUrl: URL(string: "...")!, duration: 2400, publishDate: Date().addingTimeInterval(-86400))
        ]
        
        self.podcast = Podcast(title: "Curiosity PodCast...?", description: "Testing if it works...", imageUrl: URL(string: "...")!, author: "Ryan Matheus", genre: "Curiosity", episodes: exampleEpisodes)
    }
    
    func loadPodcast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //        guard let url = URL(string: self.url) else {
            //            error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            //            return
            //        }
            //
            //        isLoading = true
            //        error = nil
            //
            //        Task {
            //            do {
            //                let podcast = try await rssParser.parsePodcast(from: url)
            //                DispatchQueue.main.async {
            //                    self.podcast = podcast
            //                    self.isLoading = false
            //                }
            //            } catch {
            //                DispatchQueue.main.async {
            //                    self.error = error
            //                    self.isLoading = false
            //                }
            //            }
            //        }
        }
    }
}
