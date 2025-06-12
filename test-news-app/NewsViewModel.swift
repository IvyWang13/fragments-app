import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var newsCards: [NewsCard] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedTopics: Set<String> = []
    @Published var availableTopics: [String] = []
    
    private let networkService = NetworkService()
    private var currentOffset = 0
    private let limit = 20
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        print("loadInitialData")
        isLoading = true
        error = nil
        
        do {
            // 加载标签
            let tags = try await networkService.getTags()
            availableTopics = tags
            
            // 加载新闻
            let response = try await networkService.getLatestNews(
                tag: selectedTopics.first,
                limit: limit,
                offset: 0
            )
            newsCards = response.cards
            currentOffset = response.cards.count
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadMoreNews() async {
        print("loadMoreNews")

        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let response = try await networkService.getLatestNews(
                tag: selectedTopics.first,
                limit: limit,
                offset: currentOffset
            )
            newsCards.append(contentsOf: response.cards)
            currentOffset += response.cards.count
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleTopic(_ topic: String) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.removeAll() // 如果API只支持单个标签过滤
            selectedTopics.insert(topic)
        }
        
        Task {
            await loadInitialData()
        }
    }
    
    func loadNewsWithTags(_ tags: Set<String>) async {
        // This would be your API call with tag filtering
        // For now, using the existing load method
        await loadInitialData()
    }
    
    func loadMoreNewsWithTags(_ tags: Set<String>) async {
        // This would be your API call for pagination with tag filtering
        // For now, using the existing load method
        await loadMoreNews()
    }
}

