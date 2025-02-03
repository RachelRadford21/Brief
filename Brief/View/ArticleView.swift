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
        VStack {
            ArticleTitleView()
            
            WebView(url: url)
                .padding()
        }
        .onAppear {
            loadArticle(url: url)
            extractAndTokenizeText(url: url)
        }
        .onChange(of: url) {
            loadArticle(url: url)
            extractAndTokenizeText(url: url)
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
    
    func extractAndTokenizeText(url: URL) {
        articleManager.fetchAndExtractText(from: url.absoluteString) { html in
            if let html = html {
                let articleText = articleManager.extractMainArticle(from: html)
              ///  print("Extracted Article:", articleText)
                Task {
                    // decide if var for tokenized text in summarizer or a model value?
                    summarizer.tokenizeText(articleText)
                   // print("Tokenized Article:", articleText)
                }
            }
        }
    }
}
