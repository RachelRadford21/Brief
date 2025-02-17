//
//  SharedArticleViewModel.swift
//  Bridge
//
//  Created by Rachel Radford on 1/18/25.
//
import Observation
import Social

@Observable
class SharedArticleManager {
    private let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
    var sharedURL: URL?

    init(
        sharedURL: URL? = nil
    ) {
        self.sharedURL = sharedURL
    }
   
    func loadSharedURL() {
        if let urlString = sharedDefaults?.string(forKey: "sharedURL"),
           let url = URL(string: urlString) {
            print("Retrieved URL: \(url.absoluteString)")
            sharedURL = url
        }
    }
    
    func clearSharedURL() {
        if sharedDefaults?.string(forKey: "sharedURL") != nil {
            sharedDefaults?.removeObject(forKey: "sharedURL")
            print("Shared URL cleared.")
        } else {
            print("No shared URL to clear.")
        }
    }
    
    func saveArticleLocally(content: String, fileName: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sanitizedFileName = fileName.replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "", options: .regularExpression)
        let fileURL = documentsDirectory.appendingPathComponent("\(sanitizedFileName).txt")
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Article saved at \(fileURL)")
        } catch {
            print("Error saving article: \(error.localizedDescription)")
        }
    }
    
    func shareArticle() {
        let text = "Check out this article"
    
        guard let urlString = sharedURL?.absoluteString,
              let url = URL(string: urlString) else {
            print("Invalid or missing URL")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityController, animated: true)
            }
        }
    }
}

extension SharedArticleManager {
    //MARK: HTML PARSERS
    func parseTitle(from html: String) -> String? {
        guard let startRange = html.range(of: "<title>"),
              let endRange = html.range(of: "</title>") else {
            return nil
        }
        
        let title = html[startRange.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        return title
    }
    
    func fetchArticleTitle(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let htmlContent = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        if var title = parseTitle(from: htmlContent) {
            title = title
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#39;", with: "'")
                .replacingOccurrences(of: "&apos;", with: "'")
        
            title = title.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return title
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func fetchAndExtractText(from url: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: url), url.scheme == "https" else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            completion(html)
        }
        task.resume()
    }
}
