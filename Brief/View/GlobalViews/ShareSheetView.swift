//
//  ShareSheetView.swift
//  Brief
//
//  Created by Rachel Radford on 2/16/25.
//

import Foundation
import UIKit
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
