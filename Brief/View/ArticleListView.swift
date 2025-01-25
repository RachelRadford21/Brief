//
//  ArticleListView.swift
//  Brief
//
//  Created by Rachel Radford on 1/21/25.
//

import SwiftUI
import SwiftData
import SwiftUI

struct ArticleListView: View {
    @Environment(\.modelContext) var context
    @Query var articles: [ArticleModel]
    var articleManager: SharedArticleManager
    init(
        articleManager: SharedArticleManager = SharedArticleManager()
    ) {
        self.articleManager = articleManager
    }
    
    var body: some View {
        NavigationStack {
            Text("ARTICLES")
                .font(.custom("MerriweatherSans-VariableFont_wght", size: 28))
            List(articles, id: \.id) { article in
                NavigationLink(value: article) {
                    Text(article.title)
                        .font(.custom("BarlowCondensed-Regular", size: 20))
                }
            }
            .navigationDestination(for: ArticleModel.self) { article in
                ArticleView(url: articleManager.sharedURL ?? article.url!)
            }
        }
    }
}

extension ArticleListView {
 
}

