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
    @State var isArticleSaved: Bool = false
    @State var articleTitle: String = ""
    var articleManager: SharedArticleManager
    var articleVM: ArticleViewModel
    // Use later? If user posts multiple article then use diff view?
    let descriptor = FetchDescriptor<ArticleModel>()
    
    var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            
            NavigationStack {
                if let url = articleManager.sharedURL {
                    ArticleView(articleTitle: $articleTitle, url: url)
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
                            print("\(String(describing: try? context.fetchCount(descriptor)))")
                        }
                } else {
                    OpeningView()
                }
            }
            .toolbar {
                if let url = articleManager.sharedURL {
                    toolbarContent(url: url)
                }
            }
            
            if isArticleSaved {
                ArticleListView()
            }
        }
    }
}

extension ContentView {
    
    @ToolbarContentBuilder
    func toolbarContent(url: URL) -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            
            ToolBarButtonView(buttonLabel: "book") {
            }
            
            Spacer()
            
            ToolBarButtonView(buttonLabel: "square.and.arrow.down.on.square") {
                articleVM.saveArticle(title: articleTitle, url: url, read: false, dateSaved: Date())
                isArticleSaved = true
            }
            
            Spacer()
            
            ToolBarButtonView(buttonLabel: "trash.square") {
                
                isArticleSaved = false
            }
        }
    }
}


