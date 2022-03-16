//
//  SearchAudio.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/03/22.
//


import UIKit
import SwiftyJSON

struct SearchAudioRequest: Codable {
    var text = String()
    var page = String()
    var limit = Int()
}

struct SearchDeleteRequest: Codable {
    var audio_search_id = Int()
}

