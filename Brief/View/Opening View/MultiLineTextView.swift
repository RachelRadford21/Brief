//
//  MultiLineTextView.swift
//  Brief
//
//  Created by Rachel Radford on 3/1/25.
//

import SwiftUI

struct MultiLineTextView: View {
    var body: some View {
        
        Text("""
                  You currently have no saved articles.
                  When you find an article you’d like to save, just share it to Brief, and it will be here waiting for you whenever you’re ready to read.
                 """)
        .multilineTextAlignment(.center)
        .font(.custom("BarlowCondensed-SemiBold", size: 20))
        .foregroundStyle(Color.gray)
        .lineSpacing(3)
        .padding()
        
    }
}

#Preview {
    MultiLineTextView()
}
