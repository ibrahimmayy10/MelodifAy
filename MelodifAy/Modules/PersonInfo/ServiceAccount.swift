//
//  ServiceAccount.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation
import Firebase

protocol ServiceAccountProtocol {
    func fetchUserInfo(completion: @escaping (UserModel) -> Void)
}

class ServiceAccount: ServiceAccountProtocol {
    let firestore = Firestore.firestore()
    
    func fetchUserInfo(completion: @escaping (UserModel) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, let data = document.data() {
                guard let name = data["name"] as? String,
                      let surname = data["surname"] as? String,
                      let username = data["username"] as? String,
                      let imageUrl = data["imageUrl"] as? String else { return }
                
                let userModel = UserModel(name: name, surname: surname, username: username, imageUrl: imageUrl)
                completion(userModel)
            }
        }
    }
}
