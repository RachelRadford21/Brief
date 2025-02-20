//
//  NotesView.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import SwiftUI

struct NotesView: View {
    @State var notes: String = ""
    var body: some View {
        VStack(spacing: 15) {
            TitleView(title: "Notes")
            TextEditor(text: $notes)
                .font(.custom("BarlowCondensed-Regular", size: 20))
                .border(Color.gray, width: 1)
                .padding()
        }
    }
}

#Preview {
    NotesView()
}
