//
//  RegisterViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import Foundation
import Firebase
import UIKit

class RegisterViewModel {
    let firestore = Firestore.firestore()
    
    func registerUser(name: String, surname: String, username: String, image: UIImage, email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            if error != nil {
                completion(false)
            } else if let user = authData?.user {
                let userRef = self.firestore.collection("Users").document(user.uid)
              
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = UUID().uuidString
                    let storage = Storage.storage(url: "gs://melodifay-15da7.firebasestorage.app")
                    let imageRef = storage.reference().child("user_images/\(fileName).jpg")
                                        
                    imageRef.putData(imageData, metadata: metadata) { metadata, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                            completion(false)
                        } else {
                            imageRef.downloadURL { url, error in
                                if error == nil {
                                    let imageUrl = url?.absoluteString
                                    
                                    let firestoreUser = ["userID": user.uid, "name": name, "surname": surname, "username": username, "imageUrl": imageUrl ?? ""] as [String: Any]
                                    userRef.setData(firestoreUser) { error in
                                        if error != nil {
                                            completion(false)
                                        } else {
                                            print("Kayıt işlemi başarılı.")
                                            completion(true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                completion(false)
            }
        }
    }
}
