//
//  SoundPlayerManager.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class SoundPlayerManager {
    static let sharedInstance = SoundPlayerManager()
    private var player: AVAudioPlayer?
    
    func play(mp3Name: String, infiniteLoop: Bool, extensionFormat: String) {
        let url = Bundle.main.url(forResource: mp3Name, withExtension: extensionFormat)!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.numberOfLoops = (infiniteLoop == true) ? -1 : 0
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        self.player?.stop()
    }
    
    func playEffect(name: String, extensionFormat: String) {
        if let soundURL = Bundle.main.url(forResource: name, withExtension: extensionFormat) {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlaySystemSound(mySound);
        }
    }
    
    
}
