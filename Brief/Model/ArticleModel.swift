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
    var id: UUID
    var title: String
    var url: URL?
    var read: Bool
    var dateSaved: Date
    
    init(
        id: UUID,
        title: String,
        url: URL? = nil,
        read: Bool = false,
        dateSaved: Date
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.read = read
        self.dateSaved = dateSaved
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case read
        case dateSaved
    }
    
    required public init(from decoder: Decoder) throws {
        self.id = try decoder.container(keyedBy: CodingKeys.self).decode(UUID.self, forKey: .id)
        self.title = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .title)
        self.url = try decoder.container(keyedBy: CodingKeys.self).decode(URL.self, forKey: .url)
        self.read = try decoder.container(keyedBy: CodingKeys.self).decode(Bool.self, forKey: .read)
        self.dateSaved = try decoder.container(keyedBy: CodingKeys.self).decode(Date.self, forKey: .dateSaved)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(read, forKey: .read)
        try container.encode(dateSaved, forKey: .dateSaved)
    }
        
}
