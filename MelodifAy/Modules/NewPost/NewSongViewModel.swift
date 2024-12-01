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
    
    func saveDraft(url: URL, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserID = user.uid
        
        let storage = Storage.storage(url: "gs://melodifay-15da7.firebasestorage.app")
        let draftRef = storage.reference().child("drafts/\(UUID().uuidString)")
        
        draftRef.putFile(from: url, metadata: nil) { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                draftRef.downloadURL { url, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                    } else if let url = url {
                        let draftUrl = url.absoluteString
                        
                        let audioDraftRef = self.firestore.collection("Drafts").document()
                        let firestoreDraft = ["url": draftUrl, "userID": currentUserID, "draftID": audioDraftRef.documentID] as [String: Any]
                        
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
            }
        }
    }
}
