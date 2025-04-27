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
    var container = try! ModelContainer(for: ArticleModel.self, NoteModel.self)
    
    static var appShortcuts: AppShortcutsProvider.Type? {
        return IntentShortcut.self
    }
    
    init()  {
        do {
            container = try ModelContainer(for: ArticleModel.self, NoteModel.self)
            
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
                        if let articleIDString = UserDefaults(suiteName: "group.com.brief.app")?.string(forKey: "SiriRequestedArticleID"),
                              let articleID = UUID(uuidString: articleIDString) {
                               
                               UserDefaults(suiteName: "group.com.brief.app")?.removeObject(forKey: "SiriRequestedArticleID")
                               
                               NotificationCenter.default.post(
                                   name: Notification.Name("OpenArticleByIDNotification"),
                                   object: nil,
                                   userInfo: ["articleID": articleID]
                               )
                           }
          
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
        guard url.scheme == "brief" else {
            return
        }
        
        if url.host == "article" {
            // Your existing article handling
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
            } else if let decodedTitle = pathComponent.removingPercentEncoding {
                print("Looking for article with title: \(decodedTitle)")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name("OpenArticleByTitleNotification"),
                        object: nil,
                        userInfo: ["title": decodedTitle]
                    )
                }
            }
        } else if url.host == "note" {
            // New note handling
            let pathComponent = url.lastPathComponent
            
            if let noteID = UUID(uuidString: pathComponent) {
                print("Looking for note with ID: \(noteID)")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name("OpenNoteByIDNotification"),
                        object: nil,
                        userInfo: ["noteID": noteID]
                    )
                }
            } else if let decodedText = pathComponent.removingPercentEncoding {
                print("Looking for note containing text: \(decodedText)")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name("OpenNoteByTextNotification"),
                        object: nil,
                        userInfo: ["text": decodedText]
                    )
                }
            }
        }
    }
}
