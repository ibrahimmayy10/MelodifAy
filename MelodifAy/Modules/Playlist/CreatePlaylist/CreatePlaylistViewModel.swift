//
//  CreatePlaylistViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 9.03.2025.
//

import Foundation
import Firebase

class CreatePlaylistViewModel {
    func createPlaylist(name: String, musicIDs: [String], image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard !name.isEmpty, let user = Auth.auth().currentUser else {
                completion(false, "Çalma listesi adı boş olamaz.")
                return
            }
            
            let currentUserID = user.uid
            
            let playlistRef = Firestore.firestore().collection("Playlists").document()
            
            let storage = Storage.storage(url: "gs://melodifay-15da7.firebasestorage.app")
            let imageRef = storage.reference().child("playlist/\(UUID().uuidString)")
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if error != nil {
                        completion(false, "Görsel yüklenemedi: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            completion(false, "Görsel URL alınamadı: \(error.localizedDescription)")
                            return
                        }
                        
                        let imageURL = url?.absoluteString ?? ""
                        
                        let playlistData: [String: Any] = [
                            "playlistID": playlistRef.documentID,
                            "name": name,
                            "musicIDs": musicIDs,
                            "imageURL": imageURL,
                            "userID": currentUserID
                        ]
                        
                        playlistRef.setData(playlistData) { error in
                            if let error = error {
                                completion(false, "Çalma listesi kaydedilemedi: \(error.localizedDescription)")
                            } else {
                                completion(true, nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
