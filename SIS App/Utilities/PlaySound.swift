//
//  PlaySound.swift
//  SIS App
//
//  Created by Zizhou Hang on 6/12/20.
//

import AVFoundation
import Foundation
import UIKit

private var audioPlayer: AVAudioPlayer?
private var generator: UINotificationFeedbackGenerator?

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

func prepareHaptics() {
    if generator == nil { generator = UINotificationFeedbackGenerator() }
    DispatchQueue.global(qos: .userInitiated).async {
        generator?.prepare()
    }
}

/// Yea this also does haptics too but shrug i couldn't think of any better name
func playCheckInOutSound() {
    // sound
    playSound(filename: Constants.checkInOutSoundFilename, fileType: Constants.checkInOutSoundFileExtnesion)

    // haptics
    if generator == nil { generator = UINotificationFeedbackGenerator() }
    generator?.notificationOccurred(.success)
    generator = nil
}
