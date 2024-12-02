//
//  ShareNewPostViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 20.11.2024.
//

import Foundation
import Firebase

class ShareNewPostViewModel {
    func shareNewPost(url: URL, songName: String, lyrics: String, coverPhoto: UIImage, name: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let currentUserID = user.uid
        
        let storage = Storage.storage(url: "gs://melodifay-15da7.firebasestorage.app")
        let postRef = storage.reference().child("musics/\(UUID().uuidString)")
        
        postRef.putFile(from: url, metadata: nil) { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                postRef.downloadURL { url, error in
                    guard let postUrl = url?.absoluteString else { return }
                    
                    let imageRef = storage.reference().child("cover_photo/\(UUID().uuidString)")
                    
                    guard let imageData = coverPhoto.jpegData(compressionQuality: 0.8) else { return }
                    
                    imageRef.putData(imageData, metadata: nil) { metadata, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                            completion(false)
                        } else {
                            imageRef.downloadURL { url, error in
                                guard let imageUrl = url?.absoluteString else { return }
                                
                                let firestore = Firestore.firestore()
                                                                
                                let sharePostRef = firestore.collection("Musics").document()
                                let firestoreMusic = ["userID": currentUserID, "musicUrl": postUrl, "musicID": sharePostRef.documentID, "songName": songName, "lyrics": lyrics, "coverPhotoURL": imageUrl, "name": name] as [String: Any]
                                
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
                    }
                }
            }
        }
    }
    
    func fetchUserName(completion: @escaping (String) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion("")
            return
        }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion("")
            } else if let document = document {
                let name = document.get("name") as? String ?? ""
                let surname = document.get("surname") as? String ?? ""
                let fullName = "\(name) \(surname)"
                completion(fullName)
            }
        }
    }

}
