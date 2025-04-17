//
//  BriefView.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import SwiftUI

struct BriefView: View {
    var article: ArticleModel?
    
    init(
        article: ArticleModel? = ArticleModel(title: "")
    ) {
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

