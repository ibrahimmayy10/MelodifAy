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
    
    var serviceUserDetails: ServiceUserDetailsProtocol { get }
}

class UserDetailsViewModel: UserDetailsViewModelProtocol {
    var serviceUserDetails: ServiceUserDetailsProtocol = ServiceUserDetails()
    weak var view: UserDetailsViewControllerProtocol?
    
    var musics = [MusicModel]()
    
    init(view: UserDetailsViewControllerProtocol) {
        self.view = view
    }
    
    func getDataMusic(userID: String, completion: @escaping (Bool) -> Void) {
        serviceUserDetails.fetchUserPosts(userID: userID) { musics in
            guard !musics.isEmpty else {
                completion(false)
                return
            }
            
            self.musics = musics
            self.view?.reloadDataTableView()
            completion(true)
        }
    }
    
    func followUser(newUserID: String) {
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
                
                newUserReference.updateData(["followers": followerList])
                
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
                        
                        currentUserReference.updateData(["following": followingList])
                    }
                }
            }
        }
    }
}
