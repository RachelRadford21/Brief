//
//  SubHeaderView.swift
//  Brief
//
//  Created by Rachel Radford on 3/1/25.
//

import SwiftUI

struct SubHeaderView: View {
    @State private var isFlipped = false
    @State private var flipCount = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let maxFlips = 3
    var body: some View {
        
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
}

#Preview {
    SubHeaderView()
}
