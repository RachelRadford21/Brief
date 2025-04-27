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
    
    static var openAppWhenRun: Bool {
        return true
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("BriefIntent activated: Looking for article '\(title)'")
        
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)
        
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

        UserDefaults(suiteName: "group.com.brief.app")?.set(article.id.uuidString, forKey: "SiriRequestedArticleID")
        
        return .result(
            dialog: "Opening article: \(article.title)"
        )
    }
}


