//
//  NoteIntent.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import Foundation
import AppIntents
import SwiftData
import SwiftUI

struct NoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Note"
    static var description: IntentDescription = IntentDescription(
        "Take a note",
        categoryName: "Notes",
        searchKeywords: ["note", "read", "save", "open", "view"]
    )
    
    @Parameter(title: "Note")
    var note: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$note)")
    }
    
    static var openAppWhenRun: Bool {
        return true
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("NoteIntent activated: Looking for note with title '\(note)'")
        
        let container = try ModelContainer(for: NoteModel.self)
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<NoteModel>(
            predicate: #Predicate<NoteModel> { noteModel in
                noteModel.title.contains(note) ||
                noteModel.title == note
            }
        )
        
        do {
            let notes = try context.fetch(descriptor)
            
            guard let matchedNote = notes.first else {
                return .result(dialog: "No note found with title containing '\(note)'.")
            }
            
            UserDefaults.standard.set(true, forKey: "BriefIntent_ShouldShowNotes")
            UserDefaults.standard.set(matchedNote.id.uuidString, forKey: "BriefIntent_NoteToOpen")
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenNoteByIDNotification"),
                    object: nil,
                    userInfo: ["noteID": matchedNote.id]
                )
            }
            
            return .result(dialog: "Opening note: \(matchedNote.title)")
        } catch {
            print("Error fetching notes: \(error)")
            return .result(dialog: "Error finding note")
        }
    }
}
