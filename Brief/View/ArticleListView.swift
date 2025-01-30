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
  @State private var isBookmarked: Bool = false
  @Query var articles: [ArticleModel]
  var articleManager: SharedArticleManager
  var articleVM: ArticleViewModel
  
  init(
    articleManager: SharedArticleManager = SharedArticleManager(),
    articleVM: ArticleViewModel = ArticleViewModel()
  ) {
    self.articleManager = articleManager
    self.articleVM = articleVM
  }
  
  var body: some View {
    NavigationStack {
      
      List(articles, id: \.id) { article in
        NavigationLink(value: article) {
          Text(article.title)
            .font(.custom("BarlowCondensed-Regular", size: 20))
        }
        .swipeActions {
          swipeActionButtonsView(name: "trash") {
            articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
          }
          
          swipeActionButtonsView(name: article.isBookmarked ? "bookmark" : "bookmark.slash") {
            article.isBookmarked.toggle()
            print("******************")
            print("\(article.title)")
            print("bookmark: \(article.isBookmarked)")
            print("******************")
          }
          
          swipeActionButtonsView(name: article.read ? "book.closed" : "book") {
            article.read.toggle()
            print("******************")
            print("\(article.title)")
            print("\(article.read)")
            print("******************")
          }
        }
      }
      .navigationTitle(navTitleView)
      .navigationDestination(for: ArticleModel.self) { article in
        ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
          .customToolbar(url: articleManager.sharedURL, buttons: [
            (article.read ? "book.closed" : "book", { /* book action */ }),
            (article.isBookmarked ? "bookmark.fill" : "bookmark", { /* book action */ }),
            ("briefcase.fill", { }),
            ("trash.square", { })
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
  
  func swipeActionButtonsView(name: String, action:  @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      Image(systemName: name)
        .foregroundStyle(isBookmarked ? Color.blue : Color.white)
    }
    
  }
}
