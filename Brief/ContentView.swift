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
    @State var articleTitle: String = ""
    @State var articleVM = ArticleViewModel.shared
    var articleManager: SharedArticleManager
    let descriptor = FetchDescriptor<ArticleModel>()
    
    init(
        articleManager: SharedArticleManager
    ) {
        self.articleManager = articleManager
    }
    
    var body: some View {
        contentView
    }
}

extension ContentView {
    @ViewBuilder
    var contentView: some View {
            openingView
            articleView
            listView
    }
    
    @ViewBuilder
    var articleView: some View {
        if let url = articleManager.sharedURL {
            ArticleView(
                articleManager: articleManager,
                url: url
            )
            .customToolbar(url: articleManager.sharedURL, buttons: [
                ("message", { articleManager.shareArticle() }),
                ("arrow.down.document", {
                    articleVM.saveArticle(
                        title: articleVM.articleTitle,
                        url: articleManager.sharedURL!,
                        dateSaved: Date()
                    )
                    articleManager.sharedURL = nil
                    articleManager.clearSharedURL()
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
    var openingView: some View {
        let results = try? context.fetch(descriptor)
        if results?.isEmpty == true && articleManager.sharedURL == nil {
            OpeningView()
        }
    }
    
    @ViewBuilder
    var listView: some View {
        let results = try? context.fetch(descriptor)
        if (results?.isEmpty == false) && articleManager.sharedURL == nil {
            ArticleListView()
        }
    }
}

#Preview {
    ContentView(articleManager: SharedArticleManager())
}

