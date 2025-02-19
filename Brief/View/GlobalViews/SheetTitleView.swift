//
//  SheetTitleView.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import SwiftUI

struct SheetTitleView: View {
    var title: String = ""
    var fontStyle: String = "MerriweatherSans-VariableFont_Wght"
    var fontSize: CGFloat = 40
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.custom(fontStyle, size: fontSize).bold())
                .padding(.top, 15)
        }
    }
}

#Preview {
    SheetTitleView()
}
