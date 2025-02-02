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
    private let model: distilbert_classification
   
   
    private init() {
        guard let loadedModel = try? distilbert_classification(configuration: MLModelConfiguration()) else {
            fatalError("Failed to load ML model")
        }
        self.model = loadedModel
    }
   
    func tokenizeText(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            tokens.append(String(text[tokenRange]))
            return true
        }
        print("\(tokens)")
        return tokens
    }


    func convertToMLMultiArray(from input: [Int]) -> MLMultiArray? {
        let array = try? MLMultiArray(shape: [NSNumber(value: input.count)], dataType: .int32)
        for (index, value) in input.enumerated() {
            array?[index] = NSNumber(value: value)
        }
        print(model.model.modelDescription)
        return array
    }
}

