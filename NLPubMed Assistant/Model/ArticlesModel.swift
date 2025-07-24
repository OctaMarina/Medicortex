//
//  ArticlesModel.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 18.04.2024.
//

import Foundation

struct ArticlesModel {
    let articles: [ArticleModel]
}

struct ArticleModel {
    let id: String
    let title: String
    let url: String
}
