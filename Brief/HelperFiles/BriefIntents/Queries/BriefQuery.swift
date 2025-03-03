//
//  BriefQuery.swift
//  Brief
//
//  Created by Rachel Radford on 2/25/25.
//

import Foundation
import SwiftData
import AppIntents

struct ArticleQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [BriefEntity] {
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate<ArticleModel> { article in
                identifiers.contains(article.id)
            }
        )

        let articles = try context.fetch(descriptor)

        return articles.map { BriefEntity(id: $0.id, title: $0.title, url: $0.url) }
    }

    func suggestedEntities() async throws -> [BriefEntity] {
        let container = try ModelContainer(for: ArticleModel.self)
        let context = ModelContext(container)

        let articles = try context.fetch(FetchDescriptor<ArticleModel>())

        return articles.map { BriefEntity(id: $0.id, title: $0.title, url: $0.url) }
    }
}
