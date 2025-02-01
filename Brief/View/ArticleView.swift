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
    var url: URL
    
    init(
        articleManager: SharedArticleManager,
        url: URL
    ) {
        self.articleManager = articleManager
        self.url = url
    }
    
    var body: some View {
        VStack {
            ArticleTitleView()
            
            WebView(url: url)
                .padding()
        }
        .onAppear {
            loadArticle(url: url)

            articleManager.fetchAndExtractText(from: url.absoluteString) { html in
                if let html = html {
                    let articleText = articleManager.extractMainArticle(from: html)
                    print("Extracted Article:", articleText)
                }
            }
        }
        .onChange(of: url) {
            loadArticle(url: url)

            articleManager.fetchAndExtractText(from: url.absoluteString) { html in
                if let html = html {
                    let articleText = articleManager.extractMainArticle(from: html)
                    print("Extracted Article:", articleText)
                }
            }
        }
    }
}

extension ArticleView {
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
