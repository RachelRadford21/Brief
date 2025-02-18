//
//  SummarizerService.swift
//  Brief
//
//  Created by Rachel Radford on 2/1/25.
//

import Foundation
import NaturalLanguage

@Observable
class SummarizerService {
    static let shared = SummarizerService()
    private let cache = NSCache<NSString, NSString>()
    var articleVM = ArticleViewModel.shared
    var articleManager: SharedArticleManager = SharedArticleManager()
    
    private let boilerplatePatterns = [
        "contact us",
        "privacy policy",
        "terms of use",
        "all rights reserved",
        "follow us",
        "share this",
        "subscribe",
        "newsletter",
        "press release",
        "press contact",
        "cookie",
        "subscribe"
    ]
    
    private let htmlEntities = [
        "&nbsp;": " ",
        "&amp;": "&",
        "&lt;": "<",
        "&gt;": ">",
        "&quot;": "\"",
        "&#39;": "'",
        "&apos;": "'"
    ]
    
    private let extendedStopWords: Set<String> = [
        "the", "and", "is", "of", "to", "in", "that", "it", "on", "for", "with",
        "about", "menu", "search", "home", "contact", "services", "resources",
        "topics", "help", "learn", "click", "here", "read", "more"
    ]
    
    func summarize(_ html: String) -> String {
        if let cachedSummary = cache.object(forKey: html as NSString) as String? {
            return cachedSummary
        }
        

        let articleText = extractMainArticle(from: html)
        let cleanedText = cleanText(articleText)
        let processedText = preprocessText(cleanedText)
        let sentences = tokenizeText(processedText)
        let keySentences = rankSentences(sentences)
        
        let summary = keySentences.joined(separator: " ")
        
        cache.setObject(summary as NSString, forKey: html as NSString)
        return summary
    }
    
    private func extractMainArticle(from html: String) -> String {
        // First remove scripts and styles
        let cleanedHTML = html
            .replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Replace HTML entities
        var processedHTML = cleanedHTML
        for (entity, replacement) in htmlEntities {
            processedHTML = processedHTML.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Extract paragraphs
        let regex = try! NSRegularExpression(pattern: "<p.*?>(.*?)</p>", options: .dotMatchesLineSeparators)
        let matches = regex.matches(in: processedHTML, range: NSRange(processedHTML.startIndex..., in: processedHTML))
        
        let paragraphs = matches.compactMap {
            Range($0.range(at: 1), in: processedHTML).map { String(processedHTML[$0]) }
        }
        
        // Filter meaningful paragraphs
        let filteredParagraphs = paragraphs.filter {
            $0.count > 50 && !containsBoilerplate($0)
        }
        
        // Clean up remaining HTML tags and normalize whitespace
        return filteredParagraphs.joined(separator: " ")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func containsBoilerplate(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return boilerplatePatterns.contains { pattern in
            lowercasedText.contains(pattern.lowercased())
        }
    }
    
    private func cleanText(_ text: String) -> String {
        var cleanedText = text
        
        // Remove URLs
        let urlPattern = "https?://\\S+\\b|www\\.\\S+\\b"
        cleanedText = cleanedText.replacingOccurrences(of: urlPattern, with: "", options: .regularExpression)
        
        // Remove email addresses
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        cleanedText = cleanedText.replacingOccurrences(of: emailPattern, with: "", options: .regularExpression)
        
        // Remove phone numbers
        let phonePattern = "\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}"
        cleanedText = cleanedText.replacingOccurrences(of: phonePattern, with: "", options: .regularExpression)
        
        // Remove multiple spaces and newlines
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func preprocessText(_ text: String) -> String {
        let words = text.components(separatedBy: " ").filter { !extendedStopWords.contains($0.lowercased()) }
        return words.joined(separator: " ")
    }
    
    private func tokenizeText(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var sentences: [String] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range])
            if sentence.split(separator: " ").count > 3 && !isNavigationElement(sentence) {
                sentences.append(sentence)
            }
            return true
        }
        
        return sentences
    }
    
    private func isNavigationElement(_ text: String) -> Bool {
        let navigationPatterns = [
            "^menu$",
            "^home$",
            "^contact$",
            "^about$",
            "^services$",
            "^top$",
            "^bottom$"
        ]
        
        let lowercasedText = text.lowercased()
        return navigationPatterns.contains { pattern in
            lowercasedText.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    private func rankSentences(_ sentences: [String]) -> [String] {
        var scoredSentences: [(String, Double)] = []
        
        for sentence in sentences {
            let entityScore = Double(entityScore(for: sentence))
            let lengthScore = lengthScore(for: sentence)
            let positionScore = positionScore(for: sentence, in: sentences)
            
            let totalScore = (entityScore * 0.4) + (lengthScore * 0.3) + (positionScore * 0.3)
            scoredSentences.append((sentence, totalScore))
        }
        
        let topSentences = scoredSentences.sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
        
        return topSentences
    }
    
    private func entityScore(for text: String) -> Int {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var score = 0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .nameType,
                            options: [.omitPunctuation, .omitWhitespace]) { tag, _ in
            if let tag = tag, tag == .personalName || tag == .placeName || tag == .organizationName {
                score += 1
            }
            return true
        }
        
        return score
    }
    
    private func lengthScore(for sentence: String) -> Double {
        let words = sentence.split(separator: " ")
        let idealLength = 20.0
        return 1.0 - (abs(Double(words.count) - idealLength) / idealLength)
    }
    
    private func positionScore(for sentence: String, in sentences: [String]) -> Double {
        if let index = sentences.firstIndex(of: sentence) {
            return 1.0 - (Double(index) / Double(sentences.count))
        }
        return 0.0
    }
    
    func getCachedSummary(for text: String) -> String? {
           return cache.object(forKey: text as NSString) as String?
    }
    
    func extractAndTokenizeText(url: URL) {
        articleManager.fetchAndExtractText(from: url.absoluteString) { html in
            if let html = html {
                self.articleVM.summary = self.summarize(html)
                print("summary: \(self.articleVM.summary)")
                print("Summarizer: \(self.summarize(html))")
                    
            }
        }
    }
}

