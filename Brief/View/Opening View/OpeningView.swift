//
//  OpeningView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct OpeningView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        openingView
        
    }
}

extension OpeningView {
    var openingView: some View {
        VStack {
            TitleView(title: "Brief")
            
            SubHeaderView()
            
            Spacer()
            
            MultiLineTextView()
            
            Spacer()
        }
    }
}

#Preview {
    OpeningView()
}
