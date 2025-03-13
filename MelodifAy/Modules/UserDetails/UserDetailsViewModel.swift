//
//  UserDetailsViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 16.01.2025.
//

import Foundation
import Firebase

protocol UserDetailsViewModelProtocol {
    func getDataMusic(userID: String, completion: @escaping (Bool) -> Void)
    func getDataUser(userID: String)
    func getDataPlaylist(userID: String)
    
    var serviceUserDetails: ServiceUserDetailsProtocol { get }
}

class UserDetailsViewModel: UserDetailsViewModelProtocol {
    var serviceUserDetails: ServiceUserDetailsProtocol = ServiceUserDetails()
    weak var view: UserDetailsViewControllerProtocol?
    
    var musics = [MusicModel]()
    var playlists = [PlaylistModel]()
    var user: UserModel?
    
    init(view: UserDetailsViewControllerProtocol) {
        self.view = view
    }
    
    func getDataPlaylist(userID: String) {
        serviceUserDetails.fetchPlaylist(userID: userID) { playlists in
            DispatchQueue.main.async {
                self.playlists = playlists
                self.view?.reloadDataTableView()
            }
        }
    }
    
    func getDataMusic(userID: String, completion: @escaping (Bool) -> Void) {
        serviceUserDetails.fetchUserPosts(userID: userID) { musics in
            guard !musics.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.musics = musics
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
    }
    
    func getDataUser(userID: String) {
        serviceUserDetails.fetchUserInfo(userID: userID) { user in
            guard let user = user else { return }
            
            DispatchQueue.main.async {
                self.view?.setUserInfo(user: user)
                self.user = user
            }
        }
    }
    
    func followUser(newUserID: String) {
        DispatchQueue.global(qos: .background).async {
            guard let user = Auth.auth().currentUser else { return }
            let currentUserID = user.uid
            
            let firestore = Firestore.firestore()
            
            let currentUserReference = firestore.collection("Users").document(currentUserID)
            let newUserReference = firestore.collection("Users").document(newUserID)
            
            newUserReference.getDocument { document, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let document = document, document.exists {
                    var followerList = document.data()?["followers"] as? [String] ?? []
                    let isFollowing = followerList.contains(currentUserID)
                    
                    if isFollowing {
                        followerList.removeAll { $0 == currentUserID }
                    } else {
                        followerList.append(currentUserID)
                    }
                    
                    DispatchQueue.main.async {
                        newUserReference.updateData(["followers": followerList])
                    }
                    
                    currentUserReference.getDocument { snapshot, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else if let snapshot = snapshot {
                            var followingList = snapshot.data()?["following"] as? [String] ?? []
                            
                            if isFollowing {
                                followingList.removeAll { $0 == newUserID }
                            } else {
                                followingList.append(newUserID)
                            }
                            
                            DispatchQueue.main.async {
                                currentUserReference.updateData(["following": followingList])
                            }
                        }
                    }
                }
            }
        }
    }
}
