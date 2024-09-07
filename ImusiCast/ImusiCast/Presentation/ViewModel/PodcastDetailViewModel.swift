import Foundation

class PodcastDetailViewModel: ObservableObject {
    @Published var podcast: Podcast
    
    init(podcast: Podcast) {
        self.podcast = podcast
    }
}
