//
//  ArticleViewModel.swift
//  Bridge
//
//  Created by Rachel Radford on 1/18/25.
//
import Observation
import Social

@Observable
class ArticleViewModel {
   var sharedURL: URL?

    func loadSharedURL() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
        if let urlString = sharedDefaults?.string(forKey: "sharedURL"),
           let url = URL(string: urlString) {
            print("Retrieved URL: \(url.absoluteString)")
            sharedURL = url
        }
    }
    
    func fetchArticleTitle(from url: URL, completion: @escaping (String?) -> Void) {
    
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching HTML: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, let htmlContent = String(data: data, encoding: .utf8) else {
                print("Failed to decode HTML content")
                completion(nil)
                return
            }

            if let title = self.parseTitle(from: htmlContent) {
                completion(title)
            } else {
                print("No title found in HTML")
                completion(nil)
            }
        }
        .resume()
    }

    func parseTitle(from html: String) -> String? {

        guard let startRange = html.range(of: "<title>"),
              let endRange = html.range(of: "</title>") else {
            return nil
        }

        let title = html[startRange.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        return title
    }
    
    func clearSharedURL() {
           let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
           sharedDefaults?.removeObject(forKey: "sharedURL")
       }
  func saveArticleLocally(content: String, fileName: String) {
      let fileManager = FileManager.default
      let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURL = documentsDirectory.appendingPathComponent("\(fileName).txt")

      do {
          try content.write(to: fileURL, atomically: true, encoding: .utf8)
          print("Article saved at \(fileURL)")
      } catch {
          print("Error saving article: \(error.localizedDescription)")
      }
}
    
}
