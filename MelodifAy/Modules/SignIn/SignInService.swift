//
//  SignInService.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import Foundation
import Firebase

protocol SignInServiceProtocol {
    func signInUser(with email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class SignInService: SignInServiceProtocol {
    let firestore = Firestore.firestore()
    
    func signInUser(with email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else if let user = authData?.user {
                self.firestore.collection("Users").whereField("userID", isEqualTo: user.uid).getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        print("Giriş işlemi başarılı")
                        completion(.success(()))
                    } else {
                        print("Customer number not found")
                        completion(.failure(NSError(domain: "SignInService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Customer number not found"])))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "RegisterService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oluşturulamadı."])))
            }
        }
    }
}
