//
//  ContentView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//
import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) var context
  @State var articleTitle: String = ""
  var articleManager: SharedArticleManager
  var articleVM: ArticleViewModel
  let descriptor = FetchDescriptor<ArticleModel>()
  
  init(
    articleManager: SharedArticleManager,
    articleVM: ArticleViewModel
  ) {
    self.articleManager = articleManager
    self.articleVM = articleVM
  }
  
  var body: some View {
    contentView
  }
}

extension ContentView {
  var contentView: some View {
    ZStack {
      Color.paperWhite.ignoresSafeArea()
      openingView
      articleView
      listView
    }
  }
  
  @ViewBuilder
  var articleView: some View {
    if let url = articleManager.sharedURL {
      ArticleView(
        articleTitle: $articleTitle,
        articleManager: articleManager,
        url: url
      )
      .customToolbar(url: articleManager.sharedURL, buttons: [
        ("message", { articleManager.shareArticle() }),
        ("arrow.down.document", {
          articleVM.saveArticle(
            title: articleTitle,
            url: articleManager.sharedURL!,
            dateSaved: Date()
          )
          articleManager.sharedURL = nil
          articleManager.clearSharedURL()
        }),
        ("trash.square", {
          articleTitle = ""
          articleManager.sharedURL = nil
          articleManager.clearSharedURL()
        })
      ])
    }
  }
  
  @ViewBuilder
  var openingView: some View {
    let results = try? context.fetch(descriptor)
    if results?.isEmpty == true && articleManager.sharedURL == nil {
      OpeningView()
    }
  }
  
  @ViewBuilder
  var listView: some View {
    let results = try? context.fetch(descriptor)
    if (results?.isEmpty == false) && articleManager.sharedURL == nil {
       ArticleListView()
    }
  }
}


