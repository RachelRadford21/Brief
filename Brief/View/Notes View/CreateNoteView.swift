//
//  CreateNoteView.swift
//  Brief
//
//  Created by Rachel Radford on 3/5/25.
//

import SwiftUI

struct CreateNoteView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var title: String
    @Binding var text: String
    @Binding var editNote: Bool
    var articleVM: ArticleViewModel = .shared
    @Bindable var note: NoteModel
    init(
        title: Binding<String> = .constant(""),
        text: Binding<String> = .constant(""),
        editNote: Binding<Bool> = .constant(false),
        note: NoteModel
    ) {
        self._title = title
        self._text = text
        self._editNote = editNote
        self.note = note
    }
    
    var body: some View {
        VStack {
            
            TextField("Title", text: $title)
                .padding(.horizontal)
            
            TextEditor(text: $text)
                .font(.custom("BarlowCondensed-Regular", size: 20))
                .border(Color.gray, width: 1)
                .padding()
            Button {
                editNote.toggle()
                Task {
                    articleVM.saveArticleNote(article: note.article, title: title, text: text)
                }
            } label: {
                Text("Save")
                    .foregroundStyle(Color.pink)
            }
        }
        .tint(colorScheme == .dark ? Color.paperWhite : .black)
        .onAppear {
            if !title.isEmpty || !text.isEmpty {
                editNote = true
            } else {
                editNote = false
            }
        }
    }
}
