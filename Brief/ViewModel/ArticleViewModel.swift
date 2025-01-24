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
  let context: ModelContext
  var orders: [ArticleModel] = []
  
  init(
    context: ModelContext? = nil
  ) {
    if let providedContext = context {
      self.context = providedContext
    } else {
      let container = try! ModelContainer(for: ArticleModel.self)
      self.context = ModelContext(container)
    }
  }
  
  func saveArticle(title: String, url: URL, read: Bool, dateSaved: Date) {
    
    let newArticle = ArticleModel(id: UUID(), title: title, url: url, read: read, dateSaved: dateSaved)
    
    context.insert(newArticle)
    
    do {
      if context.hasChanges {
        try context.save()
      }
    } catch {
      print("Could Not Save Article")
    }
  }
}
