//
//  ArticleView.swift
//  Brief
//
//  Created by Rachel Radford on 1/24/25.
//

import SwiftUI

struct ArticleView: View {
    @State var articleVM = ArticleViewModel.shared
    var articleManager: SharedArticleManager
    var summarizer = SummarizerService.shared
    var url: URL

    init(
        articleManager: SharedArticleManager,
        url: URL
    ) {
        self.articleManager = articleManager
        self.url = url
    }
    
    var body: some View {
        articleView
    }
}

extension ArticleView {
    var articleView: some View {
        VStack {
            ArticleTitleView()
            
            WebView(url: url)
        }
        .onAppear {
            loadArticle(url: url)
            summarizer.extractAndTokenizeText(url: url)
        }
        .onChange(of: url) {
            loadArticle(url: url)
            summarizer.extractAndTokenizeText(url: url)
        }
    }
    
    func loadArticle(url: URL) {
        Task {
            do {
                let title = try await articleManager.fetchArticleTitle(from: url)
                await MainActor.run {
                    articleVM.articleTitle = title
                }
            } catch {
                print("Error fetching title: \(error.localizedDescription)")
            }
        }
    }
}
