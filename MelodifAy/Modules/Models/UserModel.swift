//
//  UserModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation

struct UserModel: Codable {
    let userID: String
    let name: String
    let surname: String
    let username: String
    let imageUrl: String
    let followers: [String]?
    let following: [String]?
}
