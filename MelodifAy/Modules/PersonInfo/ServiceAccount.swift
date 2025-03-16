//
//  ServiceAccount.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation
import Firebase

protocol ServiceAccountProtocol {
    func fetchUserInfo(completion: @escaping (UserModel) -> Void)
    func fetchMusicInfo(completion: @escaping ([MusicModel]) -> Void)
    func fetchPlaylist(completion: @escaping ([PlaylistModel]) -> Void)
    func fetchLikeMusic(completion: @escaping ([MusicModel]) -> Void)
}

class ServiceAccount: ServiceAccountProtocol {
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func fetchLikeMusic(completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let currentUserID = self.currentUserID else { return }
            
            self.firestore.collection("Musics").whereField("likes", arrayContains: currentUserID).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
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
    
    func fetchUserInfo(completion: @escaping (UserModel) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let currentUserID = self.currentUserID else { return }
            
            self.firestore.collection("Users").document(currentUserID).getDocument { document, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let document = document, let data = document.data() {
                    guard let name = data["name"] as? String,
                          let userID = data["userID"] as? String,
                          let surname = data["surname"] as? String,
                          let username = data["username"] as? String,
                          let imageUrl = data["imageUrl"] as? String else { return }
                    
                    let followers = data["followers"] as? [String] ?? []
                    let following = data["following"] as? [String] ?? []
                    
                    let userModel = UserModel(userID: userID, name: name, surname: surname, username: username, imageUrl: imageUrl, followers: followers, following: following)
                    
                    DispatchQueue.main.async {
                        completion(userModel)
                    }
                }
            }
        }
    }
    
    func fetchMusicInfo(completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let currentUserID = self.currentUserID else { return }
            
            self.firestore.collection("Musics").whereField("userID", isEqualTo: currentUserID).getDocuments { snapshot, error in
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
    
    func fetchPlaylist(completion: @escaping ([PlaylistModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let currentUserID = self.currentUserID else { return }
            
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
}
