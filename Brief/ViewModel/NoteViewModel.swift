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
    let context: ModelContext
    
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
    
    func saveNote(title: String, text: String, article: ArticleModel? = nil) {
        let newNote = NoteModel(
            title: title,
            text: text
        )
        
        context.insert(newNote)
        
        do {
            try context.save()
            print("Note saved successfully with ID: \(newNote.id)")
        } catch {
            print("Could Not Save Note: \(error.localizedDescription)")
        }
        
    }
    
    func fetchNotes(article: ArticleModel?) -> [NoteModel]? {
        do {
            let descriptor = FetchDescriptor<NoteModel>()
            let allNotes = try? context.fetch(descriptor)
            
            if article == nil {
                return allNotes
            }
            
            let filteredNotes = allNotes?.filter { note in
                        if let noteArticle = note.article, let article = article {
                            return noteArticle.id == article.id
                        }
                        return false
                    }
            
            return filteredNotes
        }
    }
}
