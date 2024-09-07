import Foundation

class PodcastDetailViewModel: ObservableObject {
    @Published var podcast: Podcast
    @Published var isImageLoading = true
    
    init(podcast: Podcast) {
        self.podcast = podcast
    }
    
    func imageLoaded() {
        isImageLoading = false
    }
}
