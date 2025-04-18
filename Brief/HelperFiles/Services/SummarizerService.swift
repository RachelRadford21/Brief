//
//  SummarizerService.swift
//  Brief
//
//  Created by Rachel Radford on 2/1/25.
//

import Foundation
import NaturalLanguage
import WebKit

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
            "press contact", "cookie", "sign up", "login", "register"
        ]
        
        static let mediaPatterns = MediaPatterns()
        
        static let navigation = [
            "^menu$", "^home$", "^contact$", "^about$",
            "^services$", "^top$", "^bottom$", "^page$", "^next$", "^previous$"
        ]
        
        static let htmlTags = [
            "<script[^>]*>[\\s\\S]*?</script>",
            "<style[^>]*>[\\s\\S]*?</style>",
            "<img[^>]*>",
            "<figure[^>]*>[\\s\\S]*?</figure>",
            "<video[^>]*>[\\s\\S]*?</video>",
            "<iframe[^>]*>[\\s\\S]*?</iframe>",
            "<div[^>]*(?:video|player|media|sidebar|comment|footer|header|menu|nav)[^>]*>[\\s\\S]*?</div>",
            "<nav[^>]*>[\\s\\S]*?</nav>",
            "<footer[^>]*>[\\s\\S]*?</footer>",
            "<header[^>]*>[\\s\\S]*?</header>",
            "<aside[^>]*>[\\s\\S]*?</aside>"
        ]
    }
    
    private struct MediaPatterns {
        let imageCaption = [
            "Photo:", "Image:", "Credit:", "Source:",
            "Photo by", "Image courtesy of", "PHOTO:", "IMAGE:",
            "Caption:", "Figure:", "Illustration:"
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
        "&apos;": "'", "&mdash;": "—", "&ndash;": "–",
        "&hellip;": "...", "&lsquo;": "'", "&rsquo;": "'",
        "&ldquo;": "", "&rdquo;": ""
    ]
    
    private let extendedStopWords: Set<String> = [
        "the", "and", "is", "of", "to", "in", "that", "it",
        "on", "for", "with", "about", "menu", "search", "home",
        "contact", "services", "resources", "topics", "help",
        "learn", "click", "here", "read", "more", "said", "says",
        "told", "according", "reported", "stated", "explained"
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
        let cleanedHTML = removeUnwantedTags(from: html)
        
        let processedHTML = replaceHTMLEntities(in: cleanedHTML)

        let paragraphs = extractParagraphs(from: processedHTML)
  
        return paragraphs
            .filter { paragraph in
                let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.count > 50 &&
                       !containsBoilerplate(trimmed) &&
                       !containsImageCaption(trimmed)
            }
            .joined(separator: " ")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func removeUnwantedTags(from html: String) -> String {
        let combinedPattern = Patterns.htmlTags.joined(separator: "|")
        let regex = try? NSRegularExpression(pattern: combinedPattern, options: .dotMatchesLineSeparators)
        
        let nsString = html as NSString
        let mutableString = NSMutableString(string: nsString)
        
        if let regex = regex {
            let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))

            for match in matches.reversed() {
                mutableString.replaceCharacters(in: match.range, with: "")
            }
        }
        
        return mutableString as String
    }
    
    private func replaceHTMLEntities(in text: String) -> String {
        return htmlEntities.reduce(text) { result, entity in
            result.replacingOccurrences(of: entity.key, with: entity.value)
        }
    }
    
    private func extractParagraphs(from html: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: "<p.*?>(.*?)</p>", options: .dotMatchesLineSeparators)
        guard let regex = regex else { return [] }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))
        
        return matches.compactMap { match -> String? in
            guard match.numberOfRanges > 1 else { return nil }
            return nsString.substring(with: match.range(at: 1))
        }
    }
    
    private func cleanText(_ text: String) -> String {
        let paragraphs = text.components(separatedBy: ". ")
        var seenParagraphs = Set<String>()
        let uniqueParagraphs = paragraphs.filter { paragraph in
            let normalized = normalizeSentence(paragraph)
            return seenParagraphs.insert(normalized).inserted
        }
        let cleanedText = uniqueParagraphs.joined(separator: ". ")
        
        let cleaners: [(String, String)] = [
            ("https?://\\S+\\b|www\\.\\S+\\b", ""),
            ("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", ""),
            ("\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}", ""),
            ("\\([^)]*(?:photo|image|picture|pic|figure|illustration)[^)]*\\)", ""),
            ("(?:Photo|Image)(?:\\s+credit|\\s+by|\\s+courtesy)[^\\n.]+", ""),
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
    
    private func normalizeSentence(_ sentence: String) -> String {
        return sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                       .lowercased()
                       .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    private func preprocessText(_ text: String) -> String {
        let words = text.components(separatedBy: " ")
        let filteredWords = words.filter { word in
            !extendedStopWords.contains(word.lowercased())
        }
        return filteredWords.joined(separator: " ")
    }
    
    private func tokenizeText(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange])
            if sentence.split(separator: " ").count > 3 && !self.isNavigationElement(sentence) {
                sentences.append(sentence)
            }
            return true
        }
        return sentences
    }
    
    // MARK: - Sentence Ranking
    
    private func rankSentences(_ sentences: [String]) -> [String] {
        guard !sentences.isEmpty else { return [] }
        
        let documentTermFrequencies = calculateTermFrequencies(for: sentences)
        
        var uniqueSentences = Set<String>()
        var scoredSentences: [(String, Double)] = []
        
        var sentenceVectors: [String: [String: Double]] = [:]
        
        for (index, sentence) in sentences.enumerated() {
            let normalizedSentence = normalizeSentence(sentence)
            
            guard !uniqueSentences.contains(normalizedSentence) else { continue }
            uniqueSentences.insert(normalizedSentence)
            
            let vector = calculateTFIDFVector(for: sentence, documentFrequencies: documentTermFrequencies, totalDocs: sentences.count)
            sentenceVectors[sentence] = vector
    
            let tfIdfScore = calculateAverageTFIDF(vector: vector)
            let entityScore = Double(computeEntityScore(for: sentence))
            let lengthScore = computeLengthScore(for: sentence)
            let positionScore = computePositionScore(for: index, in: sentences.count)
            
            let totalScore = (tfIdfScore * 0.3) +
                             (entityScore * 0.3) +
                             (lengthScore * 0.2) +
                             (positionScore * 0.2)
            
            scoredSentences.append((sentence, totalScore))
        }
        
        var orderedSentences = scoredSentences.sorted { $0.1 > $1.1 }
        
        var result: [String] = []
        let maxSentences = min(3, orderedSentences.count)
        
        if !orderedSentences.isEmpty {
            result.append(orderedSentences.removeFirst().0)
        }
        
        while result.count < maxSentences && !orderedSentences.isEmpty {
            let candidate = orderedSentences.removeFirst().0
            
            let tooSimilar = result.contains { selected in
                calculateSimilarity(
                    sentenceVectors[selected] ?? [:],
                    sentenceVectors[candidate] ?? [:]
                ) > 0.5
            }
            
            if !tooSimilar {
                result.append(candidate)
            }
        }
        
        return sortByOriginalPosition(result, in: sentences)
    }
    
    private func calculateTermFrequencies(for sentences: [String]) -> [String: Int] {
        var frequencies: [String: Int] = [:]
        
        for sentence in sentences {
            let words = extractWords(from: sentence)
            for word in words {
                frequencies[word, default: 0] += 1
            }
        }
        
        return frequencies
    }
    
    private func calculateTFIDFVector(for sentence: String, documentFrequencies: [String: Int], totalDocs: Int) -> [String: Double] {
        var vector: [String: Double] = [:]
        let words = extractWords(from: sentence)
        
        var termFrequencies: [String: Int] = [:]
        for word in words {
            termFrequencies[word, default: 0] += 1
        }
        
        for (term, frequency) in termFrequencies {
            let tf = Double(frequency) / Double(words.count)
            let docFreq = Double(documentFrequencies[term] ?? 0)
            let idf = log(Double(totalDocs) / (docFreq + 1)) + 1.0
            vector[term] = tf * idf
        }
        
        return vector
    }
    
    private func calculateAverageTFIDF(vector: [String: Double]) -> Double {
        guard !vector.isEmpty else { return 0.0 }
        let sum = vector.values.reduce(0.0, +)
        return sum / Double(vector.count)
    }
    
    private func calculateSimilarity(_ vector1: [String: Double], _ vector2: [String: Double]) -> Double {
        var dotProduct: Double = 0.0
 
        for (term, value1) in vector1 {
            if let value2 = vector2[term] {
                dotProduct += value1 * value2
            }
        }

        let magnitude1 = sqrt(vector1.values.reduce(0.0) { $0 + ($1 * $1) })
        let magnitude2 = sqrt(vector2.values.reduce(0.0) { $0 + ($1 * $1) })
        
        guard magnitude1 > 0 && magnitude2 > 0 else { return 0.0 }
        return dotProduct / (magnitude1 * magnitude2)
    }
    
    private func sortByOriginalPosition(_ sentences: [String], in originalSentences: [String]) -> [String] {
        return sentences.sorted { a, b in
            let indexA = originalSentences.firstIndex(of: a) ?? Int.max
            let indexB = originalSentences.firstIndex(of: b) ?? Int.max
            return indexA < indexB
        }
    }
    
    private func extractWords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text
        
        var words: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .tokenType,
                            options: [.omitPunctuation, .omitWhitespace]) { _, tokenRange in
            let word = String(text[tokenRange]).lowercased()
            if word.count > 2 && !self.extendedStopWords.contains(word) {
                words.append(word)
            }
            return true
        }
        
        return words
    }
    
    // MARK: - Helper Methods
    
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
        let wordCount = sentence.split(separator: " ").count
        
        if wordCount >= 15 && wordCount <= 25 {
            return 1.0
        } else if wordCount < 15 {
            return Double(wordCount) / 15.0
        } else {
            return 1.0 - min(1.0, (Double(wordCount) - 25.0) / 25.0)
        }
    }
    
    private func computePositionScore(for index: Int, in total: Int) -> Double {
        guard total > 1 else { return 1.0 }
        
        if index == 0 {
            return 1.0
        } else if index == total - 1 {
            return 0.8
        } else if index < total / 3 {
            return 0.6 - (Double(index) / Double(total) * 0.3)
        } else {
            return 0.3 - (Double(index) / Double(total) * 0.3)
        }
    }
}

