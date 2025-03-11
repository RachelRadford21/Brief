//
//  NoteModel.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import SwiftData

@Model
class NoteModel: Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var text: String
    var dateCreated: Date
    
    @Relationship(inverse: \ArticleModel.note)
        var article: ArticleModel?
    
        init(
            title: String = "",
            text: String = "",
            dateCreated: Date = Date()
        ) {
            self.title = title
            self.text = text
            self.dateCreated = dateCreated
        }

    enum CodingKeys : String, CodingKey {
        case id
        case title
        case text
        case dateCreated
    }
    
    
    required public init(from decoder: Decoder) throws {
        self.id = try decoder.container(keyedBy: CodingKeys.self).decode(UUID.self, forKey: .id)
        title = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .title)
        text = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .text)
        dateCreated = try decoder.container(keyedBy: CodingKeys.self).decode(Date.self, forKey: .dateCreated)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}
