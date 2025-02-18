//
//  BriefView.swift
//
//
//  Created by Rachel Radford on 2/17/25.
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
            VStack(alignment: .center) {
                Text("Brief")
                    .font(.custom("MerriweatherSans-VariableFont_Wght", size: 40).bold())
                Text(articleVM.summary)
                    .font(.custom("BarlowCondensed-Regular", size: 25))
            }
            .padding()
        }
    }
}

extension BriefView {

}

#Preview {
    BriefView(articleManager: SharedArticleManager())
}
