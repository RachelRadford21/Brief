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
    var sharedURL: URL?
    
    init(
        sharedURL: URL? = nil
    ) {
        self.sharedURL = sharedURL
    }
    
    func loadSharedURL() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
        if let urlString = sharedDefaults?.string(forKey: "sharedURL"),
           let url = URL(string: urlString) {
            print("Retrieved URL: \(url.absoluteString)")
            sharedURL = url
        }
    }
    
    func clearSharedURL() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
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
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityController, animated: true)
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
        
        if let title = parseTitle(from: htmlContent) {
            return title
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func extractMainArticle(from html: String) -> String {
        let cleanedHTML = html
            .replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        let regex = try! NSRegularExpression(pattern: "<p.*?>(.*?)</p>", options: .dotMatchesLineSeparators)
        let matches = regex.matches(in: cleanedHTML, range: NSRange(cleanedHTML.startIndex..., in: cleanedHTML))
        
        let paragraphs = matches.compactMap {
            Range($0.range(at: 1), in: cleanedHTML).map { String(cleanedHTML[$0]) }
        }
        
        let filteredParagraphs = paragraphs.filter {
            $0.count > 50 && !$0.lowercased().contains("cookie") && !$0.lowercased().contains("subscribe")
        }
        
        let articleText = filteredParagraphs.joined(separator: " ")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return articleText
    }
    
    func fetchAndExtractText(from url: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: url), url.scheme == "https" else {
            completion(nil)
            return
        }
//        guard let url = URL(string: url) else {
//            completion(nil)
//            return
//        }
        
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
