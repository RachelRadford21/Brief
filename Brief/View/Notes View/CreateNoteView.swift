//
//  CreateNoteView.swift
//  Brief
//
//  Created by Rachel Radford on 3/5/25.
//

import SwiftUI

struct CreateNoteView: View {
    @Binding var title: String
    @Binding var text: String
    var articleVM: ArticleViewModel = .shared
    init(
        title: Binding<String> = .constant(""),
        text: Binding<String> = .constant("")
    ) {
        self._title = title
        self._text = text
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
                Task {
                    articleVM.saveArticleNote(title: title, text: text)
                }
            } label: {
                Text("Save")
            }
        }
    }
}

#Preview {
    CreateNoteView()
}
