//
//  EditNoteView.swift
//  Brief
//
//  Created by Rachel Radford on 3/15/25.
//

import SwiftUI
import SwiftData

struct EditNoteView: View {
    @Environment(\.modelContext) var context
    @Bindable var note: NoteModel
    @Binding var editNote: Bool
    var articleVM: ArticleViewModel = .shared
   
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                TextField("Title", text: $note.title )
                        .padding(.horizontal)
                TextEditor(text: $note.text)
                    .font(.custom("BarlowCondensed-Regular", size: 20))
                    .border(Color.gray, width: 1)
                    .padding()
                    .frame(height: 800)
                
                Button {
                    editNote.toggle()
                    Task {
                        articleVM.createArticleNote(article: note.article ?? ArticleModel(title: note.article?.title ?? ""), title: note.title, text: note.text)
                    }
                } label: {
                    
                    Text("Save")
                        .foregroundStyle(Color.paperWhite)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 20)
    }
}
