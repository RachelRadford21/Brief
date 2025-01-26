//
//  Extensions.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import Foundation
import SwiftUI

extension Color {
  static let paperWhite: Color = Color(#colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1))
}

extension View {
    func customToolbar(
        url: URL?,
        placement: ToolbarItemPlacement = .bottomBar,
        buttons: [(systemName: String, action: () -> Void)]
    ) -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: placement) {
                ForEach(buttons.indices, id: \.self) { index in
                    ToolBarButtonView(buttonLabel: buttons[index].systemName) {
                        buttons[index].action()
                    }
                    if index < buttons.indices.count - 1 {
                        Spacer()
                    }
                }
            }
            
        }
    }
}

