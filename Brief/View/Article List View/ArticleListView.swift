//
//  ArticleListView.swift
//  Brief
//
//  Created by Rachel Radford on 1/21/25.
//

import SwiftUI
import SwiftData

struct ArticleListView: View {
    @Environment(\.modelContext) var context
    @Query var articles: [ArticleModel]
    var articleVM: ArticleViewModel
    var articleManager: SharedArticleManager
    
    init(
        articleManager: SharedArticleManager,
        articleVM: ArticleViewModel = ArticleViewModel.shared
    ) {
        self.articleManager = articleManager
        self.articleVM = articleVM
    }
    
    var body: some View {
        articleListView
    }
}

extension ArticleListView {
    var articleListView: some View {
        VStack {
            if articles.isEmpty == true {
                ContentView(articleManager: articleManager)
            } else {
                NavStackView(articleManager: articleManager)
            }
        }
        .onChange(of: articles) {
            Task {
                articleVM.fetchData()
            }
        }
    }
}
