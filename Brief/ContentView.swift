//
//  ContentView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @State var isArticleSaved: Bool = false
    @State var articleTitle: String = ""
    var articleManager: SharedArticleManager
    var articleVM: ArticleViewModel
    var article: ArticleModel?
    let descriptor = FetchDescriptor<ArticleModel>()
    
    init(
        articleManager: SharedArticleManager,
        articleVM: ArticleViewModel
    ) {
        self.articleManager = articleManager
        self.articleVM = articleVM
    }
    
    var body: some View {
        contentView
    }
}

extension ContentView {
    var contentView: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            NavigationStack {
                articleView()
                
                openingAndListViews()
            }
            .tint(.black)
        }
    }
    
    @ViewBuilder
    func articleView() -> some View {
        if let url = articleManager.sharedURL {
            ArticleView(articleTitle: $articleTitle, articleManager: articleManager, url: url)
                .customToolbar(url: articleManager.sharedURL, buttons: [
                    ("message", { shareArticle() }),
                    ("arrow.up.document", {
                        articleVM.saveArticle(
                            title: articleTitle,
                            url: articleManager.sharedURL!,
                            read: false,
                            dateSaved: Date()
                        )
                        isArticleSaved = true
                    }),
                    ("trash.square", {
                        articleTitle = ""
                        articleManager.sharedURL = nil
                        articleManager.clearSharedURL()
                    })
                ])
        }
    }
    
    @ViewBuilder
    func openingAndListViews() -> some View {
        let results = try? context.fetch(descriptor)
        if results?.isEmpty == true && articleManager.sharedURL == nil {
            OpeningView()
        }
        if isArticleSaved || (results?.isEmpty == false) && articleManager.sharedURL == nil {
            ArticleListView()
                .onAppear {
                    articleManager.sharedURL = nil
                }
        }
    }
    
    private func shareArticle() {
        let text = "Check out this article"
        let url = URL(string: articleManager.sharedURL?.absoluteString ?? article?.url?.description ?? "")
            
            let activityController = UIActivityViewController(activityItems: [text, url as Any], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityController, animated: true)
            }
    }
}

