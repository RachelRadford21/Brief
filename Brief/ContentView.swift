//
//  ContentView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct ContentView: View {
  @State var isArticleSaved: Bool = false
  @State var articleTitle: String = ""
  var articleManager: SharedArticleManager
  var articleVM: ArticleViewModel
  
  var body: some View {
    ZStack {
      Color.paperWhite.ignoresSafeArea()
      
      VStack {
        articleTitleView
        if let url = articleManager.sharedURL {
          WebView(url: url)
              .toolbar {
                toolbarItemGroup(url: url)
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
                isArticleSaved = false
                
              }
        }
        else {
          OpeningView()
        }
      }
      .padding()
      .opacity(isArticleSaved ? 0 : 1)
      
      if isArticleSaved {
        ArticleListView()
        
      }
    }
  }
}

extension ContentView {
  var articleTitleView: some View {
      Text(articleTitle)
          .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
          .padding()
  }
  @ToolbarContentBuilder
  func toolbarItemGroup(url: URL) -> some ToolbarContent {
          ToolbarItemGroup(placement: .bottomBar) {
            // This could be an closed book when unread && open book when read. Or opposite, idk
              ToolBarButtonView(buttonLabel: "book") {
                  // Book action
              }
              
              Spacer()
              // sqare then checkmark?? idk
              ToolBarButtonView(buttonLabel: "square.and.arrow.down.on.square") {
                  articleVM.saveArticle(title: articleTitle, url: url, read: false, dateSaved: Date())
                  isArticleSaved = true
              }
              
              Spacer()
              
              ToolBarButtonView(buttonLabel: "trash.square") {
                  // Trash action
              }
          }
      }
}


