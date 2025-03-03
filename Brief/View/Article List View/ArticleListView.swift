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
    @Query var notes: [NoteModel]
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
    
    private func findArticle(withTitle title: String) -> ArticleModel? {
        return articles.first { $0.title == title }
    }
    
    private func findArticleByPartialTitle(_ partialTitle: String) -> ArticleModel? {
        if let match = articles.first(where: { partialTitle.starts(with: $0.title) || $0.title.starts(with: partialTitle) }) {
            return match
        }
        
        return articles.first { article in
            let words = partialTitle.components(separatedBy: " ")
            let significantWords = words.filter { $0.count > 3 }
            
            if !significantWords.isEmpty {
                return significantWords.contains { article.title.localizedCaseInsensitiveContains($0) }
            }
            
            return false
        }
    }
}

