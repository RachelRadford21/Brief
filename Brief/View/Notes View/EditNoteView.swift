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
    @Environment(\.colorScheme) var colorScheme
    @Bindable var note: NoteModel
    @Binding var editNote: Bool
    var articleVM: ArticleViewModel = .shared
   
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                TextField("Title", text: $note.title )
                    .font(.custom("BarlowCondensed-Regular", size: 25))
                        .padding(.horizontal)
                TextEditor(text: $note.text)
                    .font(.custom("BarlowCondensed-Regular", size: 20))
                    .border(Color.gray, width: 1)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 700)
                
                Button {
                    editNote.toggle()
                    Task {
                        articleVM.createArticleNote(article: note.article ?? ArticleModel(title: note.article?.title ?? ""), title: note.title, text: note.text)
                    }
                } label: {
                    
                    Text("Save")
                       
                        
                }
                .frame(width: 100, height: 45)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .foregroundStyle(colorScheme == .dark ? Color.paperWhite : Color.black)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 25)
        .scrollIndicators(.hidden)
    }
}
