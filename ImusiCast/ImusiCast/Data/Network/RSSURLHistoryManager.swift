import Foundation

class RSSURLHistoryManager {
    var userDefaults = UserDefaults.standard
    private let key = "RSSURLHistory"
    
    func saveURL(_ url: String) {
        var history = getHistory()
        if let index = history.urls.firstIndex(of: url) {
            history.urls.remove(at: index)
        }
        history.urls.insert(url, at: 0)
        if history.urls.count > 5 {
            history.urls = Array(history.urls.prefix(5))
        }
        save(history)
    }
    
    func getHistory() -> RSSURLHistory {
        guard let data = userDefaults.data(forKey: key),
              let history = try? JSONDecoder().decode(RSSURLHistory.self, from: data) else {
            return RSSURLHistory()
        }
        return history
    }
    
    private func save(_ history: RSSURLHistory) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: key)
        }
    }
}
