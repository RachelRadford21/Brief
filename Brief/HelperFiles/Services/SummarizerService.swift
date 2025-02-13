//
//  SummarizerService.swift
//  Brief
//
//  Created by Rachel Radford on 2/1/25.
//

import Foundation
import NaturalLanguage
import CoreML

@Observable
class SummarizerService {
    static let shared = SummarizerService()
    private let cache = NSCache<NSString, NSString>()
        
    func summarize(_ text: String) -> String {
        if let cachedSummary = cache.object(forKey: text as NSString) as String? {
            return cachedSummary
        }

        let processedText = preprocessText(text)
        let sentences = tokenizeText(processedText)
        let keySentences = rankSentences(sentences)
        
        let summary = keySentences.joined(separator: " ")
        
        // Cache the result
        cache.setObject(summary as NSString, forKey: text as NSString)
        
        return summary
    }
        
        private func preprocessText(_ text: String) -> String {
            let stopWords: Set<String> = ["the", "and", "is", "of", "to", "in", "that", "it", "on", "for", "with"]
            let words = text.components(separatedBy: " ").filter { !stopWords.contains($0.lowercased()) }
            return words.joined(separator: " ")
        }
        
        private func tokenizeText(_ text: String) -> [String] {
            let tokenizer = NLTokenizer(unit: .sentence)
            tokenizer.string = text
            var sentences: [String] = []
            
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
                sentences.append(String(text[range]))
                return true
            }
            
            return sentences
        }
        
        private func rankSentences(_ sentences: [String]) -> [String] {
            var scoredSentences: [(String, Int)] = []
            
            for sentence in sentences {
                let score = entityScore(for: sentence)
                scoredSentences.append((sentence, score))
            }
            
            let topSentences = scoredSentences.sorted { $0.1 > $1.1 }
                                              .prefix(3) // Get the top 3 sentences
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
        
        func getCachedSummary(for text: String) -> String? {
            return cache.object(forKey: text as NSString) as String?
        }
  
 
}
