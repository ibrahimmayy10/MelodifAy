//
//  FeedViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import Foundation
import Firebase

protocol FeedViewModelProtocol {
    func getDataMusicOfFollowed(completion: @escaping (Bool) -> Void)
    func getDataIsLikedTheMusic(music: MusicModel, completion: @escaping (Bool) -> Void)
    var serviceFeed: ServiceFeedProtocol { get }
}

class FeedViewModel: FeedViewModelProtocol {    
    var serviceFeed: ServiceFeedProtocol = ServiceFeed()
    var musics = [MusicModel]()
    var users = [UserModel]()
    
    weak var view: FeedViewControllerProtocol?
    
    init(view: FeedViewControllerProtocol) {
        self.view = view
    }
    
    func getDataIsLikedTheMusic(music: MusicModel, completion: @escaping (Bool) -> Void) {
        serviceFeed.isLikedTheMusic(music: music) { isLiked in
            completion(isLiked)
        }
    }
    
    func getDataMusicOfFollowed(completion: @escaping (Bool) -> Void) {
        serviceFeed.fetchFollowingMusic { musics, users in
            DispatchQueue.main.async {
                self.musics = musics
                self.users = users
                self.view?.reloadDataTableView()
                
                completion(true)
            }
        }
    }
    
    func likeTheMusic(musicID: String) {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        firestore.collection("Musics").document(musicID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                var likeList = document?.data()?["likes"] as? [String] ?? []
                
                if !likeList.contains(currentUserID) {
                    likeList.append(currentUserID)
                } else {
                    likeList.removeAll { $0 == currentUserID }
                }
                
                firestore.collection("Musics").document(musicID).updateData(["likes": likeList]) { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("beğeni işlemi başarılı")
                    }
                }
            }
        }
    }
}
