//
//  AccountViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation

protocol AccountViewModelProtocol {
    func getDataUserInfo()
    var serviceAccount: ServiceAccountProtocol { get }
}

class AccountViewModel: AccountViewModelProtocol {
    var serviceAccount: ServiceAccountProtocol = ServiceAccount()
    weak var view: AccountViewControllerProtocol?
    
    init(view: AccountViewControllerProtocol) {
        self.view = view
    }
    
    func getDataUserInfo() {
        serviceAccount.fetchUserInfo { user in
            self.view?.setUserInfo(user: user)
        }
    }
}
