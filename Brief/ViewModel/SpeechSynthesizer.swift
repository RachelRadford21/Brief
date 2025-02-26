//
//  SpeechSynthesizer.swift
//  Brief
//
//  Created by Rachel Radford on 2/18/25.
//

import AVFoundation

@Observable
class SpeechSynthesizer: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()
    static let shared = SpeechSynthesizer()
    var speechSpeed: Float = 0.35
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        // Add to settings so user has ability to change speed and voice and pitch multiplier
       
        utterance.voice = AVSpeechSynthesisVoice(identifier: "en-US")
//        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-AU.Gordon")
      //  utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-IE.Moira")
        utterance.rate = speechSpeed
        utterance.pitchMultiplier = 1.15
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
