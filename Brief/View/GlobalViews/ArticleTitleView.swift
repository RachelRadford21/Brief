//
//  ArticleTitleView.swift
//  Brief
//
//  Created by Rachel Radford on 1/30/25.
//

import SwiftUI

struct ArticleTitleView: View {
    @State var articleVM = ArticleViewModel.shared
    
    var body: some View {
        Text(articleVM.articleTitle)
            .font(.custom("MerriweatherSans-VariableFont_wght", size: 18))
            .padding()
    }
}


