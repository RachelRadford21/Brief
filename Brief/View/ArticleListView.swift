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
    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet: Bool = false
    @State private var showNotes: Bool = false
    @State private var getBriefed: Bool = false
    @State private var path = NavigationPath()
    @Query var articles: [ArticleModel]
    var articleManager: SharedArticleManager
    var articleVM: ArticleViewModel
    
    init(
        articleManager: SharedArticleManager,
        articleVM: ArticleViewModel = ArticleViewModel.shared
    ) {
        self.articleManager = articleManager
        self.articleVM = articleVM
    }
    
    var body: some View {
        articleListView
    }
}

extension ArticleListView {
    
    var articleListView: some View {
        VStack {
            if articles.isEmpty == true {
                ContentView(articleManager: articleManager)
            } else {
                navStackView
            }
        }
        .onChange(of: articles) {
            Task {
                articleVM.fetchData()
            }
        }
    }
    
    var navTitleView: Text {
        Text("ARTICLES")
            .font(.custom("Merriweather-SemiBold", size: 20))
        // This is bad but I want to customize, may change later
    }
    
    var navStackView: some View {
        NavigationStack(path: $path) {
            List(articles, id: \.id) { article in
                NavigationLink(value: article) {
                    Text(article.title)
                        .font(.custom("BarlowCondensed-Regular", size: 20))
                        .lineLimit(2)
                }
                .swipeActions {
                    swipeActionsView(article: article)
                }
                .sheet(isPresented: $getBriefed) {
                        BriefView()
                }
                .sheet(isPresented: $showShareSheet) {
                    if let url = article.url {
                        ActivityViewController(items: [url])
                    }
                }
                .sheet(isPresented: $showNotes) {
                    NotesView()
                }
            }
            .navigationTitle(navTitleView)
            .navigationDestination(for: ArticleModel.self) { article in
                ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
                    .customToolbar(url: articleManager.sharedURL, buttons: [
                        ("note.text.badge.plus", { showNotes.toggle() }),
                        ("message", { showShareSheet.toggle() }),
                        // Need to figure out why this disppears on first tap
                        ("briefcase.fill", { getBriefed.toggle() }),
                        ("trash.square", {
                            articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
                            path.removeLast()
                            
                        })
                    ])
            }
        }
        .tint(colorScheme == .dark ? Color.accent.opacity(0.7) : .black)
    }
    
    @MainActor @ViewBuilder
    func swipeActionsView(article: ArticleModel) -> some View {
        swipeActionButtonsView(name: "trash") {
            articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
        }
        
        swipeActionButtonsView(name: article.isBookmarked ? "bookmark" : "bookmark.slash") {
            article.isBookmarked.toggle()
        }
        
        swipeActionButtonsView(name: article.read ? "book.closed" : "book") {
            article.read.toggle()
        }
    }
    
    func swipeActionButtonsView(name: String, action:  @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: name)
        }
    }
}

