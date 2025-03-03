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
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var text: String
    var dateCreated: Date = Date()
    
    @Relationship var article: ArticleModel?
    
    init(
        title: String = "",
        text: String = ""
    ) {
        self.title = title
        self.text = text
    }
}
