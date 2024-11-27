//
//  AccountViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation

protocol AccountViewModelProtocol {
    func getDataUserInfo()
    func getDataMusicInfo()
    var serviceAccount: ServiceAccountProtocol { get }
}

class AccountViewModel: AccountViewModelProtocol {
    var serviceAccount: ServiceAccountProtocol = ServiceAccount()
    weak var view: AccountViewControllerProtocol?
    
    var musics = [MusicModel]()
    
    init(view: AccountViewControllerProtocol) {
        self.view = view
    }
    
    func getDataUserInfo() {
        serviceAccount.fetchUserInfo { user in
            self.view?.setUserInfo(user: user)
        }
    }
    
    func getDataMusicInfo() {
        serviceAccount.fetchMusicInfo { musics in
            self.musics = musics
            self.view?.reloadDataTableView()
        }
    }
}
