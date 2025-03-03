//
//  BriefEntity.swift
//  Brief
//
//  Created by Rachel Radford on 2/25/25.
//

import Foundation
import AppIntents
import SwiftData

struct BriefEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Article")

    static var defaultQuery = ArticleQuery()

    var id: UUID
    var title: String
    var url: URL?
    
    
    var displayRepresentation: DisplayRepresentation {
        let subtitleText = url?.absoluteString ?? "No URL"
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: LocalizedStringResource(stringLiteral: subtitleText)
        )
    }
}
