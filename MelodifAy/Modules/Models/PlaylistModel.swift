//
//  PlaylistModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 10.03.2025.
//

import Foundation

struct PlaylistModel: Codable {
    let playlistID: String
    let name: String
    var musicIDs: [String]
    let imageUrl: String
    let userID: String
}
