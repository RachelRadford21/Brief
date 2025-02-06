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
  private var vocab: [String: Int] = [:]
  
  private init() {
    guard let loadedModel = try? distilbert_classification(configuration: MLModelConfiguration()) else {
      fatalError("Failed to load ML model")
    }
    self.model = loadedModel
    loadVocabulary()
  }
  
  private func loadVocabulary() {
    guard let url = Bundle.main.url(forResource: "distilbert_vocab", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let vocabDict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
      fatalError("Failed to load vocabulary file")
    }
    self.vocab = vocabDict
  }
  
  func tokenizeText(_ text: String) -> [Int] {
    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = text.lowercased()
    
    var tokenIds: [Int] = []
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
      let token = String(text[tokenRange])
      if let tokenId = vocab[token] {
        tokenIds.append(tokenId)
      } else {
        tokenIds.append(vocab["[UNK]"] ?? 0)
      }
      return true
    }
    print("Tokenized IDs:", tokenIds)
    return tokenIds
  }
  
  func createAttentionMask(from tokens: [Int]) -> MLMultiArray? {
    guard let array = try? MLMultiArray(shape: [NSNumber(value: tokens.count)], dataType: .int32) else {
      return nil
    }
    for i in 0..<tokens.count {
      array[i] = NSNumber(value: 1)
    }
    return array
  }
  
  func convertToMLMultiArray(from input: [Int]) -> MLMultiArray? {
    guard let array = try? MLMultiArray(shape: [NSNumber(value: input.count)], dataType: .int32) else {
      return nil
    }
    for (index, value) in input.enumerated() {
      array[index] = NSNumber(value: value)
    }
    return array
  }
  
  func summarize(text: String) -> String {
    let tokenizedInput = tokenizeText(text)
    
    guard let inputArray = convertToMLMultiArray(from: tokenizedInput),
          let attentionMaskArray = createAttentionMask(from: tokenizedInput) else {
      return "Error: Failed to process input"
    }
    
    do {
      let prediction = try model.prediction(input_ids: inputArray, attention_mask: attentionMaskArray)
      guard let outputArray = prediction.featureValue(for: "output")?.multiArrayValue else {
        return "Error: Model output is not MLMultiArray"
      }
      
      var tokenIDs: [Int] = []
      for i in 0..<outputArray.count {
        tokenIDs.append(outputArray[i].intValue)
      }
      
      let summary = decodeOutput(tokenIDs)
      return summary
      
    } catch {
      return "Error: \(error.localizedDescription)"
    }
  }
  
  func decodeOutput(_ outputTokens: [Int]) -> String {
    let tokenMapping = vocab.reduce(into: [Int: String]()) { $0[$1.value] = $1.key }
    return outputTokens.compactMap { tokenMapping[$0] }.joined(separator: " ")
  }
}
