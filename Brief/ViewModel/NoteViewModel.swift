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
