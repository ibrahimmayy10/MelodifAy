//
//  RegisterViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import Foundation

protocol RegisterViewModelProtocol {
    func register(name: String, surname: String, username: String, imageUrl: String, email: String, password: String, completion: @escaping (Bool) -> Void)
    
    var serviceRegister: RegisterServiceProtocol { get }
}

final class RegisterViewModel: RegisterViewModelProtocol {
    lazy var serviceRegister: RegisterServiceProtocol = RegisterService()
    weak var view: RegisterViewControllerProtocol?
    
    func register(name: String, surname: String, username: String, imageUrl: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        serviceRegister.registerUser(name: name, surname: surname, username: username, imageUrl: imageUrl, email: email, password: password) { result in
            switch result {
            case .success:
                completion(true)
                self.view?.navigateSignIn()
            case .failure(_):
                completion(false)
            }
        }
    }
}
