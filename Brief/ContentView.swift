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
    init(
        articleManager: SharedArticleManager,
        articleVM: ArticleViewModel
    ) {
        self.articleManager = articleManager
        self.articleVM = articleVM
    }
    
    
    var body: some View {
        ZStack {
            Color.paperWhite.ignoresSafeArea()
            // This view is doing a lot
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
                        .customToolbar(url: articleManager.sharedURL, buttons: [
                            ("book", { /* book action */ }),
                            ("square.and.arrow.down.on.square", {
                                articleVM.saveArticle(title: articleTitle, url: articleManager.sharedURL!, read: false, dateSaved: Date())
                                isArticleSaved = true
                            }),
                            ("trash.square", {
                                articleTitle = ""
                                articleManager.sharedURL = nil
                                articleManager.clearSharedURL()
                            })
                        ])
                } else if articleManager.sharedURL == nil {
                    ArticleListView()
                } else {
                    OpeningView()
                }
            }
            
            if isArticleSaved {
                ArticleListView()
            }
        }
    }
}

extension ContentView {
    
}


