//
//  ArticlesManager.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 18.04.2024.
//

import Foundation

protocol ArticlesManagerDelegate {
    func didUpdateArticles(_ articles: ArticlesModel)
    func didFailWithError(error: Error)
}

struct ArticlesManager {
    var delegate: ArticlesManagerDelegate?
    
    func fetchArticles(text: String, email: String, authToken: String) {
        let urlString = "\(Constants.Networking.baseURL)/predict/"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["text": text, "email": email]
            
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Failed to encode request body: \(error)")
            return
        }
            
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to perform request: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error)
                }
                return
            }
                
            if let safeData = data, let articles = self.parseJSON(articleData: safeData) {
                DispatchQueue.main.async {
                    self.delegate?.didUpdateArticles(articles)
                }
            }
        }
        task.resume()
    }
    
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to perform request: \(error)")
                    return
                }
                
                if let safeData = data {
                    if let articles = self.parseJSON(articleData: safeData) {
                        DispatchQueue.main.async {
                            self.delegate?.didUpdateArticles(articles)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(articleData: Data) -> ArticlesModel? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(ArticlesData.self, from: articleData)
                let articles = ArticlesModel(articles: decodedData.articles.map { ArticleModel(id: String($0.id) , title: $0.title, url: $0.url) })
                print(articles)
                return articles
            } catch {
                print("Error decoding data: \(error)")
                return nil
            }
    }
    

}

