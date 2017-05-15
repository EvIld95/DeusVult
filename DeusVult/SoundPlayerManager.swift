//
//  SoundPlayerManager.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayerManager {
    static let sharedInstance = SoundPlayerManager()
    private var player: AVAudioPlayer?
    
    func play(mp3Name: String, infiniteLoop: Bool) {
        let url = Bundle.main.url(forResource: mp3Name, withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.numberOfLoops = (infiniteLoop == true) ? -1 : 1
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        self.player?.stop()
    }
}
