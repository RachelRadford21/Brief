//
//  ArticleViewModel.swift
//  Brief
//
//  Created by Rachel Radford on 1/21/25.
//

import Foundation
import SwiftData

@Observable
class ArticleViewModel {
    static let shared = ArticleViewModel()
    let context: ModelContext
    var article: ArticleModel?
    var articleTitle: String = ""
    var summary: String = ""
    
    init(
        context: ModelContext? = nil,
        article: ArticleModel? = nil
    ) {
        if let providedContext = context {
            self.context = providedContext
        } else {
            let container = try! ModelContainer(for: ArticleModel.self)
            self.context = ModelContext(container)
        }
        self.article = article
    }
    
    func saveArticle(title: String, url: URL, dateSaved: Date, articleSummary: String) {
        
        let newArticle = ArticleModel(id: UUID(), title: title, url: url, dateSaved: dateSaved, articleSummary: articleSummary)
        context.insert(newArticle)
        
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Could Not Save Article")
        }
    }
    
    func deleteArticle(id: UUID, title: String, url: URL, read: Bool, dateSaved: Date) {
        let fetchRequest = FetchDescriptor<ArticleModel>()
        
        do {
            let articles = try context.fetch(fetchRequest)
            
            if let articleToDelete = articles.first(where: { $0.title == title }) {
                context.delete(articleToDelete)
                
                if context.hasChanges {
                    try context.save()
                    print("Article deleted successfully.")
                }
                
            } else {
                print("No matching article found.")
            }
        } catch {
            print("Error fetching or deleting article: \(error.localizedDescription)")
        }
    }
    
    func fetchData() -> [ArticleModel]? {
        do {
            let descriptor = FetchDescriptor<ArticleModel>()
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching articles: \(error.localizedDescription)")
            return nil
        }
    }
}
