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
    @Environment(\.openURL) private var openURL
    var articleManager = SharedArticleManager()
    var container = try! ModelContainer(for: ArticleModel.self)
    
    static var appShortcuts: AppShortcutsProvider.Type? {
        return BriefIntentShortcut.self
    }
    
    init()  {
        do {
            container = try ModelContainer(for: ArticleModel.self)
            
        } catch {
            fatalError("Failed to create ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(articleManager: articleManager)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        articleManager.loadSharedURL()
                        
                    }
                }
                .onOpenURL(perform: { url in
                    handleDeeplink(url: url)
                    
                })
        }
        .modelContainer(container)
    }
}

extension BriefApp {
    
    func handleDeeplink(url: URL) {
        
        guard url.scheme == "brief", url.host == "article" else {
            return
        }
        
        let pathComponent = url.lastPathComponent
        
        if let articleID = UUID(uuidString: pathComponent) {
            print("Looking for article with ID: \(articleID)")
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenArticleByIDNotification"),
                    object: nil,
                    userInfo: ["articleID": articleID]
                )
            }
        }
        
        else if let decodedTitle = pathComponent.removingPercentEncoding {
            print("Looking for article with title: \(decodedTitle)")
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenArticleByTitleNotification"),
                    object: nil,
                    userInfo: ["title": decodedTitle]
                )
            }
        }
    }
}
