//
//  BriefApp.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct BriefApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var articleManager = SharedArticleManager()
    let container = try! ModelContainer(for: ArticleModel.self)
    static var appShortcuts: AppShortcutsProvider.Type? {
            return BriefIntentShortcut.self
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(articleManager: articleManager)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        articleManager.loadSharedURL()
                    }
                }
        }
        .modelContainer(for: [ArticleModel.self])
    }
}
