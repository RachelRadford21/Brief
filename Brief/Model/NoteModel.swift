//
//  NoteModel.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import SwiftData

@Model
class NoteModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var text: String
    var dateCreated: Date
    
    @Relationship(inverse: \ArticleModel.notes) var article: ArticleModel?
    
    init(
        id: UUID,
        text: String = "",
        dateCreated: Date
    ) {
        self.id = id
        self.text = text
        self.dateCreated = dateCreated
    }
}
