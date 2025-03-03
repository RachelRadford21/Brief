//
//  NotesView.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) var context
    @State private var text: String = ""
    @State private var title: String = ""
    var noteVM: NoteViewModel = NoteViewModel.shared
    var note: NoteModel
    
    public init(
        note: NoteModel = NoteModel(title: "", text: ""),
        noteVM: NoteViewModel = NoteViewModel.shared
        
    ) {
        self.note = note
        self.noteVM = noteVM
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            TitleView(title: "Notes")
            TextField("Title", text: $title)
                .frame(maxWidth: .infinity, alignment: .center)
            TextEditor(text: $text)
                .font(.custom("BarlowCondensed-Regular", size: 20))
                .border(Color.gray, width: 1)
                .padding()
            
            Button {
                noteVM.saveNote(title: title, text: text)
            } label: {
                Text("Save")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NotesView(note: NoteModel(), noteVM: NoteViewModel())
}

