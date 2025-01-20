//
//  ContentView.swift
//  Brief
//
//  Created by Rachel Radford on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    var articleManager: ArticleViewModel
    @State var articleTitle: String = ""
    
    var body: some View {
        ZStack {
            Color.paperWhite.edgesIgnoringSafeArea(.all)
            VStack {
                if let url = articleManager.sharedURL {
                    
                    articleTitleView
                  
                    WebView(url: url)
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                // This could be book  open when it needs to be read and closed when read
                                ToolBarButtonView(buttonLabel: "book") {
                                    
                                }
                                
                                Spacer()
                                // This could be this until saved and the a checkmark??
                                ToolBarButtonView(buttonLabel: "square.and.arrow.down.on.square") {
                                    
                                }
                                
                                Spacer()
                                ToolBarButtonView(buttonLabel: "trash.square") {
                                  
                                }
                            }
                        }
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

extension ContentView {
    var articleTitleView: some View {
        Text(articleTitle)
            .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
            .padding()
    }
}
