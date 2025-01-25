//
//  ToolBarButtonView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct ToolBarButtonView: View {
    var buttonLabel: String
    var action: () -> Void?
    
    var body: some View {
        buttonLabelView
    }
}

extension ToolBarButtonView {
    var buttonLabelView: some View {
        HStack {
            Button {
                action()
            } label: {
                Image(systemName: buttonLabel)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .tint(.gray).brightness(-0.1)
            }
        }
    }
}

