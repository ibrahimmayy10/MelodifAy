//
//  ServicePlaylist.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 10.03.2025.
//

import Foundation
import Firebase

protocol ServicePlaylistProtocol {
    func fetchUserPlaylist(completion: @escaping ([PlaylistModel]) -> Void)
}

class ServicePlaylist: ServicePlaylistProtocol {
    func fetchUserPlaylist(completion: @escaping ([PlaylistModel]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let user = Auth.auth().currentUser else { return }
            let currentUserID = user.uid
            
            let firestore = Firestore.firestore()
            
            firestore.collection("Playlists").whereField("userID", isEqualTo: currentUserID).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    completion([])
                } else if let documents = snapshot?.documents {
                    var playlists = [PlaylistModel]()
                    
                    for document in documents {
                        let data = document.data()
                        
                        guard let playlistID = data["playlistID"] as? String,
                              let musicIDs = data["musicIDs"] as? [String],
                              let userID = data["userID"] as? String,
                              let name = data["name"] as? String,
                              let imageUrl = data["imageURL"] as? String else { return }
                        
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
