//
//  AudioPlayerService.swift
//  TomatoTimer
//
//  Created by adam tecle on 5/10/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerServiceProvider {
    var audioPlayer: AudioPlayerServiceType { get }
}

protocol AudioPlayerServiceType {
    func playNotificationSound(_ sound: NotificationSound)
}

struct AudioPlayerService: AudioPlayerServiceType {

    func playNotificationSound(_ sound: NotificationSound) {
        configureAudioSession()
        play(resourceName: sound.description)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                AVAudioSession.Category.playback,
                mode: AVAudioSession.Mode.default,
                options: [.duckOthers]
            )
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }
    }

    private func play(resourceName: String) {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "m4r") else { return }
        configureAudioSession()
        player = try? AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }

        player.prepareToPlay()
        player.play()
    }

}

var player: AVAudioPlayer?

class AudioPlayer {
    var player: AVAudioPlayer?

    func play(resourceName: String) {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "m4r") else { return }
        configureAudioSession()
        player = try? AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }

        player.prepareToPlay()
        player.play()
    }

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                AVAudioSession.Category.playback,
                mode: AVAudioSession.Mode.default,
                options: [.duckOthers]
            )
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }
    }
}
