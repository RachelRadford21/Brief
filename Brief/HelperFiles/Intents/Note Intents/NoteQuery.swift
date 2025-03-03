//
//  NoteQuery.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import AppIntents
import SwiftUI

struct NoteQuery: EntityQuery {
    typealias Entity = NoteEntity
    
    func entities(for identifiers: [UUID]) async throws -> [NoteEntity] {
        let noteVM = NoteViewModel.shared
        
        guard let notes = noteVM.fetchNotes(article: nil) else { return [] }
       
        let uuids = identifiers.compactMap { UUID(uuidString: $0.uuidString) }
        
        let filteredNotes = notes.filter { note in
            uuids.contains(note.id)
        }
        
        return filteredNotes.map { note in
            NoteEntity(
                id: note.id,
                text: note.text
            )
        }
    }
    
    func suggestedEntities() async throws -> [NoteEntity] {
        let noteVM = NoteViewModel.shared
        guard let notes = noteVM.fetchNotes(article: nil) else { return [] }
        
        let sortedNotes = notes.sorted { $0.dateCreated > $1.dateCreated }
        let recentNotes = Array(sortedNotes.prefix(5))
        
        return recentNotes.map { note in
            NoteEntity(
                id: note.id,
                text: note.text
            )
        }
    }
}
