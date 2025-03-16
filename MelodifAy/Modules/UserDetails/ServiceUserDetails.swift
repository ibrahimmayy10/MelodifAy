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
    func fetchUserInfo(userID: String, completion: @escaping (UserModel?) -> Void)
    func fetchPlaylist(userID: String, completion: @escaping ([PlaylistModel]) -> Void)
    func fetchLikeMusic(userID: String, completion: @escaping ([MusicModel]) -> Void)
}

class ServiceUserDetails: ServiceUserDetailsProtocol {
    let firestore = Firestore.firestore()
    
    func fetchLikeMusic(userID: String, completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Musics").whereField("likes", arrayContains: userID).getDocuments { snapshot, error in
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
    
    func fetchUserPosts(userID: String, completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Musics").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
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
    
    func fetchUserInfo(userID: String, completion: @escaping (UserModel?) -> Void) {
        firestore.collection("Users").document(userID).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil)
                return
            }
            
            guard let name = document.get("name") as? String,
                  let userID = document.get("userID") as? String,
                  let surname = document.get("surname") as? String,
                  let username = document.get("username") as? String,
                  let imageUrl = document.get("imageUrl") as? String else { return }
            
            let followers = document.get("followers") as? [String] ?? []
            let following = document.get("following") as? [String] ?? []
            
            let userModel = UserModel(userID: userID, name: name, surname: surname, username: username, imageUrl: imageUrl, followers: followers, following: following)
            completion(userModel)
        }
    }
    
    func fetchPlaylist(userID: String, completion: @escaping ([PlaylistModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Playlists").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion([])
                } else if let documents = snapshot?.documents {
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
