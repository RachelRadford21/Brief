//
//  BriefApp.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

@main
struct BriefApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var articleManager = ArticleViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(articleManager: articleManager)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        articleManager.loadSharedURL()
                    }
                }
        }
    }
}
