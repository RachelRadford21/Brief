//
//  NavStackView.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import SwiftUI
import SwiftData

struct NavStackView: View {
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme
    @State private var path = NavigationPath()
    @State private var selectedNote: NoteModel? = nil
    @Query var articles: [ArticleModel]
    @Query var notes: [NoteModel]
    @Bindable var articleVM: ArticleViewModel = ArticleViewModel.shared
    var articleManager: SharedArticleManager
    
    init(
        articleManager: SharedArticleManager
    ) {
        self.articleManager = articleManager
    }
    
    var body: some View {
        navStackView
    }
}

extension NavStackView {
    
    var navStackView: some View {
        NavigationStack(path: $path) {
            NavListView()
            .navigationTitle(navTitleView)
            .navigationDestination(for: ArticleModel.self) { article in
                navDestinationFromList(article: article)
                
            }
            .navigationDestination(for: UUID.self) { articleID in
                if let article = articles.first(where: { $0.id == articleID }) {
                    navDestinationFromSiri(article: article)
                } else {
                    Text("Article not found")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenNoteByIDNotification"))) { notification in
                onReceiveNote(notification: notification)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenArticleByIDNotification"))) { notification in
                onReceive(notification: notification)
            }
        }
        .tint(colorScheme == .dark ? Color.accent.opacity(0.7) : .black)
    }
    
    var navTitleView: Text {
        Text("ARTICLES")
            .font(.custom("Merriweather-SemiBold", size: 20))
        // This is bad but I want to customize, may change later
    }
    func navDestinationFromList(article: ArticleModel) -> some View {
        ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
            .customToolbar(url: articleManager.sharedURL, buttons: [
                ("note.text.badge.plus", { articleVM.showNotes.toggle() }),
                ("message", { articleVM.showShareSheet.toggle() }),
                // Need to figure out why this disppears on first tap
                ("briefcase.fill", { articleVM.getBriefed.toggle() }),
                ("trash.square", {
                    articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
                    path.removeLast()
                    
                })
            ])
    }
    
    func navDestinationFromSiri(article: ArticleModel) -> some View  {
        ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
            .customToolbar(url: articleManager.sharedURL, buttons: [
                ("note.text.badge.plus", { articleVM.showNotes.toggle() }),
                ("message", { articleVM.showShareSheet.toggle() }),
                ("briefcase.fill", { articleVM.getBriefed.toggle() }),
                ("trash.square", {
                    articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
                })
            ])
    }
    
    @MainActor
    func onReceive(notification: NotificationCenter.Publisher.Output) {
        if let articleID = notification.userInfo?["articleID"] as? UUID {
            print("ContentView received notification to open article with ID: \(articleID)")
            
            if articles.first(where: { $0.id == articleID }) != nil {
                path.append(articleID)
            } else {
                for article in articles {
                    print("- \(article.id): \(article.title)")
                }
            }
        }
    }
    
    @MainActor
    func onReceiveNote(notification: NotificationCenter.Publisher.Output) {
        if let noteID = notification.userInfo?["noteID"] as? UUID {
            print("ContentView received notification to open note with ID: \(noteID)")
            
            if let note = notes.first(where: { $0.id == noteID }) {
                selectedNote = note
                articleVM.showNotes = true
            } else {
                print("Note not found with ID: \(noteID)")
                for note in notes {
                    print("- \(note.id): \(note.text.prefix(20))...")
                }
            }
        }
    }
}
