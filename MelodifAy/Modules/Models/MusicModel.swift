//
//  SongModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import Foundation

struct MusicModel: Codable {
    let coverPhotoURL: String
    let lyrics: String
    let musicID: String
    let musicUrl: String
    let songName: String
    let userID: String
}