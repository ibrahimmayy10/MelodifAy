//
//  MusicDetailsViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 17.03.2025.
//

import Foundation
import Firebase

class MusicDetailsViewModel {
    func saveListeningHistory(musicID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let firestore = Firestore.firestore()
        
        let listeningHistory = ["userID": currentUserID, "musicID": musicID, "listenendAt": Timestamp(date: Date())] as [String: Any]
        
        firestore.collection("ListeningHistory").addDocument(data: listeningHistory)
    }
}
