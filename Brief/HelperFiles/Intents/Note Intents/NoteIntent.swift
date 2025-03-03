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
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("NoteIntent activated: Looking for note containing '\(note)'")
        
        let container = try ModelContainer(for: NoteModel.self)
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<NoteModel>(
            predicate: #Predicate<NoteModel> { note in
                note.text.contains(note.text)
            }
        )
        
        let notes = try context.fetch(descriptor)
        
        guard let note = notes.first else {
            return .result(dialog: "No note found containing '\(note)'.")
        }
        
        let encodedText = note.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "brief://note/\(note.id)?text=\(encodedText)"
        
        if let url = URL(string: urlString) {
            await MainActor.run {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            UserDefaults.standard.set(true, forKey: "BriefIntent_ShouldShowNotes")
            UserDefaults.standard.set(note.id.uuidString, forKey: "BriefIntent_NoteToOpen")
            
            return .result(dialog: "Opening note containing: \(note.text)")
        } else {
            return .result(dialog: "Could not create URL")
        }
    }
}
