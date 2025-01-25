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

    var body: some View {
        // Use NavLink
            List(articles, id: \.id) { article in
                Text(article.title)
                    .font(.custom("BarlowCondensed-Regular", size: 20))
            }
    }
}

extension ArticleListView {
  @ToolbarContentBuilder
  func toolbarContent() -> some ToolbarContent {
    ToolbarItemGroup(placement: .bottomBar) {
     
      ToolBarButtonView(buttonLabel: "book") {
        
       
      }
      
      Spacer()
    
      ToolBarButtonView(buttonLabel: "square.and.arrow.down.on.square") {
        
      }
      
      Spacer()
      
      ToolBarButtonView(buttonLabel: "trash.square") {
       
       
      }
    }
  }
}

