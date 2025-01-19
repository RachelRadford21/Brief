//
//  OpeningView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct OpeningView: View {
    var body: some View {
        
        VStack(spacing: 10) {
            Text("BRIEF")
                .font(.custom("MerriweatherSans-VariableFont_wght", size: 28))
            Text("Save What Matters. Read Anytime.")
                .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
            Spacer()
            Text("""
                    You currently have no saved articles.
                    When you find an article you’d like to save, just share it to Brief, and it will be here waiting for you whenever you’re ready to read.
                 """)
            .multilineTextAlignment(.center)
            .font(.custom("BarlowCondensed-SemiBold", size: 20))
            .foregroundStyle(Color.gray)
            .lineSpacing(3)
            .padding()
            Spacer(minLength: 280)
        }
        .padding()
    }
}

#Preview {
    OpeningView()
}
