//
//  ServiceSeeAll.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 14.03.2025.
//

import Firebase

protocol ServicePlaylistMusicsProtocol {
    func fetchPlaylistMusics(musicIDs: [String], completion: @escaping ([MusicModel]) -> Void)
}

class ServicePlaylistMusics: ServicePlaylistMusicsProtocol {
    func fetchPlaylistMusics(musicIDs: [String], completion: @escaping ([MusicModel]) -> Void) {
        let firestore = Firestore.firestore()
        
        firestore.collection("Musics").whereField("musicID", in: musicIDs).getDocuments { snapshot, error in
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
