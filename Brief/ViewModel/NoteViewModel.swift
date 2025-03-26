//
//  NoteViewModel.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import SwiftData

@Observable
class NoteViewModel {
    static let shared = NoteViewModel()
    let articleVM: ArticleViewModel = .shared
    let context: ModelContext
    var article: ArticleModel?
    init(
        context: ModelContext? = nil
    ) {
        if let providedContext = context {
            self.context = providedContext
        } else {
            let container = try! ModelContainer(for: NoteModel.self)
            self.context = ModelContext(container)
            
        }
    }
    
    func saveNote(title: String, text: String, for article: ArticleModel) {
        if let existingNote = article.note {
            // Update the existing note
            existingNote.title = title
            existingNote.text = text
        } else {
            // Create a new note and attach it to the article
            let newNote = NoteModel(title: title, text: text)
            article.note = newNote
            context.insert(newNote)
        }

        do {
            try context.save()
            print("Note saved successfully.")
        } catch {
            print("Could not save note: \(error.localizedDescription)")
        }
    }

    
    
//    func saveNote(title: String, text: String) -> NoteModel {
//        let newNote = NoteModel(
//            title: title,
//            text: text
//        )
//        
//        context.insert(newNote)
//        
//        do {
//            try context.save()
//            print("Note saved successfully with ID: \(newNote.id)")
//        } catch {
//            print("Could Not Save Note: \(error.localizedDescription)")
//        }
//        return newNote
//    }
    
    func deleteNote(id: UUID, title: String, text: String, dateCreated: Date) {
        let fetchRequest = FetchDescriptor<NoteModel>()
        
        do {
            let notes = try context.fetch(fetchRequest)
            
            if let noteToDelete = notes.first(where: { $0.title == title }) {
                context.delete(noteToDelete)
                
                if context.hasChanges {
                    try context.save()
                    print("Note deleted successfully.")
                }
                
            } else {
                print("No matching note found.")
            }
        } catch {
            print("Error fetching or deleting note: \(error.localizedDescription)")
        }
    }
    
    func fetchNotes(sortBy sortDescriptor: SortDescriptor<NoteModel>? = nil,
                    predicate: Predicate<NoteModel>? = nil) -> [NoteModel] {
        do {
            var descriptor = FetchDescriptor<NoteModel>()
        
            if let predicate = predicate {
                descriptor.predicate = predicate
            }
            
            if let sortDescriptor = sortDescriptor {
                descriptor.sortBy = [sortDescriptor]
            } else {
                descriptor.sortBy = [SortDescriptor(\.dateCreated, order: .reverse)]
            }
 
            let notes = try context.fetch(descriptor)
            return notes
        } catch {
            print("Error fetching notes: \(error.localizedDescription)")
            return []
        }
    }
}
