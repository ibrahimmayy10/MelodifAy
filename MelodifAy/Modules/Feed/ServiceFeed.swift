//
//  ServiceFeed.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import Foundation
import Firebase

protocol ServiceFeedProtocol {
    func fetchFollowingMusic(completion: @escaping ([MusicModel], [UserModel]) -> Void)
    func fetchFollowingUserIDs(completion: @escaping ([String]?, Error?) -> Void)
    func fetchMusicPosts(for userIDs: [String], completion: @escaping ([MusicModel], Error?) -> Void)
    func fetchFollowedUsers(for userIDs: [String], completion: @escaping ([UserModel], Error?) -> Void)
}

class ServiceFeed: ServiceFeedProtocol {
    let firestore = Firestore.firestore()
    
    func fetchFollowingMusic(completion: @escaping ([MusicModel], [UserModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.fetchFollowingUserIDs { followingUserIDs, error in
                guard let followingUserIDs = followingUserIDs, error == nil else {
                    DispatchQueue.main.async { completion([], []) }
                    return
                }
                
                self.fetchMusicPosts(for: followingUserIDs) { musicPosts, error in
                    self.fetchFollowedUsers(for: followingUserIDs) { users, error in
                        DispatchQueue.main.async { completion(musicPosts, users) }
                    }
                }
            }
        }
    }
    
    func fetchFollowingUserIDs(completion: @escaping ([String]?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let userRef = firestore.collection("Users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let following = document?.data()?["following"] as? [String] ?? []
            completion(following, nil)
        }
    }
    
    func fetchMusicPosts(for userIDs: [String], completion: @escaping ([MusicModel], Error?) -> Void) {
        firestore.collection("Musics")
            .whereField("userID", in: userIDs)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let musicPosts: [MusicModel] = documents.compactMap { doc in
                    try? doc.data(as: MusicModel.self)
                }
                
                completion(musicPosts, nil)
            }
    }
    
    func fetchFollowedUsers(for userIDs: [String], completion: @escaping ([UserModel], Error?) -> Void) {
        firestore.collection("Users")
            .whereField("userID", in: userIDs)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let users: [UserModel] = documents.compactMap { doc in
                    try? doc.data(as: UserModel.self)
                }
                
                completion(users, nil)
            }
    }
}
