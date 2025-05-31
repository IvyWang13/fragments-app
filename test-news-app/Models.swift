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

struct NewsCard: Identifiable, Codable {
    let id: String
    let title: String
    let summary: String
    let imageUrl: String?
    let date: String
    let topics: [String]
    let sources: [Source]
    let relatedCards: [RelatedCard]
    let content: String? // 添加内容字段
    
    // 为了兼容现有代码的初始化器
    init(title: String, date: Date, topics: [String], imageURL: URL?, content: String) {
        self.id = UUID().uuidString // 本地测试用
        self.title = title
        self.summary = content
        self.imageUrl = imageURL?.absoluteString
        self.date = ISO8601DateFormatter().string(from: date)
        self.topics = topics
        self.sources = []
        self.relatedCards = []
        self.content = content
    }
}

// 修改 NewsResponse 结构以匹配 API 返回的格式
struct NewsResponse: Decodable {
    let cards: [NewsCard]
    let meta: MetaData
}



