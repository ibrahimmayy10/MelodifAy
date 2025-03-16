//
//  ServiceSearch.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.12.2024.
//

import Foundation
import Firebase

protocol ServiceSearchProtocol {
    func fetchMusics(completion: @escaping ([MusicModel]) -> Void)
    func fetchUsers(completion: @escaping ([UserModel]) -> Void)
}

class ServiceSearch: ServiceSearchProtocol {
    let firestore = Firestore.firestore()
    
    func fetchUsers(completion: @escaping ([UserModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Users").getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion([])
                } else if let documents = snapshot?.documents {
                    var users = [UserModel]()
                    
                    for document in documents {
                        let data = document.data()
                        
                        guard let userID = data["userID"] as? String,
                              let name = data["name"] as? String,
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
    
    func fetchMusics(completion: @escaping ([MusicModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.firestore.collection("Musics").getDocuments { snapshot, error in
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
}
