//
//  BriefView.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import SwiftUI

struct BriefView: View {
    @Bindable var articleVM = ArticleViewModel.shared
    var summarizer = SummarizerService.shared
    var articleManager: SharedArticleManager
    var article: ArticleModel?
    init(
        articleManager: SharedArticleManager = SharedArticleManager(),
        article: ArticleModel? = ArticleModel(title: "")
    ) {
        self.articleManager = articleManager
        self.article = article
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                TitleView(title: "Brief")
                Text(article?.articleSummary ?? "Loading...")
                    .font(.custom("BarlowCondensed-Regular", size: 25))
            }
            .padding()
        }
    }
}

#Preview {
    BriefView(articleManager: SharedArticleManager())
}
