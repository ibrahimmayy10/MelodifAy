//
//  RegisterService.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import Foundation
import Firebase

protocol RegisterServiceProtocol {
    func registerUser(name: String, surname: String, username: String, imageUrl: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class RegisterService: RegisterServiceProtocol {
    let firestore = Firestore.firestore()
    
    func registerUser(name: String, surname: String, username: String, imageUrl: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authData?.user {
                let firestoreUser = ["userID": user.uid, "name": name, "surname": surname, "username": username, "imageUrl": imageUrl]
                self.firestore.collection("Users").document(user.uid).setData(firestoreUser) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        print("Kayıt işlemi başarılı.")
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "RegisterService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oluşturulamadı."])))
            }
        }
    }
}
