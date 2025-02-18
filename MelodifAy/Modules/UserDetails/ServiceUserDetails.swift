//
//  ServiceUserDetails.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 16.01.2025.
//

import Foundation
import Firebase

protocol ServiceUserDetailsProtocol {
    func fetchUserPosts(userID: String, completion: @escaping ([MusicModel]) -> Void)
}

class ServiceUserDetails: ServiceUserDetailsProtocol {
    let firestore = Firestore.firestore()
    
    func fetchUserPosts(userID: String, completion: @escaping ([MusicModel]) -> Void) {
        firestore.collection("Musics").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion([])
            } else if let documents = snapshot?.documents {
                var musics = [MusicModel]()
                
                for document in documents {
                    let data = document.data()
                    
                    guard let coverPhotoURL = data["coverPhotoURL"] as? String,
                          let lyrics = data["lyrics"] as? String,
                          let musicID = data["musicID"] as? String,
                          let musicUrl = data["musicUrl"] as? String,
                          let songName = data["songName"] as? String,
                          let name = data["name"] as? String,
                          let musicFileType = data["musicFileType"] as? String,
                          let userID = data["userID"] as? String else { return }
                    
                    let musicModel = MusicModel(coverPhotoURL: coverPhotoURL, lyrics: lyrics, musicID: musicID, musicUrl: musicUrl, songName: songName, name: name, userID: userID, musicFileType: musicFileType)
                    musics.append(musicModel)
                }
                
                completion(musics)
            }
        }
    }
}
