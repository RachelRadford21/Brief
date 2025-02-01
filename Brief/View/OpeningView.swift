//
//  OpeningView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct OpeningView: View {
    @State private var isFlipped = false
    @State private var flipCount = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let maxFlips = 3
    
    var body: some View {
        VStack {
            Text("BRIEF")
                .font(.custom("MerriweatherSans-VariableFont_wght", size: 28))

            subHeaderTextView
            
            Spacer()
            
            multilineTextView
            
            Spacer()
        }
        .padding()
    }
}

extension OpeningView {
    var subHeaderTextView: some View {
        Text("\(isFlipped ? "Read" : "Save") What Matters.")
            .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
            .padding(.top, 10)
            .animation(.easeInOut(duration: 0.5), value: isFlipped)
            .onReceive(timer) { _ in
                if flipCount < maxFlips {
                    isFlipped.toggle()
                    flipCount += 1
                } else {
                    timer.upstream.connect().cancel()
                }
            }
    }
    
    var multilineTextView: some View {
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
    OpeningView()
}
