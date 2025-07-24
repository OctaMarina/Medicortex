//
//  ArticlesData.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 18.04.2024.
//

import Foundation

struct ArticlesData: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let url: String
    let id: String
}
