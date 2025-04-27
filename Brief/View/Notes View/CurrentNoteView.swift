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
        ScrollView {
            VStack(spacing: 15) {
            Text(note.title)
                .font(.custom("BarlowCondensed-SemiBold", size: 35))
            
            Text(note.text)
                .font(.custom("BarlowCondensed-Regular", size: 25))
            Spacer()
            
            Button {
                editNote.toggle()
                Task {
                    articleVM.editArticleNote(article: note.article ?? ArticleModel(title: note.article?.title ?? ""), title: note.title, text: note.text)
                }
            } label: {
                Text("Edit")
            }
            .frame(width: 100, height: 45)
            .buttonStyle(.plain)
            .background(Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    .sheet(isPresented: $editNote) {
            EditNoteView(note: note, editNote: $editNote)
        }
    }
}
