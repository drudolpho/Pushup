//
//  AudioController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioType {
    case speak
    case sound
    case none
}

class AudioController {
    
    var audioPlayer = AVAudioPlayer()
    var speakOn: Bool = false
    
    init() {
        setupAudio()
    }

    //Play Sounds
    
    func playChosenAudio(pushups: Int?) {
        if speakOn{
            speakCount(pushups: pushups ?? 0)
        } else {
            playPockAudio()
        }
    }
    
    // Helper Methods
    
    func playPockAudio() {
        audioPlayer.play()
    }
    
    func speakCount(pushups: Int) {
        let utterance = AVSpeechUtterance(string: String(pushups))
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    //Setup
    
    private func setupAudio() {
        let sound = Bundle.main.path(forResource: "ClippedPock", ofType: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        } catch {
            print("Error setting sound")
        }
    }
    
}
