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
    
    func saveAudioSketch(audioUrl: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserID = user.uid
        
        let audioSketchRef = firestore.collection("AudioSketch").document()
        let firestoreSketch = ["audioUrl": audioUrl, "userID": currentUserID, "audioID": audioSketchRef.documentID] as [String: Any]
        
        audioSketchRef.setData(firestoreSketch) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("Ses taslağı başarılı bir şekilde kaydedildi.")
                completion(true)
            }
        }
    }
}
