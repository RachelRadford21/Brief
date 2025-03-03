//
//  NoteEntity.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import AppIntents

struct NoteEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Note")
    
    static var defaultQuery = NoteQuery()
    
    var id: UUID
    var text: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(text)")
    }
}
