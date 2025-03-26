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
    @State var noteTitle: String = ""
    @State var noteText: String = ""
    var articleVM: ArticleViewModel = .shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
               
                if !editNote {
                    currentNoteView
                } else {
                    EditNoteView(noteTitle: $noteTitle, noteText: $noteText, editNote: $editNote)
                }
            }
        }
        .padding(.horizontal, 20)
      
        .foregroundStyle(colorScheme == .dark ? Color.paperWhite : Color.accentColor)
    }
}

extension CurrentNoteView {
    var currentNoteView: some View {
        VStack {
            Text(noteTitle)
                .font(.custom("BarlowCondensed-SemiBold", size: 30))
            
            Text(noteText)
                .font(.custom("BarlowCondensed-Regular", size: 25))
            Spacer()
            
            Button {
                editNote.toggle()
                Task {
                    articleVM.saveArticleNote(title: noteTitle, text: noteText)
                }
            } label: {
                Text(!editNote ? "EDIT" : "SAVE")
            }
        }
    }
}
