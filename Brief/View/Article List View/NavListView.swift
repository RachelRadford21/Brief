//
//  NavListView.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import SwiftUI
import SwiftData

struct NavListView: View {
    @Environment(\.modelContext) var context
    @State var articleVM: ArticleViewModel = ArticleViewModel.shared
    @Query var articles: [ArticleModel]

    var body: some View {
        navListView
    }
}

extension NavListView {
    
    var navListView: some View {
        List(articles, id: \.id) { article in
            NavigationLink(value: article) {
                Text(article.title)
                    .font(.custom("BarlowCondensed-Regular", size: 20))
                    .frame(height: 50)
                    .lineLimit(2)
            }
            .swipeActions {
                swipeActionsView(article: article)
            }
            .sheet(isPresented: $articleVM.getBriefed) {
                BriefView()
            }
            .sheet(isPresented: $articleVM.showShareSheet) {
                if let url = article.url {
                    ActivityViewController(items: [url])
                }
            }
            .sheet(isPresented: $articleVM.showNotes) {
                NotesView()
            }
        }
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
