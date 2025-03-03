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

    static var defaultQuery = BriefQuery()

    var id: UUID
    var title: String
    var url: URL?
    
    var displayRepresentation: DisplayRepresentation {
         DisplayRepresentation(title: "\(title)")
      }
}
