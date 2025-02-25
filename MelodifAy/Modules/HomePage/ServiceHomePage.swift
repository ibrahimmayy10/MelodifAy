//
//  ServiceHomePage.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.02.2025.
//

import Foundation
import Firebase

protocol ServiceHomePageProtocol {
    func fetchFollowingMusic(completion: @escaping ([MusicModel], Error?) -> Void)
    func fetchFollowingUserIDs(completion: @escaping ([String]?, Error?) -> Void)
    func fetchMusicPosts(for userIDs: [String], completion: @escaping ([MusicModel], Error?) -> Void)
}

class ServiceHomePage: ServiceHomePageProtocol {
    let firestore = Firestore.firestore()
    
    func fetchFollowingMusic(completion: @escaping ([MusicModel], Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.fetchFollowingUserIDs { followingUserIDs, error in
                guard let followingUserIDs = followingUserIDs, error == nil else {
                    DispatchQueue.main.async { completion([], error) }
                    return
                }
                
                self.fetchMusicPosts(for: followingUserIDs) { musicPosts, error in
                    DispatchQueue.main.async { completion(musicPosts, error) }
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
}
