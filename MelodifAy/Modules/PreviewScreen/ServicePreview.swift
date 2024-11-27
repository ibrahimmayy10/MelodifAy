//
//  ServicePreview.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.11.2024.
//

import Foundation
import Firebase

protocol ServicePreviewProtocol {
    func fetchUserName(completion: @escaping (String) -> Void)
}

class ServicePreview: ServicePreviewProtocol {
    let firestore = Firestore.firestore()
    
    func fetchUserName(completion: @escaping (String) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                guard let name = document.get("name") as? String else { return }
                guard let surname = document.get("surname") as? String else { return }
                let newName = name + " " + surname
                completion(newName)
            }
        }
    }
}
