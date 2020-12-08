//
//  PlaySound.swift
//  SIS App
//
//  Created by Zizhou Hang on 6/12/20.
//

import AVFoundation
import Foundation

var audioPlayer: AVAudioPlayer?

func playSound(_ sound: String) {
    print("🔊 playing sound")
    if let path = Bundle.main.path(forResource: sound, ofType: nil) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("Could not find and play sound file")
        }
    }
}
