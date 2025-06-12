//
//  TagManagementModels.swift
//  test-news-app
//
//  Created by Ivy Wang on 6/2/25.
//

import Foundation

// MARK: - Tag Management Models
struct UserTag: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    var isSelected: Bool
    var isCustom: Bool // true if user-created, false if predefined
    
    init(name: String, isSelected: Bool = false, isCustom: Bool = false) {
        self.name = name
        self.isSelected = isSelected
        self.isCustom = isCustom
        self.id = UUID().uuidString
    }
}
