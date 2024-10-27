//
//  NewSongViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 9.10.2024.
//

import Foundation
import Firebase

class NewSongViewModel {
    let firestore = Firestore.firestore()
    
    func saveDraft(url: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserID = user.uid
        
        let audioDraftRef = firestore.collection("Drafts").document()
        let firestoreDraft = ["url": url, "userID": currentUserID, "draftID": audioDraftRef.documentID] as [String: Any]
        
        audioDraftRef.setData(firestoreDraft) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("Taslak başarılı bir şekilde kaydedildi.")
                completion(true)
            }
        }
    }
}
