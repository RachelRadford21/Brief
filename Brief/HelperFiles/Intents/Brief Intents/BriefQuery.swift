//
//  BriefQuery.swift
//  Brief
//
//  Created by Rachel Radford on 2/25/25.
//

import Foundation
import SwiftData
import AppIntents


struct BriefQuery: EntityQuery {
    typealias Entity = BriefEntity
   
    func entities(for identifiers: [UUID]) async throws -> [BriefEntity] {
        let uuids = identifiers.compactMap { UUID(uuidString: $0.uuidString) }
     
        let viewModel = ArticleViewModel.shared
        guard let articles = viewModel.fetchData() else { return [] }
       
        let filteredArticles = articles.filter { article in
            uuids.contains(article.id)
        }
        
        return filteredArticles.map { article in
            BriefEntity(
                id: article.id,
                title: article.title,
                url: article.url
            )
        }
    }
    
   
    func suggestedEntities() async throws -> [BriefEntity] {
               let viewModel = ArticleViewModel.shared
               guard let articles = viewModel.fetchData() else { return [] }
    
               // Return the most recent 5 articles for suggestions
               let sortedArticles = articles.sorted { $0.dateSaved > $1.dateSaved }
               let recentArticles = Array(sortedArticles.prefix(5))
    
               // Convert to BriefEntity
               return recentArticles.map { article in
                   BriefEntity(
                       id: article.id,
                       title: article.title,
                       url: article.url
                   )
               }
           }
}
