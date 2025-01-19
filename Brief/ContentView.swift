//
//  ContentView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    var articleManager: ArticleViewModel
    var webView: WebView?
    @State var articleTitle: String = ""
    var body: some View {
        ZStack {
            Color.paperWhite.edgesIgnoringSafeArea(.all)
        VStack {
            if let url = articleManager.sharedURL {
                Text("\(articleTitle)")
                    .padding()
                
                // WebView(url: url, title: articleTitle)
                    .onAppear {
                        articleManager.fetchArticleTitle(from: url) { title in
                            articleTitle = title ?? "No Title"
                        }
                    }
            } else {
                OpeningView()
            }
        }
        .padding()
    }
    }
}

