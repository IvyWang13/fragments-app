// Models.swift

import Foundation


struct Source: Codable {
    let id: String
    let url: String
    let date: String
}

struct RelatedCard: Codable {
    let id: String
    let title: String
}

struct MetaData: Codable {
    let total: Int
    let limit: Int
    let offset: Int
}

struct Reference: Identifiable, Codable {
    let id: String
    let url: String
    let source: String
    let title: String
    let date: String
}

struct NewsCard: Identifiable, Codable {
    let id: String
    let title: String
    let summary: String
    let imageUrl: String
    let date: String
    let topics: [String]
    let references: [Reference]
//    let content: String
    
    // Computed property to convert date string to Date
    var dateObject: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: date) ?? Date()
    }
}


// 修改 NewsResponse 结构以匹配 API 返回的格式
struct NewsResponse: Decodable {
    let cards: [NewsCard]
    let meta: MetaData
}



