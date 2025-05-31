//
//  NetworkService.swift
//  test-news-app
//
//  Created by Wu, Ivy on 2025/5/31.
//

// NetworkService.swift

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkService {
    private let baseURL = "http://localhost.com:5000/api"
    
    func getLatestNews(tag: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> NewsResponse {
        var components = URLComponents(string: "\(baseURL)/news/latest")!
        
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        if let tag = tag {
            queryItems.append(URLQueryItem(name: "tag", value: tag))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(NewsResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getNewsCard(id: String) async throws -> NewsCard {
        guard let url = URL(string: "\(baseURL)/news/card/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(NewsCard.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getTags() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/news/tags") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        struct TagsResponse: Codable {
            let tags: [String]
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(TagsResponse.self, from: data)
            return response.tags
        } catch {
            throw NetworkError.decodingError
        }
    }
}
