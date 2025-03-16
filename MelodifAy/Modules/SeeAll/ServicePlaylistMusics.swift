//
//  ServiceSeeAll.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 14.03.2025.
//

import Firebase

protocol ServicePlaylistMusicsProtocol {
    func fetchPlaylistMusics(musicIDs: [String], completion: @escaping ([MusicModel]) -> Void)
    func fetchFollowerUsers(userID: String, completion: @escaping ([UserModel]) -> Void)
    func fetchFollowingUsers(userID: String, completion: @escaping ([UserModel]) -> Void)
}

class ServicePlaylistMusics: ServicePlaylistMusicsProtocol {
    func fetchFollowingUsers(userID: String, completion: @escaping ([UserModel]) -> Void) {
        let firestore = Firestore.firestore()
        
        firestore.collection("Users").document(userID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion([])
            } else if let document = document {
                let followingList = document.data()?["following"] as? [String] ?? []
                
                var users = [UserModel]()
                
                for userID in followingList {
                    firestore.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
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
    }
    
    func fetchFollowerUsers(userID: String, completion: @escaping ([UserModel]) -> Void) {
        let firestore = Firestore.firestore()
        
        firestore.collection("Users").document(userID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion([])
            } else if let document = document {
                let followingList = document.data()?["followers"] as? [String] ?? []
                
                var users = [UserModel]()
                
                for userID in followingList {
                    firestore.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
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
    }
    
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
                    
                    let likes = data["likes"] as? [String] ?? []
                    
                    let musicModel = MusicModel(coverPhotoURL: coverPhotoURL, lyrics: lyrics, musicID: musicID, musicUrl: musicUrl, songName: songName, name: name, userID: userID, musicFileType: musicFileType, likes: likes)
                    musics.append(musicModel)
                }
                
                completion(musics)
            }
        }
    }
}
