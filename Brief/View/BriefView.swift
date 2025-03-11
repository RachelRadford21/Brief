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
    
    init(
        articleManager: SharedArticleManager = SharedArticleManager()
    ) {
        self.articleManager = articleManager
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                TitleView(title: "Brief")
                Text(articleVM.summary)
                    .font(.custom("BarlowCondensed-Regular", size: 25))
            }
            .padding()
        }
    }
}

#Preview {
    BriefView(articleManager: SharedArticleManager())
}