extension SummarizerService {
    struct EnhancedPatterns {
        static let dateTime = [
            "\\d+ (?:hour|minute|second|day|week|month|year)s? ago",
            "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \\d{1,2},? \\d{4}",
            "\\d{1,2}:\\d{2}(?::\\d{2})? ?(?:AM|PM|am|pm)",
            "\\[(?:hour\\]:\\[minute\\]\\[AMPM\\]\\[timezone\\]|monthFull\\]\\[day\\],? \\[year\\])",
            "Updated(?: on)?(?: at)? .*",
            "Published(?: on)?(?: at)? .*"
        ]
        
        static let socialSharing = [
            "Share (?:this )?(?:on )?(?:Facebook|Twitter|LinkedIn|Pinterest|Reddit|Email)",
            "(?:Share|Tweet|Pin|Email|Send|Copy) (?:this|link|article|story|post)",
            "Copy (?:Link|URL) copied",
            "Share Facebook Copy Link",
            "Print Email X LinkedIn Bluesky Flipboard Pinterest Reddit"
        ]
        
        static let authorByline = [
            "By [A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z]+){0,4}",
            "(?:Written|Reported) by [A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z]+){0,4}",
            "(?:Author|Writer|Reporter): [A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z]+){0,4}",
            "(?:Associated Press|AP) (?:writers|reporters)"
        ]
        
