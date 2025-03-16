//
//  ServiceHomePage.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.02.2025.
//

import Foundation
import Firebase

protocol ServiceHomePageProtocol {
    func fetchMusicInfo(completion: @escaping ([MusicModel]) -> Void)
    func fetchSingersLike(completion: @escaping ([UserModel]) -> Void)
    func fetchPlaylists(completion: @escaping ([PlaylistModel]) -> Void)
    func fetchLatestMusics(completion: @escaping (MusicModel?) -> Void)
}

class ServiceHomePage: ServiceHomePageProtocol {
    let firestore = Firestore.firestore()
    
    func fetchLatestMusics(completion: @escaping (MusicModel?) -> Void) {
        firestore.collection("Musics")
            .order(by: "time", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    completion(nil)
                } else if let document = snapshot?.documents.first {
                    let data = document.data()
                    
                    guard let coverPhotoURL = data["coverPhotoURL"] as? String,
                          let lyrics = data["lyrics"] as? String,
                          let musicID = data["musicID"] as? String,
                          let musicUrl = data["musicUrl"] as? String,
                          let songName = data["songName"] as? String,
                          let name = data["name"] as? String,
                          let musicFileType = data["musicFileType"] as? String,
                          let userID = data["userID"] as? String else { return }
                    
                    let likes = data["likes"] as? [String] ?? []
                    
                    let latestMusic = MusicModel(coverPhotoURL: coverPhotoURL, lyrics: lyrics, musicID: musicID, musicUrl: musicUrl, songName: songName, name: name, userID: userID, musicFileType: musicFileType, likes: likes)
                    
                    DispatchQueue.main.async {
                        completion(latestMusic)
                    }
                } else {
                    completion(nil)
                }
            }
    }
    
    func fetchPlaylists(completion: @escaping ([PlaylistModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            
            self.firestore.collection("Playlists").whereField("userID", isEqualTo: currentUserID).getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    var playlists = [PlaylistModel]()
                    
                    for document in documents {
                        let data = document.data()
                        
                        guard let playlistID = data["playlistID"] as? String,
                              let name = data["name"] as? String,
                              let musicIDs = data["musicIDs"] as? [String],
                              let imageUrl = data["imageURL"] as? String,
                              let userID = data["userID"] as? String else { return }
                        
                        let playlistModel = PlaylistModel(playlistID: playlistID, name: name, musicIDs: musicIDs, imageUrl: imageUrl, userID: userID)
                        playlists.append(playlistModel)
                    }
                    
                    DispatchQueue.main.async {
                        completion(playlists)
                    }
                }
            }
        }
    }
    
    func fetchMusicInfo(completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Musics").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
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
                        
                        let likes = data["likes"] as? [String] ?? []
                        
                        let musicModel = MusicModel(coverPhotoURL: coverPhotoURL, lyrics: lyrics, musicID: musicID, musicUrl: musicUrl, songName: songName, name: name, userID: userID, musicFileType: musicFileType, likes: likes)
                        musics.append(musicModel)
                    }
                    
                    DispatchQueue.main.async {
                        completion(musics)
                    }
                }
            }
        }
    }
    
    func fetchSingersLike(completion: @escaping ([UserModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Users").getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    var users = [UserModel]()
                    
                    for document in documents {
                        let data = document.data()
                        
                        guard let name = data["name"] as? String,
                              let userID = data["userID"] as? String,
                              let surname = data["surname"] as? String,
                              let username = data["username"] as? String,
                              let imageUrl = data["imageUrl"] as? String else { return }
                        
                        let followers = data["followers"] as? [String] ?? []
                        let following = data["following"] as? [String] ?? []
                        
                        let userModel = UserModel(userID: userID, name: name, surname: surname, username: username, imageUrl: imageUrl, followers: followers, following: following)
                        users.append(userModel)
                    }
                    
                    DispatchQueue.main.async {
                        completion(users)
                    }
                }
            }
        }
    }
}
