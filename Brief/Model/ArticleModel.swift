//
//  ArticleModel.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import Foundation
import SwiftData

@Model
class ArticleModel {
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
}
