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
            articleManager.fetchArticleTitle(from: url) { title in
                articleVM.articleTitle = title ?? "No Title"
            }
        }
        .onChange(of: url) {
            articleManager.fetchArticleTitle(from: url) { title in
                articleVM.articleTitle = title ?? "No Title"
            }
        }
    }
}

