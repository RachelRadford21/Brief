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
    var noteTitle: String
    var noteText: String
   
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text(noteTitle)
                    .font(.custom("BarlowCondensed-SemiBold", size: 30))
                
                Text(noteText)
                    .font(.custom("BarlowCondensed-Regular", size: 25))
                Spacer()
            }
            .foregroundStyle(colorScheme == .dark ? Color.paperWhite : Color.accentColor)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    CurrentNoteView(noteTitle: "Test", noteText: "This is an example note")
}
