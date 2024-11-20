//
//  ShareNewPostViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 20.11.2024.
//

import Foundation
import Firebase

class ShareNewPostViewModel {
    func shareNewPost(url: String, songName: String, lyrics: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        let sharePostRef = firestore.collection("Musics").document()
        let firestoreMusic = ["userID": currentUserID, "musicUrl": url, "musicID": sharePostRef.documentID, "songName": songName, "lyrics": lyrics] as [String: Any]
        
        sharePostRef.setData(firestoreMusic) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("şarkınız başarılı bir şekilde paylaşıldı")
                completion(true)
            }
        }
    }
}
