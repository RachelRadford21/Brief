//
//  ArticleModel.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import Foundation
import SwiftData

@Model
class ArticleModel: Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var url: URL?
    var read: Bool
    var dateSaved: Date = Date()
    var isBookmarked: Bool
    var articleSummary: String?
    
    @Relationship(inverse: \NoteModel.article) var notes: [NoteModel] = []
    
    init(
        title: String,
        url: URL? = nil,
        read: Bool = false,
        isBookmarked: Bool = false,
        articleSummary: String? = nil
    ) {
        self.title = title
        self.url = url
        self.read = read
        self.isBookmarked = isBookmarked
        self.articleSummary = articleSummary
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case read
        case dateSaved
        case isBookmarked
        case articleSummary
    }
    
    required public init(from decoder: Decoder) throws {
        self.id = try decoder.container(keyedBy: CodingKeys.self).decode(UUID.self, forKey: .id)
        self.title = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .title)
        self.url = try decoder.container(keyedBy: CodingKeys.self).decode(URL.self, forKey: .url)
        self.read = try decoder.container(keyedBy: CodingKeys.self).decode(Bool.self, forKey: .read)
        self.dateSaved = try decoder.container(keyedBy: CodingKeys.self).decode(Date.self, forKey: .dateSaved)
        self.isBookmarked = try decoder.container(keyedBy: CodingKeys.self).decode(Bool.self, forKey: .isBookmarked)
        self.articleSummary = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .articleSummary)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(read, forKey: .read)
        try container.encode(dateSaved, forKey: .dateSaved)
        try container.encode(isBookmarked, forKey: .isBookmarked)
        try container.encode(articleSummary, forKey: .articleSummary)
    }
}