        static let runTogetherText = [
            // CamelCase detection
            "(?<=[a-z])(?=[A-Z])",
            // Long strings without spaces
            "[A-Za-z]{15,}",
            // Repeated capitalization pattern
            "(?:[A-Z][a-z]+){3,}"
        ]
    }
    
    func fixRunTogetherText(_ text: String) -> String {
        var result = text
  
        if let regex = try? NSRegularExpression(pattern: EnhancedPatterns.runTogetherText[0]) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: " "
            )
        }
        
        if let regex = try? NSRegularExpression(pattern: EnhancedPatterns.runTogetherText[2]) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let range = match.range
                let matchedText = nsString.substring(with: range)
                
                var processed = ""
                var previousCharWasLower = false
                
                for char in matchedText {
                    if char.isUppercase && previousCharWasLower {
                        processed.append(" ")
                    }
                    processed.append(char)
                    previousCharWasLower = char.isLowercase
                }
                
                let mutableString = NSMutableString(string: nsString)
                mutableString.replaceCharacters(in: range, with: processed)
                result = mutableString as String
            }
        }
        
        return result
    }
    
    func enhancedCleanText(_ text: String) -> String {
        let fixedText = fixRunTogetherText(text)
        
        let basicCleanedText = cleanText(fixedText)
        
        let additionalCleaners: [(String, String)] = [
            (EnhancedPatterns.dateTime.joined(separator: "|"), ""),
            (EnhancedPatterns.socialSharing.joined(separator: "|"), ""),
            (EnhancedPatterns.authorByline.joined(separator: "|"), ""),
            ("\\([^)]*(?:AP|AFP|Reuters|Getty)[^)]*\\)", ""),
            ("\\((?:AP|AFP|Reuters) Photo/[^)]+\\)", ""),
            ("WASHINGTON \\(AP\\) [—-]", ""),
            ("[A-Z]{2,}(?: [A-Z]{2,}){1,3} [—-]", ""), // CITY NAME —
            ("\\d{1,2}:\\d{2}(?::\\d{2})?", "") // Remove timestamps
        ]
        
        return additionalCleaners.reduce(basicCleanedText) { partialResult, cleaner in
            partialResult.replacingOccurrences(
                of: cleaner.0,
                with: cleaner.1,
                options: .regularExpression
            )
        }
    }
}

