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
    
    private struct Patterns {
        static let boilerplate = [
            "contact us", "privacy policy", "terms of use", "all rights reserved",
            "follow us", "share this", "subscribe", "newsletter", "press release",
            "press contact", "cookie"
        ]
        
        static let mediaPatterns = MediaPatterns()
        
        static let navigation = [
            "^menu$", "^home$", "^contact$", "^about$",
            "^services$", "^top$", "^bottom$"
        ]
        
        static let htmlTags = [
            "<script[^>]*>[\\s\\S]*?</script>",
            "<style[^>]*>[\\s\\S]*?</style>",
            "<img[^>]*>",
            "<figure[^>]*>[\\s\\S]*?</figure>",
            "<video[^>]*>[\\s\\S]*?</video>",
            "<iframe[^>]*>[\\s\\S]*?</iframe>",
            "<div[^>]*(?:video|player|media)[^>]*>[\\s\\S]*?</div>"
        ]
    }
    
    private struct MediaPatterns {
        let imageCaption = [
            "Photo:", "Image:", "Credit:", "Source:",
            "Photo by", "Image courtesy of", "PHOTO:", "IMAGE:"
        ]
        
        let imageMarkup = [
            "\\[image\\].*?\\[/image\\]",
            "\\{image\\}.*?\\{/image\\}",
            "\\[caption\\].*?\\[/caption\\]"
        ]
        
        let video = [
            "(?:Video|Watch): [^.]+\\.",
            "\\[(?:Video|Watch)\\].*?\\[/(?:Video|Watch)\\]",
            "Watch the video below.*?\\.",
            "Watch the full video.*?\\.",
            "Click to play the video.*?\\.",
            "\\d+:\\d+ video shows.*?\\.",
            "The video above shows.*?\\.",
            "\\d+:\\d+\\s*-\\s*\\d+:\\d+",
            "\\[\\d+:\\d+\\]",
            "Video (?:credit|courtesy of|by).*?\\."
        ]
        
        let videoKeywords = [
            "in this video", "watch as", "this clip shows",
            "the footage shows", "video player", "play button",
            "video thumbnail"
        ]
    }
    
    private let htmlEntities: [String: String] = [
        "&nbsp;": " ", "&amp;": "&", "&lt;": "<",
        "&gt;": ">", "&quot;": "\"", "&#39;": "'",
        "&apos;": "'"
    ]
    
    private let extendedStopWords: Set<String> = [
        "the", "and", "is", "of", "to", "in", "that", "it",
        "on", "for", "with", "about", "menu", "search", "home",
        "contact", "services", "resources", "topics", "help",
        "learn", "click", "here", "read", "more"
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
    
    func getCachedSummary(for text: String) -> String? {
        return cache.object(forKey: text as NSString) as String?
    }
    
    func extractAndTokenizeText(url: URL) {
        articleManager.fetchAndExtractText(from: url.absoluteString) { [weak self] html in
            guard let self = self, let html = html else { return }
            self.articleVM.summary = self.summarize(html)
        }
    }
    
    
    private func extractMainArticle(from html: String) -> String {
        // Remove unwanted HTML tags
        let cleanedHTML = Patterns.htmlTags.reduce(html) { text, pattern in
            text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // Replace HTML entities
        let processedHTML = htmlEntities.reduce(cleanedHTML) { text, entity in
            text.replacingOccurrences(of: entity.key, with: entity.value)
        }
        
        // Extract and filter paragraphs
        let regex = try! NSRegularExpression(pattern: "<p.*?>(.*?)</p>", options: .dotMatchesLineSeparators)
        let matches = regex.matches(in: processedHTML, range: NSRange(processedHTML.startIndex..., in: processedHTML))
        
        let paragraphs = matches.compactMap {
            Range($0.range(at: 1), in: processedHTML).map { String(processedHTML[$0]) }
        }
        
        return paragraphs
            .filter { paragraph in
                paragraph.count > 50 &&
                !containsBoilerplate(paragraph) &&
                !containsImageCaption(paragraph)
            }
            .joined(separator: " ")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cleanText(_ text: String) -> String {
        // First remove duplicated paragraphs
        let paragraphs = text.components(separatedBy: ". ")
        var seenParagraphs = Set<String>()
        let uniqueParagraphs = paragraphs.filter { paragraph in
            let normalized = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                                    .lowercased()
                                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            return seenParagraphs.insert(normalized).inserted
        }
        let cleanedText = uniqueParagraphs.joined(separator: ". ")
        
        // Then apply all the other cleaners
        let cleaners: [(String, String)] = [
            // URLs
            ("https?://\\S+\\b|www\\.\\S+\\b", ""),
            // Email addresses
            ("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", ""),
            // Phone numbers
            ("\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}", ""),
            // Image/video parentheticals
            ("\\([^)]*(?:photo|image|picture|pic|figure|illustration)[^)]*\\)", ""),
            // Photo credits
            ("(?:Photo|Image)(?:\\s+credit|\\s+by|\\s+courtesy)[^\\n.]+", ""),
            // Multiple spaces
            ("\\s+", " ")
        ]
        
        return cleaners.reduce(cleanedText) { partialResult, cleaner in
            partialResult.replacingOccurrences(
                of: cleaner.0,
                with: cleaner.1,
                options: .regularExpression
            )
        }
    }
    
    private func preprocessText(_ text: String) -> String {
        return text.components(separatedBy: " ")
            .filter { !extendedStopWords.contains($0.lowercased()) }
            .joined(separator: " ")
    }
    
    private func tokenizeText(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        return tokenizer.tokens(for: text.startIndex..<text.endIndex)
            .map { String(text[$0]) }
            .filter { sentence in
                sentence.split(separator: " ").count > 3 &&
                !isNavigationElement(sentence)
            }
    }
    
    private func rankSentences(_ sentences: [String]) -> [String] {
        // Create set to track unique sentences
        var uniqueSentences = Set<String>()
        var scoredSentences: [(String, Double)] = []
        
        for sentence in sentences {
            // Normalize sentence for comparison
            let normalizedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                                           .lowercased()
                                           .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            // Skip if we've seen this sentence before
            guard !uniqueSentences.contains(normalizedSentence) else { continue }
            uniqueSentences.insert(normalizedSentence)
            
            // Regular scoring logic
            let entityScore = Double(computeEntityScore(for: sentence))
            let lengthScore = computeLengthScore(for: sentence)
            let positionScore = computePositionScore(for: sentence, in: sentences)
            
            let totalScore = (entityScore * 0.4) + (lengthScore * 0.3) + (positionScore * 0.3)
            scoredSentences.append((sentence, totalScore))
        }
        
        // Get top 3 unique sentences
        return scoredSentences
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
    }
    
    private func containsBoilerplate(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return Patterns.boilerplate.contains { lowercasedText.contains($0) }
    }
    
    private func containsImageCaption(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return Patterns.mediaPatterns.imageCaption.contains { lowercasedText.contains($0.lowercased()) }
    }
    
    private func isNavigationElement(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return Patterns.navigation.contains { pattern in
            lowercasedText.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    private func computeEntityScore(for text: String) -> Int {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var score = 0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .nameType,
                             options: [.omitPunctuation, .omitWhitespace]) { tag, _ in
            if let tag = tag,
               [.personalName, .placeName, .organizationName].contains(tag) {
                score += 1
            }
            return true
        }
        return score
    }
    
    private func computeLengthScore(for sentence: String) -> Double {
        let words = sentence.split(separator: " ")
        let idealLength = 20.0
        return 1.0 - (abs(Double(words.count) - idealLength) / idealLength)
    }
    
    private func computePositionScore(for sentence: String, in sentences: [String]) -> Double {
        guard let index = sentences.firstIndex(of: sentence) else { return 0.0 }
        return 1.0 - (Double(index) / Double(sentences.count))
    }
}
