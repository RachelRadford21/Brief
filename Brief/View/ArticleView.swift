//
//  ArticleView.swift
//  Brief
//
//  Created by Rachel Radford on 1/24/25.
//

import SwiftUI

struct ArticleView: View {
    @Binding var articleTitle: String
    var articleManager: SharedArticleManager
    var url: URL
    
    init(
        articleTitle: Binding<String> = .constant(""),
        articleManager: SharedArticleManager,
        url: URL
    ) {
        self._articleTitle = articleTitle
        self.articleManager = articleManager
        self.url = url
    }
    
    var body: some View {
        VStack {
            articleTitleView
            
            WebView(url: url)
                .padding()
        }
        .onAppear {
            articleManager.fetchArticleTitle(from: url) { title in
                articleTitle = title ?? "No Title"
            }
        }
        .onChange(of: url) {
            articleManager.fetchArticleTitle(from: url) { title in
                articleTitle = title ?? "No Title"
            }
        }
    }
}

extension ArticleView {
  var articleTitleView: some View {
    Text(articleTitle)
      .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
      .padding()
  }
}

