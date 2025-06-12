//
//  TagsViewModel.swift
//  test-news-app
//
//  Created by Ivy Wang on 6/2/25.
//
import SwiftUI
import Foundation
import Combine

class TagManager: ObservableObject {
    @Published var userTags: [UserTag] = []
    @Published var availableTags: [String] = []
    @Published var newTagText: String = ""
    
    private var newsViewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // Predefined tags...
    private let predefinedTags = [
        "Technology", "AI", "Science", "Business", "Politics",
        "Sports", "Entertainment", "Health", "Environment", "Finance",
        "Gaming", "Travel", "Food", "Fashion", "Education"
    ]
    
    init(newsViewModel: NewsViewModel) {
        self.newsViewModel = newsViewModel
        loadTags()
        
        // Listen for changes in newsViewModel - fixed version
        Task { @MainActor in
            newsViewModel.$availableTopics
                .receive(on: DispatchQueue.main)
                .sink { [weak self] topics in
                    self?.updateTagsFromNewsViewModel()
                }
                .store(in: &self.cancellables)
        }
    }
    
    @MainActor
    private func updateTagsFromNewsViewModel() {
        print("updateTagsFromNewsViewModel")
        guard !newsViewModel.availableTopics.isEmpty else { return }
        
        // Only update if we don't have saved tags
//        if UserDefaults.standard.data(forKey: "user_tags") == nil {
        userTags = newsViewModel.availableTopics.map {
            UserTag(name: $0, isSelected: false, isCustom: false)
            }
            saveTags()
//        }
    }
    
    func loadTags() {
        if let data = UserDefaults.standard.data(forKey: "user_tags"),
           let decodedTags = try? JSONDecoder().decode([UserTag].self, from: data) {
            print("Using saved tags from UserDefaults")
            print(decodedTags)
            userTags = decodedTags
        } else {
            print("Initialize with predefined tags")
            userTags = predefinedTags.map { UserTag(name: $0, isSelected: false, isCustom: false) }
            saveTags()
        }
    }
    
    // Save tags to UserDefaults
    func saveTags() {
        if let encoded = try? JSONEncoder().encode(userTags) {
            UserDefaults.standard.set(encoded, forKey: "user_tags")
        }
    }
    
    // Toggle tag selection
    func toggleTag(_ tag: UserTag) {
        if let index = userTags.firstIndex(where: { $0.id == tag.id }) {
            userTags[index].isSelected.toggle()
            saveTags()
        }
    }
    
    // Add new custom tag
    func addCustomTag() {
        let trimmedText = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty,
              !userTags.contains(where: { $0.name.lowercased() == trimmedText.lowercased() }) else {
            return
        }
        
        let newTag = UserTag(name: trimmedText, isSelected: true, isCustom: true)
        userTags.append(newTag)
        newTagText = ""
        saveTags()
    }
    
    // Remove custom tag
    func removeCustomTag(_ tag: UserTag) {
        guard tag.isCustom else { return }
        userTags.removeAll { $0.id == tag.id }
        saveTags()
    }
    
    // Get selected tags
    var selectedTags: [String] {
        userTags.filter { $0.isSelected }.map { $0.name }
    }
    
    // Get selected tag names for news filtering
    var selectedTagNames: Set<String> {
        Set(selectedTags.map { $0.lowercased() })
    }
}
