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
    @Bindable var article: ArticleModel
    init(
        title: Binding<String> = .constant(""),
        text: Binding<String> = .constant(""),
        editNote: Binding<Bool> = .constant(false),
        note: NoteModel,
        article: ArticleModel
    ) {
        self._title = title
        self._text = text
        self._editNote = editNote
        self.note = note
        self.article = article
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
                
                
                articleVM.createArticleNote(article: article, title: title, text: text)
            } label: {
                Text("Save")
            }
            .frame(width: 100, height: 45)
            .background(Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundStyle(colorScheme == .dark ? Color.paperWhite : .black)
        .onAppear {
            if !title.isEmpty || !text.isEmpty {
                editNote = true
            } else {
                editNote = false
            }
        }
    }
}
