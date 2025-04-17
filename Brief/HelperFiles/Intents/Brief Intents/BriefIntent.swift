//
//  BriefIntent.swift
//  Brief
//
//  Created by Rachel Radford on 2/24/25.
//

import AppIntents
import SwiftData
import SwiftUI

struct BriefIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Article"
    static var description: IntentDescription = IntentDescription(
        "Opens a saved article in the app",
        categoryName: "Articles",
        searchKeywords: ["article", "read", "open", "view", "saved"]
    )
    
    @Parameter(title: "Article")
    var title: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$title)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog  {
        print("BriefIntent activated: Looking for article '\(title)'")
        
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container) // Ensure it's on the main thread
        
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate<ArticleModel> { article in
                article.title.contains(title) ||
                article.title == title
            }
        )
        
        let articles = try context.fetch(descriptor)
        
        guard let article = articles.first else {
            return .result(dialog: "No article found with title '\(title)'.")
        }
        
        let urlString = "brief://article/\(article.id)"
        
        if let url = URL(string: urlString) {
            await MainActor.run {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            UserDefaults.standard.set(true, forKey: "BriefIntent_ShouldOpenURL")
            UserDefaults.standard.set(urlString, forKey: "BriefIntent_URLToOpen")
            
            return .result(dialog: "Opening article: \(article.title)")
            
        } else {
            
            return .result(dialog: "Could not create URL from: \(urlString)")
        }
    }
}

// Siri suggestions
struct ArticleOptionsProvider: DynamicOptionsProvider {
    @MainActor
    func results() async throws -> [String] {
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)
        let articles = try context.fetch(FetchDescriptor<ArticleModel>())
        
        return articles.map { $0.title }
    }
}

