//
//  AVPlayer+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 10/03/22.
//

import AVFoundation

// MARK: Check audio is playing
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
