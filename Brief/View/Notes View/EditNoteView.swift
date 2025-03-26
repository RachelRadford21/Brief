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
    @Binding var noteTitle: String
    @Binding var noteText: String
    @Binding var editNote: Bool
    @Query var articles: [ArticleModel]
    var articleVM: ArticleViewModel = .shared
    
    var body: some View {
        VStack(spacing: 15) {
            
            TextField("Title", text: $noteTitle)
                .padding(.horizontal)
            
            TextEditor(text: $noteText)
                .font(.custom("BarlowCondensed-Regular", size: 20))
                .border(Color.gray, width: 1)
                .padding()
            
            Button {
                editNote.toggle()
                Task {
                    articleVM.saveArticleNote(title: noteTitle, text: noteText)
                }
            } label: {
                
                Text("Save")
                    .foregroundStyle(Color.pink)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
