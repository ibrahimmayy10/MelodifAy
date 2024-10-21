//
//  SignInViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import Foundation

protocol SignInViewModelProtocol {
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void)
    
    var serviceSignIn: SignInServiceProtocol { get }
}

final class SignInViewModel: SignInViewModelProtocol {
    lazy var serviceSignIn: SignInServiceProtocol = SignInService()
    weak var view: SignInViewControllerProtocol?
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        serviceSignIn.signInUser(with: email, password: password) { result in
            switch result {
            case .success:
                completion(true)
                self.view?.navigateHomePage()
            case .failure(_):
                completion(false)
            }
        }
    }
}
