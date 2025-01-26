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
            List(articles, id: \.id) { article in
                NavigationLink(value: article) {
                    Text(article.title)
                        .font(.custom("BarlowCondensed-Regular", size: 20))
                }
            }
            .navigationTitle(navTitleView)
            .navigationDestination(for: ArticleModel.self) { article in
                ArticleView(articleManager: articleManager, url: articleManager.sharedURL ?? article.url!)
                    .customToolbar(url: articleManager.sharedURL, buttons: [
                        ("book", { /* book action */ }),
                        ("square.and.arrow.down.on.square", {
//                            articleVM.saveArticle(
//                                title: articleTitle,
//                                url: articleManager.sharedURL!,
//                                read: false,
//                                dateSaved: Date()
//                            )
//                            isArticleSaved = true
                        }),
                        ("trash.square", {
//                            articleTitle = ""
//                            articleManager.sharedURL = nil
//                            articleManager.clearSharedURL()
                        })
                    ])
            }
        }
        .tint(Color.black)
    }
}

extension ArticleListView {
    var navTitleView: Text {
        Text("ARTICLES")
            .font(.custom("Merriweather-SemiBold", size: 20))
            // This is bad but I want to customize, may change later
    }
}

