//
//  ArticleView.swift
//  Brief
//
//  Created by Rachel Radford on 1/24/25.
//

import SwiftUI

struct ArticleView: View {
  @Binding var articleTitle: String
  var url: URL
  
    init(
        articleTitle: Binding<String> = .constant(""),
        url: URL
    ) {
        self._articleTitle = articleTitle
        self.url = url
    }
    
  var body: some View {
    VStack {
      articleTitleView
      
      WebView(url: url)
            
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

