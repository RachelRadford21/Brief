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
  @Query var articles: [ArticleModel]
    var body: some View {
      VStack {
        List(articles, id: \.id) { article in
          Text(article.title)
        }
      }
    }
}

#Preview {
    ArticleListView()
  
}
