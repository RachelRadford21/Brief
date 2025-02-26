//
//  BriefIntent.swift
//  Brief
//
//  Created by Rachel Radford on 2/24/25.
//

import Foundation
import AppIntents
import SwiftData



struct BriefIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Article"
    static var description = IntentDescription("Opens a saved article in the app.")
    
    @Parameter(title: "Article Title", optionsProvider: ArticleOptionsProvider())
    var title: String
    
    @Parameter(title: "Article URL")
    var url: String

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$title)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("BriefIntent activated: Looking for article '\(title)'")

        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate<ArticleModel> { article in
                article.title.contains(title)
            }
        )

        let articles = try context.fetch(descriptor)

        guard let article = articles.first else {
            return .result(dialog: "No article found with title '\(title)'.")
        }

        if article.url != nil {
            return .result(
                dialog: "Opening \(article.title)..."
                
            )
        } else {
            return .result(dialog: "\(article.title) has no URL.")
        }
    }
}

struct ArticleOptionsProvider: DynamicOptionsProvider {
    @MainActor
    func results() async throws -> [String] {
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)
        let articles = try context.fetch(FetchDescriptor<ArticleModel>())

        return articles.map { $0.title }
    }
}

