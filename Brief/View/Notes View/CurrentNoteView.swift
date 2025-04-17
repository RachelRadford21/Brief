//
//  CurrentNoteView.swift
//  Brief
//
//  Created by Rachel Radford on 3/5/25.
//

import SwiftUI
import SwiftData

struct CurrentNoteView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @State var editNote: Bool = false
    @Bindable var note: NoteModel
    var articleVM: ArticleViewModel = .shared
   
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                    currentNoteView
            }
        }
        .padding(.horizontal, 20)
        .foregroundStyle(colorScheme == .dark ? Color.paperWhite : Color.accentColor)
    }
}

extension CurrentNoteView {
    var currentNoteView: some View {
        VStack {
            
            Text(note.title)
                .font(.custom("BarlowCondensed-SemiBold", size: 30))
            
            Text(note.text)
                .font(.custom("BarlowCondensed-Regular", size: 25))
            Spacer()
            
            Button {
                editNote.toggle()
                Task {
                    articleVM.saveArticleNote(article: note.article, title: note.title, text: note.text)
                }
            } label: {
                Text(!editNote ? "EDIT" : "SAVE")
            }
        }
        .sheet(isPresented: $editNote) {
            EditNoteView(note: note, editNote: $editNote)
        }
    }
}
