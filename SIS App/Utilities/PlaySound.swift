//
//  PlaySound.swift
//  SIS App
//
//  Created by Zizhou Hang on 6/12/20.
//

import AVFoundation
import Foundation

var audioPlayer: AVAudioPlayer?

func playSound(filename: String, fileType: String) {
    print("🔊 playing sound \(filename)")
    if let path = Bundle.main.path(forResource: filename, ofType: fileType) {
        print("🔊 file exisits")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("🔊 Could not find and play sound file")
        }
    } else {
        print("🔊 sound doesn't exist :(")
    }
}

func playCheckInOutSound() {
    playSound(filename: Constants.checkInOutSoundFilename, fileType: Constants.checkInOutSoundFileExtnesion)
}
