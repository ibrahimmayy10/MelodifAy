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
    func fetchTopListenedSongs(completion: @escaping ([MusicModel]) -> Void)
    func fetchTopLikedArtistsUserID(for userID: String, completion: @escaping ([String]) -> Void)
    func fetchTopLikedArtists(completion: @escaping ([UserModel]) -> Void)
}

class ServiceHomePage: ServiceHomePageProtocol {
    let firestore = Firestore.firestore()
    
    func fetchTopLikedArtists(completion: @escaping ([UserModel]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        fetchTopLikedArtistsUserID(for: currentUserID) { userIDs in
            self.firestore.collection("Users").whereField("userID", in: userIDs).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion([])
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
                    
                    completion(users)
                }
            }
        }
    }
    
    func fetchTopLikedArtistsUserID(for userID: String, completion: @escaping ([String]) -> Void) {
        firestore.collection("Musics").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print(error?.localizedDescription ?? "")
                completion([])
                return
            }
            
            var likedArtistsCount: [String: Int] = [:]
            
            for document in documents {
                let data = document.data()
                
                guard let likes = data["likes"] as? [String],
                      let artistUserID = data["userID"] as? String else { continue }
                
                if likes.contains(userID) {
                    likedArtistsCount[artistUserID, default: 0] += 1
                }
            }
            
            let top5Artists = likedArtistsCount.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
            
            DispatchQueue.main.async {
                completion(top5Artists)
            }
        }
    }
    
    func fetchTopListenedSongs(completion: @escaping ([MusicModel]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let firestore = Firestore.firestore()
        
        firestore.collection("ListeningHistory")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var songPlayCounts: [String: Int] = [:]
                
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let musicId = data["musicID"] as? String {
                        songPlayCounts[musicId, default: 0] += 1
                    }
                }
                
                let sortedSongs = songPlayCounts.sorted { $0.value > $1.value }.prefix(5)
                
                var topSongs: [MusicModel] = []
                let group = DispatchGroup()
                
                for (musicId, _) in sortedSongs {
                    group.enter()
                    firestore.collection("Musics").document(musicId).getDocument { (document, error) in
                        if let error = error {
                            print("Şarkı bilgisi alınırken hata oluştu: \(error.localizedDescription)")
                            group.leave()
                            return
                        }
                        
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            guard let coverPhotoURL = data?["coverPhotoURL"] as? String,
                                  let lyrics = data?["lyrics"] as? String,
                                  let musicID = data?["musicID"] as? String,
                                  let musicUrl = data?["musicUrl"] as? String,
                                  let songName = data?["songName"] as? String,
                                  let name = data?["name"] as? String,
                                  let musicFileType = data?["musicFileType"] as? String,
                                  let userID = data?["userID"] as? String else { return }
                            
                            let likes = data?["likes"] as? [String] ?? []
                            
                            let music = MusicModel(coverPhotoURL: coverPhotoURL, lyrics: lyrics, musicID: musicID, musicUrl: musicUrl, songName: songName, name: name, userID: userID, musicFileType: musicFileType, likes: likes)
                            topSongs.append(music)
                        }
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(topSongs)
                }
            }
    }
    
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
