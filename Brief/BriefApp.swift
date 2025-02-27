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
                                checkForURLToOpen()
                    }
                }
        }
        .modelContainer(for: [ArticleModel.self])
    }
    
    func checkForURLToOpen() {
        let shouldOpen = UserDefaults.standard.bool(forKey: "BriefIntent_ShouldOpenURL")
        
        if shouldOpen {
            UserDefaults.standard.set(false, forKey: "BriefIntent_ShouldOpenURL")
            
            if let urlString = UserDefaults.standard.string(forKey: "BriefIntent_URLToOpen"),
               let url = URL(string: urlString) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("Now opening URL: \(url)")
                    openURL(url)
                }
               
            }
        }
    }
    
    func openURL(_ url: URL) {
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