extension SummarizerService {
    func enhancedExtractAndSummarize(url: URL, completion: @escaping (String) -> Void) {
        let extractor = WebContentExtractor()
        
        extractor.extractContent(from: url.absoluteString) { [weak self] html in
            guard let self = self, let html = html else {
                completion("Failed to extract content")
                return
            }
            
            let cleanedHtml = self.enhancedCleanText(html)
            let summary = self.summarize(cleanedHtml)
            completion(summary)
        }
    }
}


class WebContentExtractor: NSObject, WKNavigationDelegate {
    private var webView: WKWebView!
    private var completionHandler: ((String?) -> Void)?
    
    override init() {
        super.init()
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
    }
    
    func extractContent(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        completionHandler = completion
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let extractionScript = """
        (function() {
            // Try content-specific selectors first
            const selectors = [
                'article', '[role="article"]', '.article-content', '.story-body', 
                '.main-content', '.post-content', '.entry-content', '.content-body',
                '.story', '.post', 'main', '#main-content', '.news-content'
            ];
            
            // Find element by selector
            for (const selector of selectors) {
                const element = document.querySelector(selector);
                if (element && element.textContent.length > 500) {
                    return element.outerHTML;
                }
            }
            
            // If no selector worked, find the div with most text content in paragraphs
            let bestElement = null;
            let maxTextLength = 0;
            
            const contentContainers = document.querySelectorAll('div, section');
            for (const container of contentContainers) {
                // Skip obvious non-content areas
                if (/header|footer|sidebar|nav|menu|comment|social|share|related|widget/i.test(container.className) ||
                    /header|footer|sidebar|nav|menu|comment|social|share|related|widget/i.test(container.id)) {
                    continue;
                }
                
                const paragraphs = container.querySelectorAll('p');
                if (paragraphs.length < 3) continue;
                
                let textLength = 0;
                for (const p of paragraphs) {
                    textLength += p.textContent.length;
                }
                
                if (textLength > maxTextLength) {
                    maxTextLength = textLength;
                    bestElement = container;
                }
            }
            
            if (bestElement && maxTextLength > 500) {
                return bestElement.outerHTML;
            }
            
            // Fallback to just the paragraphs
            const allParagraphs = document.querySelectorAll('p');
            if (allParagraphs.length > 0) {
                let html = '';
                for (const p of allParagraphs) {
                    if (p.textContent.trim().length > 30) {
                        html += p.outerHTML;
                    }
                }
                return html;
            }
            
            // Ultimate fallback
            return document.body.outerHTML;
        })();
        """
        
        webView.evaluateJavaScript(extractionScript) { [weak self] result, error in
            if let htmlContent = result as? String {
                self?.completionHandler?(htmlContent)
            } else {
                self?.completionHandler?(nil)
            }
        }
    }
}

